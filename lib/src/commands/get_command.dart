import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class GetCommand extends Command {
  @override
  String get name => 'get';

  @override
  String get description => 'Resolve dependencies and run the Pulsar linter';

  GetCommand() {
    argParser.addFlag(
      'no-pub',
      negatable: false,
      help: 'Skip dart pub get and only run the linter',
    );
  }

  final logger = Logger();

  @override
  Future<void> run() async {
    final skipPub = argResults?['no-pub'] == true;

    _printHeader();

    // Ensure the project has everything needed for custom_lint to run.
    // These checks are safe to run on both new and existing projects.
    await _ensureCustomLintDependency();
    await _ensureAnalysisOptions();

    if (!skipPub) {
      await _runPubGet();
    } else {
      logger.info('Skipping dart pub get (--no-pub)');
    }

    logger.info('');
    await _runLinter();

    logger.info('');
    logger.success('Done.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pre-flight checks
  // ─────────────────────────────────────────────────────────────────────────

  /// Ensures [custom_lint] and [pulsar_lint] are declared in pubspec.yaml.
  ///
  /// If either is missing, runs `dart pub add --dev` to add it.
  /// This makes `pulsar get` safe to run on existing projects that predate
  /// the linter or were created without it.
  Future<void> _ensureCustomLintDependency() async {
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) return;

    final content = pubspec.readAsStringSync();
    final missing = <String>[];

    if (!content.contains('custom_lint')) missing.add('custom_lint');
    if (!content.contains('pulsar_lint')) missing.add('pulsar_lint');

    if (missing.isEmpty) return;

    final progress = logger.progress(
      'Adding missing dev dependencies: ${missing.join(', ')}',
    );

    try {
      final result = await Process.run('dart', [
        'pub',
        'add',
        '--dev',
        ...missing,
      ], runInShell: true);

      if (result.exitCode == 0) {
        progress.complete('Added ${missing.join(', ')} to dev dependencies');
      } else {
        progress.fail('Could not add ${missing.join(', ')}');
        final stderr = (result.stderr as String).trim();
        if (stderr.isNotEmpty) logger.err(stderr);
        // Not fatal — continue and let pub get surface the real error
      }
    } catch (e) {
      progress.fail('Could not run dart pub add');
      logger.err('$e');
    }
  }

  /// Ensures [analysis_options.yaml] exists and has [custom_lint] enabled.
  ///
  /// Three cases:
  /// 1. File does not exist → create it with the full Pulsar configuration.
  /// 2. File exists but has no [custom_lint] plugin → append the plugin block.
  /// 3. File exists and already has [custom_lint] → nothing to do.
  Future<void> _ensureAnalysisOptions() async {
    final file = File('analysis_options.yaml');

    if (!file.existsSync()) {
      _createAnalysisOptions(file);
      logger.info(
        '✓ Created analysis_options.yaml with pulsar_lint configuration',
      );
      return;
    }

    final content = file.readAsStringSync();
    if (content.contains('custom_lint')) return;

    // File exists but is missing the plugin — append rather than overwrite
    // to preserve the user's existing lints and include directives.
    final appended =
        '''
${content.trimRight()}


# Added by pulsar get — enables pulsar_lint static analysis.
# Run `pulsar get` after any dependency change to keep the linter active.
analyzer:
  plugins:
    - custom_lint
''';

    file.writeAsStringSync(appended);
    logger.info('✓ Added custom_lint plugin to existing analysis_options.yaml');
  }

  /// Creates a complete [analysis_options.yaml] with the recommended
  /// Pulsar configuration. Identical to what [pulsar create] generates.
  void _createAnalysisOptions(File file) {
    file.writeAsStringSync('''
# This file configures the static analysis results for your project (errors,
# warnings, and lints).
#
# This enables the 'recommended' set of lints from `package:lints`.
# This set helps identify many issues that may lead to problems when running
# or consuming Dart code, and enforces writing Dart using a single, idiomatic
# style and format.
#
# If you want a smaller set of lints you can change this to specify
# 'package:lints/core.yaml'. These are just the most critical lints
# (the recommended set includes the core lints).
# The core lints are also what is used by pub.dev for scoring packages.
include: package:lints/recommended.yaml

analyzer:
  plugins:
    - custom_lint

# pulsar_lint enforces Pulsar\'s architectural best practices automatically.
# Rules are pre-configured in the package — no additional setup needed.
# Run `pulsar get` to activate the linter after any dependency change.
# See https://github.com/IgnacioFernandez1311/pulsar_lint for rule details.
''');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // dart pub get
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _runPubGet() async {
    final progress = logger.progress('Resolving dependencies');

    try {
      final result = await Process.run('dart', [
        'pub',
        'get',
      ], runInShell: true);

      if (result.exitCode == 0) {
        progress.complete('Dependencies resolved');
      } else {
        progress.fail('dart pub get failed');
        logger.info('');
        if ((result.stdout as String).isNotEmpty) {
          logger.info(result.stdout as String);
        }
        if ((result.stderr as String).isNotEmpty) {
          logger.err(result.stderr as String);
        }
        exit(result.exitCode);
      }
    } catch (e) {
      progress.fail('Could not run dart pub get');
      logger.err('$e');
      exit(1);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // dart run custom_lint
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _runLinter() async {
    final progress = logger.progress('Running Pulsar linter');

    try {
      final result = await Process.run('dart', [
        'run',
        'custom_lint',
      ], runInShell: true);

      if (result.exitCode == 0) {
        final output = (result.stdout as String).trim();
        if (output.isEmpty || output.toLowerCase().contains('no issues')) {
          progress.complete('No lint issues found');
        } else {
          progress.fail('Lint issues found');
          logger.info('');
          logger.info(output);
        }
      } else {
        progress.fail('Linter reported issues');
        logger.info('');

        final stdout = (result.stdout as String).trim();
        final stderr = (result.stderr as String).trim();

        if (stdout.isNotEmpty) logger.info(stdout);
        if (stderr.isNotEmpty) logger.err(stderr);
        // Not fatal — lint issues are informational.
      }
    } catch (e) {
      progress.fail('Could not run custom_lint');
      logger.err('$e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────

  void _printHeader() {
    logger.info('');
    logger.info('   Pulsar Get');
    logger.info('────────────────────────────');
    logger.info('');
  }
}
