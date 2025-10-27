# Tasks Before Release - App Store & Play Store Deployment Guide

**Last Updated:** 2025-10-24
**App Version:** 1.0.0+1
**Target Platforms:** iOS App Store • Google Play Store

---

## Table of Contents

- [Current State Assessment](#current-state-assessment)
- [Platform Setup Tasks](#platform-setup-tasks)
  - [Phase 1: Android Play Store Setup](#phase-1-android-play-store-setup)
  - [Phase 2: iOS App Store Setup](#phase-2-ios-app-store-setup)
  - [Phase 3: Store Assets & Metadata](#phase-3-store-assets--metadata)
  - [Phase 4: Store Registration & Submission](#phase-4-store-registration--submission)
- [Automation Opportunities](#automation-opportunities)
- [Time Estimates](#time-estimates)
- [Recommended Approach](#recommended-approach)
- [Action Plan Checklist](#action-plan-checklist)

---

## Current State Assessment

### ✅ Already Configured

- **Android Package Name:** `com.healthtracker.health_tracker_reports`
- **iOS Bundle Identifier:** `com.healthtracker.health_tracker_reports` (needs Xcode verification)
- **App Icon:** `assets/images/app_icon.png` ✓
- **Version:** `1.0.0+1` configured in `pubspec.yaml`
- **Android Manifest:** Basic configuration with correct activity setup
- **iOS Info.plist:** Basic configuration present
- **Test Suite:** 865 passing tests (98.6% pass rate)

### ❌ Missing for Deployment

- [ ] Release signing configuration (Android keystore)
- [ ] iOS signing certificates and provisioning profiles
- [ ] Privacy policy document (mandatory for both stores)
- [ ] Store screenshots (multiple sizes for iOS and Android)
- [ ] Store metadata and descriptions
- [ ] Privacy permissions descriptions
- [ ] iOS Privacy Manifest (PrivacyInfo.xcprivacy)
- [ ] Play Store Data Safety form completion
- [ ] Release build validation on real devices

---

## Platform Setup Tasks

### Phase 1: Android Play Store Setup

**Estimated Time:** 3-4 hours

#### Task 1.1: Release Signing Configuration

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual (One-time, Security Sensitive)
**Time:** 30 minutes

**Steps:**

1. **Generate Release Keystore:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

   When prompted, provide:
   - Password (save securely - you'll need it later)
   - Name, Organization, City, State, Country
   - Alias password (can be same as keystore password)

2. **Move Keystore to Safe Location:**
   ```bash
   mv ~/upload-keystore.jks ~/health-tracker-keystore.jks
   ```

   **⚠️ CRITICAL:** Back up this file securely. If lost, you cannot update the app.

3. **Create `android/key.properties` File:**
   ```properties
   storePassword=<your_store_password>
   keyPassword=<your_key_password>
   keyAlias=upload
   storeFile=<path_to_keystore>/health-tracker-keystore.jks
   ```

   **⚠️ SECURITY:** Add `key.properties` to `.gitignore`

4. **Update `android/app/build.gradle.kts`:**

   Add before `android {` block:
   ```kotlin
   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }
   ```

   Inside `android {` block, add:
   ```kotlin
   signingConfigs {
       create("release") {
           keyAlias = keystoreProperties["keyAlias"] as String
           keyPassword = keystoreProperties["keyPassword"] as String
           storeFile = file(keystoreProperties["storeFile"] as String)
           storePassword = keystoreProperties["storePassword"] as String
       }
   }
   ```

   Update `buildTypes` block:
   ```kotlin
   buildTypes {
       release {
           signingConfig = signingConfigs.getByName("release")
       }
   }
   ```

**Automation Potential:** ❌ Cannot automate (security sensitive)

---

#### Task 1.2: Android Permissions & Metadata

**Status:** ❌ Not Started
**Priority:** Medium
**Type:** Manual (Can be scripted)
**Time:** 15 minutes

**Steps:**

1. **Update `android/app/src/main/AndroidManifest.xml`:**

   Add permissions before `<application>` tag:
   ```xml
   <!-- Required for LLM API calls -->
   <uses-permission android:name="android.permission.INTERNET"/>

   <!-- Required for file uploads (Android 12 and below) -->
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                    android:maxSdkVersion="32"/>

   <!-- Required for saving exported files -->
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                    android:maxSdkVersion="32"/>
   ```

2. **Verify App Label:**

   Current label: "Health Tracker"
   Confirm this is correct or update to "Health Tracker Reports"

**Automation Potential:** ✅ Can be scripted

---

#### Task 1.3: Build & Test Release APK/AAB

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual Testing Required
**Time:** 30 minutes

**Steps:**

1. **Clean Build:**
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Build Release AAB (App Bundle - Recommended for Play Store):**
   ```bash
   flutter build appbundle --release
   ```

   Output: `build/app/outputs/bundle/release/app-release.aab`

3. **Build Release APK (Alternative for Testing):**
   ```bash
   flutter build apk --release
   ```

   Output: `build/app/outputs/flutter-apk/app-release.apk`

4. **Install on Real Android Device:**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

5. **Manual Testing Checklist:**
   - [ ] App launches successfully
   - [ ] Upload PDF report works
   - [ ] LLM extraction works (with API key)
   - [ ] Save/view reports
   - [ ] Log vitals
   - [ ] View trends charts
   - [ ] Export CSV/PDF
   - [ ] Settings page
   - [ ] No crashes during normal usage
   - [ ] Performance is acceptable

**Automation Potential:** ✅ Build can be scripted; testing requires manual validation

---

### Phase 2: iOS App Store Setup

**Estimated Time:** 4-5 hours

#### Task 2.1: Xcode Project Configuration

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual (Xcode GUI Required)
**Time:** 1 hour

**Prerequisites:**
- macOS with Xcode installed
- Apple Developer account ($99/year)

**Steps:**

1. **Open Xcode Project:**
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. **Configure Bundle Identifier:**
   - Select "Runner" project in left sidebar
   - Select "Runner" target
   - General tab → Identity section
   - Verify Bundle Identifier: `com.healthtracker.health_tracker_reports`

3. **Configure Signing:**

   **Option A: Automatic Signing (Recommended for Beginners)**
   - Check "Automatically manage signing"
   - Select your Team (Apple Developer account)
   - Xcode will create/download certificates and profiles

   **Option B: Manual Signing (Advanced)**
   - Uncheck "Automatically manage signing"
   - Create certificates in Apple Developer Portal
   - Download provisioning profiles
   - Select profiles in Xcode

4. **Set Deployment Target:**
   - General tab → Deployment Info
   - Set minimum iOS version: **13.0** or higher (recommended: 14.0)

5. **Update Display Name (Optional):**
   - General tab → Identity
   - Display Name: "Health Tracker" or "Health Tracker Reports"

6. **Verify App Category (in Info.plist):**
   - Select Info.plist
   - Add if missing:
     - Key: `LSApplicationCategoryType`
     - Value: `public.app-category.healthcare-fitness`

**Automation Potential:** ⚠️ Partial (signing requires GUI; some config can be scripted)

---

#### Task 2.2: Privacy Permissions (Required for App Review)

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual (Can be scripted)
**Time:** 20 minutes

**Steps:**

1. **Open `ios/Runner/Info.plist`**

2. **Add Privacy Usage Descriptions:**

   Add these keys before the closing `</dict>` tag:

   ```xml
   <!-- Photo Library Access -->
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photo library to upload medical reports as images</string>

   <!-- Camera Access -->
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to capture photos of your medical reports</string>

   <!-- File Access (iOS 11+) -->
   <key>NSFileProviderDomainUsageDescription</key>
   <string>We need file access to upload PDF medical reports</string>

   <!-- Face ID (if using biometric auth in future) -->
   <!-- Uncomment if needed:
   <key>NSFaceIDUsageDescription</key>
   <string>We use Face ID to securely access your health data</string>
   -->
   ```

3. **Verify Other Permissions:**
   - Network usage is allowed by default
   - No location, microphone, contacts needed

**Why This Matters:**
- App Review will **reject** your app if you access features without descriptions
- Even if you don't currently use camera, add description if `file_picker` might use it

**Automation Potential:** ✅ Can be scripted

---

#### Task 2.3: Privacy Manifest (iOS 17+ Requirement)

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual (Template Available)
**Time:** 30 minutes

**Background:**
Starting iOS 17, Apple requires apps to declare certain API usage in a Privacy Manifest file.

**Steps:**

1. **Create `ios/Runner/PrivacyInfo.xcprivacy` File:**

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <!-- Domains accessed by app (for network tracking transparency) -->
       <key>NSPrivacyAccessedAPITypes</key>
       <array>
           <!-- File timestamp APIs -->
           <dict>
               <key>NSPrivacyAccessedAPIType</key>
               <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
               <key>NSPrivacyAccessedAPITypeReasons</key>
               <array>
                   <string>C617.1</string> <!-- File timestamp for app functionality -->
               </array>
           </dict>

           <!-- UserDefaults APIs (Hive uses this) -->
           <dict>
               <key>NSPrivacyAccessedAPIType</key>
               <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
               <key>NSPrivacyAccessedAPITypeReasons</key>
               <array>
                   <string>CA92.1</string> <!-- UserDefaults for app preferences -->
               </array>
           </dict>
       </array>

       <!-- Tracking domains (if any analytics/ads - not applicable here) -->
       <key>NSPrivacyTracking</key>
       <false/>

       <!-- Domain accessed for functionality -->
       <key>NSPrivacyTrackingDomains</key>
       <array>
           <!-- List API domains your app connects to -->
           <string>api.anthropic.com</string>
           <string>api.openai.com</string>
           <string>generativelanguage.googleapis.com</string>
       </array>

       <!-- Collected data types -->
       <key>NSPrivacyCollectedDataTypes</key>
       <array>
           <dict>
               <key>NSPrivacyCollectedDataType</key>
               <string>NSPrivacyCollectedDataTypeHealthAndFitness</string>
               <key>NSPrivacyCollectedDataTypeLinked</key>
               <false/>
               <key>NSPrivacyCollectedDataTypeTracking</key>
               <false/>
               <key>NSPrivacyCollectedDataTypePurposes</key>
               <array>
                   <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
               </array>
           </dict>
       </array>
   </dict>
   </plist>
   ```

2. **Add to Xcode Project:**
   - Right-click "Runner" folder in Xcode
   - Add Files to "Runner"
   - Select `PrivacyInfo.xcprivacy`
   - Ensure "Copy items if needed" is checked
   - Add to Runner target

**Automation Potential:** ✅ Template can be created and added via script

---

#### Task 2.4: Build & Test Release IPA

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual Testing Required
**Time:** 1 hour

**Steps:**

1. **Clean Build:**
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Build Release iOS App:**
   ```bash
   flutter build ios --release
   ```

3. **Create Archive in Xcode:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select "Any iOS Device (arm64)" as target (not Simulator)
   - Product → Archive
   - Wait for archive to complete
   - Organizer window will open

4. **Validate Archive:**
   - In Organizer, select the archive
   - Click "Validate App"
   - Select distribution method: "App Store Connect"
   - Follow wizard (select signing, etc.)
   - Xcode will validate with Apple servers
   - Fix any issues reported

5. **Test on Real iPhone Device:**
   - Connect iPhone via USB
   - Select device in Xcode
   - Product → Run (in Release configuration)
   - Test all features (see Android testing checklist)

**Manual Testing Checklist:**
- [ ] App launches successfully
- [ ] Upload PDF report works
- [ ] LLM extraction works (with API key)
- [ ] Save/view reports
- [ ] Log vitals
- [ ] View trends charts
- [ ] Export CSV/PDF
- [ ] Settings page
- [ ] No crashes during normal usage
- [ ] Performance is acceptable
- [ ] UI looks correct on different screen sizes

**Automation Potential:** ⚠️ Partial (build can be scripted; Xcode required for archive/validate)

---

### Phase 3: Store Assets & Metadata

**Estimated Time:** 4-6 hours

#### Task 3.1: Privacy Policy (MANDATORY)

**Status:** ❌ Not Started
**Priority:** CRITICAL
**Type:** Manual (Legal Review Recommended)
**Time:** 2-3 hours (or $50-200 for generator service)

**Why Required:**
- Both Apple and Google **require** a publicly accessible privacy policy URL
- Health apps face stricter scrutiny
- GDPR/CCPA compliance may be required depending on target markets

**Content to Cover:**

1. **Information Collection:**
   - Health data (lab reports, vitals) stored locally
   - PDF files uploaded by user
   - API keys (stored securely)

2. **Third-Party Services:**
   - Data sent to: Anthropic Claude, OpenAI, Google Gemini
   - Purpose: Biomarker extraction from reports
   - User provides their own API keys
   - No data stored by third parties (verify with API terms)

3. **Data Storage:**
   - All health data stored locally on device using Hive
   - No cloud backup (unless user explicitly exports)
   - Data encryption: SQLite database encrypted (if using encrypted Hive)

4. **Data Sharing:**
   - No data shared except to user-configured LLM APIs
   - No analytics or tracking
   - No advertising

5. **User Rights:**
   - Right to export data (CSV/PDF)
   - Right to delete data (app uninstall)
   - No account creation, no data portability issues

6. **HIPAA Compliance:**
   - **Disclaimer:** App is NOT HIPAA compliant
   - Data sent to third-party LLMs may not meet HIPAA standards
   - Not intended for HIPAA-protected health information

7. **Contact Information:**
   - Email for privacy inquiries
   - Last updated date

**Options:**

**Option A: DIY (Free)**
- Use template generator: https://www.freeprivacypolicy.com/
- Customize for your app
- Host on GitHub Pages (free)

**Option B: Professional Service ($50-200)**
- TermsFeed: https://www.termsfeed.com/
- iubenda: https://www.iubenda.com/
- Generates compliant policy + hosting

**Option C: Legal Review ($500+)**
- Hire lawyer for custom policy
- Best for commercial apps

**Steps:**

1. **Write/Generate Privacy Policy**
2. **Host Publicly:**
   - GitHub Pages (in this repo)
   - Personal website
   - Generator service hosting
3. **Get URL:** `https://yourdomain.com/privacy-policy.html`
4. **Save URL:** You'll need this for store submissions

**Automation Potential:** ⚠️ Template can be provided, but legal review recommended

---

#### Task 3.2: App Screenshots

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual (Can be partially automated)
**Time:** 3-4 hours manual, OR 1 hour with automation (+ 2 hours setup)

**Required Sizes:**

**iOS (App Store Connect):**
- **6.5" display** (iPhone 14 Pro Max, 15 Pro): `1284 × 2778 pixels`
- **6.7" display** (iPhone 15 Pro Max): `1290 × 2796 pixels`
- **12.9" iPad Pro**: `2048 × 2732 pixels`
- **Quantity:** 5-8 screenshots per size (can reuse content across sizes)

**Android (Play Console):**
- **Phone**: `1080 × 1920 pixels` minimum (16:9 or taller)
- **7" Tablet**: `1536 × 2048 pixels`
- **10" Tablet**: `1920 × 2560 pixels`
- **Quantity:** 2-8 screenshots per device type

**Recommended Screenshots (Priority Order):**

1. **Home/Timeline Screen:**
   - Shows unified timeline with reports and health logs
   - Demonstrates main value: track everything in one place

2. **Upload Report Flow:**
   - Show file selection or scanning
   - Demonstrates AI-powered extraction feature

3. **Biomarker Details:**
   - Show individual biomarker card with status (normal/high/low)
   - Reference ranges visible
   - Demonstrates health insights

4. **Trend Analysis:**
   - Line chart showing biomarker over time
   - Demonstrates tracking over time

5. **Vital Logging:**
   - Health log entry screen
   - Shows daily tracking capability

6. **Comparison View:**
   - Multiple reports comparison
   - Demonstrates advanced analytics

7. **Settings/LLM Configuration:**
   - Shows API key setup
   - Demonstrates customization

8. **Export/Share:**
   - PDF or CSV export screen
   - Demonstrates data portability

**Manual Capture Process:**

1. **Prepare Test Data:**
   - Create sample reports with realistic data
   - Log sample vitals
   - Ensure variety (normal, high, low values)

2. **For iOS:**
   - Use iPhone Simulator or real device
   - Capture: Cmd+S (Simulator) or Cmd+Shift+4 (device in Xcode)
   - Resize to required dimensions

3. **For Android:**
   - Use Android Emulator or real device
   - Capture: Screenshot button or ADB
   - Resize to required dimensions

4. **Frame Screenshots (Optional but Recommended):**
   - Use tools like:
     - https://www.appure.io/ (free)
     - https://screenshots.pro/ (paid)
     - Figma/Photoshop templates
   - Add device frame + background

**Automated Capture Process (Advanced):**

1. **Install `screenshots` Package:**
   ```bash
   flutter pub global activate screenshots
   ```

2. **Create `screenshots.yaml`:**
   ```yaml
   tests:
     - test_driver/screenshot_test.dart

   staging: /tmp/screenshots
   locales:
     - en-US

   devices:
     ios:
       iPhone-15-Pro-Max:
         frame: true
       iPad-Pro-12.9-inch:
         frame: true
     android:
       Pixel-6:
         frame: true

   frame:
     screenshot: true
   ```

3. **Write Integration Tests:**
   Create `test_driver/screenshot_test.dart` with navigation flow

4. **Run Screenshot Generation:**
   ```bash
   screenshots
   ```

**Automation Potential:** ⚠️ Partial (automated capture possible, framing still manual)

---

#### Task 3.3: Store Listing Metadata

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual (Can pre-write and copy-paste)
**Time:** 2 hours

**App Store Connect (iOS) Fields:**

1. **App Name** (30 chars max):
   ```
   Health Tracker Reports
   ```

2. **Subtitle** (30 chars max):
   ```
   Track Labs & Vitals Privately
   ```

3. **Promotional Text** (170 chars max, can be updated anytime):
   ```
   Upload lab reports for AI-powered biomarker extraction. Log daily vitals. Track trends. Export data. All stored locally for complete privacy.
   ```

4. **Description** (4000 chars max):
   ```
   PRIVACY-FIRST HEALTH TRACKING

   Take control of your health data with Health Tracker Reports - the only health tracking app that keeps 100% of your sensitive medical information on your device.

   🔒 COMPLETE PRIVACY
   • All data stored locally - never uploaded to cloud servers
   • You control your own AI API keys
   • No account required, no tracking, no ads
   • Open source and transparent

   📊 POWERFUL FEATURES

   Lab Report Tracking:
   • Upload PDF reports for AI-powered biomarker extraction
   • Supports Claude, GPT-4, and Gemini vision models
   • Smart extraction of values, units, and reference ranges
   • Edit and verify before saving

   Daily Vital Logging:
   • Blood Pressure (Systolic/Diastolic)
   • Heart Rate & SpO2
   • Body Temperature & Weight
   • Blood Glucose & Sleep Hours
   • Medication adherence tracking
   • Energy levels and notes

   Trend Analysis:
   • Interactive charts for all biomarkers and vitals
   • Spot patterns and changes over time
   • Reference range indicators
   • Compare multiple reports side-by-side

   Professional Reporting:
   • Generate PDF summaries for your doctor
   • Export raw data to CSV
   • Customizable date ranges
   • Include charts and statistics

   🎯 WHO IS THIS FOR?

   • Individuals managing chronic conditions
   • Anyone tracking regular lab work
   • Fitness enthusiasts monitoring vitals
   • People who value health data privacy
   • Patients wanting to share organized records with doctors

   ⚙️ TECHNICAL DETAILS

   • Bring your own API key (Google Gemini, Claude, or OpenAI)
   • Offline-first design (internet only needed for AI extraction)
   • Fast, native performance
   • Clean, intuitive Material Design 3 interface
   • Cross-platform: works on iPhone and iPad

   ⚠️ IMPORTANT NOTES

   • This app is NOT a medical device
   • Not intended for medical diagnosis or treatment
   • Always consult healthcare professionals
   • Verify AI-extracted data with original reports
   • Not HIPAA compliant (data sent to third-party AI services)

   📱 REQUIREMENTS

   • API key from Google Gemini, Anthropic Claude, or OpenAI
   • Free tiers available for most providers
   • iOS 14.0 or later

   Made with ❤️ for privacy-conscious health enthusiasts.
   ```

5. **Keywords** (100 chars max, comma-separated):
   ```
   health,lab,reports,biomarker,vitals,tracking,blood,test,medical,privacy,trend,chart,doctor,pdf
   ```

6. **Support URL**:
   ```
   https://github.com/mandarnilange/health_tracker_reports/issues
   ```

7. **Marketing URL** (optional):
   ```
   https://github.com/mandarnilange/health_tracker_reports
   ```

8. **What's New in This Version** (4000 chars max):
   ```
   Initial release of Health Tracker Reports!

   Features:
   • Upload and track lab reports
   • AI-powered biomarker extraction
   • Daily vital sign logging
   • Interactive trend charts
   • PDF and CSV export
   • 100% local storage for complete privacy

   Thank you for trying our app. Please rate and review!
   ```

---

**Play Console (Android) Fields:**

1. **App Name** (50 chars max):
   ```
   Health Tracker Reports
   ```

2. **Short Description** (80 chars max):
   ```
   Track lab reports & daily vitals privately with AI-powered biomarker extraction
   ```

3. **Full Description** (4000 chars max):

   Use same description as iOS above, formatted for Play Store

4. **Feature Graphic** (Required):
   - Size: `1024 × 500 pixels`
   - Content: App name + key visual + tagline
   - Tools: Canva, Figma, Photoshop

5. **App Category**:
   - Primary: `Health & Fitness`
   - Tags: health, medical, tracking

6. **Content Rating**:
   - Complete questionnaire (see Task 3.5)

7. **Target Audience**:
   - Age: 18 and over (health data sensitivity)

**Automation Potential:** ✅ Text can be pre-written and copy-pasted

---

#### Task 3.4: Play Store Data Safety Form (CRITICAL)

**Status:** ❌ Not Started
**Priority:** CRITICAL
**Type:** Manual Form Completion
**Time:** 1 hour

**Background:**
Google requires detailed disclosure of data collection and sharing practices. This is a multi-step form in Play Console.

**Key Questions & Recommended Answers:**

**Section 1: Data Collection and Security**

Q: Does your app collect or share any of the required user data types?
A: **YES**

Q: Is all of the user data collected by your app encrypted in transit?
A: **YES** (HTTPS for API calls)

Q: Do you provide a way for users to request that their data is deleted?
A: **YES** (uninstalling app deletes all local data; also can add in-app delete)

---

**Section 2: Data Types**

**Health and Fitness:**
- Collected: **YES**
- Shared: **YES** (with third-party LLM APIs)
- Data types:
  - Health info (biomarkers, vitals)
  - Fitness info (weight, sleep)
- Ephemeral: **NO**
- Required: **YES** (core functionality)
- Purpose: App functionality
- User can choose not to provide: **NO**

**Files and Docs:**
- Collected: **YES**
- Shared: **YES** (PDF reports sent to LLM)
- Data types: Files and docs (medical reports)
- Ephemeral: **YES** (processed by LLM, not permanently stored by them - verify)
- Required: **YES**
- Purpose: App functionality

**App Activity:**
- Collected: **NO** (no analytics)

**App Info and Performance:**
- Collected: **NO** (no crash reporting - may change if you add Firebase)

---

**Section 3: Data Usage and Handling**

For each data type marked YES above, specify:

**Health Info:**
- Is this data processed ephemerally? **NO** (stored locally)
- Is sharing optional? **NO** (required for AI extraction)
- Purpose: App functionality
- Data is: **Encrypted in transit** (HTTPS)
- Data is: **Not encrypted at rest** (unless you enable Hive encryption)
- Third parties receiving data:
  - Anthropic (Claude API)
  - OpenAI (GPT-4 API)
  - Google (Gemini API)

**Files and Docs:**
- Same as above

---

**Section 4: Third-Party Data Sharing**

List all third parties:

1. **Anthropic (Claude API)**
   - Purpose: Analytics (NO), Fraud prevention (NO), App functionality (YES)
   - Data shared: Health info, Files and docs
   - Privacy policy: https://www.anthropic.com/privacy

2. **OpenAI**
   - Purpose: App functionality (YES)
   - Data shared: Health info, Files and docs
   - Privacy policy: https://openai.com/policies/privacy-policy

3. **Google (Gemini API)**
   - Purpose: App functionality (YES)
   - Data shared: Health info, Files and docs
   - Privacy policy: https://policies.google.com/privacy

---

**Important Notes:**

1. Verify each LLM provider's data retention policy
2. Some providers may NOT store data sent via API (check terms)
3. Update form if you add analytics (Firebase, etc.)
4. Be truthful - false declarations can result in app removal

**Automation Potential:** ❌ Cannot automate (requires manual judgment and verification)

---

#### Task 3.5: Content Rating Questionnaire

**Status:** ❌ Not Started
**Priority:** Medium
**Type:** Manual Form Completion
**Time:** 20 minutes

**For Both Stores:**

**iOS (App Store):**
- **Age Rating:** 4+ (Medical/Treatment Information)
- No: Violence, Sexual Content, Profanity, Horror, Mature Themes
- Yes: Medical/Treatment Information (health data)

**Android (Play Console):**
- Complete IARC rating questionnaire
- Similar questions as iOS
- Result: Rated for Everyone or Teen
- Medical references: YES

**Steps:**
1. In Play Console: Release → App content → Content rating
2. Select rating authority (IARC recommended)
3. Answer questionnaire honestly
4. Submit for rating
5. Rating certificate generated automatically

**Automation Potential:** ❌ Cannot automate

---

### Phase 4: Store Registration & Submission

**Estimated Time:** 2-3 hours

#### Task 4.1: Developer Account Setup

**Status:** ❌ Not Started (if you don't have accounts)
**Priority:** High
**Type:** Manual
**Time:** 1-2 hours (one-time per platform)

**Apple Developer Program:**

**Cost:** $99/year

**Steps:**
1. Go to https://developer.apple.com/programs/
2. Click "Enroll"
3. Sign in with Apple ID
4. Choose Individual or Organization
5. Complete enrollment form
6. Pay $99 fee
7. Wait for approval (usually 24-48 hours)

**After Approval:**
1. Go to https://appstoreconnect.apple.com/
2. Agreements, Tax, and Banking
3. Accept Paid Apps agreement
4. Complete tax forms (W-9 for US, W-8BEN for international)
5. Add banking info for app sales (if paid app or IAPs)

---

**Google Play Console:**

**Cost:** $25 one-time

**Steps:**
1. Go to https://play.google.com/console/signup
2. Sign in with Google account
3. Pay $25 registration fee
4. Complete developer account form
5. Verify email and phone
6. Account activated immediately (usually)

**After Activation:**
1. Complete merchant account setup (if selling paid apps)
2. Accept Developer Distribution Agreement
3. Set up payment profile

---

**Automation Potential:** ❌ Cannot automate

---

#### Task 4.2: App Store Connect Submission (iOS)

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual (Partially automatable with Fastlane)
**Time:** 1-2 hours

**Prerequisites:**
- [ ] Developer account active
- [ ] Agreements accepted
- [ ] Privacy policy URL ready
- [ ] Screenshots prepared
- [ ] Build validated in Xcode
- [ ] Metadata written

**Steps:**

1. **Upload Build:**
   - In Xcode Organizer, select your archive
   - Click "Distribute App"
   - Select "App Store Connect"
   - Upload (may take 10-30 minutes)
   - Build will appear in App Store Connect after processing

2. **Create App Listing:**
   - Go to https://appstoreconnect.apple.com/
   - My Apps → Click "+" → New App
   - Platform: iOS
   - Name: Health Tracker Reports
   - Primary Language: English
   - Bundle ID: com.healthtracker.health_tracker_reports
   - SKU: `health-tracker-reports-001` (unique identifier for your records)
   - User Access: Full Access

3. **App Information:**
   - Privacy Policy URL: (your URL from Task 3.1)
   - Category: Primary: Health & Fitness, Secondary: Medical
   - License Agreement: Standard (or custom if needed)

4. **Pricing and Availability:**
   - Price: Free
   - Availability: All countries (or select specific)

5. **Version Information (1.0):**
   - Screenshots: Upload from Task 3.2
   - Promotional Text: (from Task 3.3)
   - Description: (from Task 3.3)
   - Keywords: (from Task 3.3)
   - Support URL: (your GitHub issues URL)
   - Marketing URL: (optional, your GitHub repo)

6. **Build Selection:**
   - Click "+" next to Build
   - Select your uploaded build (1.0.0+1)
   - Export Compliance: Answer questions
     - Does your app use encryption? **YES**
     - Is it exempt from regulations? **YES** (if using standard HTTPS)
     - Provide documentation if using custom crypto

7. **App Review Information:**
   - Contact Information: Your name, email, phone
   - Sign-In Required: **NO**
   - Demo Account: N/A (or provide test API key if requested)
   - Notes:
     ```
     This app requires users to provide their own API key from:
     - Google Gemini (https://aistudio.google.com/)
     - Anthropic Claude (https://console.anthropic.com/)
     - OpenAI (https://platform.openai.com/)

     Free tiers are available. For review purposes, a demo API key
     can be provided upon request.

     All health data is stored locally on the device.
     The app is not intended for medical diagnosis or treatment.
     ```

8. **Version Release:**
   - Automatic release after approval (or Manual release)

9. **Submit for Review:**
   - Click "Submit for Review"
   - Confirm all sections complete
   - Submit

**Review Timeline:**
- Typical: 24-48 hours
- Can be up to 7 days
- Often faster for initial submission

**Common Rejection Reasons to Avoid:**
- Missing privacy policy
- Missing usage descriptions
- Crashes during review
- Incomplete metadata
- Misleading screenshots
- App doesn't work as described

**Automation Potential:** ⚠️ Partial (Fastlane can automate metadata upload and build submission)

---

#### Task 4.3: Play Console Submission (Android)

**Status:** ❌ Not Started
**Priority:** High
**Type:** Manual (Partially automatable with Fastlane)
**Time:** 1-2 hours

**Prerequisites:**
- [ ] Developer account active
- [ ] Privacy policy URL ready
- [ ] Screenshots prepared
- [ ] Feature graphic created
- [ ] AAB built and tested
- [ ] Metadata written
- [ ] Data safety form completed
- [ ] Content rating completed

**Steps:**

1. **Create New App:**
   - Go to https://play.google.com/console/
   - All apps → Create app
   - App name: Health Tracker Reports
   - Default language: English
   - App or game: App
   - Free or paid: Free
   - Declarations:
     - [x] Developer Program Policies
     - [x] US export laws
   - Create app

2. **Set Up Your App (Dashboard Tasks):**

   **Store Settings:**
   - App category: Health & Fitness
   - Tags: health, medical, lab reports, tracking
   - Email address: (your support email)
   - External marketing: No (unless you have website)

   **Store Listing:**
   - App name: Health Tracker Reports
   - Short description: (from Task 3.3)
   - Full description: (from Task 3.3)
   - App icon: Upload 512 × 512 PNG
   - Feature graphic: Upload 1024 × 500 PNG
   - Screenshots: Upload from Task 3.2
     - Phone: 2-8 screenshots
     - 7-inch tablet: 1-8 screenshots (optional but recommended)
     - 10-inch tablet: 1-8 screenshots (optional but recommended)
   - Privacy policy: (your URL from Task 3.1)

3. **App Content:**

   **App access:**
   - All functionality is available without restrictions: **YES** (or NO if API key required)
   - If NO, provide test credentials

   **Ads:**
   - Contains ads: **NO**

   **Content rating:**
   - Complete questionnaire (see Task 3.5)

   **Target audience:**
   - Age: 18 and over
   - Appeal to children: No

   **News app:**
   - Is this a news app? **NO**

   **COVID-19 contact tracing and status:**
   - **NO**

   **Data safety:**
   - Complete form (see Task 3.4)

   **Government apps:**
   - **NO**

4. **Production Release:**

   **Countries/Regions:**
   - Available in: All countries (or select specific)

   **Create new release:**
   - Production track (or Internal testing first - recommended)
   - Upload AAB: Click "Upload" and select `app-release.aab`
   - Release name: `1.0.0 (1)` or "Initial Release"
   - Release notes:
     ```
     Initial release of Health Tracker Reports!

     Features:
     • Upload and track lab reports
     • AI-powered biomarker extraction
     • Daily vital sign logging
     • Interactive trend charts
     • PDF and CSV export
     • 100% local storage for complete privacy

     Requires API key from Google Gemini, Anthropic Claude, or OpenAI.
     Free tiers available for all providers.
     ```

5. **Review Release:**
   - Verify all sections complete (green checkmarks)
   - Click "Start rollout to Production" (or "Start rollout to Internal testing")

6. **Submit for Review:**
   - Release sent for review
   - Can take 1-7 days (often faster)

**Internal Testing Track (Recommended First):**
- Upload to "Internal testing" instead of "Production"
- Add test users (up to 100 email addresses)
- Get instant access to test app
- Fix any issues before production submission
- Then promote to Production

**Review Timeline:**
- Internal testing: Instant (no review)
- Production: 1-7 days (usually 2-3 days)

**Common Rejection Reasons to Avoid:**
- Missing privacy policy
- Incomplete data safety form
- Crashes or bugs
- Violates health/medical policies
- Misleading store listing

**Automation Potential:** ⚠️ Partial (Fastlane can automate AAB upload and metadata sync)

---

## Automation Opportunities

### What CAN Be Automated

#### 1. Build Scripts

**Create `scripts/build-release.sh`:**

```bash
#!/bin/bash
set -e

echo "🧹 Cleaning previous builds..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Running code generation..."
dart run build_runner build --delete-conflicting-outputs

echo "🤖 Building Android AAB..."
flutter build appbundle --release

echo "🍎 Building iOS..."
flutter build ios --release

echo "✅ Build complete!"
echo ""
echo "Android AAB: build/app/outputs/bundle/release/app-release.aab"
echo "iOS: Open ios/Runner.xcworkspace in Xcode to archive"
```

**Make executable:**
```bash
chmod +x scripts/build-release.sh
```

**Run:**
```bash
./scripts/build-release.sh
```

**Time Savings:** 10 minutes per build cycle

---

#### 2. Screenshot Automation

**Using `screenshots` Package:**

**Installation:**
```bash
flutter pub global activate screenshots
```

**Configuration (`screenshots.yaml`):**
```yaml
tests:
  - test_driver/app_test.dart

staging: /tmp/screenshots

locales:
  - en-US

devices:
  ios:
    iPhone-15-Pro-Max:
      frame: true
    iPad-Pro-12-inch:
      frame: true
  android:
    Pixel-7-Pro:
      frame: true
    Nexus-9:
      frame: true

frame:
  screenshot: true
```

**Integration Test (`test_driver/app_test.dart`):**
```dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:screenshots/screenshots.dart';
import 'package:test/test.dart';

void main() {
  group('App Screenshots', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('capture home screen', () async {
      await screenshot(driver, config, 'home_screen');
    });

    test('capture upload flow', () async {
      await driver.tap(find.byValueKey('upload_button'));
      await Future.delayed(Duration(seconds: 1));
      await screenshot(driver, config, 'upload_screen');
    });

    // Add more screenshot captures...
  });
}
```

**Run:**
```bash
screenshots
```

**Time Savings:** 2-3 hours (after initial 2-hour setup)

---

#### 3. Metadata Management with Fastlane

**What is Fastlane?**
- Automation tool for iOS and Android deployments
- Manages metadata, screenshots, builds, submissions
- Command-line driven, scriptable

**Installation:**
```bash
# macOS
brew install fastlane

# Or via RubyGems
sudo gem install fastlane
```

**iOS Setup:**
```bash
cd ios
fastlane init
```

**Android Setup:**
```bash
cd android
fastlane init
```

**Example Fastfile (`ios/fastlane/Fastfile`):**
```ruby
default_platform(:ios)

platform :ios do
  desc "Upload metadata to App Store Connect"
  lane :upload_metadata do
    deliver(
      metadata_path: "./fastlane/metadata",
      screenshots_path: "./fastlane/screenshots",
      skip_binary_upload: true,
      skip_screenshots: false
    )
  end

  desc "Build and upload to TestFlight"
  lane :beta do
    build_app(
      scheme: "Runner",
      workspace: "Runner.xcworkspace",
      export_method: "app-store"
    )
    upload_to_testflight
  end
end
```

**Metadata Structure:**
```
ios/fastlane/metadata/en-US/
├── name.txt                  # App name
├── subtitle.txt              # Subtitle
├── description.txt           # Description
├── keywords.txt              # Keywords
├── marketing_url.txt         # Marketing URL
├── support_url.txt           # Support URL
└── privacy_url.txt           # Privacy policy URL
```

**Run:**
```bash
cd ios
fastlane upload_metadata
```

**Time Savings:** 30 minutes per metadata update

---

#### 4. CI/CD Pipeline (Advanced - Future)

**GitHub Actions Example (`.github/workflows/release.yml`):**

```yaml
name: Release Build

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      - name: Build AAB
        run: |
          flutter pub get
          dart run build_runner build --delete-conflicting-outputs
          flutter build appbundle --release

      - name: Upload to Play Console
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAYSTORE_SERVICE_ACCOUNT }}
          packageName: com.healthtracker.health_tracker_reports
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      - name: Build iOS
        run: |
          flutter pub get
          dart run build_runner build --delete-conflicting-outputs
          flutter build ios --release --no-codesign

      - name: Upload to TestFlight
        run: |
          cd ios
          fastlane beta
        env:
          FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}
```

**Time Savings:** Significant for ongoing releases (hours per release)

---

### What CANNOT Be Automated

1. ❌ **Keystore Generation** - Security sensitive, one-time manual task
2. ❌ **Apple Developer Signing** - Xcode GUI required for initial setup
3. ❌ **Privacy Policy Writing** - Legal review recommended, requires judgment
4. ❌ **Data Safety Form** - Manual judgment required for accurate disclosure
5. ❌ **Initial Store Account Creation** - Manual identity verification
6. ❌ **App Review Communication** - May need to respond to reviewer questions
7. ❌ **Manual Testing** - Human validation of app functionality required

---

## Time Estimates

### First Release (Mostly Manual)

| Phase | Task | Manual Time | With Automation | Automation Setup Time |
|-------|------|-------------|-----------------|----------------------|
| **Android** | Signing Config | 30 min | 30 min | N/A (cannot automate) |
| | Permissions | 15 min | 5 min | 10 min (script) |
| | Build & Test | 30 min | 15 min | 15 min (script) |
| **iOS** | Xcode Config | 1 hour | 45 min | N/A (GUI required) |
| | Privacy Permissions | 20 min | 10 min | 10 min (template) |
| | Privacy Manifest | 30 min | 10 min | 15 min (template) |
| | Build & Test | 1 hour | 45 min | 20 min (script) |
| **Assets** | Privacy Policy | 2-3 hours | 1 hour | N/A (use generator) |
| | Screenshots | 3-4 hours | 1 hour | 2 hours (automation setup) |
| | Store Metadata | 2 hours | 30 min | 30 min (pre-write) |
| | Data Safety Form | 1 hour | 1 hour | N/A (cannot automate) |
| **Submission** | iOS Submission | 1.5 hours | 45 min | 1 hour (Fastlane setup) |
| | Android Submission | 1.5 hours | 45 min | 1 hour (Fastlane setup) |
| **TOTAL** | **15-18 hours** | **7-9 hours** | **+5 hours automation setup** |

### Ongoing Releases (With Automation)

| Task | Manual | Automated | Savings |
|------|--------|-----------|---------|
| Build both platforms | 1.5 hours | 15 min | 75% |
| Update screenshots | 3 hours | 30 min | 83% |
| Update metadata | 1 hour | 10 min | 83% |
| Submit to stores | 2 hours | 30 min | 75% |
| **TOTAL per release** | **7.5 hours** | **1.5 hours** | **80% savings** |

---

## Recommended Approach

### For First Release: Hybrid Approach

**Do Manually:**
1. Android signing setup (security)
2. iOS signing in Xcode (one-time)
3. Privacy policy (use generator service)
4. Screenshots (manual is faster for first time)
5. Store metadata (pre-write, copy-paste)
6. Data safety form (requires judgment)
7. Initial submissions (learn the process)

**Use Simple Automation:**
1. Build script for cleaning and building
2. Permission/manifest templates
3. Metadata text in version-controlled files

**Total Time Investment:** ~12-16 hours over 2-3 days

**Automation Setup Time:** ~1 hour (just build scripts and templates)

---

### For Ongoing Releases: Full Automation

**After First Release, Invest In:**
1. Fastlane setup (both platforms) - 4-6 hours
2. Screenshot automation - 2-3 hours
3. CI/CD pipeline (optional) - 4-8 hours

**Total Automation Setup:** ~10-17 hours

**ROI:**
- Saves 50-80% time on each subsequent release
- Pays off after 2-3 releases
- Enables rapid iteration
- Reduces human error

---

## Action Plan Checklist

### Pre-Deployment (Complete Before Starting)

- [ ] **Test Coverage:** Fix all failing tests (currently 12 failures)
- [ ] **Manual Testing:** Test app thoroughly on real devices (iOS and Android)
- [ ] **Performance:** Ensure app performs well in release mode
- [ ] **Bug Fixes:** Address any known critical bugs
- [ ] **API Keys:** Verify all 3 LLM providers work correctly

---

### Phase 1: Android Setup (Day 1)

- [ ] Generate release keystore
- [ ] Create `key.properties` file (add to `.gitignore`)
- [ ] Update `build.gradle.kts` with signing config
- [ ] Add required permissions to `AndroidManifest.xml`
- [ ] Build release AAB
- [ ] Test AAB on real Android device
- [ ] Verify all features work in release mode

**Estimated Time:** 2-3 hours

---

### Phase 2: iOS Setup (Day 1-2)

- [ ] Open Xcode project and configure Bundle ID
- [ ] Set up signing (automatic or manual)
- [ ] Add privacy usage descriptions to `Info.plist`
- [ ] Create `PrivacyInfo.xcprivacy` file
- [ ] Add privacy manifest to Xcode project
- [ ] Set deployment target (iOS 14.0+)
- [ ] Build and archive in Xcode
- [ ] Validate archive
- [ ] Test on real iPhone device
- [ ] Verify all features work in release mode

**Estimated Time:** 3-4 hours

---

### Phase 3: Store Assets (Day 2-3)

- [ ] **Privacy Policy:**
  - [ ] Write or generate privacy policy
  - [ ] Cover all data collection and sharing
  - [ ] Host publicly (GitHub Pages or service)
  - [ ] Save URL for store submissions

- [ ] **Screenshots:**
  - [ ] Prepare test data (sample reports, vitals)
  - [ ] Capture iOS screenshots (6.5", 6.7", 12.9")
  - [ ] Capture Android screenshots (phone, tablet)
  - [ ] Frame screenshots (optional)
  - [ ] Organize by platform and size

- [ ] **Store Metadata:**
  - [ ] Write app descriptions (iOS and Android)
  - [ ] Write keywords
  - [ ] Write promotional text
  - [ ] Write release notes
  - [ ] Create feature graphic (Android, 1024×500)
  - [ ] Save all text in version-controlled files

- [ ] **Data Safety Form (Android):**
  - [ ] Review LLM provider data policies
  - [ ] Complete data collection disclosure
  - [ ] Specify data sharing (third parties)
  - [ ] Document data security measures

- [ ] **Content Rating:**
  - [ ] Complete iOS age rating (4+)
  - [ ] Complete Android IARC questionnaire

**Estimated Time:** 5-7 hours

---

### Phase 4: Store Accounts (Day 3)

**If you don't already have accounts:**

- [ ] **Apple Developer:**
  - [ ] Enroll at developer.apple.com
  - [ ] Pay $99 fee
  - [ ] Wait for approval (24-48 hours)
  - [ ] Accept agreements in App Store Connect
  - [ ] Complete tax and banking info (if applicable)

- [ ] **Google Play Console:**
  - [ ] Register at play.google.com/console
  - [ ] Pay $25 fee
  - [ ] Complete developer profile
  - [ ] Accept Developer Distribution Agreement

**Estimated Time:** 1-2 hours (plus waiting for Apple approval)

---

### Phase 5: Submissions (Day 4)

- [ ] **App Store Connect (iOS):**
  - [ ] Upload build via Xcode
  - [ ] Create new app listing
  - [ ] Upload screenshots
  - [ ] Fill in all metadata
  - [ ] Add privacy policy URL
  - [ ] Complete app review information
  - [ ] Provide reviewer notes about API keys
  - [ ] Submit for review

- [ ] **Play Console (Android):**
  - [ ] Create new app
  - [ ] Complete store listing
  - [ ] Upload screenshots and feature graphic
  - [ ] Complete app content sections
  - [ ] Fill in data safety form
  - [ ] Complete content rating
  - [ ] Upload AAB to Internal Testing (recommended first)
  - [ ] Or upload AAB to Production
  - [ ] Submit for review

**Estimated Time:** 2-3 hours

---

### Phase 6: Post-Submission (Day 4+)

- [ ] Monitor review status daily
- [ ] Respond to any rejection feedback
- [ ] Fix issues if rejected and resubmit
- [ ] Test published app after approval
- [ ] Monitor user reviews and ratings
- [ ] Plan for first update (bug fixes, improvements)

**Review Timelines:**
- iOS: 24-48 hours (typically)
- Android: 1-7 days (typically 2-3 days)

---

### Optional: Automation Setup (Day 5+)

- [ ] Create `scripts/build-release.sh`
- [ ] Set up Fastlane for iOS
- [ ] Set up Fastlane for Android
- [ ] Organize metadata in version-controlled files
- [ ] Set up screenshot automation (optional)
- [ ] Set up CI/CD pipeline (optional)

**Estimated Time:** 5-10 hours (optional, for future releases)

---

## Final Checklist Before Submit

### Technical Validation

- [ ] All tests pass (0 failures)
- [ ] App builds successfully in release mode (both platforms)
- [ ] No crashes during manual testing
- [ ] All features work as expected
- [ ] Performance is acceptable
- [ ] App size is reasonable (check AAB/IPA sizes)
- [ ] App follows platform design guidelines

### Store Requirements

- [ ] Privacy policy URL is public and accessible
- [ ] Screenshots accurately represent the app
- [ ] Descriptions are clear and not misleading
- [ ] No prohibited content or claims
- [ ] Age rating is appropriate
- [ ] Data safety disclosures are accurate and complete
- [ ] All required permissions are justified

### Legal & Compliance

- [ ] App complies with health data regulations (HIPAA disclaimer if needed)
- [ ] Medical disclaimers are prominent
- [ ] Third-party licenses are acknowledged (if required)
- [ ] Terms of Service (if applicable)
- [ ] Export compliance answered correctly
- [ ] No trademark violations

### User Experience

- [ ] Onboarding is clear for new users
- [ ] API key setup instructions are provided
- [ ] Error messages are helpful
- [ ] Support contact information is provided
- [ ] App works offline (except AI extraction)
- [ ] Data export/deletion is available

---

## Common Rejection Reasons & How to Avoid

### iOS App Store

| Rejection Reason | How to Avoid |
|-----------------|--------------|
| **Crash on launch** | Test thoroughly in release mode on real devices |
| **Missing privacy descriptions** | Add all required NSUsage* keys to Info.plist |
| **Broken links** | Verify privacy policy URL is accessible |
| **Incomplete metadata** | Fill in all required fields in App Store Connect |
| **Misleading screenshots** | Show actual app features, not mockups |
| **Guideline 4.3 (Spam)** | Ensure your app provides unique value |
| **Guideline 5.1.1 (Privacy)** | Complete privacy manifest, clear data usage |

---

### Google Play Store

| Rejection Reason | How to Avoid |
|-----------------|--------------|
| **Incomplete Data Safety** | Thoroughly fill out data safety form with accurate info |
| **Missing privacy policy** | Provide valid URL in store listing |
| **Crashes or bugs** | Test on multiple Android devices and versions |
| **Misleading store listing** | Ensure descriptions match actual functionality |
| **Health claims** | Include medical disclaimer, don't claim diagnosis capability |
| **Missing permissions justification** | Only request necessary permissions, explain usage |

---

## Support Resources

### Official Documentation

- **iOS:** https://developer.apple.com/app-store/submissions/
- **Android:** https://support.google.com/googleplay/android-developer/

### Tools

- **Fastlane:** https://fastlane.tools/
- **Screenshots Package:** https://pub.dev/packages/screenshots
- **Privacy Policy Generators:**
  - Free: https://www.freeprivacypolicy.com/
  - Paid: https://www.termsfeed.com/

### Community

- **Flutter Discord:** https://discord.gg/flutter
- **r/FlutterDev:** https://reddit.com/r/FlutterDev
- **Stack Overflow:** Tag questions with `flutter`, `ios`, `android`

---

## Conclusion

**Total Time to First Release:**
- **Minimum:** 12-16 hours (focused work over 2-3 days)
- **With Automation Setup:** 17-21 hours (saves time on future releases)
- **Plus Review Time:** 1-7 days (varies by platform)

**Recommended Timeline:**
- **Week 1:** Android & iOS setup, build validation
- **Week 2:** Store assets (screenshots, privacy policy, metadata)
- **Week 3:** Account setup, submissions, wait for review
- **Week 4:** Address any rejections, launch 🚀

**Key Success Factors:**
1. Test thoroughly before submitting
2. Be honest and accurate in all disclosures
3. Provide clear reviewer notes for API key requirement
4. Have patience with review process
5. Respond quickly to rejection feedback

**Good luck with your launch! 🎉**

---

*Last updated: 2025-10-24*
*For questions or issues, see: [GitHub Issues](https://github.com/mandarnilange/health_tracker_reports/issues)*
