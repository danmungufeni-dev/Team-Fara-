import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/features/authentication/security_verification_screen.dart';
import 'package:padcare/features/authentication/terms_consent_screen.dart';
import 'package:padcare/features/authentication/welcome_authentication_screen.dart';

void main() {
  testWidgets('WelcomeAuthenticationScreen renders branding and form fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeAuthenticationScreen(),
      ),
    );

    expect(find.text('PadCare'), findsOneWidget);
    expect(find.text('Care Within Reach • Menstrual Health & Dignity'), findsOneWidget);
    expect(find.text('Continue with Email'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('TermsConsentScreen displays zero-tracking pledges and consent',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TermsConsentScreen(),
      ),
    );

    expect(find.text('Terms of Use & Privacy Consent'), findsOneWidget);
    expect(find.text('Zero Cycle Tracking'), findsOneWidget);
    expect(find.text('Accept & Enter Safe Space'), findsOneWidget);
  });

  testWidgets('SecurityVerificationScreen renders 6-digit pin keypad',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SecurityVerificationScreen(),
      ),
    );

    expect(find.text('Two-Step Verification'), findsOneWidget);
    expect(find.text('E2E 256-bit Encrypted'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });
}
