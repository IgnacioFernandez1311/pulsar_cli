import 'package:args/command_runner.dart';
import 'dev/dev_server.dart';

class ServeCommand extends Command {
  @override
  String get name => 'serve';

  @override
  String get description => 'Start Pulsar dev server';

  ServeCommand() {
    argParser
      ..addOption('port', abbr: 'p', defaultsTo: '8080')
      ..addFlag(
        'watch',
        abbr: 'w',
        negatable: false,
        help: 'Enable live reload on file changes',
      );
  }

  @override
  Future<void> run() async {
    final port = int.parse(argResults?['port'] ?? '8080');
    final watch = argResults?['watch'] == true;

    final server = DevServer(port: port, watch: watch);
    await server.start();
  }
}
