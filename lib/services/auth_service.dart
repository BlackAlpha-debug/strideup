import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  final StorageService storage;

  AuthService({required this.storage}) {
    _userEmail = storage.getString('session_email');
    _isLoggedIn = _userEmail?.isNotEmpty ?? false;
  }
  bool _isLoggedIn = false;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;

  static const _tempEmail = 'test@strideup.com';
  static const _tempPassword = 'stride123';
  static const _accountKey = 'local_account_v1';

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  bool _validEmail(String email) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

  String _newSalt() {
    final random = Random.secure();
    return base64UrlEncode(List<int>.generate(24, (_) => random.nextInt(256)));
  }

  String _passwordHash(String password, String salt) {
    final saltBytes = utf8.encode(salt);
    List<int> bytes = List<int>.from(utf8.encode('$salt:$password'));
    for (var i = 0; i < 20000; i++) {
      bytes = sha256.convert([...bytes, ...saltBytes]).bytes;
    }
    return base64UrlEncode(bytes);
  }

  Map<String, dynamic>? get _localAccount {
    final raw = storage.getJson(_accountKey);
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  Future<bool> login(String email, String password) async {
    final normalized = _normalizeEmail(email);
    final account = _localAccount;
    final localMatch =
        account != null &&
        account['email'] == normalized &&
        account['passwordHash'] ==
            _passwordHash(password, account['salt'] as String? ?? '');
    final demoMatch = normalized == _tempEmail && password == _tempPassword;
    if (localMatch || demoMatch) {
      await storage.saveString('session_email', normalized);
      _isLoggedIn = true;
      _userEmail = normalized;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    final normalized = _normalizeEmail(email);
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty &&
        _validEmail(normalized) &&
        password.length >= 6) {
      final salt = _newSalt();
      await storage.saveJson(_accountKey, {
        'email': normalized,
        'salt': salt,
        'passwordHash': _passwordHash(password, salt),
      });
      await storage.saveString('user_name', trimmedName);
      await storage.saveString('session_email', normalized);
      _isLoggedIn = true;
      _userEmail = normalized;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await storage.remove('session_email');
    _isLoggedIn = false;
    _userEmail = null;
    notifyListeners();
  }
}
