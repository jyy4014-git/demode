import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:demode/backend/services/auth_service.dart';

class SocialAuthService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> signIn(String provider) async {
    try {
      switch (provider) {
        case 'google':
          return await _handleGoogleSignIn();
        case 'kakao':
          return await _handleKakaoSignIn();
        case 'naver':
          return await _handleNaverSignIn();
        default:
          throw Exception('Unknown provider');
      }
    } catch (e) {
      print('Social login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _handleGoogleSignIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      return {
        'id': account.id,
        'email': account.email,
        'name': account.displayName,
        'provider': 'google'
      };
    }
    return null;
  }

  Future<Map<String, dynamic>?> _handleKakaoSignIn() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        final user = await UserApi.instance.me();
        return {
          'id': user.id.toString(),
          'email': user.kakaoAccount?.email,
          'name': user.kakaoAccount?.profile?.nickname,
          'provider': 'kakao'
        };
      } catch (e) {
        return await _handleKakaoAccountLogin();
      }
    } else {
      return await _handleKakaoAccountLogin();
    }
  }

  Future<Map<String, dynamic>?> _handleKakaoAccountLogin() async {
    try {
      await UserApi.instance.loginWithKakaoAccount();
      final user = await UserApi.instance.me();
      return {
        'id': user.id.toString(),
        'email': user.kakaoAccount?.email,
        'name': user.kakaoAccount?.profile?.nickname,
        'provider': 'kakao'
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _handleNaverSignIn() async {
    final NaverLoginResult result = await FlutterNaverLogin.logIn();
    if (result.status == NaverLoginStatus.loggedIn) {
      return {
        'id': result.account.id,
        'email': result.account.email,
        'name': result.account.name,
        'provider': 'naver'
      };
    }
    return null;
  }
}
