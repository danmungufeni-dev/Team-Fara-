# PadCare Privacy Policy

**Effective date:** 10 November 2026  
**Last updated:** 10 November 2026  
**Status:** Draft — verify implementation details before publication

**Contact:** [padcareforher@gmail.com](mailto:padcareforher@gmail.com)  
**Website:** Coming soon  
**Country:** Uganda

> **Implementation note:** This policy reflects the product choices confirmed by the PadCare project owner: email and Google sign-in, manual area selection and GPS-based nearby search, mobile-money donations, and an audience that may include minors, adults, and participating institutions. Any item marked **[VERIFY IN CODE]** must be checked against the actual Flutter/Firebase implementation before release. Remove statements about features or services that are not implemented.

## 1. Introduction

PadCare is a menstrual-product access platform intended to help users find locations where menstrual pads may be available through participating schools, community organisations, institutions, and supporting individuals. Depending on the version of the app, users may be able to create accounts, choose an area manually or use device location to find nearby collection points, and make voluntary donations through supported mobile-money services.

This Privacy Policy explains how PadCare may collect, use, store, disclose, and delete personal information when you use the application and its related services. We aim to collect only information reasonably needed to provide and protect the service.

Where applicable law requires consent, we will request it separately and explain the relevant choice. Reading this policy does not replace any consent required by law.

## 2. Who is responsible for your information?

**Service:** PadCare  
**Privacy contact:** padcareforher@gmail.com  
**Website:** Coming soon  
**Country of operation:** Uganda

The PadCare project owner or operating entity responsible for deciding how personal information is processed will act as the data controller where applicable. **[VERIFY IN CODE / BUSINESS DETAILS: confirm the legal name of the responsible person or entity and whether a separate organisation operates PadCare.]**

For privacy questions, access or correction requests, complaints, or account-deletion requests, email padcareforher@gmail.com. Do not send passwords, payment PINs, or other secret credentials.

## 3. Information we may collect

The information actually collected depends on the features enabled in the released app.

### 3.1 Account and sign-in information

PadCare is intended to support email sign-in and Google sign-in. Depending on the sign-in method and configuration, we may process:
- Email address and account identifier.
- Name or profile image made available by Google, if requested and used.
- Sign-in provider and authentication status.
- Account preferences, account status, and security records.

**[VERIFY IN CODE: confirm Firebase Authentication providers, profile fields stored in Firestore, and whether display names or profile images are saved.]**

PadCare should not store passwords in plain text. If Firebase Authentication is used, authentication credentials should be handled by Firebase rather than stored in PadCare's own database.

### 3.2 Collection-point and institution information

To display and maintain collection points, PadCare may process:
- Collection-point name, description, address, area, and coordinates.
- Opening hours, access instructions, and availability information.
- Public contact details supplied for the collection point.
- Institution or organisation name and authorised administrator details.
- Reports or corrections submitted about listings.

Information intended for public display may be visible to other app users. Private account information should not be made public simply because a user views or searches for a location.

**[VERIFY IN CODE: identify which fields are stored and which are visible publicly or to administrators.]**

### 3.3 Location information

Users may choose an area manually or, if permission is granted, use device GPS to find nearby collection points.

- **Manual area selection:** the area or place selected by the user may be processed to return relevant listings.
- **GPS:** if implemented, the app may access the device's approximate or precise location when the user invokes the nearby-location feature and grants permission.

Location permission should be requested in context and explained clearly. Users should be able to deny GPS permission and use manual area selection if that alternative is available. PadCare should not collect continuous background location unless a specific feature genuinely requires it, is clearly disclosed, and has the necessary permission.

**[VERIFY IN CODE: confirm whether coordinates are sent to a server, saved to an account or database, logged, or used only on-device; confirm whether the app requests foreground or background location permission.]**

### 3.4 Mobile-money donations

If donation functionality is enabled, PadCare may process information needed to initiate, confirm, reconcile, or acknowledge a donation, such as:
- Donation amount and currency.
- Transaction reference, status, date, and payment method.
- Phone number or other payment identifier entered for the transaction, where required.
- Optional donor name or email supplied for a receipt.

A mobile-money operator or payment service may independently process payment details under its own terms and privacy policy. PadCare should not ask users to provide their mobile-money PIN, one-time password, or account password to PadCare. Never share these credentials with PadCare support.

PadCare may receive a transaction result or reference without receiving all payment credentials held by the payment provider.

**[VERIFY IN CODE: identify the actual mobile-money provider(s), payment flow, data returned to PadCare, and whether payments occur in an external USSD/app flow or through a payment gateway. Do not name a provider in the final policy until confirmed.]**

### 3.5 Technical, security, and diagnostic information

