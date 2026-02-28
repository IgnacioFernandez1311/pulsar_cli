import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';
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
        help: 'Define the initial template. default, minimum or empty',
      )
      ..addOption(
        'use-cdn',
        help:
            'Define the CDN to use. tailwind, materialize or none for vanilla CSS',
      )
      ..addOption(
        'icons',
        help: 'Icon library to include: none, material or bootstrap',
      )
      ..addFlag(
        'yes',
        abbr: 'y',
        negatable: false,
        help: 'Skip interactive prompts',
      );
  }

  final logger = Logger();

  @override
  Future<void> run() async {
    final args = argResults!;
    final skipPrompts = args['yes'] == true;

    _printHeader();

    String? projectName = args.rest.isNotEmpty ? args.rest.first : null;

    if (!skipPrompts) {
      projectName ??= Input(
        prompt: 'Project name',
        validator: (value) => value.trim().isNotEmpty,
      ).interact();
    }

    if (projectName == null || projectName.isEmpty) {
      logger.err('You must specify a project name.');
      exit(1);
    }

    final template =
        args['template'] ?? (skipPrompts ? 'default' : _selectTemplate());

    final cdn = args['use-cdn'] ?? (skipPrompts ? 'none' : _selectCdn());

    final icons = args['icons'] ?? (skipPrompts ? 'none' : _selectIcons());

    final destination = Directory(projectName);

    if (destination.existsSync()) {
      logger.err('Directory "$projectName" already exists.');
      exit(1);
    }

    logger.info('Creating project...');
    await copyTemplate(template, destination);

    _generatePubspec(destination, projectName);
    _generateMainDart(destination, template);
    _selectIndexHtml(destination, cdn);
    _selectAppAndStyles(destination, cdn);
    _injectIcons(destination, icons);

    logger.success('Project "$projectName" created successfully!\n');

    logger.info('Next steps:');
    logger.info('  cd $projectName');
    logger.info('  dart pub get');
    logger.info('  pulsar serve\n');
  }

  /* -------------------------------------------------------------------------- */
  /*                               Interactive UI                               */
  /* -------------------------------------------------------------------------- */

  void _printHeader() {
    logger.info('');
    logger.info('   Pulsar Project Setup');
    logger.info('────────────────────────────');
    logger.info('');
  }

  String _selectTemplate() {
    final options = ['default', 'minimum', 'empty'];
    final index = Select(
      prompt: 'Choose template',
      options: options,
    ).interact();
    return options[index];
  }

  String _selectCdn() {
    final options = ['none', 'tailwind', 'materialize'];
    final index = Select(prompt: 'Choose UI CDN', options: options).interact();
    return options[index];
  }

  String _selectIcons() {
    final options = ['none', 'material', 'bootstrap'];
    final index = Select(
      prompt: 'Include icon library?',
      options: options,
    ).interact();
    return options[index];
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
  pulsar_web: ^0.4.9+1
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

    if (template == 'empty') {
      main.writeAsStringSync('void main() {}');
      return;
    }

    main.writeAsStringSync('''
import 'package:pulsar_web/pulsar.dart';
import 'package:${root.path.split(Platform.pathSeparator).last}/app.dart';

void main() {
  mountApp(App(), selector: "#app");
}
''');
  }

  /* -------------------------------------------------------------------------- */
  /*                              index.html                                    */
  /* -------------------------------------------------------------------------- */

  void _selectIndexHtml(Directory root, String cdn) {
    final webDir = Directory('${root.path}/web');
    if (!webDir.existsSync()) return;

    final selected = File('${webDir.path}/index.$cdn.html');
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
  /*                              Icon Injection                                */
  /* -------------------------------------------------------------------------- */

  void _injectIcons(Directory root, String icons) {
    if (icons == 'none') return;

    final indexFile = File('${root.path}/web/index.html');
    if (!indexFile.existsSync()) return;

    final html = indexFile.readAsStringSync();

    String linkTag = '';

    if (icons == 'material') {
      linkTag =
          '<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">';
    }

    if (icons == 'bootstrap') {
      linkTag =
          '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">';
    }

    final updated = html.replaceFirst('</head>', '$linkTag\n</head>');

    indexFile.writeAsStringSync(updated);
  }

  /* -------------------------------------------------------------------------- */
  /*                              App + CSS selection                           */
  /* -------------------------------------------------------------------------- */

  void _selectAppAndStyles(Directory root, String cdn) {
    final libDir = Directory('${root.path}/lib');
    final stylesDir = Directory('${root.path}/web/styles');

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
