import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';
import 'package:health_tracker_reports/domain/services/report_scan_service.dart';
import 'package:meta/meta.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
typedef Clock = DateTime Function();

@lazySingleton
class ExtractReportFromFile {
  final ReportScanService reportScanService;
  final NormalizeBiomarkerName normalizeBiomarker;
  final IdGenerator _idGenerator;
  final Clock _now;

  ExtractReportFromFile({
    required this.reportScanService,
    required this.normalizeBiomarker,
  })  : _idGenerator = (() => const Uuid().v4()),
        _now = DateTime.now;

  @visibleForTesting
  ExtractReportFromFile.test({
    required this.reportScanService,
    required this.normalizeBiomarker,
    required IdGenerator idGenerator,
    required Clock now,
  })  : _idGenerator = idGenerator,
        _now = now;

  Future<Either<Failure, Report>> call(String filePath) async {
    final request = _buildRequest(filePath);
    final collectedBiomarkers = <StructuredBiomarker>[];
    final rawTexts = <String>[];
    final collectedLines = <RecognizedLine>[];

    try {
      await for (final event in reportScanService.scanReport(request)) {
        if (event is ReportScanEventStructured) {
          collectedBiomarkers.addAll(event.payload.biomarkers);
          if (event.payload.rawText.isNotEmpty) {
            rawTexts.add(event.payload.rawText);
          }
          collectedLines.addAll(event.payload.lines);
        } else if (event is ReportScanEventText) {
          if (event.text.isNotEmpty) {
            rawTexts.add(event.text);
          }
        } else if (event is ReportScanEventError) {
          final message = event.message ?? 'Report scan failed';
          return Left(OcrFailure(message: message));
        } else if (event is ReportScanEventComplete) {
          final extraction = _convertLinesToBiomarkers(collectedLines);
          final allBiomarkers = [
            ...collectedBiomarkers,
            ...extraction.biomarkers,
          ];

          final report = _buildReport(
            filePath: filePath,
            biomarkers: allBiomarkers,
            rawTexts: rawTexts,
            patientName: extraction.patientName,
            metadata: extraction.metadata,
          );
          if (report == null) {
            return const Left(
              ValidationFailure(message: 'No biomarkers detected'),
            );
          }
          return Right(report);
        }
      }
      // Stream ended without completion event
      return const Left(CacheFailure('Scan ended unexpectedly'));
    } catch (error) {
      return Left(OcrFailure(message: error.toString()));
    }
  }

  ReportScanRequest _buildRequest(String filePath) {
    final uri = Uri.file(filePath).toString();
    final extension = p.extension(filePath).toLowerCase();
    if (extension == '.pdf') {
      return ReportScanRequest(
        source: ScanSource.pdf,
        uri: uri,
        imageUris: const [],
      );
    }
    return ReportScanRequest(
      source: ScanSource.images,
      uri: uri,
      imageUris: [uri],
    );
  }

  ({
    List<StructuredBiomarker> biomarkers,
    String? patientName,
    Map<String, String> metadata
  }) _convertLinesToBiomarkers(List<RecognizedLine> lines) {
    final biomarkers = <StructuredBiomarker>[];
    final metadata = <String, String>{};
    final sanitizedLines = lines
        .map((line) => _LineData(text: line.text.trim(), box: line.boundingBox))
        .where((line) => line.text.isNotEmpty)
        .toList()
      ..sort((a, b) => a.centerY.compareTo(b.centerY));

    const rowThreshold = 0.025;
    final rows = <_RowData>[];

    for (final line in sanitizedLines) {
      if (rows.isEmpty) {
        rows.add(_RowData(line));
        continue;
      }

      final lastRow = rows.last;
      if ((line.centerY - lastRow.centerY).abs() <= rowThreshold) {
        lastRow.addLine(line);
      } else {
        rows.add(_RowData(line));
      }
    }

    for (final row in rows) {
      final rowText = row.combinedText;
      if (rowText.isEmpty) continue;

      final metadataEntry = _parseMetadata(row);
      if (metadataEntry != null) {
        metadata[metadataEntry.key] = metadataEntry.value;
        continue;
      }

      final biomarker = _parseBiomarkerRow(rowText);
      if (biomarker != null) {
        biomarkers.add(biomarker);
      }
    }

    return (
      biomarkers: biomarkers,
      patientName: metadata['patientName'],
      metadata: metadata
    );
  }

