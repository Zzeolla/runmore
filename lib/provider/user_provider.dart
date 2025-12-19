import 'package:flutter/widgets.dart';
import 'package:runmore/model/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseClient _client =Supabase.instance.client;

  AppUser? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoaded = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoaded => _isLoaded;
  String? get userId => _currentUser?.id;

  String _defaultNickname(User authUser) {
    final email = authUser.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return '러너';
  }

  // 앱 시작 시 한 번 호출 (SplashScreen 등에서)
  Future<void> loadOrCreateUser() async {
    final authUser = _client.auth.currentUser;

    _isLoggedIn = authUser != null;

    if (authUser == null) {
      _currentUser = null;
      _isLoaded = true;
      notifyListeners();
      return;
    }

    final uid = authUser.id;

    // 1) users 테이블 조회
    final data = await _client
        .from('users')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (data == null) {
      // 2) 없으면 생성
      final nickname = _defaultNickname(authUser);

      await _client.from('users').insert({'id': uid, 'nickname': nickname});

      _currentUser = AppUser(
        id: uid,
        nickname: nickname,
        createdAt: DateTime.now(),
        coverUrl: null,
      );
    } else {
      // 3) 있으면 UserModel로 파싱
      _currentUser = AppUser.fromJson(data);
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// 로그아웃 시 초기화 (옵션)
  void clear() {
    _currentUser = null;
    _isLoggedIn = false;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    // final authUser = _client.auth.currentUser;
    //
    // if (authUser != null) {
    //   final userId = authUser.id;
    //
    //   final fcmTokenService = FcmTokenService(_client);
    //   await fcmTokenService.unregister(userId);
    // }

    await _client.auth.signOut();
    clear();
  }
}