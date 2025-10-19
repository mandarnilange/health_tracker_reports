# Phase 5: Doctor PDF & CSV Export - Task List

**Phase Goal:** Enable users to generate professional 2-4 page Doctor Summary PDFs with integrated biomarker/vitals trends and export data to CSV (3 denormalized files).

**Scope:** Doctor PDF generation + CSV export only. Google Drive backup, import/restore deferred to future phase.

**Status:** In Progress

**Start Date:** 2026-01-15

**Completion Date:** TBD

---

## Product Vision

Provide healthcare professionals with comprehensive, print-ready PDF reports that integrate lab biomarker trends and daily vital sign monitoring. Enable data export to CSV for external analysis in spreadsheet applications.

---

## Feature 1: CSV Export (3 Files - TDD)

### Overview

Export user data to 3 separate CSV files with simple denormalized structure:
1. **reports_biomarkers.csv** - One row per biomarker measurement (report info repeated)
2. **health_logs_vitals.csv** - One row per vital measurement (log info repeated)
3. **trends_statistics.csv** - Pre-calculated trends for both biomarkers and vitals

**CSV Format Specifications:**
- Encoding: UTF-8 with BOM
- Line endings: CRLF (Windows-compatible)
- Date format: ISO 8601 (YYYY-MM-DD HH:MM:SS)
- Decimals: 2 decimal places for numeric values
- Null handling: Empty string for optional fields
- Compatible with: Excel, Google Sheets, LibreOffice Calc

### Tasks

#### 1.1 ExportReportsToCsv UseCase
- [ ] **TEST:** Export single report with multiple biomarkers to CSV rows
- [ ] **CODE:** Create ExportReportsToCsv usecase
- [ ] **TEST:** Export multiple reports (denormalized - biomarker rows)
- [ ] **CODE:** Implement denormalized CSV generation
- [ ] **TEST:** Handle special characters (commas, quotes, newlines in notes/lab names)
- [ ] **CODE:** Properly escape special characters per CSV spec
- [ ] **TEST:** Date formatting (ISO 8601)
- [ ] **CODE:** Format all dates consistently
- [ ] **TEST:** Empty reports list handling
- [ ] **CODE:** Handle case with no reports (return empty CSV with headers)
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ExportReportsToCsv usecase`
- [ ] **COMMIT:** `feat: implement reports CSV export usecase`

**Output Structure (reports_biomarkers.csv):**
```
report_id,report_date,lab_name,biomarker_id,biomarker_name,value,unit,ref_min,ref_max,status,notes,file_path,created_at,updated_at
rpt_001,2026-01-10,Quest,bio_123,Glucose,112.0,mg/dL,70.0,100.0,HIGH,,/files/report.pdf,2026-01-10 14:23:00,2026-01-10 14:23:00
```

**Location:** `lib/domain/usecases/export_reports_to_csv.dart`
**Test Location:** `test/unit/domain/usecases/export_reports_to_csv_test.dart`

---

#### 1.2 ExportVitalsToCsv UseCase
- [ ] **TEST:** Export health logs with vitals (denormalized)
- [ ] **CODE:** Create ExportVitalsToCsv usecase
- [ ] **TEST:** Handle multiple vitals per log entry
- [ ] **CODE:** Generate one CSV row per vital measurement
- [ ] **TEST:** Empty health logs handling
- [ ] **CODE:** Handle case with no logs (return empty CSV with headers)
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ExportVitalsToCsv usecase`
- [ ] **COMMIT:** `feat: implement vitals CSV export usecase`

**Output Structure (health_logs_vitals.csv):**
```
log_id,log_timestamp,vital_id,vital_type,value,unit,ref_min,ref_max,status,notes,created_at,updated_at
log_001,2026-01-15 07:30:00,vit_101,BP Systolic,125.0,mmHg,90.0,120.0,BORDERLINE,Morning reading,2026-01-15 07:32:00,2026-01-15 07:32:00
```

