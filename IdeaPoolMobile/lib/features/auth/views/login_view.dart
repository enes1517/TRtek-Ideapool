import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
  }

  void _handleGoogleLogin() {
    ref.read(authProvider.notifier).loginWithGoogle();
  }

  void _showGoogleRegistrationSheet(BuildContext context, WidgetRef ref) {
    final identityController = TextEditingController();
    final registrationController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kaydınızı Tamamlayın',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Kurumsal hesabınız için eksik bilgileri giriniz.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'TC Kimlik No',
                hint: '11 Haneli',
                keyboardType: TextInputType.number,
                controller: identityController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Sicil No',
                hint: 'Kurum Sicil',
                controller: registrationController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Telefon Numarası',
                hint: '0555 555 5555',
                keyboardType: TextInputType.phone,
                controller: phoneController,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Tamamla ve Giriş Yap',
                onPressed: () async {
                  if (identityController.text.isEmpty || registrationController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('TC ve Sicil zorunludur.')));
                    return;
                  }
                  final success = await ref.read(authProvider.notifier).completeGoogleRegistration(
                        identityController.text,
                        registrationController.text,
                        phoneController.text,
                      );
                  if (success && ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).cancelGoogleRegistration();
                  Navigator.pop(ctx);
                },
                child: const Text('İptal Et', style: TextStyle(color: AppColors.error)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Eğer giriş başarılıysa router otomatik yönlendirecek, ama state değişimi dinleyebiliriz:
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      
      // Google ile ilk kez giren kullanıcı eksik bilgileri tamamlamalı
      if (previous?.pendingGoogleToken == null && next.pendingGoogleToken != null) {
        _showGoogleRegistrationSheet(context, ref);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                Icon(
                  Icons.lightbulb,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  "TRtek Fikir Havuzu",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Giriş Yaparak Fikirlerinizi Paylaşın",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),

                // Form
                CustomTextField(
                  label: "E-Posta Adresi",
                  hint: "ornek@trtek.com",
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Şifre",
                  hint: "••••••••",
                  controller: _passwordController,
                  prefixIcon: Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 32),

                // Butonlar
                CustomButton(
                  text: "Giriş Yap",
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("VEYA"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: "Google ile Devam Et",
                  isOutlined: true,
                  icon: Icons.login,
                  onPressed: authState.isLoading ? null : _handleGoogleLogin,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hesabın yok mu?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        "Kayıt Ol",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
