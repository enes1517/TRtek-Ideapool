import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/ui_helpers.dart';
import '../models/idea_model.dart';
import '../providers/idea_provider.dart';
import '../widgets/idea_card.dart';

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final dateRangeProvider = StateProvider.autoDispose<DateTimeRange?>((ref) => null);

class IdeaFeedView extends ConsumerWidget {
  const IdeaFeedView({super.key});

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filtrele', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Tarih Aralığı Seç'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final currentRange = ref.read(dateRangeProvider);
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: currentRange,
                  );
                  if (picked != null) {
                    ref.read(dateRangeProvider.notifier).state = picked;
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.apps),
                title: const Text('Tümü / Sıfırla'),
                onTap: () {
                  ref.read(ideaProvider.notifier).fetchIdeas(categoryId: null);
                  ref.read(dateRangeProvider.notifier).state = null;
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2),
                title: const Text('Ürün'),
                onTap: () {
                  ref.read(ideaProvider.notifier).fetchIdeas(categoryId: 1);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.build),
                title: const Text('Hizmet'),
                onTap: () {
                  ref.read(ideaProvider.notifier).fetchIdeas(categoryId: 2);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_tree),
                title: const Text('Süreç'),
                onTap: () {
                  ref.read(ideaProvider.notifier).fetchIdeas(categoryId: 3);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasAsync = ref.watch(ideaProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fikir Havuzu'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
          // Filtreleme / Arama Çubuğu
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: '',
                    hint: 'Fikirlerde ara...',
                    prefixIcon: Icons.search,
                    onChanged: (val) {
                      ref.read(searchQueryProvider.notifier).state = val;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () {
                      _showFilterBottomSheet(context, ref);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Fikir Listesi
          Expanded(
            child: ideasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Hata: $err')),
              data: (ideas) {
                final query = searchQuery.toLowerCase();
                var filteredIdeas = query.isEmpty 
                    ? ideas 
                    : ideas.where((idea) {
                        return idea.title.toLowerCase().contains(query) ||
                               idea.description.toLowerCase().contains(query) ||
                               idea.userFullName.toLowerCase().contains(query);
                      }).toList();

                if (dateRange != null) {
                   filteredIdeas = filteredIdeas.where((idea) {
                     return idea.createdAt.isAfter(dateRange.start.subtract(const Duration(days: 1))) && 
                            idea.createdAt.isBefore(dateRange.end.add(const Duration(days: 1)));
                   }).toList();
                }

                if (filteredIdeas.isEmpty) {
                  return const Center(child: Text("Henüz fikir yok veya eşleşen sonuç bulunamadı."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredIdeas.length,
                  itemBuilder: (context, index) {
                    final idea = filteredIdeas[index];
                    return IdeaCard(
                      idea: idea,
                      onTap: () => context.go('/feed/detail', extra: idea),
                    );
                  },
                );
              },
            ),
          ),
          ],
        ),
        ),
      ),
    );
  }
}
