import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class DoctorCommand extends Command {
  @override
  String get name => 'doctor';

  @override
  String get description => 'Analyze Pulsar environment health';

  DoctorCommand() {
    argParser.addFlag(
      'ci',
      negatable: false,
      help: 'Run in CI mode (fails if score is too low)',
    );
  }

  final Logger logger = Logger();

  late bool _ciMode;

  int _passed = 0;
  int _warnings = 0;

  final Map<String, int> _breakdown = {};
  int _score = 0;

  @override
  Future<void> run() async {
    _ciMode = argResults?['ci'] == true;

    if (!_ciMode) {
      logger.info('');
      logger.info('  Pulsar Doctor');
      logger.info('────────────────────────────────');
    }

    await _checkDart();
    await _checkStructure();
    await _checkDependencies();
    await _checkDartTool();
    await _checkRouting();
    await _checkBuildHygiene();
    await _checkBundleSize();
    await _checkCssExtraction();

    _renderSummary();

    if (_ciMode && _score < 70) {
      exit(1);
    }
  }

  /* ---------------------------------------------------------- */
  /* CHECKS                                                     */
  /* ---------------------------------------------------------- */

  Future<void> _checkDart() async {
    final sw = Stopwatch()..start();

    try {
      final result = await Process.run('dart', ['--version']);
      sw.stop();

      if (result.exitCode == 0) {
        _pass('Dart SDK detected', 20, sw);
      } else {
        _fail('Dart SDK not detected');
      }
    } catch (_) {
      _fail('Dart SDK not detected');
    }
  }

  Future<void> _checkStructure() async {
    final sw = Stopwatch()..start();
    final web = Directory('web');
    final lib = Directory('lib');
    final main = File('web/main.dart');
    sw.stop();

    if (web.existsSync() && lib.existsSync() && main.existsSync()) {
      _pass('Project structure valid', 15, sw);
    } else {
      _fail('Invalid project structure');
    }
  }

  Future<void> _checkDependencies() async {
    final sw = Stopwatch()..start();
    final lock = File('pubspec.lock');
    sw.stop();

    if (lock.existsSync()) {
      _pass('Dependencies look good', 15, sw);
    } else {
      _warn('Dependencies not resolved (run dart pub get)');
      _addScore(5);
    }
  }

  Future<void> _checkDartTool() async {
    final sw = Stopwatch()..start();
    final dir = Directory('.dart_tool');
    sw.stop();

    if (dir.existsSync()) {
      _pass('.dart_tool directory present', 5, sw);
    } else {
      _warn('.dart_tool directory missing');
    }
  }

  Future<void> _checkRouting() async {
    final sw = Stopwatch()..start();
    final index = File('web/index.html');
    sw.stop();

    if (index.existsSync()) {
      _pass('Routing base configuration looks valid', 10, sw);
    } else {
      _warn('index.html missing');
    }
  }

  Future<void> _checkBuildHygiene() async {
    final sw = Stopwatch()..start();
    final build = Directory('build');
    sw.stop();

    if (!build.existsSync()) {
      _pass('No build/ directory (clean project)', 10, sw);
    } else {
      _warn('build/ directory present');
      _addScore(5);
    }
  }

  Future<void> _checkBundleSize() async {
    final sw = Stopwatch()..start();
    final js = File('.dart_tool/pulsar/main.dart.js');
    sw.stop();

    if (!js.existsSync()) {
      _warn('JS bundle not generated (run pulsar serve)');
      return;
    }

    final sizeKB = js.lengthSync() / 1024;

    int points;
    if (sizeKB < 200) {
      points = 10;
    } else if (sizeKB < 400) {
      points = 7;
    } else if (sizeKB < 700) {
      points = 5;
    } else {
      points = 2;
      _warn('Large JS bundle detected (${sizeKB.toStringAsFixed(0)} KB)');
    }

    _pass('JS bundle size check (${sizeKB.toStringAsFixed(0)} KB)', points, sw);
  }

  Future<void> _checkCssExtraction() async {
    final sw = Stopwatch()..start();
    final css = File('.dart_tool/pulsar/pulsar.css');
    sw.stop();

    if (css.existsSync()) {
      _pass('CSS extraction present', 15, sw);
    } else {
      _warn('CSS not extracted (FOUC risk)');
    }
  }

  /* ---------------------------------------------------------- */
  /* RENDER                                                     */
  /* ---------------------------------------------------------- */

  void _pass(String message, int points, Stopwatch sw) {
    _passed++;
    _addScore(points);
    _breakdown[message] = points;

    if (!_ciMode) {
      logger.info('✓ $message (${_format(sw)})');
    }
  }

  void _warn(String message) {
    _warnings++;
    if (!_ciMode) {
      logger.warn(message);
    }
  }

  void _fail(String message) {
    if (!_ciMode) {
      logger.err(message);
    }
  }

  void _addScore(int points) {
    _score += points;
  }

  void _renderSummary() {
    if (!_ciMode) {
      logger.info('');
      logger.info('────────────────────────────────');
      logger.info('Score: $_score / 100 (${_grade(_score)})');
      logger.info('');
      logger.info('$_passed checks passed');
      if (_warnings > 0) {
        logger.warn('$_warnings warnings');
      }
      logger.info('');
    } else {
      stdout.writeln('Pulsar Health Score: $_score');
    }
  }

  String _grade(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Fair';
    return 'Needs Attention';
  }

  String _format(Stopwatch sw) {
    if (sw.elapsedMilliseconds == 0) return '0ms';
    return '${sw.elapsedMilliseconds}ms';
  }
}
