import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/view/login_screen.dart';
import '../features/booking/view/booking_screen.dart';
import '../features/booking/view/booking_success_screen.dart';
import '../features/booking/view/payment_screen.dart';
import '../features/car_detail/view/car_detail_screen.dart';
import '../features/eligibility/view/eligibility_screen.dart';
import '../features/eligibility/view/keyless_info_screen.dart';
import '../features/home/view/home_screen.dart';
import '../features/identity/view/identity_scan_screen.dart';
import '../features/inspection/bloc/inspection_state.dart';
import '../features/inspection/view/video_360_screen.dart';
import '../features/messages/view/conversation_screen.dart';
import '../features/messages/view/messages_screen.dart';
import '../features/my_rentals/view/my_rentals_screen.dart';
import '../features/profile/view/profile_screen.dart';
import '../features/rental/view/active_rental_screen.dart';
import '../features/rental_detail/view/rental_detail_screen.dart';
import '../features/return/view/return_success_screen.dart';
import '../features/shell/view/main_shell.dart';
import '../features/search_choice/view/search_choice_screen.dart';
import '../features/splash/view/splash_screen.dart';
import '../features/unlock/view/bluetooth_lock_screen.dart';
import '../features/unlock/view/bluetooth_unlock_screen.dart';
import '../features/wizard/view/wizard_screen.dart';

CustomTransitionPage<T> _slideFadePage<T>({
  required LocalKey key,
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/search-choice', builder: (_, __) => const SearchChoiceScreen()),
      GoRoute(path: '/wizard', builder: (_, __) => const WizardScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
              path: '/home/explorer',
              builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: '/home/rentals',
              builder: (_, __) => const MyRentalsScreen()),
          GoRoute(
              path: '/home/messages',
              builder: (_, __) => const MessagesScreen()),
GoRoute(
              path: '/home/profile',
              builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/conversation/:id',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: ConversationScreen(
            conversationId: s.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/car/:id',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: CarDetailScreen(carId: s.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/booking/:carId/eligibility',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: EligibilityScreen(carId: s.pathParameters['carId']!),
        ),
      ),
      GoRoute(
        path: '/booking/:carId/keyless-info',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: KeylessInfoScreen(carId: s.pathParameters['carId']!),
        ),
      ),
      GoRoute(
        path: '/booking/:carId',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: BookingScreen(carId: s.pathParameters['carId']!),
        ),
      ),
      GoRoute(
        path: '/booking/:carId/identity',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: IdentityScanScreen(carId: s.pathParameters['carId']!),
        ),
      ),
      GoRoute(
        path: '/booking/:carId/payment',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: PaymentScreen(carId: s.pathParameters['carId']!),
        ),
      ),
      GoRoute(
        path: '/booking/:carId/success',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: BookingSuccessScreen(carId: s.pathParameters['carId']!),
        ),
      ),
      GoRoute(
        path: '/inspection/pickup/:bookingId',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: Video360Screen(
            bookingId: s.pathParameters['bookingId']!,
            mode: InspectionMode.pickup,
          ),
        ),
      ),
      GoRoute(
        path: '/inspection/return/:bookingId',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: Video360Screen(
            bookingId: s.pathParameters['bookingId']!,
            mode: InspectionMode.returnMode,
          ),
        ),
      ),
      GoRoute(
        path: '/unlock/:bookingId',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: BluetoothUnlockScreen(
              bookingId: s.pathParameters['bookingId']!),
        ),
      ),
      GoRoute(
        path: '/lock/:bookingId',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: BluetoothLockScreen(
              bookingId: s.pathParameters['bookingId']!),
        ),
      ),
      GoRoute(
        path: '/rental/:bookingId',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: ActiveRentalScreen(
              bookingId: s.pathParameters['bookingId']!),
        ),
      ),
      GoRoute(
        path: '/booking-detail/:bookingId',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: RentalDetailScreen(
              bookingId: s.pathParameters['bookingId']!),
        ),
      ),
      GoRoute(
        path: '/return/success/:bookingId',
        pageBuilder: (_, s) => _slideFadePage(
          key: s.pageKey,
          state: s,
          child: ReturnSuccessScreen(
              bookingId: s.pathParameters['bookingId']!),
        ),
      ),
    ],
    errorBuilder: (_, s) => Scaffold(
      body: Center(child: Text('Route introuvable: ${s.uri}')),
    ),
  );
}
