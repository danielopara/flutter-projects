import 'package:logger/logger.dart';

class CLoggerHelper {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
    // Shows debug logs in development; change to Level.warning for production
    level: Level.debug,
  );

  static void debug(String message) {
    _logger.d(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(String message, [dynamic error]) {
    _logger.e(message, error: error, stackTrace: StackTrace.current);
  }
}
