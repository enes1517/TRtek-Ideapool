import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../api_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/ui_helpers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserManagementView extends ConsumerStatefulWidget {
  const UserManagementView({super.key});

  @override
  ConsumerState<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends ConsumerState<UserManagementView> {
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  bool _hasLiveGrantPerm = false;
  bool _hasLiveRevokePerm = false;
  bool _isLivePermsLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await _fetchLivePermissions();
    await _fetchUsers();
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
              _hasLiveGrantPerm = perms.any((p) => p['code'] == 'KullaniciYetkiEkleme');
              _hasLiveRevokePerm = perms.any((p) => p['code'] == 'KullaniciYetkiSilme');
              _isLivePermsLoaded = true;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLivePermsLoaded = true);
      }
    }
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('api/User');
      if (response != null && response is List) {
        setState(() {
          _allUsers = response.map((u) => u as Map<String, dynamic>).toList();
          _filterUsers();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredUsers = _allUsers.where((user) {
        final name = '${user['firstName']} ${user['lastName']}'.toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }
  }

  Future<void> _toggleUserStatus(int userId, bool currentStatus) async {
    try {
      await ApiService.patch('api/User/$userId/toggle-status');
      _fetchUsers(); // Refresh
    } catch (e) {
      if (mounted) {
        // Hata mesajını detaylı göster (Örn: Yetki yok)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  void _showAddUserBottomSheet() {
    final formKey = GlobalKey<FormState>();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final tcCtrl = TextEditingController();
    final sicilCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Yeni Kullanıcı Ekle', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(label: 'Ad', controller: firstNameCtrl)),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'Soyad', controller: lastNameCtrl)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'E-Posta', controller: emailCtrl),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'Şifre', controller: passwordCtrl, isPassword: true),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'TC Kimlik No', controller: tcCtrl),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'Sicil No', controller: sicilCtrl),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'Telefon No', controller: phoneCtrl),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: isSubmitting ? 'Ekleniyor...' : 'Kullanıcıyı Kaydet',
                      onPressed: isSubmitting ? null : () async {
                        if (firstNameCtrl.text.trim().length < 2) {
                          ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Ad en az 2 karakter olmalıdır.'), backgroundColor: AppColors.error));
                          return;
                        }
                        if (lastNameCtrl.text.trim().length < 2) {
                          ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Soyad en az 2 karakter olmalıdır.'), backgroundColor: AppColors.error));
                          return;
                        }
                        if (!emailCtrl.text.contains('@') || emailCtrl.text.length < 5) {
                          ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Geçerli bir e-posta adresi giriniz.'), backgroundColor: AppColors.error));
                          return;
                        }
                        if (passwordCtrl.text.length < 6) {
                          ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Şifre en az 6 karakter olmalıdır.'), backgroundColor: AppColors.error));
                          return;
                        }
                        
                        setModalState(() => isSubmitting = true);
                        try {
                          final data = {
                            'firstName': firstNameCtrl.text,
                            'lastName': lastNameCtrl.text,
                            'email': emailCtrl.text,
                            'password': passwordCtrl.text,
                            'identityNumber': tcCtrl.text,
                            'registrationNumber': sicilCtrl.text,
                            'phone': phoneCtrl.text,
                          };
                          await ApiService.post('api/Auth/register', data);
                          Navigator.pop(ctx);
                          _fetchUsers();
                          ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Kullanıcı eklendi.')));
                        } catch (e) {
                          ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                        } finally {
                          setModalState(() => isSubmitting = false);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  void _showEditUserBottomSheet(Map<String, dynamic> user) {
    final formKey = GlobalKey<FormState>();
    final firstNameCtrl = TextEditingController(text: user['firstName']);
    final lastNameCtrl = TextEditingController(text: user['lastName']);
    final emailCtrl = TextEditingController(text: user['email']);
    final tcCtrl = TextEditingController(text: user['identityNumber']);
    final sicilCtrl = TextEditingController(text: user['registrationNumber']);
    final phoneCtrl = TextEditingController(text: user['phone']);
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Kullanıcıyı Düzenle', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(label: 'Ad', controller: firstNameCtrl)),
                        const SizedBox(width: 16),
                        Expanded(child: CustomTextField(label: 'Soyad', controller: lastNameCtrl)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'E-Posta', controller: emailCtrl),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'TC Kimlik No', controller: tcCtrl),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'Sicil No', controller: sicilCtrl),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'Telefon No', controller: phoneCtrl),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: isSubmitting ? 'Güncelleniyor...' : 'Kullanıcıyı Güncelle',
                      onPressed: isSubmitting ? null : () async {
                        setModalState(() => isSubmitting = true);
                        try {
                          final data = {
                            'firstName': firstNameCtrl.text,
                            'lastName': lastNameCtrl.text,
                            'email': emailCtrl.text,
                            'identityNumber': tcCtrl.text,
                            'registrationNumber': sicilCtrl.text,
                            'phone': phoneCtrl.text,
                          };
                          await ApiService.put('api/User/${user['id']}', data);
                          Navigator.pop(ctx);
                          _fetchUsers();
                          ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Kullanıcı güncellendi.')));
                        } catch (e) {
                          ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                        } finally {
                          setModalState(() => isSubmitting = false);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  void _showManagePermissionsBottomSheet(Map<String, dynamic> user) {
    int userId = user['id'];
    List<dynamic> allPermissions = [];
    List<dynamic> userPermissions = [];
    bool isLoading = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final hasGrantPerm = _hasLiveGrantPerm;
          final hasRevokePerm = _hasLiveRevokePerm;
          
          if (isLoading) {
             isLoading = false;
             Future.microtask(() async {
                try {
                   final allResp = await ApiService.get('api/Permission');
                   final userResp = await ApiService.get('api/Permission/user/$userId');
                   if (allResp != null) allPermissions = allResp as List;
                   if (userResp != null) userPermissions = userResp as List;
                } catch (e) {
                   if (mounted) {
                     ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Yetkiler alınamadı: $e')));
                   }
                } finally {
                   if (mounted) setModalState(() {});
                }
             });
             return const Padding(
               padding: EdgeInsets.all(48.0),
               child: Center(child: CircularProgressIndicator()),
             );
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${user['firstName']} - Yetkiler', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  if (allPermissions.isEmpty) 
                     const Text('Sistemde tanımlı yetki bulunamadı.'),
                  ...allPermissions.map((perm) {
                     bool hasPerm = userPermissions.any((up) => up['id'] == perm['id']);
                     bool isEnabled = (hasPerm && hasRevokePerm) || (!hasPerm && hasGrantPerm);
                     
                     return CheckboxListTile(
                        title: Text(perm['description'] ?? perm['code']),
                        value: hasPerm,
                        activeColor: AppColors.primary,
                        enabled: isEnabled,
                        onChanged: isEnabled ? (val) async {
                           if (val == null) return;
                           setModalState(() {
                             if (val) {
                               userPermissions.add(perm);
                             } else {
                               userPermissions.removeWhere((up) => up['id'] == perm['id']);
                             }
                           });
                           try {
                             if (val) {
                               await ApiService.post('api/Permission/grant', {'userId': userId, 'permissionId': perm['id']});
                             } else {
                               await ApiService.delete('api/Permission/revoke/$userId/${perm['id']}');
                             }
                           } catch (e) {
                             if (!mounted) return;
                             ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Yetki güncellenemedi: $e')));
                             setModalState(() {
                               if (val) {
                                 userPermissions.removeWhere((up) => up['id'] == perm['id']);
                               } else {
                                 userPermissions.add(perm);
                               }
                             });
                           }
                        } : null,
                     );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLivePermsLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasGrantPerm = _hasLiveGrantPerm;
    final hasRevokePerm = _hasLiveRevokePerm;
    final canManagePermissions = hasGrantPerm || hasRevokePerm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Yönetimi'),
        actions: [
          if (hasGrantPerm)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                _showAddUserBottomSheet();
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomTextField(
                  label: '',
                  hint: 'İsim veya e-posta ile ara...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterUsers();
                    });
                  },
                ),
              ),
              
              Expanded(
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredUsers.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final name = '${user['firstName']} ${user['lastName']}';
                          final email = user['email'] ?? '';
                          final isActive = user['isActive'] ?? false;
                          final id = user['id'] ?? 0;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(email),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.textSecondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Kullanıcı',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (canManagePermissions)
                                  IconButton(
                                    icon: const Icon(Icons.shield, color: AppColors.accent),
                                    onPressed: () {
                                      _showManagePermissionsBottomSheet(user);
                                    },
                                  ),
                                if (hasGrantPerm) // Assuming users who can grant can also edit/toggle
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: AppColors.primary),
                                    onPressed: () {
                                      _showEditUserBottomSheet(user);
                                    },
                                  ),
                                if (hasGrantPerm)
                                  Switch(
                                    value: isActive,
                                    activeColor: AppColors.success,
                                    onChanged: (val) {
                                      _toggleUserStatus(id, isActive);
                                    },
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
