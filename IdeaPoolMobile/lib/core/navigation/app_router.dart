import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/views/main_layout.dart';
import '../../features/idea/views/idea_feed_view.dart';
import '../../features/idea/views/create_idea_view.dart';
import '../../features/admin/views/user_management_view.dart';
import '../../features/idea/views/idea_detail_view.dart';
import '../../features/idea/models/idea_model.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/profile/views/my_ideas_view.dart';
import '../../features/profile/views/favorite_ideas_view.dart';
import '../../features/profile/views/password_security_view.dart';
import '../../features/profile/views/settings_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStateNotifier = ValueNotifier<bool>(false);

  // Sadece isAuthenticated değiştiğinde GoRouter'a haber ver
  ref.listen(authProvider.select((val) => val.isAuthenticated), (prev, next) {
    authStateNotifier.value = next;
  });

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final isAuth = ref.read(authProvider).isAuthenticated;
      
      // matchedLocation bazen null dönebilir, uri üzerinden kontrol daha güvenli
      final path = state.uri.path;
      final isLoggingIn = path == '/login';
      final isRegistering = path == '/register';

      if (!isAuth && !isLoggingIn && !isRegistering) return '/login';
      if (isAuth && (isLoggingIn || isRegistering)) return '/feed';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/feed',
            builder: (context, state) => const IdeaFeedView(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final idea = state.extra as IdeaModel;
                  return IdeaDetailView(idea: idea);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) => const CreateIdeaView(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const UserManagementView(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileView(),
            routes: [
              GoRoute(
                path: 'my-ideas',
                builder: (context, state) => const MyIdeasView(),
              ),
              GoRoute(
                path: 'favorites',
                builder: (context, state) => const FavoriteIdeasView(),
              ),
              GoRoute(
                path: 'security',
                builder: (context, state) => const PasswordSecurityView(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsView(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
