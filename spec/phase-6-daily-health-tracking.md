# Phase 6: Daily Health Tracking – Task List

**Phase Goal:** Enable users to log daily vital signs (BP, SpO2, heart rate, temperature, weight, glucose, sleep, medication, energy level) alongside lab reports in a unified timeline view, with trend analysis and comprehensive health monitoring.

**Status:** Not Started

**Start Date:** TBD

**Completion Date:** TBD

---

## Product Vision

Complement lab report tracking with daily vital sign logging, creating a unified health timeline that combines professional lab results with self-monitored vitals for comprehensive health management.

---

## Core Requirements

### Unified Timeline
- Single chronological view showing both lab reports AND health logs
- Visual timeline design with dots and connecting lines
- Filter chips: "All" | "Lab Reports" | "Health Logs"
- Clear type indicators (📊 lab reports, 📝 health logs)
- Color-coded dots: blue (reports), green (normal logs), orange (warnings)

### Health Log Entry
- Bottom sheet modal covering 85% of screen
- Default visible vitals: BP, SpO2, Heart Rate
- Additional vitals via "+ Add Another Vital" dropdown:
  - Body Temperature
  - Weight
  - Blood Glucose
  - Sleep Hours
  - Medication Taken
  - Respiratory Rate
  - Energy Level (1-10 scale)
- Timestamp (auto-populated, editable)
- Notes field (optional, free text)
- Real-time status indicators (🟢🟡🔴)

### Reference Ranges
- Extract from medical reports for biomarkers
- Medical standard defaults for vitals:
  - BP Systolic: 90-120 mmHg
  - BP Diastolic: 60-80 mmHg
  - SpO2: 95-100%
  - Heart Rate: 60-100 bpm
  - Body Temperature: 97-99°F
  - Blood Glucose: 70-100 mg/dL (fasting)
- User-customizable ranges (future enhancement)

### Vital Trends
- Extend existing trends page
- Tab selector: "Biomarkers" | "Vitals"
- Vital type dropdown
- Line charts with reference range bands
- Dual-line chart for BP (systolic + diastolic)
- Statistics: average, min, max, trend direction
- Tap biomarker card → navigate to trends

### Data Management
- CRUD operations for health logs
- Timestamp-based sorting
- Search and filter
- Edit/delete functionality
- Offline-first with Hive storage

---

## Architecture Design

### Domain Layer

#### Entities (`lib/domain/entities/`)

**`health_entry.dart`** - Abstract interface for unified timeline
```dart
abstract class HealthEntry {
  String get id;
  DateTime get timestamp;
  HealthEntryType get entryType;
  String get displayTitle;
  String get displaySubtitle;
  bool get hasWarnings;
}

enum HealthEntryType {
  labReport,
  healthLog,
}
```

**`health_log.dart`** - Daily vital measurements
```dart
class HealthLog extends Equatable implements HealthEntry {
  final String id;
  final DateTime timestamp;
  final List<VitalMeasurement> vitals;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthLog({
    required this.id,
    required this.timestamp,
    required this.vitals,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  HealthEntryType get entryType => HealthEntryType.healthLog;

  @override
  String get displayTitle => 'Health Log';

  @override
  String get displaySubtitle {
    final vitalNames = vitals.take(3).map((v) => v.type.displayName).join(', ');
    return vitals.length <= 3 ? vitalNames : '$vitalNames +${vitals.length - 3}';
  }

  @override
  bool get hasWarnings {
    return vitals.any((v) => v.status != VitalStatus.normal);
  }

  List<VitalMeasurement> get outOfRangeVitals {
    return vitals.where((v) => v.status != VitalStatus.normal).toList();
  }

  HealthLog copyWith({
    String? id,
    DateTime? timestamp,
    List<VitalMeasurement>? vitals,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  List<Object?> get props => [id, timestamp, vitals, notes, createdAt, updatedAt];
}
```

**`vital_measurement.dart`** - Individual vital reading
```dart
class VitalMeasurement extends Equatable {
  final String id;
  final VitalType type;
  final double value;
  final String unit;
  final VitalStatus status;
  final ReferenceRange? referenceRange;

  const VitalMeasurement({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.status,
    this.referenceRange,
  });

  bool get isOutOfRange => status != VitalStatus.normal;

  VitalMeasurement copyWith({
    String? id,
    VitalType? type,
    double? value,
    String? unit,
    VitalStatus? status,
    ReferenceRange? referenceRange,
  });

  @override
  List<Object?> get props => [id, type, value, unit, status, referenceRange];
}
```

