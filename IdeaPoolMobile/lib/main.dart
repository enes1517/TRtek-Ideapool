import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uygulama her açıldığında oturumu temizle (Her zaman Login ekranından başlasın)
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');

  final container = ProviderContainer();
  await container.read(authProvider.notifier).checkAuth();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouter sağlayıcısını dinle
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TRtek Fikir Havuzu',
      debugShowCheckedModeBanner: false,
      
      // Temalarımızı entegre ediyoruz
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Her zaman açık (beyaz) temayı kullan
      
      // Router entegrasyonu
      routerConfig: router,
    );
  }
}