**Location:** `lib/domain/usecases/export_vitals_to_csv.dart`
**Test Location:** `test/unit/domain/usecases/export_vitals_to_csv_test.dart`

---

#### 1.3 ExportTrendsToCsv UseCase
- [ ] **TEST:** Calculate and export biomarker trend statistics
- [ ] **CODE:** Create ExportTrendsToCsv usecase
- [ ] **TEST:** Calculate and export vital trend statistics
- [ ] **CODE:** Compute trends for vitals
- [ ] **TEST:** Trend direction calculation (increasing/decreasing/stable)
- [ ] **CODE:** Implement trend direction algorithm
- [ ] **TEST:** Statistics calculation (avg, min, max, std dev, % change)
- [ ] **CODE:** Implement statistical calculations
- [ ] **TEST:** Handle metrics with single data point (no trend possible)
- [ ] **CODE:** Return "N/A" for trend when insufficient data
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ExportTrendsToCsv usecase`
- [ ] **COMMIT:** `feat: implement trends CSV export usecase`

**Output Structure (trends_statistics.csv):**
```
metric_type,metric_name,period_start,period_end,num_readings,avg_value,min_value,max_value,std_dev,trend_direction,trend_slope,first_value,last_value,pct_change,out_of_range_count,unit
biomarker,Glucose,2025-10-01,2026-01-10,3,101.67,93.0,112.0,9.71,INCREASING,9.5,93.0,112.0,20.43,1,mg/dL
```

**Location:** `lib/domain/usecases/export_trends_to_csv.dart`
**Test Location:** `test/unit/domain/usecases/export_trends_to_csv_test.dart`

---

#### 1.4 CsvExportService (Data Layer)
- [ ] **TEST:** Convert Report entities to CSV string
- [ ] **CODE:** Create CsvExportService
- [ ] **TEST:** Convert HealthLog entities to CSV string
- [ ] **CODE:** Implement vitals CSV generation
- [ ] **TEST:** Convert trend statistics to CSV string
- [ ] **CODE:** Implement trends CSV generation
- [ ] **TEST:** Escape special characters (quotes, commas, newlines)
- [ ] **CODE:** Properly escape per CSV RFC 4180
- [ ] **TEST:** Generate CSV headers
- [ ] **CODE:** Add headers to all CSV outputs
- [ ] **TEST:** Handle null/optional fields (convert to empty string)
- [ ] **CODE:** Implement null handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for CsvExportService`
- [ ] **COMMIT:** `feat: implement CSV export service`

**Location:** `lib/data/datasources/external/csv_export_service.dart`
**Register DI:** `@lazySingleton`

---

#### 1.5 FileWriterService
- [ ] **TEST:** Write file to downloads folder (iOS/Android/Web)
- [ ] **CODE:** Create FileWriterService using path_provider
- [ ] **TEST:** Generate unique filename with timestamp
- [ ] **CODE:** Implement filename generation: `reports_biomarkers_2026-01-15.csv`
- [ ] **TEST:** Handle file permission errors
- [ ] **CODE:** Catch and return appropriate Failure
- [ ] **TEST:** Handle storage full errors
- [ ] **CODE:** Catch and return StorageFailure
- [ ] **TEST:** Return file path on success
- [ ] **CODE:** Return absolute path for sharing/display
- [ ] **VERIFY:** Test on iOS, Android, Web
- [ ] **COMMIT:** `test: add tests for FileWriterService`
- [ ] **COMMIT:** `feat: implement file writing service`

**Location:** `lib/data/datasources/external/file_writer_service.dart`
**Register DI:** `@lazySingleton`

---

#### 1.6 Export UI & Provider
- [ ] **TEST:** ExportProvider initial state is idle
- [ ] **CODE:** Create ExportProvider (StateNotifier)
- [ ] **TEST:** Export single CSV - loading → success with file path
- [ ] **CODE:** Implement single CSV export method
- [ ] **TEST:** Export all 3 CSVs - track progress (1/3, 2/3, 3/3)
- [ ] **CODE:** Implement multi-file export with progress
- [ ] **TEST:** Export failure - show error state with message
- [ ] **CODE:** Handle failures and update state
- [ ] **COMMIT:** `test: add tests for ExportProvider`
- [ ] **COMMIT:** `feat: implement export state management`

