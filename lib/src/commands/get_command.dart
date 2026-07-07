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

  /* -------------------------------------------------------------------------- */
  /*                               dart pub get                                 */
  /* -------------------------------------------------------------------------- */

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
        // Forward dart's output so the developer sees what went wrong
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

  /* -------------------------------------------------------------------------- */
  /*                            dart run custom_lint                            */
  /* -------------------------------------------------------------------------- */

  Future<void> _runLinter() async {
    // Verify custom_lint is available before attempting to run it.
    // If pubspec.yaml doesn't include it, give a clear actionable message.
    final pubspec = File('pubspec.yaml');
    if (pubspec.existsSync()) {
      final content = pubspec.readAsStringSync();
      if (!content.contains('custom_lint')) {
        logger.warn(
          'custom_lint not found in pubspec.yaml — skipping linter.\n'
          '  Add it to dev_dependencies and run pulsar get again.',
        );
        return;
      }
    }

    final progress = logger.progress('Running Pulsar linter');

    try {
      final result = await Process.run('dart', [
        'run',
        'custom_lint',
      ], runInShell: true);

      if (result.exitCode == 0) {
        final output = (result.stdout as String).trim();

        // custom_lint exits 0 with no output when there are no issues.
        if (output.isEmpty || output.toLowerCase().contains('no issues')) {
          progress.complete('No lint issues found');
        } else {
          // Lint issues found — exit code is still 0 but there is output.
          // Show it so the developer can act on it.
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

        // Don't exit — lint issues are informational, not fatal.
        // The developer should see the full output and decide.
      }
    } catch (e) {
      progress.fail('Could not run custom_lint');
      logger.err('$e');
      // Not fatal — the project is still usable.
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                  Header                                    */
  /* -------------------------------------------------------------------------- */

  void _printHeader() {
    logger.info('');
    logger.info('   Pulsar Get');
    logger.info('────────────────────────────');
    logger.info('');
  }
}