**`vital_type.dart`** - Enum with all vital types
```dart
enum VitalType {
  bloodPressureSystolic,
  bloodPressureDiastolic,
  oxygenSaturation,      // SpO2
  heartRate,
  bodyTemperature,
  weight,
  bloodGlucose,
  sleepHours,
  medicationAdherence,   // boolean (0 or 1)
  respiratoryRate,
  energyLevel,           // 1-10 scale
}

enum VitalStatus {
  normal,    // Within reference range
  warning,   // Slightly outside range
  critical,  // Significantly outside range
}

extension VitalTypeExtension on VitalType {
  String get displayName {
    switch (this) {
      case VitalType.bloodPressureSystolic:
        return 'BP Systolic';
      case VitalType.bloodPressureDiastolic:
        return 'BP Diastolic';
      case VitalType.oxygenSaturation:
        return 'SpO2';
      case VitalType.heartRate:
        return 'Heart Rate';
      case VitalType.bodyTemperature:
        return 'Temperature';
      case VitalType.weight:
        return 'Weight';
      case VitalType.bloodGlucose:
        return 'Blood Glucose';
      case VitalType.sleepHours:
        return 'Sleep';
      case VitalType.medicationAdherence:
        return 'Medication';
      case VitalType.respiratoryRate:
        return 'Respiratory Rate';
      case VitalType.energyLevel:
        return 'Energy Level';
    }
  }

  String get icon {
    switch (this) {
      case VitalType.bloodPressureSystolic:
      case VitalType.bloodPressureDiastolic:
        return '🩺';
      case VitalType.oxygenSaturation:
      case VitalType.respiratoryRate:
        return '🫁';
      case VitalType.heartRate:
        return '❤️';
      case VitalType.bodyTemperature:
        return '🌡️';
      case VitalType.weight:
        return '⚖️';
      case VitalType.bloodGlucose:
        return '🩸';
      case VitalType.sleepHours:
        return '😴';
      case VitalType.medicationAdherence:
        return '💊';
      case VitalType.energyLevel:
        return '⚡';
    }
  }

  bool get isDefaultVisible {
    return this == VitalType.bloodPressureSystolic ||
           this == VitalType.bloodPressureDiastolic ||
           this == VitalType.oxygenSaturation ||
           this == VitalType.heartRate;
  }
}
```

**`vital_reference_defaults.dart`** - Medical standard ranges
```dart
class VitalReferenceDefaults {
  static ReferenceRange? getDefault(VitalType type) {
    switch (type) {
      case VitalType.bloodPressureSystolic:
        return const ReferenceRange(min: 90, max: 120);
      case VitalType.bloodPressureDiastolic:
        return const ReferenceRange(min: 60, max: 80);
      case VitalType.oxygenSaturation:
        return const ReferenceRange(min: 95, max: 100);
      case VitalType.heartRate:
        return const ReferenceRange(min: 60, max: 100);
      case VitalType.bodyTemperature:
        return const ReferenceRange(min: 97.0, max: 99.0); // °F
      case VitalType.bloodGlucose:
        return const ReferenceRange(min: 70, max: 100); // mg/dL fasting
      case VitalType.respiratoryRate:
        return const ReferenceRange(min: 12, max: 20); // breaths per minute
      // No reference ranges for weight, sleep, medication, energy
      default:
        return null;
    }
  }

  static String getUnit(VitalType type) {
    switch (type) {
      case VitalType.bloodPressureSystolic:
      case VitalType.bloodPressureDiastolic:
        return 'mmHg';
      case VitalType.oxygenSaturation:
        return '%';
      case VitalType.heartRate:
        return 'bpm';
      case VitalType.bodyTemperature:
        return '°F';
      case VitalType.weight:
        return 'lbs';
      case VitalType.bloodGlucose:
        return 'mg/dL';
      case VitalType.sleepHours:
        return 'hours';
      case VitalType.medicationAdherence:
        return '';
      case VitalType.respiratoryRate:
        return 'breaths/min';
      case VitalType.energyLevel:
        return '/10';
    }
  }

  static VitalStatus calculateStatus(VitalType type, double value) {
    final range = getDefault(type);
    if (range == null) return VitalStatus.normal;

    if (value < range.min || value > range.max) {
      // Determine if warning or critical
      final deviation = value < range.min
          ? (range.min - value) / range.min
          : (value - range.max) / range.max;

      return deviation > 0.2 ? VitalStatus.critical : VitalStatus.warning;
    }

    return VitalStatus.normal;
  }
}
```

