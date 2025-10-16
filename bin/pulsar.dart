import 'package:args/command_runner.dart';
import 'package:pulsar_cli/src/commands/build_command.dart';
import 'package:pulsar_cli/src/commands/create_command.dart';
import 'package:pulsar_cli/src/commands/serve_command.dart';

void main(List<String> args) async {
  final CommandRunner runner =
      CommandRunner(
          'pulsar',
          'oficial CLI for create and manage projects with the Pulsar Web Framework',
        )
        ..addCommand(CreateCommand())
        ..addCommand(ServeCommand())
        ..addCommand(BuildCommand());

  await runner.run(args);
}
