import 'dart:io';
import 'package:args/command_runner.dart';

class BuildCommand extends Command {
  @override
  String get name => 'build';

  @override
  String get description => 'Build the Pulsar project for production.';

  BuildCommand() {
    argParser.addFlag(
      'release',
      defaultsTo: true,
      help: 'Build in release mode (minified)',
    );
  }

  @override
  Future<void> run() async {
    final projectRoot = Directory.current;
    final webDir = Directory('${projectRoot.path}/web');
    final buildDir = Directory('${projectRoot.path}/build');

    if (!webDir.existsSync()) {
      throw Exception('Missing web/ directory');
    }

    // 1️⃣ Clean build/
    if (buildDir.existsSync()) {
      buildDir.deleteSync(recursive: true);
    }
    buildDir.createSync(recursive: true);

    // 2️⃣ Copy web/ → build/ (RECURSIVE, RAW)
    await _copyDirectory(webDir, buildDir);

    // 3️⃣ Compile Dart → JS
    final entrypoint = File('${webDir.path}/main.dart');
    if (!entrypoint.existsSync()) {
      throw Exception('Missing web/main.dart');
    }

    stdout.writeln('Compiling Dart to JavaScript...');

    final result = await Process.start(
      'dart',
      [
        'compile',
        'js',
        entrypoint.path,
        '-o',
        '${buildDir.path}/main.dart.js',
        if (argResults?['release'] == true) '-O4',
      ],
      workingDirectory: projectRoot.path,
      mode: ProcessStartMode.inheritStdio,
    );

    final exitCode = await result.exitCode;
    if (exitCode != 0) {
      throw Exception('Dart compilation failed');
    }

    // 4️⃣ SPA redirects
    await _writeRedirects(buildDir);

    stdout.writeln('✔ Build completed successfully');
  }

  /// Copies a directory recursively (FILES + SUBFOLDERS)
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (final entity in source.list(recursive: true)) {
      final relativePath = entity.path.substring(source.path.length + 1);
      final newPath = '${destination.path}/$relativePath';

      if (entity is Directory) {
        await Directory(newPath).create(recursive: true);
      } else if (entity is File) {
        await File(newPath).create(recursive: true);
        await entity.copy(newPath);
      }
    }
  }

  /// Adds SPA fallback for popular hosts
  Future<void> _writeRedirects(Directory buildDir) async {
    // Netlify
    final netlify = File('${buildDir.path}/_redirects');
    netlify.writeAsStringSync('/* /index.html 200\n');

    // Vercel
    final vercel = File('${buildDir.path}/vercel.json');
    vercel.writeAsStringSync('''
{
  "routes": [
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
''');

    // GitHub Pages note (documented, not auto-fixable)
  }
}
