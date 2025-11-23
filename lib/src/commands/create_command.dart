import 'dart:async';

import 'package:args/command_runner.dart';
import 'dart:io';
import '../utils/io_utils.dart';

class CreateCommand extends Command {
  @override
  String get name => 'create';
  @override
  String get description => 'Create a new Pulsar project';

  CreateCommand() {
    argParser.addOption(
      'template',
      abbr: 't',
      help: 'Default template: default. Also try other options: empty, minimum',
      defaultsTo: 'default',
    );
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final String? projectName = args.rest.isNotEmpty ? args.rest.first : null;

    if (projectName == null) {
      print('You must specify the project name');
      print('Example: pulsar create my_app');
      exit(1);
    }

    final template = args['template'] as String;
    final destination = Directory(projectName);

    if (destination.existsSync()) {
      print('The folder "$projectName" already exists');
      exit(1);
    }

    print('Creating the Pulsar project "$projectName"');
    await copyTemplate(template, destination);
    print('Project created successfully');
    print('cd $projectName');
    print('dart pub get');
    print('pulsar serve');
  }
}
