import 'dart:io';
import 'package:args/command_runner.dart';

class BuildCommand extends Command {
  @override
  String get name => 'build';

  @override
  String get description => 'Build a Pulsar project for production.';

  @override
  Future<void> run() async {
    final process = await Process.start('dart', [
      'run',
      'webdev',
      'build',
      '--release',
    ], mode: ProcessStartMode.inheritStdio);

    process.exitCode.then((code) {
      if (code != 0) {
        stderr.writeln(
          'Error while building the Pulsar project (exit code $code)',
        );
        exit(1);
      }
    });
  }
}