**Update `report.dart`** to implement HealthEntry
```dart
class Report extends Equatable implements HealthEntry {
  // ... existing fields

  @override
  HealthEntryType get entryType => HealthEntryType.labReport;

  @override
  DateTime get timestamp => date;

  @override
  String get displayTitle => 'Lab Report';

  @override
  String get displaySubtitle => '$labName • ${biomarkers.length} biomarkers';

  @override
  bool get hasWarnings => hasOutOfRangeBiomarkers;
}
```

#### Repositories (`lib/domain/repositories/`)

**`health_log_repository.dart`**
```dart
abstract class HealthLogRepository {
  Future<Either<Failure, HealthLog>> saveHealthLog(HealthLog log);
  Future<Either<Failure, List<HealthLog>>> getAllHealthLogs();
  Future<Either<Failure, List<HealthLog>>> getHealthLogsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<Either<Failure, HealthLog>> getHealthLogById(String id);
  Future<Either<Failure, void>> deleteHealthLog(String id);
  Future<Either<Failure, void>> updateHealthLog(HealthLog log);
  Future<Either<Failure, List<VitalMeasurement>>> getVitalTrend(
    VitalType type, {
    DateTime? startDate,
    DateTime? endDate,
  });
}
```

**`timeline_repository.dart`**
```dart
abstract class TimelineRepository {
  Future<Either<Failure, List<HealthEntry>>> getUnifiedTimeline({
    DateTime? startDate,
    DateTime? endDate,
    HealthEntryType? filterType,
  });
}
```

#### Use Cases (`lib/domain/usecases/`)

1. **`create_health_log.dart`**
   - Validate vital measurements
   - Calculate status for each vital
   - Assign UUID
   - Save via repository

2. **`get_all_health_logs.dart`**
   - Fetch all logs
   - Sort by timestamp descending

3. **`get_health_log_by_id.dart`**
   - Fetch specific log by ID

4. **`update_health_log.dart`**
   - Validate changes
   - Update timestamp
   - Save via repository

5. **`delete_health_log.dart`**
   - Remove log by ID

6. **`get_vital_trend.dart`**
   - Fetch all measurements for specific vital type
   - Filter by date range
   - Sort chronologically

7. **`calculate_vital_statistics.dart`**
   - Compute average, min, max
   - Calculate trend direction
   - Return summary stats

8. **`get_unified_timeline.dart`**
   - Fetch reports from ReportRepository
   - Fetch health logs from HealthLogRepository
   - Combine into single list
   - Sort by timestamp descending
   - Apply filters

9. **`validate_vital_measurement.dart`**
   - Check value against reference range
   - Determine status (normal/warning/critical)

---

### Data Layer

#### Models (`lib/data/models/`)

**`health_log_model.dart`** - Hive model
```dart
@HiveType(typeId: 11)
class HealthLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final List<VitalMeasurementModel> vitals;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  HealthLogModel({
    required this.id,
    required this.timestamp,
    required this.vitals,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthLogModel.fromEntity(HealthLog entity) {
    return HealthLogModel(
      id: entity.id,
      timestamp: entity.timestamp,
      vitals: entity.vitals
          .map((v) => VitalMeasurementModel.fromEntity(v))
          .toList(),
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  HealthLog toEntity() {
    return HealthLog(
      id: id,
      timestamp: timestamp,
      vitals: vitals.map((v) => v.toEntity()).toList(),
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

**`vital_measurement_model.dart`**
```dart
@HiveType(typeId: 12)
class VitalMeasurementModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int vitalTypeIndex; // enum index

  @HiveField(2)
  final double value;

  @HiveField(3)
  final String unit;

  @HiveField(4)
  final int statusIndex; // enum index

  @HiveField(5)
  final ReferenceRangeModel? referenceRange;

  VitalMeasurementModel({
    required this.id,
    required this.vitalTypeIndex,
    required this.value,
    required this.unit,
    required this.statusIndex,
    this.referenceRange,
  });

  factory VitalMeasurementModel.fromEntity(VitalMeasurement entity) {
    return VitalMeasurementModel(
      id: entity.id,
      vitalTypeIndex: entity.type.index,
      value: entity.value,
      unit: entity.unit,
      statusIndex: entity.status.index,
      referenceRange: entity.referenceRange != null
          ? ReferenceRangeModel.fromEntity(entity.referenceRange!)
          : null,
    );
  }

  VitalMeasurement toEntity() {
    return VitalMeasurement(
      id: id,
      type: VitalType.values[vitalTypeIndex],
      value: value,
      unit: unit,
      status: VitalStatus.values[statusIndex],
      referenceRange: referenceRange?.toEntity(),
    );
  }
}
```

#### Repository Implementations (`lib/data/repositories/`)

**`health_log_repository_impl.dart`**
```dart
@LazySingleton(as: HealthLogRepository)
class HealthLogRepositoryImpl implements HealthLogRepository {
  final HealthLogLocalDataSource localDataSource;

