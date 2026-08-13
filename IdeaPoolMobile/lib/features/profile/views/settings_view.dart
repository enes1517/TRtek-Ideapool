import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Karanlık Tema'),
                subtitle: const Text('Uygulama temasını karanlık yapar.'),
                value: false, // Tema yönetimi eklendiğinde bağlanacak
                onChanged: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tema yönetimi MVP sonrasında eklenecektir.')));
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('E-posta Bildirimleri'),
                subtitle: const Text('Fikirlerinizle ilgili güncellemeleri mail olarak alın.'),
                value: true,
                onChanged: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bildirim tercihleri kaydedildi.')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
