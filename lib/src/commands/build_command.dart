import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import './dev/pulsar_compiler.dart';

class BuildCommand extends Command {
  @override
  String get name => 'build';

  @override
  String get description => 'Build the Pulsar project for production';

  BuildCommand() {
    argParser.addFlag(
      'release',
      defaultsTo: true,
      help: 'Build in release mode (optimized)',
    );
  }

  final logger = Logger();

  @override
  Future<void> run() async {
    final root = Directory.current;
    final webDir = Directory('${root.path}/web');
    final buildDir = Directory('${root.path}/build');

    if (!webDir.existsSync()) {
      logger.err('web/ directory not found');
      return;
    }

    final compiler = PulsarCompiler(root: root, mode: CompileMode.release);

    final progress = logger.progress('Building project...');

    final result = await compiler.compile();

    if (!result.success) {
      progress.fail('Compilation failed');
      logger.err(result.error ?? '');
      return;
    }

    // Clean previous build
    if (buildDir.existsSync()) {
      buildDir.deleteSync(recursive: true);
    }
    buildDir.createSync(recursive: true);

    // Copy web directory
    await _copyDirectory(webDir, buildDir);

    // Replace JS bundle
    await compiler.jsOutput.copy('${buildDir.path}/main.dart.js');

    // Copy extracted CSS
    await compiler.cssOutput.copy('${buildDir.path}/pulsar.css');

    // Inject CSS link into index.html
    await _injectCssLink(buildDir);

    // Write SPA redirects
    await _writeRedirects(buildDir);

    progress.complete(
      'Build completed in ${result.duration.inMilliseconds}ms 🚀',
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                               UTILITIES                                    */
  /* -------------------------------------------------------------------------- */

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (final entity in source.list(recursive: true)) {
      final relative = entity.path.substring(source.path.length + 1);
      final newPath = '${destination.path}/$relative';

      if (entity is Directory) {
        await Directory(newPath).create(recursive: true);
      } else if (entity is File) {
        await entity.copy(newPath);
      }
    }
  }

  Future<void> _injectCssLink(Directory buildDir) async {
    final indexFile = File('${buildDir.path}/index.html');

    if (!indexFile.existsSync()) return;

    var content = await indexFile.readAsString();

    if (!content.contains('pulsar.css')) {
      content = content.replaceFirst(
        '</head>',
        '  <link rel="stylesheet" href="/pulsar.css">\n</head>',
      );

      await indexFile.writeAsString(content);
    }
  }

  Future<void> _writeRedirects(Directory buildDir) async {
    final netlify = File('${buildDir.path}/_redirects');
    netlify.writeAsStringSync('/* /index.html 200\n');

    final vercel = File('${buildDir.path}/vercel.json');
    vercel.writeAsStringSync('''
{
  "routes": [
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
''');
  }
}
