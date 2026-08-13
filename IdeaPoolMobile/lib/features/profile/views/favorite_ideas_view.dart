import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../idea/widgets/idea_card.dart';
import '../../../api_service.dart';
import '../../idea/models/idea_model.dart';
import 'package:go_router/go_router.dart';

class FavoriteIdeasView extends ConsumerStatefulWidget {
  const FavoriteIdeasView({super.key});

  @override
  ConsumerState<FavoriteIdeasView> createState() => _FavoriteIdeasViewState();
}

class _FavoriteIdeasViewState extends ConsumerState<FavoriteIdeasView> {
  List<IdeaModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('api/Idea/favorites');
      if (response != null && response is List) {
        if (mounted) {
          setState(() {
            _favorites = response.map((e) => IdeaModel.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Fikirler'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_border, size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text('Henüz favori fikriniz yok.', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final idea = _favorites[index];
                        return GestureDetector(
                          onTap: () {
                            context.push('/feed/detail', extra: idea).then((_) => _fetchFavorites());
                          },
                          child: IdeaCard(idea: idea),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
