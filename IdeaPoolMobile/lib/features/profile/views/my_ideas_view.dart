import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../idea/providers/idea_provider.dart';
import '../../idea/widgets/idea_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/theme/app_colors.dart';

class MyIdeasView extends ConsumerWidget {
  const MyIdeasView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final ideaState = ref.watch(ideaProvider);

    final ideaList = ideaState.value ?? [];

    // Sadece mevcut kullanıcının fikirlerini filtrele
    final myIdeas = currentUser != null 
        ? ideaList.where((idea) => idea.userId == currentUser.id).toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fikir Geçmişim'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ideaState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ideaState.hasError
                  ? Center(
                      child: Text(
                        'Hata: ${ideaState.error}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    )
                  : myIdeas.isEmpty
                      ? EmptyStateView(
                          icon: Icons.history,
                          title: 'Henüz Bir Fikir Paylaşmadınız',
                          message: 'İlk fikrinizi paylaşarak yeniliklere öncülük edin!',
                          buttonText: 'Yeni Fikir Paylaş',
                          onButtonPressed: () {
                            context.go('/create');
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: myIdeas.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final idea = myIdeas[index];
                            return IdeaCard(
                              idea: idea,
                              onTap: () => context.go('/feed/detail', extra: idea),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
