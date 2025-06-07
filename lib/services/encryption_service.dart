import 'dart:convert';
import 'dart:math';

class EncryptionService {
  static const String _key = 'yugioh_tcg_app_secret_key_2024';

  // Simple encryption using base64 and XOR
  static String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final keyBytes = utf8.encode(_key);
    
    final encrypted = <int>[];
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64.encode(encrypted);
  }

  // Decrypt password
  static String decryptPassword(String encryptedPassword) {
    try {
      final encrypted = base64.decode(encryptedPassword);
      final keyBytes = utf8.encode(_key);
      
      final decrypted = <int>[];
      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      return '';
    }
  }

  // Generate session token
  static String generateSessionToken() {
    final random = Random();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }
}