**Location:** `lib/presentation/providers/export_provider.dart`

- [ ] **TEST (widget):** ExportPage renders with 4 export buttons
- [ ] **CODE:** Create ExportPage
- [ ] **TEST:** "Export All CSVs" button triggers 3 exports
- [ ] **CODE:** Implement "Export All" functionality
- [ ] **TEST:** Individual export buttons (reports, vitals, trends)
- [ ] **CODE:** Implement individual export buttons
- [ ] **TEST:** Show progress indicator during export (with percentage)
- [ ] **CODE:** Display CircularProgressIndicator with progress text
- [ ] **TEST:** Show success snackbar with file paths
- [ ] **CODE:** Display SnackBar with "Saved to: /path/to/file.csv"
- [ ] **TEST:** Show error snackbar on failure
- [ ] **CODE:** Display error message from Failure
- [ ] **COMMIT:** `test: add ExportPage widget tests`
- [ ] **COMMIT:** `feat: implement export page UI`

**Location:** `lib/presentation/pages/export/export_page.dart`

---

## Feature 2: Doctor Summary PDF Generation (TDD)

### Overview

Generate professional 2-4 page PDF reports for healthcare providers with:
- **Page 1:** Executive summary with critical findings and health status dashboard
- **Page 2:** Lab biomarker trends with comparison tables and embedded line charts
- **Page 3:** Daily vitals summary with charts (BP dual-line, glucose correlation)
- **Page 4 (optional):** Full data reference table with all biomarkers

