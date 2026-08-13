import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../api_service.dart';

class EvaluationBottomSheet extends StatefulWidget {
  final int ideaId;
  const EvaluationBottomSheet({super.key, required this.ideaId});

  @override
  State<EvaluationBottomSheet> createState() => _EvaluationBottomSheetState();
}

class _EvaluationBottomSheetState extends State<EvaluationBottomSheet> {
  bool _isApproved = true;
  double _score = 80;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitEvaluation() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Açıklama boş bırakılamaz.')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.post('api/evaluations', {
        'ideaId': widget.ideaId,
        'score': _score.toInt(),
        'explanation': _commentController.text,
        'isApproved': _isApproved,
      });
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Değerlendirme başarıyla kaydedildi.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fikri Değerlendir',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Karar (Olumlu / Olumsuz)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isApproved = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isApproved ? AppColors.success.withOpacity(0.1) : Colors.transparent,
                      border: Border.all(
                        color: _isApproved ? AppColors.success : AppColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Olumlu',
                        style: TextStyle(
                          color: _isApproved ? AppColors.success : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isApproved = false),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: !_isApproved ? AppColors.error.withOpacity(0.1) : Colors.transparent,
                      border: Border.all(
                        color: !_isApproved ? AppColors.error : AppColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Olumsuz',
                        style: TextStyle(
                          color: !_isApproved ? AppColors.error : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Puanlama Slider
          Text(
            'Puan: ${_score.toInt()}/100',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _score,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _score = val;
              });
            },
          ),
          const SizedBox(height: 16),

          // Açıklama
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Değerlendirme notunuzu buraya yazın...',
            ),
          ),
          const SizedBox(height: 24),

          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: 'Değerlendirmeyi Kaydet',
                  icon: Icons.check_circle,
                  onPressed: _submitEvaluation,
                ),
        ],
      ),
    );
  }
}
