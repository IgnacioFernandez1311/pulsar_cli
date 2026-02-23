import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class CleanCommand extends Command {
  @override
  String get name => 'clean';

  @override
  String get description => 'Clean Pulsar build cache (.dart_tool/.pulsar)';

  final logger = Logger();

  @override
  Future<void> run() async {
    final root = Directory.current;
    final pulsarCache = Directory('${root.path}/.dart_tool/pulsar');

    if (!pulsarCache.existsSync()) {
      logger.info('Nothing to clean.');
      return;
    }

    final progress = logger.progress('Cleaning cache...');

    try {
      pulsarCache.deleteSync(recursive: true);
      progress.complete('Cache cleaned successfully');
    } catch (e) {
      progress.fail('Failed to clean cache');
      logger.err(e.toString());
    }
  }
}
