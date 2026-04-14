import 'dart:developer' as developer;

class AppLogger {
  static void info(String message, [String name = 'KedaiApp']) {
    developer.log('🔵 INFO: $message', name: name, level: 800);
  }

  static void warning(String message, [String name = 'KedaiApp']) {
    developer.log('🟠 WARN: $message', name: name, level: 900);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'KedaiApp',
  }) {
    developer.log(
      '🔴 ERROR: $message',
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static void success(String message, [String name = 'KedaiApp']) {
    developer.log('🟢 SUCCESS: $message', name: name, level: 800);
  }
}
