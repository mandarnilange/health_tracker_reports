# Extract Biomarker Pipeline – Design Notes (LLM-Based Approach)

## Objective

Deliver a highly accurate extraction flow that accepts:
- Multi-page PDF lab reports imported from Files/Drive.
- One or more images captured by the camera or chosen from the gallery.

The pipeline must:
- Prioritize **accuracy over offline processing** (95%+ target vs 88-93% local).
- Use remote LLM APIs (Claude, Gemini, ChatGPT) with vision capabilities for parsing.
- Convert LLM responses into normalized biomarker entities and persist them locally via Hive.
- Provide responsive UX feedback (progress, errors, cancel support).
- Support user-configurable API keys and provider selection.
- Gracefully handle network failures and API errors.

## Constraints & Considerations

| Constraint | Notes |
|------------|-------|
| Network dependency | Requires internet connection for LLM API calls. Graceful offline degradation. |
| API costs | User provides their own API keys; no cost to app developer. |
| Supported platforms | iOS, Android, Web (all platforms support HTTP API calls). |
| Performance | Multi-page PDFs extraction time depends on API response time (5-15s per page). |
| Privacy | User data sent to third-party LLM providers (Anthropic, OpenAI, Google). Requires user consent. |
| Security | API keys stored securely using flutter_secure_storage. |
| User experience | Progress indicator per page, graceful cancel, network error handling, API rate limiting. |

## Problem Analysis

The local ML Kit approach (88-93% accuracy) has fundamental limitations:

1. **OCR limitations** – ML Kit text recognition struggles with:
   - Complex table layouts in medical reports
   - Handwritten annotations and signatures
   - Low-quality scans or photos
   - Varied fonts and formatting

2. **Parsing complexity** – Pattern-based extraction is brittle:
   - Requires maintaining extensive regex patterns
   - Fails on non-standard report formats
   - Cannot handle semantic relationships between fields
   - Metadata extraction (patient name, dates, lab name) is error-prone

3. **Accuracy ceiling** – Current approach achieves:
   - Basic (rule-based): 88%
   - Enhanced (embeddings): 90-93%
   - Advanced (NER model): 95-96% (but requires 66MB download)

4. **Maintenance burden** – Each new report format requires:
   - New regex patterns
   - Updated normalization rules
   - Additional test cases
   - Platform-specific code changes

**Proposed solution**: Use vision-capable LLMs (Claude 3.5 Sonnet, GPT-4 Vision, Gemini Pro Vision) which can:
- Directly understand medical report structure and semantics
- Extract biomarkers with 95%+ accuracy out-of-the-box
- Handle diverse report formats without pattern updates
- Provide structured JSON output with confidence scores

## Candidate Approaches

### 1. **LLM Vision API (Direct Image-to-JSON)** ⭐ Recommended

Steps:
1. Convert PDF pages to base64-encoded images (PNG/JPEG).
2. Send images directly to LLM vision API (Claude, GPT-4V, Gemini) with structured prompt.
3. LLM returns JSON with extracted biomarkers, metadata, and confidence scores.
4. Parse JSON response and normalize biomarker names in Dart.
5. Persist Report entity via existing use cases.

Pros:
- **Highest accuracy** (95%+ based on LLM benchmarks on medical documents).
- **No OCR step** – LLMs natively understand images and text.
- **Format-agnostic** – Handles diverse report layouts without code changes.
- **Structured output** – JSON schema ensures consistent parsing.
- **Minimal maintenance** – No regex patterns or normalization maps to update.
- **Multi-provider support** – Can switch between Claude/GPT/Gemini based on cost/accuracy.

Cons:
- Requires internet connection.
- User must provide API key.
- API costs (mitigated by user-provided keys).
- Slower than local processing (5-15s per page vs 1-2s).
- Privacy concerns (data sent to third party).

### 2. **LLM Text API (OCR + Text Extraction)**

Steps:
1. Use existing OCR (ML Kit or native Vision API) to extract raw text.
2. Send text to LLM text-only API (cheaper than vision).
3. LLM parses text into structured biomarkers.

Pros:
- Lower API costs than vision APIs.
- Can work with existing OCR pipeline.
- Still benefits from LLM semantic understanding.

