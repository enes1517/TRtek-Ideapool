import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/idea_model.dart';

class IdeaCard extends StatelessWidget {
  final IdeaModel idea;
  final VoidCallback? onTap;

  const IdeaCard({
    super.key,
    required this.idea,
    this.onTap,
  });

  BadgeStatus _getStatus(String st) {
    if (st.toLowerCase() == 'onaylandı') return BadgeStatus.success;
    if (st.toLowerCase() == 'reddedildi') return BadgeStatus.error;
    return BadgeStatus.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Kısım: Avatar, Yazar, Kategori Çipi
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      idea.userFullName[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      idea.userFullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(
                    text: idea.status,
                    status: _getStatus(idea.status),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Orta Kısım: Başlık
              Text(
                idea.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Alt Kısım: Tarih, Durum ve Ekstra İkonlar
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(idea.createdAt),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const Spacer(),
                  if (idea.documentUrl != null && idea.documentUrl!.isNotEmpty) ...[
                    Icon(Icons.attach_file, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                  ],
                  if (idea.evaluation != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            (idea.evaluation!['score'] ?? 0).toString(),
                            style: const TextStyle(
                                color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
