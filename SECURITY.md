# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Currently supported versions:

| Version | Supported          |
| ------- | ------------------ |
| 0.2.x   | :white_check_mark: |
| < 0.2.0 | :x:                |

## Reporting a Vulnerability

We take the security of Health Tracker Reports seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Please Do Not:

- Open a public GitHub issue for security vulnerabilities
- Disclose the vulnerability publicly before it has been addressed

### Please Do:

**Report security vulnerabilities using GitHub's Private Vulnerability Reporting:**

1. Go to the [Security tab](https://github.com/[your-username]/health_tracker_reports/security) of this repository
2. Click "Report a vulnerability"
3. Fill out the vulnerability report form

You should receive a response within 48 hours. If for some reason you do not, please follow up by creating a private security advisory.

Please include the following information in your report:

- Type of vulnerability (e.g., SQL injection, XSS, data exposure, etc.)
- Full paths of source file(s) related to the vulnerability
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the vulnerability, including how an attacker might exploit it

### What to Expect:

1. **Acknowledgment**: We will acknowledge receipt of your vulnerability report within 48 hours
2. **Communication**: We will keep you informed about our progress in addressing the vulnerability
3. **Verification**: We will verify the vulnerability and determine its impact
4. **Fix**: We will develop and test a fix
5. **Release**: We will release a security update
6. **Credit**: We will publicly acknowledge your responsible disclosure (if you wish)

## Security Considerations for Users

### Data Privacy

This application handles sensitive health data. Please be aware:

- **Local-First Storage**: All health data is stored locally on your device using Hive encryption
- **No Cloud Sync**: By default, no data is transmitted to external servers
- **OCR Processing**: Image processing happens on-device using Google ML Kit
- **PDF Reports**: Generated PDFs are stored locally and only shared if you explicitly choose to do so

### Best Practices

1. **Device Security**
   - Use strong device passcodes/biometric authentication
   - Keep your device OS and this app updated
   - Enable device encryption (enabled by default on modern iOS/Android)

2. **Data Backup**
   - If you export your data, store backups securely
   - Be cautious when sharing PDF reports (they contain personal health information)
   - Delete old reports from shared locations (email, cloud storage) when no longer needed

3. **Permissions**
   - Camera: Required for scanning blood test reports
   - Storage: Required for saving and loading reports
   - We do not request network permissions unless explicitly needed for future features

### Known Security Limitations

- **Beta Software**: This is beta software (v0.2.x). While we follow security best practices, it has not undergone a professional security audit
- **OCR Accuracy**: OCR extraction may misread values. Always verify extracted data against original reports
- **Encryption**: Local storage uses Hive's encryption. The encryption key is stored on the device

## Security Features

- **Local-First Architecture**: No data leaves your device by default
- **Encrypted Storage**: Local data storage is encrypted using Hive
- **On-Device Processing**: OCR and data processing happen locally
- **No Analytics**: No tracking or analytics by default
- **Open Source**: Code is open for security review

## Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the problem and determine affected versions
2. Audit code to find similar problems
3. Prepare fixes for all supported versions
4. Release new versions as soon as possible

## Comments on This Policy

If you have suggestions on how this process could be improved, please submit a pull request or open an issue.

---

Last updated: 2025-10-23
