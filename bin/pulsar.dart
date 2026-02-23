import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:pulsar_cli/src/commands/build_command.dart';
import 'package:pulsar_cli/src/commands/clean_command.dart';
import 'package:pulsar_cli/src/commands/create_command.dart';
import 'package:pulsar_cli/src/commands/doctor_command.dart';
import 'package:pulsar_cli/src/commands/serve_command.dart';

Future<void> main(List<String> args) async {
  final String cliVersion = '0.2.9';
  final CommandRunner runner =
      CommandRunner(
          'pulsar',
          'oficial CLI for create and manage projects with the Pulsar Web Framework',
        )
        ..argParser.addFlag(
          'version',
          abbr: 'v',
          negatable: false,
          help: 'Print current CLI version',
        )
        ..addCommand(CreateCommand())
        ..addCommand(ServeCommand())
        ..addCommand(BuildCommand())
        ..addCommand(CleanCommand())
        ..addCommand(DoctorCommand());

  try {
    final result = runner.parse(args);

    if (result['version']) {
      stdout.writeln('Pulsar CLI version is $cliVersion');
      exit(0);
    }

    await runner.run(args);
  } catch (error) {
    stderr.writeln(error);
    exit(1);
  }
}
