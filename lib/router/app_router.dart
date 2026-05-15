import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/core/app_session.dart';
import '../product/auth/view/auth_view.dart';
import '../product/auth/view/otp_verify_view.dart';
import '../product/register/view/register_admin_view.dart';
import '../product/shell/main_shell.dart';
import '../product/register/view/register_view.dart';
import '../product/welcome/welcome_view.dart';

final appRouter = GoRouter(
  initialLocation: '/welcome',
  redirect: (context, state) {
    final loggedIn = AppSession.instance.isLoggedIn;
    final onAuth = state.matchedLocation == '/welcome' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation.startsWith('/register') ||
        state.matchedLocation.startsWith('/otp');

    if (loggedIn && onAuth) return '/home';
    if (!loggedIn && !onAuth) return '/welcome';
    return null;
  },
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (_, __) => const WelcomeView(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const AuthView(),
    ),
    GoRoute(
      path: '/register-admin',
      builder: (_, __) => const RegisterAdminView(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final token   = state.uri.queryParameters['invite_token'] ?? '';
        final orgName = state.uri.queryParameters['org_name']     ?? '';
        return RegisterView(inviteToken: token, orgName: orgName);
      },
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final gsm = state.uri.queryParameters['gsm'] ?? '';
        return OtpVerifyView(gsmNumber: gsm);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const MainShell(),
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Sayfa bulunamadı: ${state.error}')),
  ),
);
