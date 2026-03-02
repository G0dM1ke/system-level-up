import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LockService {
  static const _pinKey = 'system_pin';
  static const _panicPinKey = 'system_panic_pin';
  static const _secretEnabledKey = 'secret_enabled';

  static const _storage = FlutterSecureStorage();
  static final _auth = LocalAuthentication();

  static Future<bool> isSecretEnabled() async {
    final v = await _storage.read(key: _secretEnabledKey);
    return v == '1';
  }

  static Future<void> setSecretEnabled(bool enabled) async {
    await _storage.write(key: _secretEnabledKey, value: enabled ? '1' : '0');
  }

  static Future<String?> getPin() => _storage.read(key: _pinKey);
  static Future<String?> getPanicPin() => _storage.read(key: _panicPinKey);

  static Future<void> setPins({required String pin, required String panicPin}) async {
    await _storage.write(key: _pinKey, value: pin);
    await _storage.write(key: _panicPinKey, value: panicPin);
    await setSecretEnabled(true);
  }

  static Future<bool> canBiometric() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> biometricAuth() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock SYSTEM',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