Cons:
- OCR errors compound with LLM errors.
- Loses visual layout information (tables, columns).
- Requires two-step processing (OCR → LLM).
- Lower accuracy than direct vision approach (90-92% vs 95%+).

### 3. **Hybrid Local + Cloud Fallback**

Steps:
1. Attempt local extraction first (existing ML Kit pipeline).
2. If confidence < 80%, fallback to cloud LLM.
3. User can configure "always use cloud" preference.

Pros:
- Preserves offline capability for simple reports.
- Reduces API costs.
- Best of both worlds.

Cons:
- Complex state management (two extraction paths).
- User experience inconsistency.
- Still maintains brittle local parsing code.
- Delays results when fallback triggers.

### 4. **Self-Hosted LLM (Ollama/LocalAI)**

Steps:
1. User runs local LLM server (Ollama with LLaVA or similar).
2. App sends requests to localhost API.

Pros:
- No API costs.
- Data stays on device/local network.
- Works offline (if model downloaded).

Cons:
- Complex setup for non-technical users.
- Requires powerful hardware (8GB+ RAM, GPU).
- Lower accuracy than commercial LLMs.
- Platform-specific (desktop only, not mobile).

## Recommended Solution: LLM Vision API (Approach 1)

This approach prioritizes **accuracy** as the primary objective, accepting trade-offs in offline capability and processing speed.

### High-Level Flow

```
User selects PDF/images
    ↓
PDF/Image Processing (Dart)
    - For PDFs: render each page to PNG/JPEG (pdf_image or native rendering)
    - For images: load and optionally resize/compress
    - Convert to base64-encoded string
    ↓
LLM Service (External API)
    - Send image + structured prompt to LLM API
    - Prompt specifies JSON schema for biomarkers + metadata
    - LLM analyzes image and returns structured JSON
    - Handle rate limiting, retries, and errors
    ↓
Dart Extraction Layer
    - Parse JSON response
    - Validate biomarker data (required fields, data types)
    - Normalize biomarker names (reuse existing normalization)
    - Generate Report entity with timestamps and IDs
    - Persist via SaveReport use case
```

### Detailed Design

#### 1. Domain Layer - Repository Pattern

**LLM Extraction Repository Interface** (`lib/domain/repositories/llm_extraction_repository.dart`):

```dart
/// Repository for LLM-based biomarker extraction
/// Abstracts provider-specific implementations
abstract class LlmExtractionRepository {
  /// Extracts biomarkers from a base64-encoded image
  Future<Either<Failure, LlmExtractionResult>> extractFromImage({
    required String base64Image,
    LlmProvider? provider, // Uses configured provider if null
  });

  /// Returns the currently configured LLM provider
  LlmProvider getCurrentProvider();

  /// Cancels ongoing extraction request
  void cancel();
}
```

**Domain Entities** (`lib/domain/entities/llm_extraction.dart`):

```dart
enum LlmProvider {
  claude,    // Anthropic Claude 3.5 Sonnet
  openai,    // OpenAI GPT-4 Vision
  gemini,    // Google Gemini Pro Vision
}

class LlmExtractionResult extends Equatable {
  final List<ExtractedBiomarker> biomarkers;
  final ExtractedMetadata? metadata;
  final double confidence; // 0.0-1.0
  final String? rawResponse;
  final LlmProvider provider;

  const LlmExtractionResult({
    required this.biomarkers,
    this.metadata,
    required this.confidence,
    this.rawResponse,
    required this.provider,
  });

  @override
  List<Object?> get props => [biomarkers, metadata, confidence, rawResponse, provider];
}

class ExtractedBiomarker extends Equatable {
  final String name;
  final String value;
  final String? unit;
  final String? referenceRange;
  final double? confidence;

  const ExtractedBiomarker({
    required this.name,
    required this.value,
    this.unit,
    this.referenceRange,
    this.confidence,
  });

  @override
  List<Object?> get props => [name, value, unit, referenceRange, confidence];
}

class ExtractedMetadata extends Equatable {
  final String? patientName;
  final DateTime? reportDate;
  final DateTime? collectionDate;
  final String? labName;
  final String? labReference;

  const ExtractedMetadata({
    this.patientName,
    this.reportDate,
    this.collectionDate,
    this.labName,
    this.labReference,
  });

  @override
  List<Object?> get props => [patientName, reportDate, collectionDate, labName, labReference];
}

#### 2. Data Layer - Provider Abstraction

**LLM Provider Service Interface** (`lib/data/datasources/external/llm_provider_service.dart`):

```dart
/// Abstract service for specific LLM provider API
abstract class LlmProviderService {
  /// Extracts biomarkers from image using provider's API
  Future<LlmExtractionResult> extractFromImage({
    required String base64Image,
    required String apiKey,
    int timeoutSeconds = 30,
  });

