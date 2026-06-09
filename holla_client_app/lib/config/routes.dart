import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/client/home/home_screen.dart';
import '../features/client/orders/orders_screen.dart';
import '../features/client/orders/order_detail_screen.dart';
import '../features/client/services/services_screen.dart';
import '../features/client/chat/chat_screen.dart';
import '../features/client/profile/profile_screen.dart';
import '../features/client/home/partner_detail_screen.dart';
import '../features/client/orders/tracking_screen.dart';
import '../features/client/orders/payment_screen.dart';
import '../features/client/services/service_selection_screen.dart';
import '../shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth  = session != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuth && !isAuthRoute) return '/auth/login';
      if (isAuth && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // ── Auth ────────────────────────────────────────────
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Shell tabs client ────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/',            builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/orders',      builder: (_, __) => const OrdersScreen()),
          GoRoute(path: '/services',    builder: (_, __) => const ServicesScreen()),
          GoRoute(path: '/chat',        builder: (_, __) => const ChatScreen()),
          GoRoute(path: '/profile',     builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Screens ─────────────────────────────────────────
      GoRoute(
        path: '/partner/:id',
        builder: (_, state) => PartnerDetailScreen(
          partnerId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) => OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      /*GoRoute(
        path: '/tracking/:id',
        builder: (_, state) => TrackingScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),*/
      GoRoute(
        path: '/payment',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentScreen(
            orderId:     extra['orderId'],
            amount:      extra['amount'],
            deliveryFee: extra['deliveryFee'],
          );
        },
      ),
      /*GoRoute(
        path: '/service-selection/:skill',
        builder: (_, state) => ServiceSelectionScreen(
          skill: state.pathParameters['skill']!,
        ),
      ), */
    ],  
  );
}); 