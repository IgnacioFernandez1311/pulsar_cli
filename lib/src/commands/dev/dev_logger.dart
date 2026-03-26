import 'package:mason_logger/mason_logger.dart';

class DevLogger {
  static final Logger _logger = Logger(theme: _pulsarTheme());

  static Progress? _currentProgress;

  static LogTheme _pulsarTheme() {
    return LogTheme(
      info: (msg) => cyan.wrap(msg ?? ''),
      success: (msg) => green.wrap(msg ?? ''),
      warn: (msg) => yellow.wrap(msg ?? ''),
      err: (msg) => red.wrap(msg ?? ''),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                                   BANNER                                   */
  /* -------------------------------------------------------------------------- */

  static void banner(int port, bool watch) {
    _logger.info('');
    _logger.info('     Pulsar Dev Server');
    _logger.info('────────────────────────────');
    _logger.info('Mode   : Development');
    _logger.info('Watch  : ${watch ? 'Enabled' : 'Disabled'}');
    _logger.info('Local  : http://localhost:$port');
    _logger.info('');
  }

  /* -------------------------------------------------------------------------- */
  /*                                   BUILD                                    */
  /* -------------------------------------------------------------------------- */

  static void buildStart(String message) {
    _currentProgress = _logger.progress(message);
  }

  static void buildSuccess(String message) {
    _currentProgress?.complete(message);
    _currentProgress = null;
  }

  static void buildFail(String message) {
    _currentProgress?.fail(message);
    _currentProgress = null;
  }

  /* -------------------------------------------------------------------------- */
  /*                                    WATCH                                   */
  /* -------------------------------------------------------------------------- */

  static void watch(String message) {
    _logger.warn('⟳ $message');
  }

  /* -------------------------------------------------------------------------- */
  /*                                    INFO                                    */
  /* -------------------------------------------------------------------------- */

  static void info(String message) {
    _logger.info(message);
  }

  static void success(String message) {
    _logger.success(message);
  }

  static void error(String message) {
    _logger.err(message);
  }
}
