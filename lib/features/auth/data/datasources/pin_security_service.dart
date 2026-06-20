import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PinSecurityService {
  static const _boxName = 'secureBox';
  static const _pinKey = 'pinHash';
  static const _q1Key = 'q1Hash';
  static const _q2Key = 'q2Hash';
  static const _q3Key = 'q3Hash';
  static const _attemptsKey = 'failedAttempts';
  static const _lockoutKey = 'lockoutUntil';
  static const _saltStorageKey = 'app_salt';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String> _getSalt() async {
    String? salt = await _secureStorage.read(key: _saltStorageKey);
    if (salt == null) {
      final random = Hive.generateSecureKey();
      salt = base64Encode(random);
      await _secureStorage.write(key: _saltStorageKey, value: salt);
    }
    return salt;
  }

  Future<Box> _getEncryptedBox() async {
    String? base64Key = await _secureStorage.read(key: 'hive_key');
    if (base64Key == null) {
      final key = Hive.generateSecureKey();
      base64Key = base64Encode(key);
      await _secureStorage.write(key: 'hive_key', value: base64Key);
    }

    final encryptionKey = base64Decode(base64Key);
    return await Hive.openBox(_boxName, encryptionCipher: HiveAesCipher(encryptionKey));
  }

  Future<String> _hashData(String data) async {
    final salt = await _getSalt();
    final bytes = utf8.encode(data + salt);
    return sha256.convert(bytes).toString();
  }

  Future<void> savePinSetup({
    required String pin,
    required String answer1,
    required String answer2,
    required String answer3,
  }) async {
    final box = await _getEncryptedBox();
    await box.put(_pinKey, await _hashData(pin));
    await box.put(_q1Key, await _hashData(answer1.toLowerCase().trim()));
    await box.put(_q2Key, await _hashData(answer2.toLowerCase().trim()));
    await box.put(_q3Key, await _hashData(answer3.toLowerCase().trim()));
  }

  Future<bool> verifyPin(String pin) async {
    final box = await _getEncryptedBox();
    final savedPin = box.get(_pinKey);

    if (savedPin == null) return false;

    return savedPin == await _hashData(pin);
  }

  Future<bool> verifyAnswers({
    required String answer1,
    required String answer2,
    required String answer3,
  }) async {
    final box = await _getEncryptedBox();

    final savedA1 = box.get(_q1Key);
    final savedA2 = box.get(_q2Key);
    final savedA3 = box.get(_q3Key);

    if (savedA1 == null || savedA2 == null || savedA3 == null) return false;

    return savedA1 == await _hashData(answer1.toLowerCase().trim()) &&
           savedA2 == await _hashData(answer2.toLowerCase().trim()) &&
           savedA3 == await _hashData(answer3.toLowerCase().trim());
  }

  Future<bool> hasPinConfigured() async {
    final box = await _getEncryptedBox();
    return box.containsKey(_pinKey);
  }

  Future<void> deletePinSetup() async {
    final box = await _getEncryptedBox();
    await box.delete(_pinKey);
    await box.delete(_q1Key);
    await box.delete(_q2Key);
    await box.delete(_q3Key);
    await box.delete(_attemptsKey);
    await box.delete(_lockoutKey);
  }

  Future<int> getFailedAttempts() async {
    final box = await _getEncryptedBox();
    return box.get(_attemptsKey, defaultValue: 0);
  }

  Future<DateTime?> getLockoutUntil() async {
    final box = await _getEncryptedBox();
    final millis = box.get(_lockoutKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> recordFailedAttempt() async {
    final box = await _getEncryptedBox();
    int attempts = box.get(_attemptsKey, defaultValue: 0);
    attempts++;
    await box.put(_attemptsKey, attempts);

    DateTime? lockout;
    if (attempts == 5) lockout = DateTime.now().add(const Duration(seconds: 30));
    else if (attempts == 6) lockout = DateTime.now().add(const Duration(minutes: 1));
    else if (attempts == 7) lockout = DateTime.now().add(const Duration(minutes: 5));
    else if (attempts == 8) lockout = DateTime.now().add(const Duration(minutes: 15));
    else if (attempts == 9) lockout = DateTime.now().add(const Duration(minutes: 30));
    else if (attempts >= 10) lockout = DateTime.now().add(const Duration(hours: 1));

    if (lockout != null) {
      await box.put(_lockoutKey, lockout.millisecondsSinceEpoch);
    }
  }

  Future<void> resetFailedAttempts() async {
    final box = await _getEncryptedBox();
    await box.delete(_attemptsKey);
    await box.delete(_lockoutKey);
  }
}