  /// Cancels ongoing request
  void cancel();

  /// Returns the provider type
  LlmProvider get provider;
}
```

**Repository Implementation** (`lib/data/repositories/llm_extraction_repository_impl.dart`):

```dart
class LlmExtractionRepositoryImpl implements LlmExtractionRepository {
  final Map<LlmProvider, LlmProviderService> _providerServices;
  final ConfigRepository _configRepository;

  LlmExtractionRepositoryImpl({
    required ClaudeLlmService claudeService,
    required OpenAiLlmService openAiService,
    required GeminiLlmService geminiService,
    required ConfigRepository configRepository,
  })  : _providerServices = {
          LlmProvider.claude: claudeService,
          LlmProvider.openai: openAiService,
          LlmProvider.gemini: geminiService,
        },
        _configRepository = configRepository;

  @override
  Future<Either<Failure, LlmExtractionResult>> extractFromImage({
    required String base64Image,
    LlmProvider? provider,
  }) async {
    try {
      // Get provider from config if not specified
      final configResult = await _configRepository.getConfig();
      final config = configResult.fold((l) => null, (r) => r);

      final activeProvider = provider ?? config?.llmProvider ?? LlmProvider.claude;
      final apiKey = config?.llmApiKeys[activeProvider];

      if (apiKey == null || apiKey.isEmpty) {
        return Left(ApiKeyMissingFailure(activeProvider));
      }

      final service = _providerServices[activeProvider]!;
      final result = await service.extractFromImage(
        base64Image: base64Image,
        apiKey: apiKey,
      );

      return Right(result);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return Left(RateLimitFailure(DateTime.now().add(Duration(seconds: 60))));
      }
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(OcrFailure('Extraction failed: $e'));
    }
  }

  @override
  LlmProvider getCurrentProvider() {
    final configResult = _configRepository.getConfig();
    return configResult.fold(
      (l) => LlmProvider.claude,
      (r) => r.llmProvider,
    );
  }

  @override
  void cancel() {
    _providerServices.values.forEach((service) => service.cancel());
  }
}
```

**Claude Provider Implementation** (`lib/data/datasources/external/claude_llm_service.dart`):

```dart
class ClaudeLlmService implements LlmProviderService {
  static const _baseUrl = 'https://api.anthropic.com/v1';
  static const _model = 'claude-3-5-sonnet-20241022';

  final Dio _dio;
  CancelToken? _cancelToken;

  ClaudeLlmService(this._dio);

  @override
  LlmProvider get provider => LlmProvider.claude;