  const HealthLogRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, HealthLog>> saveHealthLog(HealthLog log) async {
    try {
      final model = HealthLogModel.fromEntity(log);
      await localDataSource.saveHealthLog(model);
      return Right(log);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<HealthLog>>> getAllHealthLogs() async {
    try {
      final models = await localDataSource.getAllHealthLogs();
      final logs = models.map((m) => m.toEntity()).toList();
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Right(logs);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, HealthLog>> getHealthLogById(String id) async {
    try {
      final model = await localDataSource.getHealthLogById(id);
      return Right(model.toEntity());
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteHealthLog(String id) async {
    try {
      await localDataSource.deleteHealthLog(id);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateHealthLog(HealthLog log) async {
    try {
      final model = HealthLogModel.fromEntity(log);
      await localDataSource.updateHealthLog(model);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<VitalMeasurement>>> getVitalTrend(
    VitalType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await localDataSource.getAllHealthLogs();
      final measurements = <VitalMeasurement>[];

      for (final model in models) {
        // Filter by date range
        if (startDate != null && model.timestamp.isBefore(startDate)) continue;
        if (endDate != null && model.timestamp.isAfter(endDate)) continue;

        // Find matching vital type
        final vital = model.vitals.firstWhere(
          (v) => VitalType.values[v.vitalTypeIndex] == type,
          orElse: () => null,
        );

        if (vital != null) {
          measurements.add(vital.toEntity());
        }
      }

      // Sort chronologically
      measurements.sort((a, b) => a.id.compareTo(b.id));

      return Right(measurements);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<HealthLog>>> getHealthLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final models = await localDataSource.getAllHealthLogs();
      final filtered = models
          .where((m) =>
              m.timestamp.isAfter(start) && m.timestamp.isBefore(end))
          .map((m) => m.toEntity())
          .toList();
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Right(filtered);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
```

**`timeline_repository_impl.dart`**
```dart
@LazySingleton(as: TimelineRepository)
class TimelineRepositoryImpl implements TimelineRepository {
  final ReportRepository reportRepository;
  final HealthLogRepository healthLogRepository;

  const TimelineRepositoryImpl({
    required this.reportRepository,
    required this.healthLogRepository,
  });

  @override
  Future<Either<Failure, List<HealthEntry>>> getUnifiedTimeline({
    DateTime? startDate,
    DateTime? endDate,
    HealthEntryType? filterType,
  }) async {
    try {
      final entries = <HealthEntry>[];

      // Fetch reports if not filtered to health logs only
      if (filterType != HealthEntryType.healthLog) {
        final reportsResult = await reportRepository.getAllReports();
        reportsResult.fold(
          (failure) => throw CacheException(),
          (reports) => entries.addAll(reports),
        );
      }

      // Fetch health logs if not filtered to reports only
      if (filterType != HealthEntryType.labReport) {
        final logsResult = await healthLogRepository.getAllHealthLogs();
        logsResult.fold(
          (failure) => throw CacheException(),
          (logs) => entries.addAll(logs),
        );
      }

      // Filter by date range
      var filtered = entries;
      if (startDate != null) {
        filtered = filtered.where((e) => e.timestamp.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        filtered = filtered.where((e) => e.timestamp.isBefore(endDate)).toList();
      }

      // Sort by timestamp descending (newest first)
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return Right(filtered);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
```

#### Local Data Source (`lib/data/datasources/local/`)

**`health_log_local_datasource.dart`**
```dart
@lazySingleton
class HealthLogLocalDataSource {
  final HiveInterface hive;

  HealthLogLocalDataSource({required this.hive});

  Future<void> saveHealthLog(HealthLogModel log) async {
    final box = hive.box<HealthLogModel>('health_logs');
    await box.put(log.id, log);
  }

  Future<List<HealthLogModel>> getAllHealthLogs() async {
    final box = hive.box<HealthLogModel>('health_logs');
    return box.values.toList();
  }

  Future<HealthLogModel> getHealthLogById(String id) async {
    final box = hive.box<HealthLogModel>('health_logs');
    final log = box.get(id);
    if (log == null) {
      throw CacheException('Health log not found: $id');
    }
    return log;
  }

  Future<void> deleteHealthLog(String id) async {
    final box = hive.box<HealthLogModel>('health_logs');
    await box.delete(id);
  }

  Future<void> updateHealthLog(HealthLogModel log) async {
    final box = hive.box<HealthLogModel>('health_logs');
    await box.put(log.id, log);
  }
}
```

**Update `hive_database.dart`**
```dart
Future<void> init() async {
  await hive.initFlutter();

  // ... existing adapters

  // Register health log adapters
  hive.registerAdapter(HealthLogModelAdapter());
  hive.registerAdapter(VitalMeasurementModelAdapter());

  // ... existing boxes

  // Open health logs box
  await hive.openBox<HealthLogModel>('health_logs');
}
```

---

### Presentation Layer

#### Providers (`lib/presentation/providers/`)

**`health_log_provider.dart`**
```dart
final healthLogsProvider = StateNotifierProvider<HealthLogsNotifier, AsyncValue<List<HealthLog>>>(
  (ref) => HealthLogsNotifier(),
);

class HealthLogsNotifier extends StateNotifier<AsyncValue<List<HealthLog>>> {
  HealthLogsNotifier() : super(const AsyncValue.loading()) {
    loadHealthLogs();
  }

  Future<void> loadHealthLogs() async {
    state = const AsyncValue.loading();
    final getAllLogs = getIt<GetAllHealthLogs>();
    final result = await getAllLogs();

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (logs) => AsyncValue.data(logs),
    );
  }

  Future<void> addHealthLog(HealthLog log) async {
    final createLog = getIt<CreateHealthLog>();
    final result = await createLog(log);

    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async {
        await loadHealthLogs();
      },
    );
  }

  Future<void> updateHealthLog(HealthLog log) async {
    final updateLog = getIt<UpdateHealthLog>();
    final result = await updateLog(log);

    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async {
        await loadHealthLogs();
      },
    );
  }

  Future<void> deleteHealthLog(String id) async {
    final deleteLog = getIt<DeleteHealthLog>();
    final result = await deleteLog(id);

    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async {
        await loadHealthLogs();
      },
    );
  }
}
```

**`timeline_provider.dart`**
```dart
final timelineFilterProvider = StateProvider<HealthEntryType?>((ref) => null);

final timelineProvider = StateNotifierProvider<TimelineNotifier, AsyncValue<List<HealthEntry>>>(
  (ref) => TimelineNotifier(),
);

class TimelineNotifier extends StateNotifier<AsyncValue<List<HealthEntry>>> {
  TimelineNotifier() : super(const AsyncValue.loading()) {
    loadTimeline();
  }

  Future<void> loadTimeline({HealthEntryType? filter}) async {
    state = const AsyncValue.loading();
    final getTimeline = getIt<GetUnifiedTimeline>();
    final result = await getTimeline(filterType: filter);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (entries) => AsyncValue.data(entries),
    );
  }

  Future<void> refresh() async {
    await loadTimeline();
  }
}

final filteredTimelineProvider = Provider<AsyncValue<List<HealthEntry>>>((ref) {
  final timeline = ref.watch(timelineProvider);
  final filter = ref.watch(timelineFilterProvider);

  if (filter == null) return timeline;

  return timeline.whenData((entries) {
    return entries.where((e) => e.entryType == filter).toList();
  });
});
```

**`vital_trend_provider.dart`**
```dart
final selectedVitalTypeProvider = StateProvider<VitalType?>((ref) => null);

final vitalTrendProvider = FutureProvider.family<List<VitalMeasurement>, VitalType>(
  (ref, vitalType) async {
    final getVitalTrend = getIt<GetVitalTrend>();
    final result = await getVitalTrend(vitalType);
    return result.fold(
      (failure) => throw failure,
      (measurements) => measurements,
    );
  },
);

final vitalStatisticsProvider = FutureProvider.family<VitalStatistics, VitalType>(
  (ref, vitalType) async {
    final calculateStats = getIt<CalculateVitalStatistics>();
    final result = await calculateStats(vitalType);
    return result.fold(
      (failure) => throw failure,
      (stats) => stats,
    );
  },
);
```

#### Pages

**`lib/presentation/pages/health_log/health_log_entry_sheet.dart`** (Bottom Sheet)
- DraggableScrollableSheet covering 85% of screen
- Default visible: BP (sys/dias), SpO2, Heart Rate
- Expandable "Add Another Vital" dropdown
- DateTime picker
- Notes text field
- Real-time status indicators
- Save button

**`lib/presentation/pages/health_log/health_log_detail_page.dart`**
- Display all vitals with status
- Visual range indicators
- Edit/delete actions
- Navigate to trends

**Update `lib/presentation/pages/home/reports_list_page.dart`**
- Replace report list with timeline view
- Add filter chips
- Integrate HealthTimeline widget

**Update `lib/presentation/pages/trends/trends_page.dart`**
- Add tab selector: Biomarkers | Vitals
- Vital type dropdown
- VitalTrendChart widget
- Statistics card

#### Widgets

**`lib/presentation/widgets/health_timeline.dart`**
- Timeline layout with dots and lines
- Date separators
- Color-coded dots
- Renders HealthLogCard or ReportCard

**`lib/presentation/widgets/health_log_card.dart`**
- 📝 icon + timestamp
- Top 3-4 vitals with values
- Status indicators
- Notes preview
- Tap to detail page

**`lib/presentation/widgets/vital_input_field.dart`**
- Custom input per vital type
- BP: two fields (sys/dias)
- Energy Level: slider 1-10
- Medication: checkbox
- Others: numeric input

**`lib/presentation/widgets/vital_trend_chart.dart`**
- Line chart using fl_chart
- Reference range band
- Dual-line for BP
- Color-coded points

---

## UI/UX Design

### Timeline View

```
┌─────────────────────────────────────┐
│  Health Timeline             [⚙️]   │
│                                      │
│  ┌────┬──────────────┬─────────────┐│
│  │All │ Lab Reports  │ Health Logs ││
│  └────┴──────────────┴─────────────┘│
│                                      │
│  Today • Oct 18, 2025                │
│    │                                 │
│    ●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┐│
│    ┃ 📝 7:30 AM                    ││
│    ┃ BP: 120/80 🟢  SpO2: 98% 🟢  ││
│    ┃ HR: 72 bpm 🟢                 ││
│    ┃ 💬 "Morning reading"          ││
│    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┘│
│    ┃                                 │
│    ●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┐│
│    ┃ 📊 Quest Diagnostics          ││
│    ┃ 23 biomarkers • 3 out ⚠️      ││
│    ┃ Hemoglobin, Glucose, Chol...  ││
│    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━┘│
│    ┃                                 │
│                                      │
│               [+]                    │
└─────────────────────────────────────┘
```

### Bottom Sheet Entry

```
┌──────────────────────────────────────┐
│  ━━━  (drag handle)                  │
│                                      │
│  Log Health Vitals          [✕]     │
│                                      │
│  📅 Oct 18, 2025 • 7:30 AM  [Edit]  │
│                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                      │
│  🩺 Blood Pressure                   │
│  ┌─────┐ / ┌─────┐ mmHg            │
│  │ 120 │   │  80 │                  │
│  └─────┘   └─────┘                  │
│  Range: 90-120 / 60-80 🟢            │
│                                      │
│  🫁 Oxygen Saturation (SpO2)         │
│  ┌─────┐ %                          │
│  │  98 │                             │
│  └─────┘                             │
│  Range: 95-100% 🟢                   │
│                                      │
│  ❤️  Heart Rate                      │
│  ┌─────┐ bpm                        │
│  │  72 │                             │
│  └─────┘                             │
│  Range: 60-100 bpm 🟢                │
│                                      │
│  [+ Add Another Vital ▼]             │
│                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                      │
│  💬 Notes (Optional)                 │
│  ┌──────────────────────────────────┐│
│  │                                  ││
│  └──────────────────────────────────┘│
│                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                      │
│            [Save Health Log]         │
│                                      │
└──────────────────────────────────────┘
```

---

## Implementation Timeline

### Week 1: Foundation (Domain Layer)
**Day 1-2: Entities**
- [x] TEST: HealthLog entity tests
- [x] CODE: HealthLog entity
- [x] TEST: VitalMeasurement entity tests
- [x] CODE: VitalMeasurement entity
- [x] TEST: VitalType enum tests
- [x] CODE: VitalType enum + extensions
- [x] CODE: VitalReferenceDefaults utility
- [x] CODE: Update Report to implement HealthEntry
- [ ] COMMIT: Domain entities complete

**Day 3: Repository Interfaces**
- [x] CODE: HealthLogRepository interface
- [x] CODE: TimelineRepository interface
- [ ] COMMIT: Repository interfaces

**Day 4-5: Use Cases**
- [x] TEST: ValidateVitalMeasurement tests
- [x] CODE: ValidateVitalMeasurement
- [x] TEST: CreateHealthLog tests
- [x] CODE: CreateHealthLog
- [x] TEST: GetAllHealthLogs tests
- [x] CODE: GetAllHealthLogs
- [x] TEST: GetHealthLogById tests
- [x] CODE: GetHealthLogById
- [x] TEST: UpdateHealthLog tests
- [x] CODE: UpdateHealthLog
- [x] TEST: DeleteHealthLog tests
- [x] CODE: DeleteHealthLog
- [x] TEST: GetVitalTrend tests
- [x] CODE: GetVitalTrend
- [x] TEST: CalculateVitalStatistics tests
- [x] CODE: CalculateVitalStatistics
- [x] TEST: GetUnifiedTimeline tests
- [x] CODE: GetUnifiedTimeline
- [ ] VERIFY: All tests pass, 90%+ coverage
- [ ] COMMIT: Use cases complete

### Week 2: Data Layer
**Day 1-2: Hive Models**
- [x] TEST: HealthLogModel tests
- [x] CODE: HealthLogModel + TypeAdapter
- [x] TEST: VitalMeasurementModel tests
- [x] CODE: VitalMeasurementModel + TypeAdapter
- [x] CODE: Update HiveDatabase (register adapters, open box)
- [x] CODE: Run build_runner
- [ ] COMMIT: Hive models complete

**Day 3: Local Data Source**
- [ ] TEST: HealthLogLocalDataSource tests
- [ ] CODE: HealthLogLocalDataSource
- [ ] VERIFY: All tests pass
- [ ] COMMIT: Local data source complete

**Day 4-5: Repository Implementations**
- [ ] TEST: HealthLogRepositoryImpl tests
- [ ] CODE: HealthLogRepositoryImpl
- [ ] TEST: TimelineRepositoryImpl tests
- [ ] CODE: TimelineRepositoryImpl
- [ ] CODE: Update injection_container.dart
- [ ] CODE: Run build_runner
- [ ] VERIFY: All tests pass, 90%+ coverage
- [ ] COMMIT: Repository implementations complete

### Week 3: Presentation Layer (Providers & Basic UI)
**Day 1: Providers**
- [ ] TEST: HealthLogsNotifier tests
- [ ] CODE: health_log_provider.dart
- [ ] TEST: TimelineNotifier tests
- [ ] CODE: timeline_provider.dart
- [ ] TEST: VitalTrendProvider tests
- [ ] CODE: vital_trend_provider.dart
- [ ] VERIFY: All tests pass
- [ ] COMMIT: Providers complete

**Day 2-3: Timeline Widget**
- [ ] TEST: HealthTimeline widget tests
- [ ] CODE: HealthTimeline widget
- [ ] TEST: HealthLogCard widget tests
- [ ] CODE: HealthLogCard widget
- [ ] CODE: Update reports_list_page.dart
- [ ] VERIFY: Widget tests pass
- [ ] COMMIT: Timeline view complete

**Day 4-5: Bottom Sheet Entry**
- [ ] TEST: HealthLogEntrySheet widget tests
- [ ] CODE: HealthLogEntrySheet
- [ ] TEST: VitalInputField widget tests
- [ ] CODE: VitalInputField
- [ ] CODE: Add FAB to home page
- [ ] VERIFY: Widget tests pass
- [ ] COMMIT: Health log entry complete

### Week 4: Advanced Features & Polish
**Day 1-2: Detail Page & Edit**
- [ ] TEST: HealthLogDetailPage widget tests
- [ ] CODE: HealthLogDetailPage
- [ ] CODE: Edit functionality
- [ ] CODE: Delete functionality
- [ ] VERIFY: Widget tests pass
- [ ] COMMIT: Detail page complete

**Day 3: Vital Trends**
- [ ] TEST: VitalTrendChart widget tests
- [ ] CODE: VitalTrendChart
- [ ] CODE: Update trends_page.dart (add vitals tab)
- [ ] CODE: Statistics display
- [ ] VERIFY: Widget tests pass
- [ ] COMMIT: Vital trends complete

**Day 4: Navigation & Integration**
- [ ] CODE: Update app_router.dart (routes)
- [ ] CODE: Update route_names.dart
- [ ] CODE: Navigation flows
- [ ] TEST: Integration tests
- [ ] VERIFY: All flows work end-to-end
- [ ] COMMIT: Navigation complete

**Day 5: Final Testing & Documentation**
- [ ] RUN: flutter test --coverage
- [ ] VERIFY: 90%+ coverage
- [ ] RUN: flutter analyze
- [ ] VERIFY: No issues
- [ ] UPDATE: CHANGELOG.md
- [ ] UPDATE: AGENTS.md
- [ ] UPDATE: overall-plan.md
- [ ] COMMIT: Phase 6 complete

---

## Acceptance Criteria

### Functional
- [ ] User can tap FAB to open bottom sheet
- [ ] Bottom sheet covers 85% of screen
- [ ] BP, SpO2, HR fields visible by default
- [ ] Additional vitals accessible via dropdown
- [ ] All 11 vital types supported
- [ ] Timestamp auto-populated and editable
- [ ] Notes field supports free text
- [ ] Status indicators update in real-time
- [ ] Health log saves successfully
- [ ] Timeline shows both reports and logs
- [ ] Filter chips work (All/Reports/Logs)
- [ ] Timeline has dots and connecting lines
- [ ] Cards show correct icons and data
- [ ] Tap card navigates to detail page
- [ ] Detail page shows all vitals
- [ ] Edit/delete functionality works
- [ ] Trends page shows vital trends
- [ ] BP displays dual-line chart
- [ ] Statistics calculate correctly
- [ ] Reference ranges apply correctly

### Technical
- [ ] 90%+ test coverage
- [ ] All tests pass
- [ ] No analyzer warnings
- [ ] Clean architecture maintained
- [ ] Repository pattern followed
- [ ] Hive storage works correctly
- [ ] TypeAdapters generated
- [ ] Dependency injection configured
- [ ] Navigation routes configured

### Documentation
- [ ] spec/phase-6-daily-health-tracking.md created
- [ ] spec/overall-plan.md updated
- [ ] CHANGELOG.md updated
- [ ] AGENTS.md updated with examples

---

## Notes

### Default Vitals (Always Visible)
1. Blood Pressure (Systolic/Diastolic)
2. Oxygen Saturation (SpO2)
3. Heart Rate

### Additional Vitals (Dropdown)
4. Body Temperature
5. Weight
6. Blood Glucose
7. Sleep Hours
8. Medication Taken
9. Respiratory Rate
10. Energy Level (1-10 scale)

### Reference Ranges
- BP Systolic: 90-120 mmHg
- BP Diastolic: 60-80 mmHg
- SpO2: 95-100%
- Heart Rate: 60-100 bpm
- Temperature: 97-99°F
- Glucose: 70-100 mg/dL (fasting)
- Respiratory Rate: 12-20 breaths/min
- No ranges: Weight, Sleep, Medication, Energy

### Export Integration
Deferred to Phase 5. When implemented:
- CSV export includes health logs
- Doctor PDF includes vital signs section
- Separate sheets for reports vs logs

---

**Last Updated:** 2025-10-18
**Status:** Ready for implementation