Depending on the services enabled, technical information may include app version, device operating system, crash reports, error diagnostics, authentication logs, and security events used to troubleshoot problems and prevent misuse.

**[VERIFY IN CODE: confirm whether Firebase Crashlytics, Analytics, Cloud Logging, or other diagnostics/analytics tools are enabled. Do not state that a service is used if it is not enabled.]**

### 3.6 Support and user-submitted information

If users submit support messages, feedback, corrections, or reports, PadCare may process the content and contact information provided to respond and maintain the service. Please avoid including sensitive information that is not necessary to explain the issue.

## 4. Sensitive information and menstrual health

PadCare is intended to help people find menstrual products. It does not need a user's menstrual history or medical records to display collection points. We do not intend to require menstrual-cycle history, pregnancy information, sexual history, diagnoses, or medical records for ordinary use.

If a future feature proposes collecting sensitive information, PadCare should first assess whether it is necessary, explain the purpose, and obtain any consent or other legal authorisation required by applicable law.

## 5. How we use information

Subject to applicable law, PadCare may use information to:
1. Create, authenticate, and maintain accounts.
2. Display collection points and help users find nearby services.
3. Support manual area search and GPS-based nearby search where enabled.
4. Allow authorised institutions or administrators to maintain collection-point information.
5. Initiate, confirm, reconcile, and acknowledge donations where enabled.
6. Respond to support requests and correct inaccurate listings.
7. Protect accounts, investigate abuse, and maintain app security.
8. Diagnose technical errors and improve reliability.
9. Meet legal obligations and resolve disputes.

We will not use personal information for an unrelated purpose without an appropriate legal basis and any notice or consent required by law.

## 6. Legal grounds for processing

Depending on the activity and applicable law, processing may be based on consent, providing a service requested by the user, compliance with a legal obligation, or another lawful basis permitted by law.

Where consent is the basis, users may withdraw it. Withdrawal does not make processing carried out lawfully before withdrawal unlawful. Some features may stop working if the information or permission is necessary for that feature.

## 7. Firebase and other service providers

PadCare is being developed with Firebase integration. The actual Firebase services in use must be confirmed before publication. They may include Firebase Authentication, Cloud Firestore, Firebase Storage, Crashlytics, or other configured Google Cloud services.

Service providers may process information on PadCare's behalf to host the app's data, authenticate users, provide diagnostics, or complete a requested payment. Access should be limited to what each provider needs to perform its service.

**[VERIFY IN CODE / CONSOLE: list only the Firebase products actually enabled, the configured database/storage regions, relevant processors, and the retention settings. Confirm that Firestore and Storage security rules enforce least-privilege access.]**

Firebase configuration does not by itself guarantee that the app is secure. PadCare must maintain appropriate access controls, rules, secret management, and security testing.

## 8. How information may be shared

PadCare does not intend to sell personal information.

Information may be shared in these limited circumstances:
- **Service providers:** with hosting, authentication, diagnostics, and payment providers where needed to operate the requested feature.
- **Participating institutions:** with authorised listing managers only to the extent needed to administer collection points or respond to a specific service request.
- **Public listings:** collection-point details deliberately published for users to find a location may be visible to other users.
- **Legal and safety matters:** where disclosure is required by law or lawful process, or is otherwise permitted and reasonably necessary to protect rights or security.
- **Organisational changes:** if operation of PadCare is transferred, information may be transferred subject to applicable law and appropriate safeguards.

PadCare should not disclose a user's private account details to a collection point simply because the user searches for or views it.

## 9. Location choices and permissions

Users can choose a location manually or, where the feature is implemented, allow GPS access. Device permissions can generally be changed through Android settings. Denying GPS should not prevent manual search if that alternative is available.

PadCare should explain whether location is used only to show nearby results or is also transmitted, stored, or linked to an account. That detail must be confirmed against the implementation before release.

## 10. Data security

PadCare intends to use reasonable technical and organisational safeguards, which should include, as appropriate:
- Encrypted network connections.
- Firebase Authentication and access controls.
- Restrictive database and storage rules.
- Least-privilege administrator access.
- Secure handling of API keys, tokens, and other secrets.
- Appropriate software updates, testing, and incident response.

**[VERIFY IN CODE / CONSOLE: test these controls; do not claim a safeguard is implemented until verified.]**

No internet service can guarantee absolute security. Users should protect their accounts and report suspected unauthorised access to padcareforher@gmail.com.

## 11. Retention and deletion

PadCare should retain personal information only as long as reasonably needed for the purposes described here, subject to legal retention requirements.