  StructuredBiomarker? _parseBiomarkerRow(String rowText) {
    final blacklistKeywords = <String>{
      'patient',
      'bill',
      'report',
      'release',
      'specimen',
      'registration',
      'method',
      'processing',
      'session',
      'investigation',
      'units',
      'interval',
      'biological reference',
    };

    final trimmed = rowText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (trimmed.isEmpty) {
      return null;
    }

    String name;
    List<String> valueTokens;
    List<String> unitTokens;

    final colonIndex = trimmed.indexOf(':');
    if (colonIndex != -1) {
      name = trimmed.substring(0, colonIndex).trim();
      final remainder = trimmed.substring(colonIndex + 1).trim();
      final tokens = remainder.split(' ');
      var valueIndex = _findValueTokenIndex(tokens);
      if (valueIndex < 0) {
        valueIndex = 0;
      }
      final extraction = _extractValueAndUnit(tokens, valueIndex);
      valueTokens = extraction.valueTokens;
      unitTokens = extraction.unitTokens;
    } else {
      final tokens = trimmed.split(' ');
      var valueIndex = _findValueTokenIndex(tokens);
      if (valueIndex < 0) {
        valueIndex = tokens.length > 1 ? 1 : 0;
      }
      name = tokens.take(valueIndex).join(' ');
      final extraction = _extractValueAndUnit(tokens, valueIndex);
      valueTokens = extraction.valueTokens;
      unitTokens = extraction.unitTokens;
    }

    name = name.replaceFirst(RegExp(r'^[\s:,-]+'), '').trim();
    if (name.isEmpty) return null;
    final lower = name.toLowerCase();
    if (blacklistKeywords.any(lower.contains)) {
      return null;
    }

    final value = valueTokens.join(' ').trim();
    if (value.isEmpty) return null;

    var unitCandidate = unitTokens.join(' ').trim();
    String? referenceMin;
    String? referenceMax;

    final hyphenRange =
        RegExp(r'([+\-]?\d+(?:[.,]\d+)?)\s*[-–]\s*([+\-]?\d+(?:[.,]\d+)?)');
    final pipeRange =
        RegExp(r'([+\-]?\d+(?:[.,]\d+)?)\s*\|\s*([+\-]?\d+(?:[.,]\d+)?)');

    if (hyphenRange.hasMatch(unitCandidate)) {
      final match = hyphenRange.firstMatch(unitCandidate)!;
      referenceMin = match.group(1);
      referenceMax = match.group(2);
      unitCandidate = (unitCandidate.substring(0, match.start) +
              ' ' +
              unitCandidate.substring(match.end))
          .trim();
    } else if (pipeRange.hasMatch(unitCandidate)) {
      final match = pipeRange.firstMatch(unitCandidate)!;
      referenceMin = match.group(1);
      referenceMax = match.group(2);
      unitCandidate = (unitCandidate.substring(0, match.start) +
              ' ' +
              unitCandidate.substring(match.end))
          .trim();
    } else {
      final lessMatch = RegExp(r'<\s*([0-9.,]+)').firstMatch(unitCandidate);
      if (lessMatch != null) {
        referenceMax = lessMatch.group(1);
        unitCandidate =
            unitCandidate.replaceFirst(lessMatch.group(0)!, '').trim();
      }

      final greaterMatch = RegExp(r'>\s*([0-9.,]+)').firstMatch(unitCandidate);
      if (greaterMatch != null) {
        referenceMin = greaterMatch.group(1);
        unitCandidate =
            unitCandidate.replaceFirst(greaterMatch.group(0)!, '').trim();
      }
    }

    if (unitCandidate.startsWith('(') && unitCandidate.endsWith(')')) {
      unitCandidate =
          unitCandidate.substring(1, unitCandidate.length - 1).trim();
    }

    return StructuredBiomarker(
      name: name,
      value: value,
      unit: unitCandidate.isNotEmpty ? unitCandidate : null,
      referenceMin: referenceMin,
      referenceMax: referenceMax,
    );
  }

