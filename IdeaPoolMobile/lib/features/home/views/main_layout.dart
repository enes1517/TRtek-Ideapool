import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final hasGrantPerm = user?.permissions.contains('KullaniciYetkiEkleme') ?? false;
    final hasRevokePerm = user?.permissions.contains('KullaniciYetkiSilme') ?? false;
    final showAdminTab = hasGrantPerm || hasRevokePerm;

    // Define all possible tabs
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home),
        selectedIcon: Icon(Icons.home, color: AppColors.primary),
        label: 'Fikirler',
      ),
      const NavigationDestination(
        icon: Icon(Icons.add_circle_outline),
        selectedIcon: Icon(Icons.add_circle_outline, color: AppColors.primary),
        label: 'Yeni Ekle',
      ),
    ];

    if (showAdminTab) {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.people),
          selectedIcon: Icon(Icons.people, color: AppColors.primary),
          label: 'Yönetim',
        ),
      );
    }

    destinations.add(
      const NavigationDestination(
        icon: Icon(Icons.account_circle),
        selectedIcon: Icon(Icons.account_circle, color: AppColors.primary),
        label: 'Profil',
      ),
    );

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex >= destinations.length ? destinations.length - 1 : _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) context.go('/feed');
            if (index == 1) context.go('/create');
            if (index == 2 && showAdminTab) context.go('/admin');
            if ((index == 2 && !showAdminTab) || index == 3) context.go('/profile');
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          indicatorColor: AppColors.accent.withOpacity(0.2),
          destinations: destinations,
        ),
      ),
    );
  }
}
