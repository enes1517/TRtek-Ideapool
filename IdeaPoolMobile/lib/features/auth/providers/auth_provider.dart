import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class CurrentUser {
  final int id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final List<String> permissions;

  CurrentUser({required this.id, required this.email, required this.fullName, this.avatarUrl, this.permissions = const []});
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? pendingGoogleToken; // Google ile ilk kez girenler için
  final CurrentUser? user;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.pendingGoogleToken,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? pendingGoogleToken,
    bool clearPendingToken = false,
    CurrentUser? user,
    bool clearUser = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingGoogleToken: clearPendingToken ? null : (pendingGoogleToken ?? this.pendingGoogleToken),
      user: clearUser ? null : (user ?? this.user),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: "Lütfen tüm alanları doldurun.");
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await ApiService.post('api/Auth/login', {
        'email': email,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        await _handleToken(response['token']);
      } else {
        state = state.copyWith(isLoading: false, error: "Giriş başarısız.");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _handleToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    
    // JWT'yi decode edip kullanıcı bilgilerini al
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payloadStr = parts[1];
        final normalized = base64Url.normalize(payloadStr);
        final payloadMap = jsonDecode(utf8.decode(base64Url.decode(normalized)));
        
        var perms = <String>[];
        if (payloadMap['permission'] is List) {
          perms = (payloadMap['permission'] as List).map((e) => e.toString()).toList();
        } else if (payloadMap['permission'] is String) {
          perms = [payloadMap['permission'].toString()];
        }
        
        final user = CurrentUser(
          id: int.tryParse(payloadMap['userId']?.toString() ?? '0') ?? 0,
          email: payloadMap['email'] ?? '',
          fullName: payloadMap['fullName'] ?? 'Kullanıcı',
          avatarUrl: payloadMap['avatarUrl'],
          permissions: perms,
        );
        state = state.copyWith(isLoading: false, isAuthenticated: true, user: user, clearPendingToken: true);
        
        // En güncel bilgileri (özellikle Avatar) veritabanından çek
        _fetchFreshUserProfile(user.id);
        return;
      }
    } catch (e) {
      print("JWT Decode error: $e");
    }
    
    state = state.copyWith(isLoading: false, isAuthenticated: true, clearPendingToken: true);
  }

  Future<void> _fetchFreshUserProfile(int userId) async {
    try {
      final response = await ApiService.get('api/User/$userId');
      if (response != null && state.user != null) {
        final updatedUser = CurrentUser(
          id: state.user!.id,
          email: state.user!.email,
          fullName: state.user!.fullName,
          permissions: state.user!.permissions,
          avatarUrl: response['avatarUrl'] ?? state.user!.avatarUrl,
        );
        state = state.copyWith(user: updatedUser);
      }
    } catch (_) {}
  }

  void updateAvatarLocal(String newUrl) {
    if (state.user != null) {
      final updatedUser = CurrentUser(
        id: state.user!.id,
        email: state.user!.email,
        fullName: state.user!.fullName,
        permissions: state.user!.permissions,
        avatarUrl: newUrl,
      );
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiService.post('api/Auth/register', data);
      if (response != null && response['id'] != null) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: "Kayıt başarısız oldu.");
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Kayıt Hatası: ${e.toString()}");
      return false;
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '538838303073-18tus87440aaismiruj4klq3gbnddnlf.apps.googleusercontent.com',
        scopes: ['email', 'profile', 'openid'],
      );

      // if (await googleSignIn.isSignedIn()) {
      //   await googleSignIn.signOut();
      // }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("Frontend: googleUser null döndü (Giriş iptal edildi).");
        state = state.copyWith(isLoading: false, error: "Giriş iptal edildi.");
        return;
      }
      print("Frontend: googleUser başarıyla alındı: ${googleUser.email}");

      print("Frontend: googleAuth bekleniyor...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("Frontend: googleAuth başarıyla alındı.");
      
      final String? tokenToUse = googleAuth.idToken ?? googleAuth.accessToken;

      if (tokenToUse == null) {
        state = state.copyWith(isLoading: false, error: "Google'dan token alınamadı.");
        return;
      }
      
      print("Frontend: Google token alındı. Backend'e gönderiliyor...");
      final response = await ApiService.post('api/Auth/google-login', {
        'idToken': tokenToUse,
      });
      print("Frontend: Backend'den cevap geldi: $response");

      if (response != null && response['loginResponse'] != null && response['loginResponse']['token'] != null) {
        await _handleToken(response['loginResponse']['token']);
      } else if (response != null && response['requiresRegistration'] == true) {
        print("Frontend: Kullanıcı yeni, eksik bilgiler için form açılmalı.");
        // Kullanıcı yeni, eksik bilgileri tamamlaması için token'ı state'e koyuyoruz
        state = state.copyWith(
          isLoading: false, 
          pendingGoogleToken: tokenToUse,
        );
      } else {
        state = state.copyWith(isLoading: false, error: "Google ile giriş başarısız.");
      }
    } catch (e) {
      print("Frontend Google Hata: $e");
      state = state.copyWith(isLoading: false, error: "Google Hata: ${e.toString()}");
    }
  }

  Future<bool> completeGoogleRegistration(String identityNumber, String registrationNumber, String phone) async {
    if (state.pendingGoogleToken == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiService.post('api/Auth/google-register', {
        'idToken': state.pendingGoogleToken,
        'identityNumber': identityNumber,
        'registrationNumber': registrationNumber,
        'phoneNumber': phone,
      });

      if (response != null && response['token'] != null) {
        await _handleToken(response['token']);
        return true;
      }
      state = state.copyWith(isLoading: false, error: "Google Kaydı tamamlama başarısız.");
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Kayıt Hatası: ${e.toString()}");
      return false;
    }
  }

  void cancelGoogleRegistration() {
    state = state.copyWith(clearPendingToken: true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '538838303073-18tus87440aaismiruj4klq3gbnddnlf.apps.googleusercontent.com',
      );
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      print("Google Logout Error: $e");
    }

    state = state.copyWith(isAuthenticated: false, clearUser: true, clearPendingToken: true);
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      await _handleToken(token);
    }
  }
}
