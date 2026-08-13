import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'package:flutter/foundation.dart';
import '../providers/idea_provider.dart';

class CreateIdeaView extends ConsumerStatefulWidget {
  const CreateIdeaView({super.key});

  @override
  ConsumerState<CreateIdeaView> createState() => _CreateIdeaViewState();
}

class _CreateIdeaViewState extends ConsumerState<CreateIdeaView> {
  String _selectedCategory = 'Ürün'; // Varsayılan seçim
  final _titleController = TextEditingController();
  final _benefitController = TextEditingController();
  final _descriptionController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _benefitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Fikir/Öneri Ekle'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Fikir/Öneri Başlığı',
              hint: 'Örn: Şirket içi eğitim portalı',
              controller: _titleController,
            ),
            const SizedBox(height: 24),
            
            Text(
              'Konu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            // Segmented Control (Ürün, Hizmet, Süreç)
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Ürün', label: Text('Ürün')),
                ButtonSegment(value: 'Hizmet', label: Text('Hizmet')),
                ButtonSegment(value: 'Süreç', label: Text('Süreç')),
              ],
              selected: {_selectedCategory},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedCategory = newSelection.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return null;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.primary;
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            CustomTextField(
              label: 'Amaçlanan Fayda',
              hint: 'Bu fikir uygulanırsa ne gibi bir fayda sağlar?',
              maxLines: 3,
              controller: _benefitController,
            ),
            const SizedBox(height: 24),

            CustomTextField(
              label: 'Açıklama',
              hint: 'Fikrinizin detaylarını buraya yazabilirsiniz...',
              maxLines: 5,
              controller: _descriptionController,
            ),
            const SizedBox(height: 24),

            // Doküman Ekleme Alanı (Dashed Border Simülasyonu)
            Text(
              'Doküman(lar)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
                if (result != null) {
                  setState(() {
                    _selectedFile = result.files.single;
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.02),
                  border: Border.all(color: AppColors.border, width: 1.5, style: BorderStyle.solid), // İleride dotted/dashed paket eklenebilir
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload, size: 32, color: _selectedFile != null ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFile?.name ?? 'PDF, resim veya belge yüklemek için dokunun',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _selectedFile != null ? AppColors.primary : null,
                        fontWeight: _selectedFile != null ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            CustomButton(
              text: _isUploading ? 'Gönderiliyor...' : 'Gönder',
              icon: Icons.send,
              onPressed: _isUploading ? null : () async {
                if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _benefitController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen tüm alanları doldurunuz.')),
                  );
                  return;
                }

                setState(() => _isUploading = true);

                try {
                  String? uploadedUrl;
                  if (_selectedFile != null) {
                    uploadedUrl = await ApiService.uploadFile(
                      'api/Idea/upload',
                      bytes: _selectedFile!.bytes,
                      filePath: kIsWeb ? null : _selectedFile!.path,
                      filename: _selectedFile!.name,
                    );
                  }

                  int categoryInt = 1; // Ürün
                  if (_selectedCategory == 'Hizmet') categoryInt = 2;
                  if (_selectedCategory == 'Süreç') categoryInt = 3;

                  final success = await ref.read(ideaProvider.notifier).createIdea({
                    'title': _titleController.text,
                    'category': categoryInt,
                    'benefit': _benefitController.text,
                    'description': _descriptionController.text,
                    'documentUrl': uploadedUrl, 
                  });

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fikriniz başarıyla gönderildi!')),
                    );
                    context.go('/feed');
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gönderim sırasında hata oluştu.')),
                    );
                  }
                } catch (e) {
                   if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: $e')),
                      );
                   }
                } finally {
                  if (mounted) {
                    setState(() => _isUploading = false);
                  }
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
        ),
      ),
    );
  }
}