  @override
  Future<LlmExtractionResult> extractFromImage({
    required String base64Image,
    required String apiKey,
    int timeoutSeconds = 30,
  }) async {
    _cancelToken = CancelToken();

    final response = await _dio.post(
      '$_baseUrl/messages',
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        sendTimeout: Duration(seconds: timeoutSeconds),
        receiveTimeout: Duration(seconds: timeoutSeconds),
      ),
      data: {
        'model': _model,
        'max_tokens': 4096,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/png',
                  'data': base64Image,
                }
              },
              {
                'type': 'text',
                'text': _getPrompt(),
              }
            ]
          }
        ]
      },
      cancelToken: _cancelToken,
    );

    return _parseResponse(response.data);
  }

  @override
  void cancel() {
    _cancelToken?.cancel();
  }

  String _getPrompt() {
    return '''You are a medical lab report analyzer. Extract biomarker data from the provided blood test report image.

Return ONLY valid JSON in this exact format (no markdown, no explanations):

{
  "confidence": <0.0-1.0>,
  "metadata": {
    "patientName": "<string or null>",
    "reportDate": "<YYYY-MM-DD or null>",
    "collectionDate": "<YYYY-MM-DD or null>",
    "labName": "<string or null>",
    "labReference": "<string or null>"
  },
  "biomarkers": [
    {
      "name": "<biomarker name>",
      "value": "<numeric or qualitative value>",
      "unit": "<unit string or null>",
      "referenceRange": "<range string or null>",
      "confidence": <0.0-1.0>
    }
  ]
}

Rules:
1. Extract ALL biomarkers visible in the report
2. Preserve exact spelling of biomarker names
3. Include units even if they're in column headers
4. Parse reference ranges (e.g., "10-20", "<5", ">100")
5. Set confidence scores based on clarity
6. If a field is unclear or missing, use null
7. For dates, use ISO format (YYYY-MM-DD)
8. For qualitative values (Reactive, Not Detected), include in value field''';
  }

  LlmExtractionResult _parseResponse(Map<String, dynamic> response) {
    // Parse Claude response format
    final content = response['content'] as List;
    final textBlock = content.firstWhere((c) => c['type'] == 'text');
    final jsonString = textBlock['text'] as String;

    // Parse JSON response
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Convert to domain entities
    // Implementation continues...
  }
}
```

#### 3. Structured Prompt Design

The prompt sent to LLMs will follow this template:

```text
You are a medical lab report analyzer. Extract biomarker data from the provided blood test report image.

Return ONLY valid JSON in this exact format (no markdown, no explanations):

{
  "confidence": <0.0-1.0>,
  "metadata": {
    "patientName": "<string or null>",
    "reportDate": "<YYYY-MM-DD or null>",
    "collectionDate": "<YYYY-MM-DD or null>",
    "labName": "<string or null>",
    "labReference": "<string or null>"
  },
  "biomarkers": [
    {
      "name": "<biomarker name>",
      "value": "<numeric or qualitative value>",
      "unit": "<unit string or null>",
      "referenceRange": "<range string or null>",
      "confidence": <0.0-1.0>
    }
  ]
}

Rules:
1. Extract ALL biomarkers visible in the report
2. Preserve exact spelling of biomarker names
3. Include units even if they're in column headers
4. Parse reference ranges (e.g., "10-20", "<5", ">100")
5. Set confidence scores based on clarity
6. If a field is unclear or missing, use null
7. For dates, use ISO format (YYYY-MM-DD)
8. For qualitative values (Reactive, Not Detected), include in value field
```

#### 4. PDF/Image Processing Service

**File**: `lib/data/datasources/external/image_processing_service.dart`

```dart
abstract class ImageProcessingService {
  /// Renders PDF pages to base64-encoded images
  Future<List<String>> pdfToBase64Images(String pdfPath);

  /// Converts image file to base64-encoded string
  Future<String> imageToBase64(String imagePath);

  /// Compresses image to reduce API payload size (target <5MB)
  Future<String> compressImageBase64(String base64, {int maxSize = 5 * 1024 * 1024});
}
```

Implementation will use:
- `pdf_image` package for PDF rendering (pure Dart, cross-platform)
- `image` package for compression and format conversion

#### 5. Updated ExtractReportFromFile Use Case

```dart
class ExtractReportFromFile {
  final LlmExtractionService llmService;
  final ImageProcessingService imageService;
  final NormalizeBiomarkerName normalizeBiomarker;