**PDF Specifications:**
- Page size: A4 (210 × 297 mm)
- Margins: 20mm all sides
- Font: Helvetica (built-in), 10-12pt body, 14-16pt headings
- Colors: Print-optimized (red #D32F2F, orange #F57C00, green #388E3C)
- Charts: Embedded PNG images, 300 DPI
- File naming: `health_summary_YYYY-MM-DD.pdf`

**PDF Template:** See discussion for full markdown template with all sections

### Tasks

#### 2.1 Domain Entities

**DoctorSummaryConfig Entity:**
- [ ] **TEST:** Create entity with date range and options
- [ ] **CODE:** Implement DoctorSummaryConfig
- [ ] **TEST:** Test equality and copyWith
- [ ] **CODE:** Add Equatable implementation
- [ ] **COMMIT:** `test: add DoctorSummaryConfig entity tests`
- [ ] **COMMIT:** `feat: add DoctorSummaryConfig entity`

```dart
class DoctorSummaryConfig extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final List<String> selectedReportIds; // empty = all in range
  final bool includeVitals; // default: true
  final bool includeFullDataTable; // default: false, Page 4
}
```

**Location:** `lib/domain/entities/doctor_summary_config.dart`

---

**SummaryStatistics Entity:**
- [ ] **TEST:** Create entity with biomarker and vital trends
- [ ] **CODE:** Implement SummaryStatistics
- [ ] **TEST:** Test nested objects (CriticalFinding, HealthStatusDashboard)
- [ ] **CODE:** Add nested entity classes
- [ ] **COMMIT:** `test: add SummaryStatistics entity tests`
- [ ] **COMMIT:** `feat: add SummaryStatistics entity`

```dart
class SummaryStatistics extends Equatable {
  final List<BiomarkerTrendSummary> biomarkerTrends;
  final List<VitalTrendSummary> vitalTrends;
  final List<CriticalFinding> criticalFindings;
  final HealthStatusDashboard dashboard;
  final int totalReports;
  final int totalHealthLogs;
}

class CriticalFinding extends Equatable {
  final int priority; // 1, 2, 3
  final String category; // "Glucose Control"
  final String finding; // "Fasting: 112 mg/dL (↑12% vs 3mo)"
  final String actionNeeded;
}

class HealthStatusDashboard extends Equatable {
  final DashboardCategory glucoseControl;
  final DashboardCategory lipidPanel;
  final DashboardCategory kidneyFunction;
  final DashboardCategory bloodPressure;
  final DashboardCategory cardiovascular;
}

class DashboardCategory extends Equatable {
  final String status; // "Normal", "Borderline", "High"
  final String trend; // "Improving", "Stable", "Worsening"
  final String latestValue;
}
```

**Location:** `lib/domain/entities/summary_statistics.dart`

---

#### 2.2 Use Cases

**CalculateSummaryStatistics UseCase:**
- [ ] **TEST:** Fetch reports in date range
- [ ] **CODE:** Create CalculateSummaryStatistics usecase
- [ ] **TEST:** Fetch health logs in date range
- [ ] **CODE:** Fetch logs from HealthLogRepository
- [ ] **TEST:** Identify critical findings (top 3 out-of-range biomarkers/vitals)
- [ ] **CODE:** Implement critical findings algorithm
- [ ] **TEST:** Determine trend directions for each biomarker
- [ ] **CODE:** Use existing GetBiomarkerTrend and CalculateTrend
- [ ] **TEST:** Determine trend directions for each vital
- [ ] **CODE:** Use existing GetVitalTrend
- [ ] **TEST:** Build health status dashboard (5 categories)
- [ ] **CODE:** Categorize biomarkers into health systems
- [ ] **TEST:** Calculate correlation (e.g., glucose lab vs daily glucose)
- [ ] **CODE:** Implement correlation analysis
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add CalculateSummaryStatistics tests`
- [ ] **COMMIT:** `feat: implement summary statistics calculation`

**Dependencies:**
- `ReportRepository.getReportsByDateRange()`
- `HealthLogRepository.getHealthLogsByDateRange()` (Phase 6)
- `GetBiomarkerTrend` (existing)
- `GetVitalTrend` (Phase 6)
- `CalculateTrend` (existing)

**Location:** `lib/domain/usecases/calculate_summary_statistics.dart`

---

**GenerateDoctorPdf UseCase:**
- [ ] **TEST:** Generate PDF with valid config
- [ ] **CODE:** Create GenerateDoctorPdf usecase
- [ ] **TEST:** Validate config (start date before end date)
- [ ] **CODE:** Add config validation
- [ ] **TEST:** Return error when no reports in date range
- [ ] **CODE:** Return ValidationFailure
- [ ] **TEST:** Generate PDF with vitals included
- [ ] **CODE:** Call CalculateSummaryStatistics, then PdfGeneratorService
- [ ] **TEST:** Generate PDF without vitals
- [ ] **CODE:** Pass includeVitals flag to service
- [ ] **TEST:** Generate PDF with optional full data table
- [ ] **CODE:** Pass includeFullDataTable flag to service
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add GenerateDoctorPdf usecase tests`
- [ ] **COMMIT:** `feat: implement doctor PDF generation usecase`

**Location:** `lib/domain/usecases/generate_doctor_pdf.dart`

---

**Add Date Range Query to ReportRepository:**
- [ ] **TEST:** Add getReportsByDateRange() method test
- [ ] **CODE:** Add method to ReportRepository interface
- [ ] **TEST:** Implement in ReportRepositoryImpl
- [ ] **CODE:** Filter reports by date range from Hive
- [ ] **COMMIT:** `test: add date range query to ReportRepository`
- [ ] **COMMIT:** `feat: add getReportsByDateRange to ReportRepository`

**Note:** HealthLogRepository already has this method from Phase 6

---

#### 2.3 Chart Rendering Service

**ChartRenderingService:**
- [ ] **TEST:** Render biomarker line chart (single line)
- [ ] **CODE:** Create ChartRenderingService
- [ ] **TEST:** Render dual-line chart for BP (systolic + diastolic)
- [ ] **CODE:** Implement dual-line rendering using fl_chart
- [ ] **TEST:** Add reference range bands (shaded green area)
- [ ] **CODE:** Add background shading for reference ranges
- [ ] **TEST:** Add trend annotations (arrows, percentages)
- [ ] **CODE:** Overlay trend indicators
- [ ] **TEST:** Color-code data points by status (red/orange/green)
- [ ] **CODE:** Apply status colors to chart dots
- [ ] **TEST:** Export chart as PNG (300 DPI)
- [ ] **CODE:** Capture widget as image, convert to PNG bytes
- [ ] **VERIFY:** Generated PNGs are print-quality
- [ ] **COMMIT:** `test: add ChartRenderingService tests`
- [ ] **COMMIT:** `feat: implement chart rendering service`

**Technical Approach:**
- Wrap fl_chart LineChart in RepaintBoundary
- Use RenderRepaintBoundary.toImage(pixelRatio: 3.0) for 300 DPI
- Convert to PNG bytes with ui.Image.toByteData()
- Return Uint8List for PDF embedding

**Location:** `lib/data/datasources/external/chart_rendering_service.dart`
**Register DI:** `@lazySingleton`

---

#### 2.4 PDF Generator Service

**Page 1 - Executive Summary:**
- [ ] **TEST:** Generate page 1 with critical priorities table (3 rows)
- [ ] **CODE:** Implement _buildExecutiveSummaryPage()
- [ ] **TEST:** Generate health status dashboard (5 categories)
- [ ] **CODE:** Build dashboard table with emoji status indicators
- [ ] **TEST:** Handle 0, 1, 2, 3+ critical findings
- [ ] **CODE:** Dynamically size priorities table
- [ ] **COMMIT:** `test: add PDF page 1 generation tests`
- [ ] **COMMIT:** `feat: implement PDF executive summary page`

---

**Page 2 - Lab Biomarker Trends:**
- [ ] **TEST:** Generate out-of-range biomarkers section with charts
- [ ] **CODE:** Implement _buildBiomarkerTrendsPage()
- [ ] **TEST:** Embed line chart images (from ChartRenderingService)
- [ ] **CODE:** Use pw.Image(MemoryImage(chartPngBytes))
- [ ] **TEST:** Highlight out-of-range values (red color, bold)
- [ ] **CODE:** Apply PdfColor.fromInt(0xFFD32F2F) to cells
- [ ] **TEST:** Add trend indicators (↑↓→ symbols with percentages)
- [ ] **CODE:** Insert Unicode arrows and calculated percentages
- [ ] **TEST:** Generate borderline/normal biomarkers table
- [ ] **CODE:** Add condensed table for remaining biomarkers
- [ ] **COMMIT:** `test: add PDF page 2 generation tests`
- [ ] **COMMIT:** `feat: implement PDF biomarker trends page`

---

**Page 3 - Vitals Summary:**
- [ ] **TEST:** Generate BP chart (dual-line with reference bands)
- [ ] **CODE:** Implement _buildVitalsSummaryPage()
- [ ] **TEST:** Generate glucose correlation chart (scatter + lab overlay)
- [ ] **CODE:** Render correlation chart
- [ ] **TEST:** Add vitals statistics table (HR, SpO2, weight, sleep)
- [ ] **CODE:** Build condensed vitals table
- [ ] **TEST:** Skip page if includeVitals = false
- [ ] **CODE:** Conditionally generate page
- [ ] **COMMIT:** `test: add PDF page 3 generation tests`
- [ ] **COMMIT:** `feat: implement PDF vitals summary page`

---

**Page 4 - Full Data Table (Optional):**
- [ ] **TEST:** Generate complete biomarkers table (all 23+ biomarkers)
- [ ] **CODE:** Implement _buildFullDataTablePage()
- [ ] **TEST:** Skip page if includeFullDataTable = false
- [ ] **CODE:** Conditionally generate page
- [ ] **COMMIT:** `test: add PDF page 4 generation tests`
- [ ] **COMMIT:** `feat: implement PDF full data table page`

---

**Main PDF Orchestration:**
- [ ] **TEST:** Generate complete 2-page PDF (no vitals, no full table)
- [ ] **CODE:** Implement main generatePdf() method
- [ ] **TEST:** Generate complete 3-page PDF (with vitals, no full table)
- [ ] **CODE:** Conditionally add pages based on config
- [ ] **TEST:** Generate complete 4-page PDF (with vitals and full table)
- [ ] **CODE:** Add all optional pages
- [ ] **TEST:** Apply print-optimized styling (fonts, colors, spacing)
- [ ] **CODE:** Use Helvetica font, proper spacing
- [ ] **TEST:** Add headers/footers with page numbers
- [ ] **CODE:** Add "Health Summary Report | Page X of Y"
- [ ] **TEST:** Verify page breaks (no orphaned content)
- [ ] **CODE:** Use pw.MultiPage with proper breaks
- [ ] **VERIFY:** Generate sample PDF from fixture data, manual review
- [ ] **COMMIT:** `test: add complete PDF generation tests`
- [ ] **COMMIT:** `feat: implement complete PDF generation service`

**Location:** `lib/data/datasources/external/pdf_generator_service.dart`
**Register DI:** `@lazySingleton`

---

#### 2.5 Doctor PDF Config Page UI

**DoctorPdfConfigPage:**
- [ ] **TEST (widget):** Render date range pickers (start & end)
- [ ] **CODE:** Create DoctorPdfConfigPage
- [ ] **TEST:** Render report multi-select checkboxes (with biomarker counts)
- [ ] **CODE:** Display reports with "Quest - Jan 10 (23 biomarkers)" format
- [ ] **TEST:** Render "Include Vitals" toggle switch
- [ ] **CODE:** Add SwitchListTile for vitals option
- [ ] **TEST:** Render "Include Full Data Table" toggle switch
- [ ] **CODE:** Add SwitchListTile for full table option
- [ ] **TEST:** Preview shows summary ("3 reports, 42 logs, 69 biomarkers")
- [ ] **CODE:** Calculate and display preview stats
- [ ] **TEST:** Generate button enabled only when ≥1 report selected
- [ ] **CODE:** Disable button when no reports selected
- [ ] **TEST:** Generate button triggers PDF creation
- [ ] **CODE:** Call GenerateDoctorPdf usecase via provider
- [ ] **TEST:** Show progress indicator during generation
- [ ] **CODE:** Display CircularProgressIndicator with status text
- [ ] **TEST:** Show success with file path
- [ ] **CODE:** Display SnackBar with "PDF saved to: /path/to/file.pdf"
- [ ] **TEST:** Show error on failure
- [ ] **CODE:** Display error message from Failure
- [ ] **COMMIT:** `test: add DoctorPdfConfigPage widget tests`
- [ ] **COMMIT:** `feat: implement doctor PDF config page`

**Location:** `lib/presentation/pages/export/doctor_pdf_config_page.dart`

---

## Feature 3: Native Sharing (TDD)

### Tasks

#### 3.1 ShareService
- [ ] **TEST:** Share PDF file via native sheet
- [ ] **CODE:** Create ShareService using share_plus
- [ ] **TEST:** Share CSV file via native sheet
- [ ] **CODE:** Use ShareService.shareXFiles() with XFile
- [ ] **TEST:** Handle share cancellation (user dismisses)
- [ ] **CODE:** No error on cancellation
- [ ] **TEST:** Platform-specific behavior (iOS shows sheet, Android shows chooser)
- [ ] **CODE:** Let share_plus handle platform differences
- [ ] **COMMIT:** `test: add ShareService tests`
- [ ] **COMMIT:** `feat: implement native sharing service`

**Location:** `lib/data/datasources/external/share_service.dart`
**Register DI:** `@lazySingleton`

---

#### 3.2 Share Button UI Integration
- [ ] **TEST:** Add "Share" button to ExportPage (after successful CSV export)
- [ ] **CODE:** Show IconButton(Icons.share) next to exported file path
- [ ] **TEST:** Add "Generate & Share" button to DoctorPdfConfigPage
- [ ] **CODE:** Add secondary button that generates PDF and immediately shares
- [ ] **TEST:** Share triggers native share sheet
- [ ] **CODE:** Call ShareService.sharePdf() or shareCsv()
- [ ] **COMMIT:** `test: add share button widget tests`
- [ ] **COMMIT:** `feat: add share buttons to export UI`

---

## Feature 4: Navigation & Routes

### Tasks

#### 4.1 Update App Router
- [ ] **CODE:** Add `/export` route → ExportPage
- [ ] **CODE:** Add `/export/doctor-pdf-config` route → DoctorPdfConfigPage
- [ ] **CODE:** Add navigation from HomePage (AppBar action or FAB menu)
- [ ] **CODE:** Add navigation from Settings (Export section)
- [ ] **TEST:** Test navigation flows
- [ ] **COMMIT:** `feat: add export routes to app router`

**Location:** `lib/presentation/router/app_router.dart`

---

## Phase 5 Completion Checklist

### Functional Requirements
- [ ] User can navigate to Export page
- [ ] User can export reports_biomarkers.csv
- [ ] User can export health_logs_vitals.csv
- [ ] User can export trends_statistics.csv
- [ ] User can export all 3 CSVs with one button
- [ ] CSV files open correctly in Excel/Google Sheets
- [ ] User can select date range for Doctor PDF
- [ ] User can select which reports to include
- [ ] User can toggle "Include Vitals" option
- [ ] User can toggle "Include Full Data Table" option
- [ ] PDF generates in 2-4 pages as expected
- [ ] PDF includes all required sections per template
- [ ] PDF charts are embedded and readable
- [ ] PDF highlights out-of-range values
- [ ] PDF includes trend indicators (↑↓→)
- [ ] PDF is print-optimized (readable in grayscale)
- [ ] User can share PDF via native share sheet
- [ ] User can share CSV via native share sheet
- [ ] Files saved to downloads folder
- [ ] Success messages show file paths
- [ ] Error messages are actionable
- [ ] Works on iOS and Android

### Technical Requirements
- [ ] 90%+ test coverage for Phase 5 code
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] Clean architecture maintained
- [ ] TDD approach followed (tests before code)
- [ ] Dependency injection configured
- [ ] Conventional commits used

