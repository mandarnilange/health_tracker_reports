# Health Tracker Reports

A privacy-focused Flutter application for tracking your personal health data. All data is stored locally on your device.

Upload your medical reports in PDF format for AI-powered biomarker extraction, log daily vitals (e.g., heart rate, blood pressure), and monitor trends over time. Export your raw data or generate shareable summaries for your healthcare providers.

## Getting Started & Building the Project

To get a local copy up and running, follow these simple steps.

### Prerequisites

Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.

### Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/mandarnilange/health_tracker_reports.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd health_tracker_reports
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the code generator:**
    This project uses code generation for dependency injection. Run this command before building.
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
5.  **Run the app:**
    ```bash
    # Run on your connected device or emulator
    flutter run

    # Or run on a specific platform
    flutter run -d chrome
    ```

## Usage Guidelines

This guide explains how to use the app from a user's perspective.

### 1. Upload a Report
- Tap the '+' or 'Upload' button on the main screen.
- Select any medical report in PDF format to have it scanned.

### 2. Review and Confirm Data
- The app will automatically process the report using an AI model to extract biomarkers.
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

### Setting up Your AI API Key (Required)

This application requires an API key from a supported AI service (Google Gemini, Anthropic Claude, or OpenAI) to power the automatic biomarker extraction from your reports. The app does **not** use on-device OCR and relies on one of these powerful models for accuracy.

**Example: Getting a Google Gemini API Key:**

1.  **Go to Google AI Studio:** Open your web browser and navigate to [Google AI Studio](https://aistudio.google.com/).
2.  **Sign In:** Sign in with your Google account.
3.  **Get API Key:** Look for a button or link that says "**Get API key**" (often in the top left or top right corner) and click it.
4.  **Create New Key:** You may be prompted to create a new project. Follow the on-screen instructions to create a new API key.
5.  **Copy the Key:** Once generated, copy the long string of characters. This is your API key.
6.  **Add to App:**
    *   Open the Health Tracker app and go to the **Settings** page.
    *   Find the section for **LLM Configuration**.
    *   Paste your copied API key into the designated field and save.

## Current Limitations

This is a project in active development. The following are known open items:

- Uploading reports from image files (PNG, JPG) has not been thoroughly tested yet.
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
- **Offline First:** The app is fully functional without an internet connection for most features, but requires it for AI data extraction.

### Core Technologies
- **Framework:** Flutter
- **State Management:** `flutter_riverpod`
- **Local Database:** `hive`
- **Routing:** `go_router`
- **Data Extraction:** AI-powered biomarker extraction via external LLMs (e.g., Google Gemini).
- **Charting:** `fl_chart`
- **Dependency Injection:** `get_it` and `injectable`

### Development Process
The project adheres to a strict **Test-Driven Development (TDD)** workflow. All business logic and features are accompanied by a comprehensive suite of unit and widget tests before the implementation is written.

## AI-Assisted Development

This project leverages an AI agent for assistance with development tasks. The agent's behavior and knowledge base are guided by the following files:

- **`AGENTS.md`**: This is the primary context file for the AI agent. It contains the project overview, architecture, technology stack, design patterns, and testing strategy.
- **`spec/` folder**: This directory contains high-level planning documents, feature breakdowns, and design specifications that are used to guide the agent's implementation process.

## Tooling & Development Environment

- **IDE:** VS Code
- **AI Assistants:** Gemini Code Assist, GitHub Copilot, Claude, OpenAI Codex