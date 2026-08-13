import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../api_service.dart';

class PasswordSecurityView extends ConsumerStatefulWidget {
  const PasswordSecurityView({super.key});

  @override
  ConsumerState<PasswordSecurityView> createState() => _PasswordSecurityViewState();
}

class _PasswordSecurityViewState extends ConsumerState<PasswordSecurityView> {
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isSaving = false;

  Future<void> _changePassword() async {
    if (_oldPasswordCtrl.text.isEmpty || _newPasswordCtrl.text.isEmpty || _confirmPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm alanları doldurun.')));
      return;
    }
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni şifreler eşleşmiyor.')));
      return;
    }
    if (_newPasswordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni şifre en az 6 karakter olmalıdır.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ApiService.post('api/User/change-password', {
        'oldPassword': _oldPasswordCtrl.text,
        'newPassword': _newPasswordCtrl.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şifreniz başarıyla güncellendi!')));
        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Şifre ve Güvenlik')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Şifrenizi güvenli tutmak için en az 6 karakter uzunluğunda, güçlü bir şifre seçin.'),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Mevcut Şifre',
                  controller: _oldPasswordCtrl,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Yeni Şifre',
                  controller: _newPasswordCtrl,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Yeni Şifre (Tekrar)',
                  controller: _confirmPasswordCtrl,
                  isPassword: true,
                ),
                const SizedBox(height: 48),
                CustomButton(
                  text: _isSaving ? 'Kaydediliyor...' : 'Şifreyi Güncelle',
                  onPressed: _isSaving ? null : _changePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