  MapEntry<String, String>? _parseMetadata(_RowData row) {
    final text = row.combinedText;
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return null;
    }

    final lower = normalized.toLowerCase();
    final value = _extractMetadataValue(normalized);

    bool containsAll(List<String> tokens) => tokens.every(lower.contains);
    bool containsAny(List<String> tokens) => tokens.any(lower.contains);

    if (containsAll(['patient', 'name'])) {
      return MapEntry('patientName', value ?? normalized);
    }
    if (containsAll(['report', 'date'])) {
      return MapEntry('reportDate', value ?? normalized);
    }
    if (containsAll(['collected', 'date'])) {
      return MapEntry('collectedDate', value ?? normalized);
    }
    if (containsAll(['bill', 'date'])) {
      return MapEntry('billDate', value ?? normalized);
    }
    if (containsAll(['lab', 'ref'])) {
      return MapEntry('labReference', value ?? normalized);
    }
    if (containsAll(['lab', 'ref', 'no']) ||
        containsAll(['lab', 'ref', 'uhid'])) {
      return MapEntry('labReference', value ?? normalized);
    }
    if (containsAll(['uhid'])) {
      return MapEntry('labReference', value ?? normalized);
    }
    if (containsAll(['lab', 'name'])) {
      return MapEntry('labName', value ?? normalized);
    }
    if (containsAll(['age', 'gender'])) {
      return MapEntry('ageGender', value ?? normalized);
    }
    if (containsAll(['age'])) {
      return MapEntry('age', value ?? normalized);
    }
    if (containsAll(['gender'])) {
      return MapEntry('gender', value ?? normalized);
    }

    if (containsAny(
        ['clinic', 'hospital', 'diagnostic', 'laboratory', 'foundation'])) {
      if (row.centerY < 0.35) {
        return MapEntry('labName', value ?? normalized);
      }
    }

    if (row.centerY < 0.2 && value == null) {
      final words = normalized.split(' ');
      final uppercaseWords =
          words.where((word) => word.length > 1 && word == word.toUpperCase());
      if (uppercaseWords.length >= (words.length / 2)) {
        return MapEntry('labName', normalized);
      }
    }

