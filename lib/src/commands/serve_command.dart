import 'dart:io';
import 'package:args/command_runner.dart';

class ServeCommand extends Command {
  @override
  String get name => "serve";

  @override
  String get description => "Initialize a local dev server.";

  ServeCommand() {
    argParser.addOption(
      'port',
      abbr: 'p',
      defaultsTo: '8080',
      help: 'Port to serve the application',
    );
  }
  @override
  Future<void> run() async {
    final process = await Process.start('dart', [
      'run',
      'webdev',
      'serve',
    ], mode: ProcessStartMode.inheritStdio);

    process.exitCode.then((code) {
      if (code != 0) {
        stderr.writeln('Error while executing webdev serve (exit code $code)');
      }
    });
  }
}
