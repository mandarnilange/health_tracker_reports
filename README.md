# Health Tracker Reports

A privacy-focused Flutter application for tracking your personal health data. All data is stored locally on your device and the app works completely offline.

Upload blood reports (PDF/images) for automatic biomarker extraction, log daily vitals (e.g., heart rate, blood pressure), and monitor trends over time. Export your raw data or generate shareable summaries for your healthcare providers.

## Usage Guidelines

This guide explains how to use the app from a user's perspective.

### 1. Upload a Report
- Tap the '+' or 'Upload' button on the main screen.
- Select a PDF or image file of your blood test report from your device.

### 2. Review and Confirm Data
- The app will automatically scan the report using OCR to extract biomarkers.
- A review screen will appear with the extracted data.
- Verify the accuracy of the names, values, and units. You can tap on any field to make corrections.
- Once confirmed, save the report.

### 3. Log Daily Vitals
- Navigate to the 'Vitals' or 'Log' section.
- Select the vital you want to record (e.g., Blood Pressure, Heart Rate, Weight).
- Enter the value and save.

### 4. View Trends
- Go to the 'Trends' or 'Dashboard' section.
- Select a biomarker or vital to see a chart of its values over time.
- This helps you and your doctor spot patterns and track your progress.

### 5. Export and Share
- From the 'Export' or 'Share' menu, you can:
  - **Generate a Summary PDF:** Create a clean, professional summary for your healthcare provider, showing trends and out-of-range values.
  - **Export Raw Data:** Get a complete export of your data in a raw format (like CSV or JSON) for your personal records or for use in other applications.

## Configuration

### Setting up the Gemini API Key (Optional)

The app uses on-device OCR by default, which is free and private. For more advanced biomarker extraction, you can optionally use the Gemini AI model. This requires an API key.

**How to get your Gemini API Key:**

1.  **Go to Google AI Studio:** Open your web browser and navigate to [Google AI Studio](https://aistudio.google.com/).
2.  **Sign In:** Sign in with your Google account.
3.  **Get API Key:** Look for a button or link that says "**Get API key**" (often in the top left or top right corner) and click it.
4.  **Create New Key:** You may be prompted to create a new project. Follow the on-screen instructions to create a new API key.
5.  **Copy the Key:** Once generated, copy the long string of characters. This is your API key.
6.  **Add to App:**
    *   Open the Health Tracker app and go to the **Settings** page.
    *   Find the section for **LLM Configuration**.
    *   Paste your copied Gemini API key into the designated field and save.

## Current Limitations

This is a project in active development. The following are known open items:

- The LLM extraction feature has not been tested with OpenAI or Claude models yet.
- The PDF export for doctors needs improved formatting for better readability.
- The application has not been thoroughly tested on Android devices yet.

## Technical Overview

This application is built with a focus on maintainability, testability, and user privacy.

### Architecture
The project follows **Clean Architecture** principles, strictly separating the codebase into three layers:
- **Domain:** Contains the core business logic, entities, and use cases. It is pure Dart and has no dependencies on Flutter or external packages.
- **Data:** Implements the repository interfaces defined in the Domain layer. It handles data sources, such as the local Hive database and external services.
- **Presentation:** The UI layer, built with Flutter. It uses Riverpod for state management and interacts with the Domain layer through use cases.

### Data and Privacy
- **Local-Only Storage:** All user data is stored exclusively on the device using the **Hive** database. No data is sent to any cloud server, ensuring 100% privacy.
- **Offline First:** The app is fully functional without an internet connection.

### Core Technologies
- **Framework:** Flutter
- **State Management:** `flutter_riverpod`
- **Local Database:** `hive`
- **Routing:** `go_router`
- **Data Extraction:** `google_mlkit_text_recognition` for on-device OCR.
- **Charting:** `fl_chart`
- **Dependency Injection:** `get_it` and `injectable`

### Development Process
The project adheres to a strict **Test-Driven Development (TDD)** workflow. All business logic and features are accompanied by a comprehensive suite of unit and widget tests before the implementation is written.