  Future<Either<Failure, Report>> call({
    required String filePath,
    required FileType fileType,
    required LlmProvider provider,
    String? apiKey,
  }) async {
    try {
      // 1. Convert file to base64 images
      final images = fileType == FileType.pdf
          ? await imageService.pdfToBase64Images(filePath)
          : [await imageService.imageToBase64(filePath)];

      // 2. Extract from each page
      final allBiomarkers = <Biomarker>[];
      ExtractedMetadata? metadata;

      for (final (index, image) in images.indexed) {
        final result = await llmService.extractFromImage(
          base64Image: image,
          provider: provider,
          apiKey: apiKey,
          timeoutSeconds: 30,
        );

        // Use metadata from first page
        metadata ??= result.metadata;

        // Normalize and convert to domain entities
        for (final extracted in result.biomarkers) {
          final normalized = normalizeBiomarker(extracted.name);
          allBiomarkers.add(Biomarker(
            id: Uuid().v4(),
            name: normalized,
            value: _parseValue(extracted.value),
            unit: extracted.unit,
            referenceRange: _parseReferenceRange(extracted.referenceRange),
            measuredAt: metadata?.collectionDate ?? DateTime.now(),
          ));
        }
      }

      // 3. Build Report entity
      final report = Report(
        id: Uuid().v4(),
        patientName: metadata?.patientName ?? '',
        reportDate: metadata?.reportDate ?? DateTime.now(),
        labName: metadata?.labName,
        biomarkers: allBiomarkers,
      );

      return Right(report);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(OcrFailure(e.toString()));
    }
  }
}
```

#### 6. Settings Management

Update existing `AppSettings` entity to include LLM configuration:

```dart
class AppSettings extends Equatable {
  final LlmProvider preferredProvider;
  final Map<LlmProvider, String?> apiKeys;  // Stored securely
  final bool autoExtractOnUpload;
  final int extractionTimeoutSeconds;

  // ... existing fields
}
```

**Security**: Use `flutter_secure_storage` to store API keys securely (encrypted keychain on iOS, EncryptedSharedPreferences on Android).

#### 7. Data Flow Summary

1. **User action**: Selects PDF or images + configures LLM provider in Settings
2. **Upload Page**: Calls `ExtractReportFromFile` use case
3. **Use Case**:
   - Renders PDF pages to base64 images
   - Sends each image to LLM API with structured prompt
   - Parses JSON responses
   - Normalizes biomarker names
   - Aggregates into Report entity
4. **Persistence**: SaveReport stores in Hive
5. **UI**: Navigate to Review page to show extracted data

#### 8. Error Handling

New failure types:
```dart
class NetworkFailure extends Failure {
  NetworkFailure(String message);
}

class ApiKeyMissingFailure extends Failure {
  ApiKeyMissingFailure(LlmProvider provider);
}

class RateLimitFailure extends Failure {
  final DateTime retryAfter;
  RateLimitFailure(this.retryAfter);
}