Proposed retention approach, to be confirmed:
- Account data: while an account is active and for a limited period afterward if needed for security or legal obligations.
- Collection-point data: while a listing is active and for a reasonable administrative period afterward.
- Donation records: as needed for transaction reconciliation, accounting, disputes, fraud prevention, and legal obligations.
- Security and diagnostic logs: for a proportionate period based on their operational purpose.
- Support messages: until resolved and for a reasonable follow-up period.

When data is no longer needed, PadCare should delete it, securely dispose of it, or anonymise it. Backups may retain deleted data temporarily until the normal backup cycle ends, where permitted by law.

**[VERIFY IN CODE / CONSOLE: set actual retention periods and confirm how deletion propagates to Firestore, Firebase Authentication, Storage, payment-provider records, logs, and backups.]**

## 12. Account deletion

If users can create accounts, PadCare should provide a clear in-app way to request deletion and a working external request method if required by the app-store rules that apply. Users may contact padcareforher@gmail.com to request account deletion.

A completed deletion request should remove or anonymise personal data PadCare controls that is no longer needed, subject to lawful retention obligations. Transaction records that must be retained by law may be kept for that limited purpose and period. Uninstalling the app alone does not delete an account or cloud-stored information.

**[VERIFY IN CODE: confirm an in-app deletion flow exists, the email request process is monitored, identity is verified proportionately, and Firebase Authentication and associated user records are actually deleted.]**

## 13. Children and mixed-age audiences

PadCare may be used by adults, young people, and participating institutions. We recognise that menstrual-product access can be important to younger users and aim to minimise the information required to find a collection point.

We will comply with applicable child-protection and data-protection laws. Where parental or guardian consent or another specific safeguard is legally required, the appropriate process must be implemented before the relevant personal information is collected or processed.

We do not intend to profile young users or collect unnecessary sensitive information. Institutions that provide information about children must have proper authority to do so and should avoid submitting unnecessary identifying details.

**[VERIFY BEFORE RELEASE: review the app's target age, account-registration flow, Google Play target-audience declarations, consent mechanisms, and any applicable child-data obligations with qualified local advice.]**

## 14. International processing

Cloud or payment providers may process information outside Uganda. Where cross-border transfers occur, PadCare will use the safeguards and procedures required by applicable law.

**[VERIFY IN CONSOLE / CONTRACTS: determine the actual service regions and transfer arrangements. Do not imply a specific storage country without evidence.]**

## 15. Your rights and requests

Subject to applicable law, users may have rights to request access to personal information, correction of inaccurate information, deletion, withdrawal of consent, objection to certain processing, or information about how their data is handled.

To make a request, email **padcareforher@gmail.com**. We may ask for proportionate information to verify that the request comes from the relevant person. We will respond within the time required by applicable law.

You may also contact the appropriate data-protection authority in Uganda if you believe your rights have been infringed.

## 16. Cookies and local storage

The mobile app may store preferences or session-related information locally. If PadCare later operates a website, that website may use essential cookies and, if enabled, analytics or other technologies. Any such use must be disclosed and managed as required by applicable law.

**[VERIFY IN CODE: confirm whether the app uses local storage, analytics identifiers, cookies through embedded web views, or advertising SDKs.]**

## 17. Third-party services and links

PadCare may link to or rely on Google/Firebase services, mobile-money operators, maps, or other third-party services. Their own privacy terms apply to their independent processing. Users should review those terms before providing information directly to a third party.

**[VERIFY IN CODE: add links to the actual payment provider's and other relevant third-party privacy policies once providers are confirmed.]**

## 18. Changes to this policy

We may update this policy when the app, service providers, or legal requirements change. We will update the effective date and provide appropriate notice for material changes. Where the law requires consent for a new processing purpose, we will obtain it before beginning that processing.

## 19. Contact

**PadCare Privacy Team**  
Email: **padcareforher@gmail.com**  
Website: **Coming soon**  
Country: **Uganda**

Please use this email for privacy questions, data requests, account-deletion requests, or complaints. Do not email passwords, mobile-money PINs, or one-time verification codes.

---

### Publication checklist — remove this section from the public policy after completing it

- [ ] Confirm actual Firebase products and database/storage configuration.
- [ ] Confirm exact Google and email authentication behaviour.
- [ ] Confirm how GPS coordinates are used, transmitted, and retained.
- [ ] Confirm the mobile-money provider and exact transaction data received.
- [ ] Confirm analytics, crash reporting, and advertising SDKs, if any.
- [ ] Test account deletion and associated-data removal.
- [ ] Confirm data retention and backup deletion practices.
- [ ] Review child-data, consent, registration, and cross-border obligations under applicable Ugandan law.
- [ ] Replace or remove every **[VERIFY IN CODE]** note before publishing.
- [ ] Have the final policy reviewed for legal compliance.
