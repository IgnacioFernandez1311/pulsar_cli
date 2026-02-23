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

  Future<void> _extractCss() async {
    // Aquí luego irá el extractor real
    const css = '/* Pulsar extracted styles */';
    await cssOutput.writeAsString(css);
  }
}