### Documentation
- [ ] spec/phase-5-export-sharing-tasks.md updated (this file)
- [ ] spec/overall-plan.md updated with Phase 5 status
- [ ] AGENTS.md includes CSV/PDF examples
- [ ] CHANGELOG.md includes all Phase 5 commits

---

## Status Summary

**Scope:** Doctor PDF + CSV Export (3 files)
**Deferred:** Google Drive backup, CSV import/restore

**Total Tasks:** ~40
**Completed:** 0
**In Progress:** 2 (Documentation updates)
**Blocked:** 0

**Test Coverage:** 0% (Phase 5 code)

**Last Updated:** 2026-01-15

---

## Notes

### PDF Template Reference
See detailed markdown template in project discussion with:
- Executive summary structure
- Critical findings table format
- Biomarker trends layout with charts
- Vitals summary design
- Correlation analysis examples

### CSV Structure Reference
See CSV format specifications in Feature 1 with:
- Column definitions for each file
- Denormalized structure examples
- Special character escaping rules
- Null handling strategy

### Dependencies (Already Available)
- `pdf: ^3.11.1` - PDF generation
- `printing: ^5.14.1` - PDF utilities
- `fl_chart: ^1.1.1` - Chart rendering
- `share_plus: ^12.0.0` - Native sharing
- `path_provider: ^2.1.5` - File system paths

No new dependencies required!

### Performance Targets
- CSV export (all 3 files): <5 seconds for 50 reports + 100 logs
- PDF generation: <10 seconds for 50 reports + 100 logs
- Chart rendering: <2 seconds per chart

### Future Enhancements (Post-Phase 5)
- Google Drive backup and restore
- CSV import functionality
- PDF template customization (logo, colors)
- Additional export formats (JSON, XML)
- Scheduled automated exports
- Encrypted export files
