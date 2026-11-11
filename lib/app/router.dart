import 'package:go_router/go_router.dart';

import '../features/authentication/welcome_authentication_screen.dart';
import '../features/authentication/security_verification_screen.dart';
import '../features/authentication/terms_consent_screen.dart';
import '../features/onboarding/user_onboarding_screen.dart';
import '../features/dashboard/padcare_home_dashboard_screen.dart';
import '../features/maps/live_map_discovery_screen.dart';
import '../features/distribution_points/add_distribution_point_screen.dart';
import '../features/distribution_points/distribution_point_details_screen.dart';
import '../features/requests/discreet_request_flow_screen.dart';
import '../features/messaging/discreet_messaging_screen.dart';
import '../features/notifications/notifications_center_screen.dart';
import '../features/herhelp/herhelp_assistant_screen.dart';
import '../features/profile/user_profile_privacy_screen.dart';
import '../features/donations/support_donations_screen1.dart';
import '../features/donations/support_donations_screen2.dart';
import '../features/donations/support_donations_screen3.dart';
import '../features/donations/donation_receipt_screen.dart';
import '../features/supplier/supplier_dashboard_screen.dart';
import '../features/stock/stock_management_screen.dart';
import '../features/admin/admin_verification_dashboard_screen.dart';
import '../features/synchronization/full_offline_queue_sync_screen.dart';
import '../features/synchronization/offline_sync_confirmation_screen.dart';
import '../features/synchronization/sync_conflict_resolution_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      // 1. Welcome / Authentication
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeAuthenticationScreen(),
      ),

      // 2. User Onboarding Carousel
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const UserOnboardingScreen(),
      ),

      // 3. Security Verification
      GoRoute(
        path: '/security-verification',
        builder: (context, state) => const SecurityVerificationScreen(),
      ),

      // 4. Terms & Consent Acceptance
      GoRoute(
        path: '/terms-consent',
        builder: (context, state) => const TermsConsentScreen(),
      ),

      // 5. PadCare Home Dashboard
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const PadCareHomeDashboardScreen(),
      ),

      // 6. Live Map Discovery
      GoRoute(
        path: '/map',
        builder: (context, state) {
          final q = state.uri.queryParameters['q'];
          return LiveMapDiscoveryScreen(initialQuery: q);
        },
      ),

      // 7. Add Distribution Point
      GoRoute(
        path: '/add-distribution-point',
        builder: (context, state) => const AddDistributionPointScreen(),
      ),

      // 8. Distribution Point Details
      GoRoute(
        path: '/hub-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'hub_kisenyi';
          return DistributionPointDetailsScreen(hubId: id);
        },
      ),

      // 9. Discreet Request Flow
      GoRoute(
        path: '/requests',
        builder: (context, state) => const DiscreetRequestFlowScreen(),
      ),

      // 10. Discreet Messaging
      GoRoute(
        path: '/messaging',
        builder: (context, state) => const DiscreetMessagingScreen(),
      ),

      // 11. In-App Notifications Center
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsCenterScreen(),
      ),

      // 12. HerHelp Assistant
      GoRoute(
        path: '/herhelp',
        builder: (context, state) => const HerHelpAssistantScreen(),
      ),

      // 13. User Profile / Privacy Settings
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfilePrivacyScreen(),
      ),

      // 14. Support / Donations 1
      GoRoute(
        path: '/donations',
        builder: (context, state) => const SupportDonationsScreen1(),
      ),

      // 15. Support / Donations 2
      GoRoute(
        path: '/donations-step2',
        builder: (context, state) {
          final amount = num.tryParse(state.uri.queryParameters['amount'] ?? '15000') ?? 15000;
          final kit = int.tryParse(state.uri.queryParameters['kit'] ?? '80') ?? 80;
          final dev = int.tryParse(state.uri.queryParameters['dev'] ?? '20') ?? 20;
          final freq = state.uri.queryParameters['freq'] ?? 'One-time';
          return SupportDonationsScreen2(
            amount: amount,
            kitPercent: kit,
            devPercent: dev,
            frequency: freq,
          );
        },
      ),

      // 16. Support / Donations 3
      GoRoute(
        path: '/donations-step3',
        builder: (context, state) {
          final amount = num.tryParse(state.uri.queryParameters['amount'] ?? '15000') ?? 15000;
          final kit = int.tryParse(state.uri.queryParameters['kit'] ?? '80') ?? 80;
          final dev = int.tryParse(state.uri.queryParameters['dev'] ?? '20') ?? 20;
          final provider = state.uri.queryParameters['provider'] ?? 'mtnMomo';
          final phone = state.uri.queryParameters['phone'] ?? '+256 772 449 881';
          return SupportDonationsScreen3(
            amount: amount,
            kitPercent: kit,
            devPercent: dev,
            providerName: provider,
            phone: phone,
          );
        },
      ),

      // 17. Donation Receipt Confirmation
      GoRoute(
        path: '/donation-receipt',
        builder: (context, state) {
          final amount = num.tryParse(state.uri.queryParameters['amount'] ?? '15000') ?? 15000;
          final ref = state.uri.queryParameters['ref'] ?? 'TXN-EAC-202505-8842';
          final provider = state.uri.queryParameters['provider'] ?? 'mtnMomo';
          final phone = state.uri.queryParameters['phone'] ?? '+256 772 449 881';
          return DonationReceiptScreen(
            amount: amount,
            reference: ref,
            providerName: provider,
            phone: phone,
          );
        },
      ),

      // 18. Supplier Dashboard
      GoRoute(
        path: '/supplier',
        builder: (context, state) => const SupplierDashboardScreen(),
      ),

      // 19. Stock Management
      GoRoute(
        path: '/stock',
        builder: (context, state) => const StockManagementScreen(),
      ),

      // 20. Admin Verification Dashboard
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminVerificationDashboardScreen(),
      ),

      // 21. Full Offline Queue Sync Manager
      GoRoute(
        path: '/sync',
        builder: (context, state) => const FullOfflineQueueSyncScreen(),
      ),

      // 22. Offline Sync Confirmation
      GoRoute(
        path: '/offline-sync-confirmation',
        builder: (context, state) => const OfflineSyncConfirmationScreen(),
      ),

      // 23. Sync Conflict Resolution
      GoRoute(
        path: '/sync-conflict',
        builder: (context, state) => const SyncConflictResolutionScreen(),
      ),
    ],
  );
}
