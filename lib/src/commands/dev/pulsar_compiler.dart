import 'dart:io';

enum CompileMode { dev, release }

class CompileResult {
  final bool success;
  final Duration duration;
  final String? error;

  CompileResult({required this.success, required this.duration, this.error});
}

class PulsarCompiler {
  final Directory root;
  final CompileMode mode;

  late final Directory dartToolDir;
  late final Directory pulsarDir;

  late final File jsOutput;
  late final File cssOutput;

  PulsarCompiler({required this.root, required this.mode}) {
    dartToolDir = Directory('${root.path}/.dart_tool');
    pulsarDir = Directory('${dartToolDir.path}/pulsar');

    jsOutput = File('${pulsarDir.path}/main.dart.js');
    cssOutput = File('${pulsarDir.path}/pulsar.css');
  }

  /* ---------------------------------------------------------- */
  /* MAIN COMPILE                                               */
  /* ---------------------------------------------------------- */

  Future<CompileResult> compile() async {
    final stopwatch = Stopwatch()..start();

    try {
      pulsarDir.createSync(recursive: true);

      final entry = File('${root.path}/web/main.dart');
      if (!entry.existsSync()) {
        return CompileResult(
          success: false,
          duration: Duration.zero,
          error: 'web/main.dart not found',
        );
      }

      final args = ['compile', 'js', 'web/main.dart', '-o', jsOutput.path];

      if (mode == CompileMode.release) {
        args.add('-O4');
      }

      final result = await Process.run(
        'dart',
        args,
        workingDirectory: root.path,
        runInShell: true,
      );

      if (result.exitCode != 0) {
        return CompileResult(
          success: false,
          duration: stopwatch.elapsed,
          error: result.stderr.toString(),
        );
      }

      await _extractCss();

      stopwatch.stop();

      return CompileResult(success: true, duration: stopwatch.elapsed);
    } catch (e) {
      return CompileResult(
        success: false,
        duration: stopwatch.elapsed,
        error: e.toString(),
      );
    }
  }

  /* ---------------------------------------------------------- */
  /* CSS EXTRACTION                                             */
  /* ---------------------------------------------------------- */

  Future<void> _extractCss() async {
    final cssImports = await _scanCssImports();

    if (cssImports.isEmpty) {
      await cssOutput.writeAsString('');
      return;
    }

    final buffer = StringBuffer();

    for (final path in cssImports) {
      final file = File('${root.path}/web/$path');
      if (file.existsSync()) {
        buffer.writeln(await file.readAsString());
      }
    }

    var css = buffer.toString();

    if (mode == CompileMode.release) {
      css = _minifyCss(css);
    }

    await cssOutput.writeAsString(css);
  }

  /* ---------------------------------------------------------- */
  /* CSS ANALYZER (SCAN css("file.css"))                       */
  /* ---------------------------------------------------------- */

  Future<Set<String>> _scanCssImports() async {
    final cssFiles = <String>{};

    final libDir = Directory('${root.path}/lib');
    final webDir = Directory('${root.path}/web');

    final regex = RegExp(r'''css\(["']([^"']+)["']\)''');

    Future<void> scanDir(Directory dir) async {
      if (!dir.existsSync()) return;

      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = await entity.readAsString();
          final matches = regex.allMatches(content);

          for (final match in matches) {
            cssFiles.add(match.group(1)!);
          }
        }
      }
    }

    await scanDir(libDir);
    await scanDir(webDir);

    return cssFiles;
  }

  /* ---------------------------------------------------------- */
  /* CSS MINIFIER                                               */
  /* ---------------------------------------------------------- */

  String _minifyCss(String css) {
    // Remove comments
    css = css.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');

    // Collapse whitespace
    css = css.replaceAll(RegExp(r'\s+'), ' ');

    // Remove space around symbols
    css = css.replaceAll(RegExp(r'\s*{\s*'), '{');
    css = css.replaceAll(RegExp(r'\s*}\s*'), '}');
    css = css.replaceAll(RegExp(r'\s*:\s*'), ':');
    css = css.replaceAll(RegExp(r'\s*;\s*'), ';');
    css = css.replaceAll(RegExp(r'\s*,\s*'), ',');

    // Remove last semicolon before }
    css = css.replaceAll(RegExp(r';}'), '}');

    return css.trim();
  }
}
