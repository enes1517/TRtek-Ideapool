import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../evaluation/views/evaluation_bottom_sheet.dart';
import '../models/idea_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../api_service.dart';
import '../providers/idea_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class IdeaDetailView extends ConsumerStatefulWidget {
  final IdeaModel idea;
  const IdeaDetailView({super.key, required this.idea});

  @override
  ConsumerState<IdeaDetailView> createState() => _IdeaDetailViewState();
}

class _IdeaDetailViewState extends ConsumerState<IdeaDetailView> {
  bool _hasLiveEvalPerm = false;
  bool _isPermsLoaded = false;
  IdeaModel? _currentIdea;

  @override
  void initState() {
    super.initState();
    _currentIdea = widget.idea;
    _fetchLivePermissions();
  }

  bool _isFavorite = false;
  bool _isFavoriteLoading = false;

  Future<void> _fetchIdeaDetails() async {
    try {
      final response = await ApiService.get('api/Idea/${widget.idea.id}');
      final favResponse = await ApiService.get('api/Idea/favorites');
      
      if (mounted) {
        setState(() {
          if (response != null) _currentIdea = IdeaModel.fromJson(response);
          if (favResponse != null && favResponse is List) {
            _isFavorite = favResponse.any((fav) => fav['id'] == widget.idea.id);
          }
        });
      }
    } catch (e) {
      debugPrint("Fikir güncellenirken hata: $e");
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading) return;
    setState(() => _isFavoriteLoading = true);
    try {
      await ApiService.post('api/Idea/${widget.idea.id}/favorite', {});
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isFavorite ? 'Favorilere eklendi.' : 'Favorilerden çıkarıldı.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isFavoriteLoading = false);
    }
  }

  Future<void> _fetchLivePermissions() async {
    try {
      final currentUser = ref.read(authProvider).user;
      if (currentUser != null) {
        final resp = await ApiService.get('api/Permission/user/${currentUser.id}');
        if (resp != null) {
          final perms = resp as List;
          if (mounted) {
            setState(() {
              _hasLiveEvalPerm = perms.any((p) => p['code'] == 'FikirDegerlendirme');
              _isPermsLoaded = true;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPermsLoaded = true);
      }
    }
  }

  void _showEvaluationSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => EvaluationBottomSheet(ideaId: widget.idea.id),
    );
    
    // Eğer değerlendirme yapıldıysa ve geri dönüldüyse güncel veriyi çek
    if (result == true) {
      await _fetchIdeaDetails();
      ref.read(ideaProvider.notifier).fetchIdeas();
    }
  }

  BadgeStatus _getStatus(String st) {
    if (st.toLowerCase() == 'onaylandı') return BadgeStatus.success;
    if (st.toLowerCase() == 'reddedildi') return BadgeStatus.error;
    return BadgeStatus.warning;
  }

  @override
  Widget build(BuildContext context) {
    final idea = _currentIdea ?? widget.idea;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fikir Detayı'),
        actions: [
          IconButton(
            icon: _isFavoriteLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isFavorite ? Icons.star : Icons.star_border,
                    color: _isFavorite ? AppColors.accent : null,
                  ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori & Durum
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        idea.category,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StatusBadge(text: idea.status, status: _getStatus(idea.status)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Başlık
                Text(
                  idea.title,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 24),
                
                // Yazar ve Tarih Kutusu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          idea.userFullName.isNotEmpty ? idea.userFullName[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              idea.userFullName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(idea.createdAt),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // İçerik Başlıkları
                Text('Amaçlanan Fayda', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  idea.benefit,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 24),

                Text('Detaylı Açıklama', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  idea.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 32),

                // Ekli Dokümanlar (Varsa)
                if (idea.documentUrl != null && idea.documentUrl!.isNotEmpty) ...[
                  Text('Ekli Dokümanlar', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final url = Uri.parse('${ApiService.baseUrl}${idea.documentUrl}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dosya açılamadı.')));
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              idea.documentUrl ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                          const Icon(Icons.download, color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Değerlendirme Sonucu
                if (idea.evaluation != null) ...[
                  Text('Değerlendirme Sonucu', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: idea.evaluation['isApproved'] == true 
                            ? [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.05)]
                            : [AppColors.error.withOpacity(0.1), AppColors.error.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: idea.evaluation['isApproved'] == true ? AppColors.success.withOpacity(0.5) : AppColors.error.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  idea.evaluation['isApproved'] == true ? Icons.verified : Icons.cancel,
                                  color: idea.evaluation['isApproved'] == true ? AppColors.success : AppColors.error,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  idea.evaluation['isApproved'] == true ? 'Onaylandı' : 'Reddedildi',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: idea.evaluation['isApproved'] == true ? AppColors.success : AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: idea.evaluation['isApproved'] == true ? AppColors.success : AppColors.error,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Puan: ${idea.evaluation['score']}/100',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.person, color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Değerlendiren: ${idea.evaluation['evaluatorFullName'] ?? 'Bilinmiyor'}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        if (idea.evaluation['evaluatedAt'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Tarih: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(idea.evaluation['evaluatedAt']))}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'Açıklama:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          idea.evaluation['explanation'] ?? 'Açıklama girilmemiş.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: (_isPermsLoaded && _hasLiveEvalPerm) 
        ? FloatingActionButton.extended(
            onPressed: () => _showEvaluationSheet(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('Değerlendir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ) 
        : null,
    );
  }
}
