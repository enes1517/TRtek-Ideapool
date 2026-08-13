import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/ui_helpers.dart';
import 'package:go_router/go_router.dart';
import '../widgets/avatar_selection_sheet.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AvatarSelectionSheet(),
                    );
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary,
                    backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!) // Use network image
                        : null,
                    child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Giriş Yapmış Kullanıcı',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'kullanici@trtek.com',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),

                ListTile(
                  leading: const Icon(Icons.history, color: AppColors.primary),
                  title: const Text('Fikir Geçmişim'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.go('/profile/my-ideas');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.star, color: AppColors.accent),
                  title: const Text('Favori Fikirler'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/profile/favorites');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.security, color: AppColors.textPrimary),
                  title: const Text('Şifre ve Güvenlik'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/profile/security');
                  },
                ),
                const Divider(),
                
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Çıkış Yap',
                  icon: Icons.logout,
                  isOutlined: true,
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