    return null;
  }

  Report? _buildReport({
    required String filePath,
    required List<StructuredBiomarker> biomarkers,
    required List<String> rawTexts,
    String? patientName,
    Map<String, String> metadata = const {},
  }) {
    final now = _now();
    final parsedBiomarkers = <Biomarker>[];
    final qualitativeSegments = <String>[];

    final labName = metadata['labName'] ??
        metadata['labReference'] ??
        _extractLabFromFirstLines(rawTexts) ??
        'Unknown Lab';

    for (final structured in biomarkers) {
      final valueNumeric = _parseDouble(structured.value);
      if (valueNumeric == null) {
        final snippet = [
          structured.name,
          if ((structured.value ?? '').trim().isNotEmpty)
            structured.value!.trim(),
          if ((structured.unit ?? '').trim().isNotEmpty)
            structured.unit!.trim(),
        ]
            .where((element) => element != null && element.trim().isNotEmpty)
            .map((e) => e.trim())
            .join(' ');
        if (snippet.isNotEmpty) {
          qualitativeSegments.add(snippet);
        }
        continue;
      }

      final normalizedName = normalizeBiomarker(structured.name);
      final name =
          normalizedName.isNotEmpty ? normalizedName : structured.name.trim();

      if (name.isEmpty) continue;

      final referenceMin =
          _parseDouble(structured.referenceMin) ?? valueNumeric;
      final referenceMax =
          _parseDouble(structured.referenceMax) ?? valueNumeric;

      parsedBiomarkers.add(
        Biomarker(
          id: _idGenerator(),
          name: name,
          value: valueNumeric,
          unit: structured.unit?.trim() ?? '',
          referenceRange: ReferenceRange(
            min: referenceMin,
            max: referenceMax,
          ),
          measuredAt: now,
        ),
      );
    }

    if (parsedBiomarkers.isEmpty) {
      return null;
    }

    final nowNotes = _buildNotes(
      rawTexts: rawTexts,
      patientName: patientName,
      metadata: metadata,
      qualitativeValues: qualitativeSegments,
    );

    return Report(
      id: '',
      date: now,
      labName: labName,
      biomarkers: parsedBiomarkers,
      originalFilePath: filePath,
      notes: nowNotes,
      createdAt: now,
      updatedAt: now,
    );
  }

  String? _buildNotes({
    required List<String> rawTexts,
    String? patientName,
    Map<String, String> metadata = const {},
    List<String> qualitativeValues = const [],
  }) {
    final segments = <String>[];
    if (patientName != null && patientName.trim().isNotEmpty) {
      segments.add('Patient Name: ${patientName.trim()}');
    }
    if (metadata.isNotEmpty) {
      final metadataLines = metadata.entries
          .where(
            (entry) =>
                entry.key != 'patientName' &&
                entry.key != 'labName' &&
                entry.value.trim().isNotEmpty,
          )
          .map((entry) => '${_formatMetadataKey(entry.key)}: ${entry.value}')
          .toList();
      if (metadataLines.isNotEmpty) {
        segments.add(metadataLines.join('\n'));
      }
    }
    if (qualitativeValues.isNotEmpty) {
      segments.add(
        [
          'Qualitative Results:',
          ...qualitativeValues.map((value) => '- $value'),
        ].join('\n'),
      );
    }
    if (rawTexts.isNotEmpty) {
      final joined = rawTexts.join('\n');
      final sanitized =
          patientName != null ? _removePatientMetadata(joined) : joined;
      if (sanitized.trim().isNotEmpty) {
        segments.add(sanitized.trim());
      }
    }
    if (segments.isEmpty) {
      return null;
    }
    return segments.join('\n\n');
  }

  String _removePatientMetadata(String input) {
    final lines = input.split('\n');
    final filtered = lines.where((line) {
      final lower = line.toLowerCase();
      if (lower.contains('patient') && lower.contains('name')) {
        return false;
      }
      return true;
    }).toList();

    return filtered.join('\n');
  }

  String _formatMetadataKey(String key) {
    switch (key) {
      case 'reportDate':
        return 'Report Date';
      case 'collectedDate':
        return 'Collected Date';
      case 'billDate':
        return 'Bill Date';
      case 'labReference':
        return 'Lab Reference';
      case 'ageGender':
        return 'Age / Gender';
      case 'labName':
        return 'Lab Name';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }

  String? _extractMetadataValue(String text) {
    for (final separator in [':', '-', '–']) {
      final index = text.indexOf(separator);
      if (index != -1 && index + 1 < text.length) {
        final candidate = text.substring(index + 1).trim();
        if (candidate.isNotEmpty) {
          return candidate;
        }
      }
    }
    if (text.contains('/')) {
      final parts = text.split('/');
      final tail = parts.last.trim();
      if (tail.isNotEmpty) {
        return tail;
      }
    }
    return null;
  }

  double? _parseDouble(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final sanitized =
        trimmed.replaceAll(RegExp(r'[^0-9.,+-]'), '').replaceAll(',', '.');
    return double.tryParse(sanitized);
  }
}

class _LineData {
  _LineData({
    required this.text,
    required BoundingBox box,
  })  : boundingBox = box,
        centerY = (box.y + box.height / 2).clamp(0.0, 1.0),
        centerX = (box.x + box.width / 2).clamp(0.0, 1.0);

