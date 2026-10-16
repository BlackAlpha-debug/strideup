import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stride_up/services/auth_service.dart';
import 'package:stride_up/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StorageService storage;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
  });
  test('Successful login survives recreation and logout clears it', () async {
    final auth = AuthService(storage: storage);
    expect(await auth.login('test@strideup.com', 'stride123'), isTrue);
    final restartedStorage = StorageService();
    await restartedStorage.init();
    final restored = AuthService(storage: restartedStorage);
    expect(restored.isLoggedIn, isTrue);
    expect(restored.userEmail, 'test@strideup.com');
    await restored.logout();
    expect(AuthService(storage: restartedStorage).isLoggedIn, isFalse);
  });
  test('Invalid credentials never create a saved session', () async {
    expect(
      await AuthService(storage: storage).login('wrong@example.com', 'invalid'),
      isFalse,
    );
    expect(AuthService(storage: storage).isLoggedIn, isFalse);
  });
  test(
    'Signup preserves session and profile name without saving password',
    () async {
      expect(
        await AuthService(
          storage: storage,
        ).signUp('Sam', 'sam@example.com', 'secret123'),
        isTrue,
      );
      expect(AuthService(storage: storage).userEmail, 'sam@example.com');
      expect(storage.getString('user_name'), 'Sam');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isNot(contains('password')));
      expect(prefs.getString('local_account_v1'), isNot(contains('secret123')));
      final auth = AuthService(storage: storage);
      await auth.logout();
      expect(await auth.login('SAM@example.com', 'secret123'), isTrue);
      expect(auth.userEmail, 'sam@example.com');
      await auth.logout();
      expect(await auth.login('sam@example.com', 'wrong-password'), isFalse);
    },
  );
}
