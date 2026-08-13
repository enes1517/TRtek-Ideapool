import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../api_service.dart';

class AvatarSelectionSheet extends ConsumerStatefulWidget {
  const AvatarSelectionSheet({super.key});

  @override
  ConsumerState<AvatarSelectionSheet> createState() => _AvatarSelectionSheetState();
}

class _AvatarSelectionSheetState extends ConsumerState<AvatarSelectionSheet> {
  final List<String> _avatars = [
    'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Mimi',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Oliver',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Sam',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Jack',
  ];

  bool _isSaving = false;

  Future<void> _selectAvatar(String avatar) async {
    setState(() => _isSaving = true);
    try {
      await ApiService.patch('api/User/avatar', {'avatarUrl': avatar});
      if (mounted) {
        ref.read(authProvider.notifier).updateAvatarLocal(avatar);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil fotoğrafı güncellendi!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Profil Fotoğrafı Seç', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          if (_isSaving)
            const CircularProgressIndicator()
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _avatars.map((avatar) {
                return GestureDetector(
                  onTap: () => _selectAvatar(avatar),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.surface,
                    backgroundImage: NetworkImage(avatar),
                    onBackgroundImageError: (_, __) {},
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