class InvalidResponseFailure extends Failure {
  InvalidResponseFailure(String message);
}
```

#### 9. UX Considerations

- **Settings Page**: Add API key configuration UI with provider selection
- **Privacy Notice**: Show disclaimer about data being sent to third parties
- **Progress Indicator**: Show "Analyzing page X/Y..." during extraction
- **Offline Handling**: Display clear message if no internet connection
- **Retry Logic**: Auto-retry on transient failures with exponential backoff
- **Review Page**: Allow manual correction of extracted biomarkers

### Testing Strategy

1. **Unit Tests (TDD)**
   - Mock `LlmExtractionService` to return predefined JSON responses
   - Test `ExtractReportFromFile` with various LLM responses (success, errors, malformed JSON)
   - Test biomarker normalization and entity construction
   - Test error handling for network failures, API key missing, rate limits
   - Target: 90%+ coverage

2. **Integration Tests**
   - Use real sample lab report images with known biomarker values
   - Verify end-to-end extraction accuracy (compare extracted vs expected)
   - Test multi-page PDF extraction
   - Test different LLM providers (Claude, OpenAI, Gemini)
   - Measure API response times and success rates

3. **Widget Tests**
   - Settings page: API key input, provider selection
   - Upload page: Progress indicators, error messages
   - Review page: Extracted biomarker display and editing

4. **Manual QA**
   - Test with real lab reports from different labs and formats
   - Verify accuracy across diverse report layouts
   - Test offline behavior and error messaging
   - Validate secure storage of API keys

### API Cost Estimation

Per-page costs (approximate, as of 2025):
- **Claude 3.5 Sonnet**: ~$0.01-0.02 per image (depending on size)
- **GPT-4 Vision**: ~$0.01-0.03 per image
- **Gemini Pro Vision**: ~$0.005-0.01 per image

Example: 10-page PDF report:
- Claude: $0.10-0.20
- GPT-4V: $0.10-0.30
- Gemini: $0.05-0.10

User provides their own API keys, so no cost to app developer.

## Next Steps

### Phase 1: LLM Integration (Remove ML Kit)

1. **Remove ML Kit infrastructure** (Current task)
   - Delete native scanning code (iOS/Android)
   - Remove ML Kit Dart services
   - Remove metadata extraction (embeddings, NER)
   - Clean up settings infrastructure for extraction modes
   - Remove unused dependencies

2. **Implement LLM services** (TDD)
   - Define domain interfaces (`LlmExtractionService`)
   - Implement Claude API client
   - Implement OpenAI API client
   - Implement Gemini API client
   - Add JSON response parsing and validation
   - Test error handling and retries

3. **Implement image processing**
   - Add `pdf_image` package for PDF rendering
   - Implement base64 encoding
   - Add image compression logic
   - Test with various PDF formats

4. **Update use cases**
   - Refactor `ExtractReportFromFile` to use LLM service
   - Remove OCR-based extraction logic
   - Add LLM provider configuration
   - Update tests

5. **Settings & Security**
   - Add `flutter_secure_storage` dependency
   - Implement secure API key storage
   - Update AppSettings entity
   - Build Settings UI for API keys
   - Add privacy notice/consent

6. **UI Updates**
   - Update Upload page progress indicators
   - Add network error handling
   - Add API key setup prompts
   - Update Review page as needed

### Phase 2: Accuracy Validation

1. **Create test corpus**
   - Collect 100+ diverse lab reports
   - Annotate ground truth biomarker values
   - Cover different formats, labs, languages

2. **Benchmark accuracy**
   - Run extraction on test corpus
   - Measure precision, recall, F1 score
   - Compare providers (Claude vs GPT-4V vs Gemini)
   - Identify failure patterns

3. **Prompt optimization**
   - Iterate on system prompts based on errors
   - Add few-shot examples for edge cases
   - Test structured output modes (JSON schema)

### Phase 3: Production Hardening

1. **Performance optimization**
   - Implement request batching where possible
   - Add caching for repeated extractions
   - Optimize image compression

2. **Reliability**
   - Add exponential backoff for retries
   - Implement circuit breaker pattern
   - Add request queueing

3. **Monitoring**
   - Track extraction success rates
   - Monitor API costs per user
   - Log failure reasons for analysis

## Migration Impact Summary

**Removed Components** (to be deleted):
- Native iOS code: `AppDelegate.swift` (480+ lines)
- Native Android code: `MainActivity.kt` (334+ lines)
- ReportScanService and implementations
- MetadataEmbeddingMatcher
- NerMetadataExtractor and helper
- ModelDownloadManager
- Settings infrastructure (extraction mode)
- 200+ test files for removed components

**New Dependencies**:
```yaml
dependencies:
  flutter_secure_storage: ^9.2.2  # API key storage
  pdf_image: ^2.1.3                # PDF rendering (replaces pdf_render)

# Remove:
  google_mlkit_text_recognition  # No longer needed
  google_mlkit_commons           # No longer needed
  pdf_render                     # Replaced by pdf_image
  tflite_flutter                 # No longer needed
```

**Benefits**:
- ✅ Accuracy: 88-93% → 95%+ target
- ✅ Simpler codebase: Remove 1000+ lines of native/parsing code
- ✅ Lower maintenance: No regex patterns to update
- ✅ Format flexibility: Handles any report layout

**Trade-offs**:
- ❌ Requires internet connection
- ❌ API costs (user-provided keys)
- ❌ Data sent to third parties
- ❌ Slower (5-15s vs 1-2s per page)

---

## Architecture Change History

### 2025-10-18: Migration to LLM-Based Extraction

**Rationale**: Local ML Kit approach achieved 88-93% accuracy with significant complexity (native code, embeddings, NER models). Pivoting to cloud LLM APIs (Claude, GPT-4V, Gemini) for:
- Higher accuracy target (95%+)
- Simpler codebase (remove 1000+ lines of native/parsing code)
- Better handling of diverse report formats
- Lower maintenance burden

**Previous Implementation** (DEPRECATED):
- Native iOS/Android bridge with ML Kit OCR
- Pattern-based biomarker extraction
- Metadata embeddings (7KB asset)
- Optional NER model (66MB download)
- Settings UI for extraction modes

All previous local extraction code will be removed in favor of the LLM-based approach documented above.