  final String text;
  final BoundingBox boundingBox;
  final double centerY;
  final double centerX;
}

class _RowData {
  _RowData(_LineData line)
      : lines = [line],
        centerY = line.centerY;

  final List<_LineData> lines;
  double centerY;

  void addLine(_LineData line) {
    lines.add(line);
    centerY =
        lines.map((l) => l.centerY).reduce((a, b) => a + b) / lines.length;
  }

  String get combinedText {
    final sorted = lines.toList()
      ..sort((a, b) => a.centerX.compareTo(b.centerX));
    return sorted
        .map((line) => line.text)
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  double get centerX =>
      lines.map((line) => line.centerX).reduce((a, b) => a + b) / lines.length;
}

int _findValueTokenIndex(List<String> tokens) {
  for (var i = 0; i < tokens.length; i++) {
    if (_isValueToken(tokens[i])) {
      return i;
    }
  }
  return -1;
}

_ValueUnitExtraction _extractValueAndUnit(List<String> tokens, int startIndex) {
  final valueTokens = <String>[];
  var index = startIndex;
  while (index < tokens.length) {
    final token = tokens[index];
    if (valueTokens.isEmpty) {
      valueTokens.add(token);
      index++;
      continue;
    }
    final lower = token.toLowerCase();
    if (_isQualitativeContinuation(lower)) {
      valueTokens.add(token);
      index++;
      continue;
    }
    break;
  }

  final unitTokens = index < tokens.length ? tokens.sublist(index) : <String>[];
  return _ValueUnitExtraction(valueTokens: valueTokens, unitTokens: unitTokens);
}

bool _isValueToken(String token) {
  final trimmed = token.trim();
  if (trimmed.isEmpty) return false;
  final lower = trimmed.toLowerCase();
  const qualitativeTokens = <String>{
    'positive',
    'negative',
    'reactive',
    'non-reactive',
    'not',
    'detected',
    'present',
    'absent',
    'trace',
    'borderline',
    'equivocal',
  };
  if (qualitativeTokens.contains(lower)) {
    return true;
  }

  final numericPattern = RegExp(r'^[+\-]?\d+(?:[.,]\d+)?(?:[x×]10\^?\d+)?$');
  final comparisonPattern = RegExp(r'^[<>]=?\s*\d+(?:[.,]\d+)?$');
  final fractionPattern = RegExp(r'^\d+(?:[.,]\d+)?/\d+(?:[.,]\d+)?$');

  if (numericPattern.hasMatch(trimmed) ||
      comparisonPattern.hasMatch(trimmed) ||
      fractionPattern.hasMatch(trimmed) ||
      trimmed.contains(RegExp(r'\d'))) {
    return true;
  }

  if (trimmed.contains('+') || trimmed.contains('±')) {
    return true;
  }

  return false;
}

bool _isQualitativeContinuation(String tokenLower) {
  const continuationTokens = <String>{
    'positive',
    'negative',
    'reactive',
    'non-reactive',
    'detected',
    'present',
    'absent',
    'trace',
    'borderline',
    'equivocal',
    'not',
  };

  return continuationTokens.contains(tokenLower);
}

String? _extractLabFromFirstLines(List<String> rawTexts) {
  final candidateLines = rawTexts
      .expand((text) => text.split('\n'))
      .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
      .where((line) => line.isNotEmpty)
      .take(10)
      .toList();

  final keywordPattern = RegExp(
      r'(clinic|hospital|diagnostic|laboratory|labs?|centre|foundation)',
      caseSensitive: false);

  for (final line in candidateLines) {
    if (keywordPattern.hasMatch(line)) {
      return line;
    }
  }

  if (candidateLines.isNotEmpty) {
    return candidateLines.first;
  }
  return null;
}

class _ValueUnitExtraction {
  const _ValueUnitExtraction({
    required this.valueTokens,
    required this.unitTokens,
  });

  final List<String> valueTokens;
  final List<String> unitTokens;
}
