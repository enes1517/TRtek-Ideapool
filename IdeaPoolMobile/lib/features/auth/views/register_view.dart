import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _identityNumberController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _identityNumberController.dispose();
    _registrationNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).register({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'phone': _phoneController.text,
        'registrationNumber': _registrationNumberController.text,
        'identityNumber': _identityNumberController.text,
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarılı! Lütfen giriş yapın.'), backgroundColor: AppColors.success),
        );
        context.go('/login');
      } else if (mounted) {
        final error = ref.read(authProvider).error ?? 'Kayıt olurken bir hata oluştu.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Aramıza Katıl",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Lütfen kurum bilgilerinizi eksiksiz doldurun.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Adınız',
                        hint: 'Örn: Ahmet',
                        controller: _firstNameController,
                        validator: (val) => val == null || val.isEmpty ? 'Zorunlu alan' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Soyadınız',
                        hint: 'Örn: Yılmaz',
                        controller: _lastNameController,
                        validator: (val) => val == null || val.isEmpty ? 'Zorunlu alan' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'TC Kimlik No',
                        hint: '11 Haneli',
                        keyboardType: TextInputType.number,
                        controller: _identityNumberController,
                        validator: (val) => val == null || val.length != 11 ? 'Geçersiz TC' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Sicil No',
                        hint: 'Kurum Sicil',
                        controller: _registrationNumberController,
                        validator: (val) => val == null || val.isEmpty ? 'Zorunlu alan' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Telefon Numarası',
                  hint: '0555 555 5555',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  prefixIcon: Icons.phone,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Kurumsal E-Posta',
                  hint: 'ornek@trtek.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  validator: (val) => val == null || !val.contains('@') ? 'Geçerli e-posta girin' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Şifre',
                  hint: '••••••••',
                  isPassword: true,
                  controller: _passwordController,
                  prefixIcon: Icons.lock,
                  validator: (val) => val == null || val.length < 6 ? 'En az 6 karakter' : null,
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Hesabımı Oluştur',
                  isLoading: authState.isLoading,
                  icon: Icons.person_add,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),
              ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
