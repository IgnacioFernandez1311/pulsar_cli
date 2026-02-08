import 'dart:io';
import 'package:args/command_runner.dart';
import '../utils/io_utils.dart';

class CreateCommand extends Command {
  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Pulsar project';

  CreateCommand() {
    argParser
      ..addOption(
        'template',
        abbr: 't',
        defaultsTo: 'default',
        help: 'Project template: default, minimum, empty',
      )
      ..addOption(
        'use-cdn',
        defaultsTo: 'none',
        help: 'UI CDN to use: none, materialize, tailwind',
      );
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final projectName = args.rest.isNotEmpty ? args.rest.first : null;

    if (projectName == null) {
      stderr.writeln('You must specify the project name');
      stderr.writeln('Example: pulsar create my_app');
      exit(1);
    }

    final template = args['template'] as String;
    final cdn = args['use-cdn'] as String;

    final destination = Directory(projectName);
    if (destination.existsSync()) {
      stderr.writeln('The folder "$projectName" already exists');
      exit(1);
    }

    print('Creating Pulsar project "$projectName"...');

    await copyTemplate(template, destination);

    _generatePubspec(destination, projectName);
    _generateMainDart(destination, template);
    _selectIndexHtml(destination, cdn);
    _selectAppAndStyles(destination, cdn);

    print('Project created successfully.');
    print('');
    print('Next steps:');
    print('  cd $projectName');
    print('  dart pub get');
    print('  pulsar serve');
  }

  /* -------------------------------------------------------------------------- */
  /*                              pubspec.yaml                                  */
  /* -------------------------------------------------------------------------- */

  void _generatePubspec(Directory root, String projectName) {
    final pubspec = File('${root.path}/pubspec.yaml');

    pubspec.writeAsStringSync('''
name: $projectName
description: A Pulsar application
version: 0.1.0

environment:
  sdk: ^3.9.0

dependencies:
  pulsar_web: ^0.4.5
  universal_web: ^1.1.1+1

dev_dependencies:
  lints: ^6.0.0
''');
  }

  /* -------------------------------------------------------------------------- */
  /*                              web/main.dart                                 */
  /* -------------------------------------------------------------------------- */

  void _generateMainDart(Directory root, String template) {
    final webDir = Directory('${root.path}/web');
    if (!webDir.existsSync()) return;

    final main = File('${webDir.path}/main.dart');

    // empty template: no imports, no App
    if (template == 'empty') {
      main.writeAsStringSync('''
void main() {}
''');
      return;
    }

    // default / minimum
    main.writeAsStringSync('''
import 'package:pulsar_web/pulsar.dart';
import 'package:${root.path.split(Platform.pathSeparator).last}/app.dart';

void main() {
  mountApp(App(), selector: "#app");
}
''');
  }

  /* -------------------------------------------------------------------------- */
  /*                              index.html (CDN)                              */
  /* -------------------------------------------------------------------------- */

  void _selectIndexHtml(Directory root, String cdn) {
    final webDir = Directory('${root.path}/web');
    if (!webDir.existsSync()) return;

    final selected = File('${webDir.path}/index.$cdn.html');
    if (!selected.existsSync()) {
      throw Exception('Unknown CDN: $cdn');
    }

    selected.renameSync('${webDir.path}/index.html');

    for (final file in webDir.listSync()) {
      if (file is File &&
          file.path.endsWith('.html') &&
          !file.path.endsWith('index.html')) {
        file.deleteSync();
      }
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                        App Dart + CSS variant selection                     */
  /* -------------------------------------------------------------------------- */

  void _selectAppAndStyles(Directory root, String cdn) {
    final libDir = Directory('${root.path}/lib');
    final stylesDir = Directory('${root.path}/web/styles');

    // ---- Dart (App) ----------------------------------------------------------

    if (libDir.existsSync()) {
      final selected = File('${libDir.path}/app.$cdn.dart');
      if (selected.existsSync()) {
        selected.renameSync('${libDir.path}/app.dart');
      }

      for (final file in libDir.listSync()) {
        if (file is File &&
            file.path.contains('app.') &&
            file.path.endsWith('.dart') &&
            !file.path.endsWith('app.dart')) {
          file.deleteSync();
        }
      }
    }

    // ---- CSS ----------------------------------------------------------------

    if (stylesDir.existsSync()) {
      final selected = File('${stylesDir.path}/app.$cdn.css');
      if (selected.existsSync()) {
        selected.renameSync('${stylesDir.path}/app.css');
      }

      for (final file in stylesDir.listSync()) {
        if (file is File &&
            file.path.contains('app.') &&
            file.path.endsWith('.css') &&
            !file.path.endsWith('app.css')) {
          file.deleteSync();
        }
      }
    }
  }
}
