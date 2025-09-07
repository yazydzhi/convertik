# App Encryption Documentation - Convertik

## App Information
- **App Name:** Convertik
- **Bundle ID:** com.yazydzhi.Convertik
- **Version:** 2.1

## Encryption Declaration

### Does your app implement encryption?
**YES** - Our app uses standard encryption algorithms provided by Apple's operating system.

### What type of encryption algorithms does your app implement?
**Standard encryption algorithms instead of, or in addition to, using or accessing the encryption within Apple's operating system.**

## Detailed Encryption Usage

### 1. HTTPS/TLS Communication
- **Purpose:** Secure API communication with backend server
- **Implementation:** Standard TLS 1.2/1.3 via URLSession
- **Data:** Currency exchange rates, user preferences, analytics data
- **Server:** https://convertik.ponravilos.ru/api/v1

### 2. CoreData Encryption
- **Purpose:** Secure local storage of user data
- **Implementation:** Apple's CoreData with encryption
- **Data:** User currency preferences, app settings, cached exchange rates
- **Algorithm:** AES encryption (Apple's implementation)

### 3. Keychain Services
- **Purpose:** Secure storage of sensitive data
- **Implementation:** iOS Keychain Services
- **Data:** User authentication tokens, subscription status
- **Algorithm:** AES encryption (Apple's implementation)

### 4. StoreKit2 Security
- **Purpose:** Secure in-app purchase processing
- **Implementation:** Apple's StoreKit2 framework
- **Data:** Purchase receipts, subscription validation
- **Algorithm:** RSA/ECC digital signatures (Apple's implementation)

### 5. AdMob Integration
- **Purpose:** Secure ad serving and analytics
- **Implementation:** Google Mobile Ads SDK
- **Data:** Ad requests, user analytics (anonymized)
- **Algorithm:** HTTPS/TLS for all communications

## Compliance Statement

### Export Compliance Classification
- **Category:** Standard encryption algorithms only
- **No proprietary encryption:** We do not implement any custom or proprietary encryption algorithms
- **Apple's encryption only:** All encryption is provided by Apple's operating system and frameworks
- **No cryptographic exports:** We do not export any cryptographic functionality

### Technical Details
- **TLS Version:** 1.2 and 1.3 (standard IETF protocols)
- **Encryption Algorithms:** AES, RSA, ECC (standard NIST/FIPS algorithms)
- **Hash Functions:** SHA-256 (standard NIST algorithm)
- **Key Management:** iOS Keychain Services (Apple's implementation)

### Data Protection
- **Local Storage:** CoreData with encryption
- **Network Communication:** HTTPS/TLS only
- **Sensitive Data:** Stored in iOS Keychain
- **Analytics:** Anonymized data only

## Legal Compliance

### France Export Control
- **Compliance:** We comply with French export control regulations
- **Documentation:** This document serves as our encryption declaration
- **No restricted algorithms:** We use only standard, non-restricted encryption
- **Commercial use:** Standard commercial encryption for consumer app

### Apple Guidelines
- **App Store Review:** Compliant with App Store encryption guidelines
- **Privacy Policy:** Available at https://convertik.ponravilos.ru/privacy.html
- **Terms of Service:** Available at https://convertik.ponravilos.ru/terms.html
- **Data Processing Policy:** Available at https://convertik.ponravilos.ru/data.html

## Contact Information
- **Developer:** Yazydzhi
- **Email:** convertik@ponravilos.ru
- **Website:** https://convertik.ponravilos.ru

---

**Declaration:** We declare that Convertik uses only standard encryption algorithms provided by Apple's operating system and does not implement any proprietary or restricted encryption algorithms. All cryptographic functionality is standard and compliant with international standards (IETF, NIST, FIPS).

**Date:** September 6, 2025
**Signature:** [Digital signature will be provided by Apple after approval]
