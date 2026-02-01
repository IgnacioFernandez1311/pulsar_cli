import 'dart:async';
import 'dart:io';
import 'package:args/command_runner.dart';

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

  final _reloadClients = <WebSocket>[];
  Timer? _debounce;
  bool _isCompiling = false;

  @override
  Future<void> run() async {
    final port = int.parse(argResults?['port'] ?? '8080');
    final watch = argResults?['watch'] == true;

    final root = Directory.current;
    final webDir = Directory('${root.path}/web');
    final libDir = Directory('${root.path}/lib');

    if (!webDir.existsSync()) {
      stderr.writeln('❌ web/ directory not found');
      exit(1);
    }

    await _compile(root.path);

    if (watch) {
      _startWatcher(root.path, webDir, libDir);
    }

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

    print(
      watch
          ? '🔥 Pulsar dev server (watch) → http://localhost:$port'
          : '🚀 Pulsar running → http://localhost:$port',
    );

    await for (final request in server) {
      if (request.uri.path == '/__pulsar_ws') {
        await _handleWebSocket(request);
        continue;
      }

      await _handleRequest(request, webDir, injectReload: watch);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                   Watcher                                  */
  /* -------------------------------------------------------------------------- */

  void _startWatcher(String cwd, Directory webDir, Directory libDir) {
    print('👀 Watching for file changes...');

    bool shouldIgnore(String path) {
      return path.endsWith('.js') ||
          path.endsWith('.dart.js') ||
          path.endsWith('.js.map') ||
          path.endsWith('.map');
    }

    void onChange(FileSystemEvent event) {
      // 🔒 Ignore our own compilation output
      if (_isCompiling) return;

      // 🔕 Ignore directory-level noise
      if (event is FileSystemModifyEvent && event.isDirectory) return;

      // 🔕 Ignore JS & map outputs
      if (shouldIgnore(event.path)) return;

      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () async {
        print('🔁 Changes detected, rebuilding...');
        _isCompiling = true;
        await _compile(cwd);
        _isCompiling = false;
        _notifyReload();
      });
    }

    if (webDir.existsSync()) {
      webDir.watch(recursive: true).listen(onChange);
    }

    if (libDir.existsSync()) {
      libDir.watch(recursive: true).listen(onChange);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                               Dart compilation                              */
  /* -------------------------------------------------------------------------- */

  Future<void> _compile(String cwd) async {
    final entry = File('$cwd/web/main.dart');

    if (!entry.existsSync()) {
      stderr.writeln('❌ web/main.dart not found');
      exit(1);
    }

    print('🔨 Compiling Dart → JS');

    final result = await Process.run(
      'dart',
      ['compile', 'js', 'web/main.dart', '-o', 'web/main.dart.js'],
      workingDirectory: cwd,
      runInShell: true,
    );

    if (result.stdout.toString().isNotEmpty) {
      stdout.writeln(result.stdout);
    }

    if (result.stderr.toString().isNotEmpty) {
      stderr.writeln(result.stderr);
    }

    if (result.exitCode != 0) {
      stderr.writeln('❌ Dart compilation failed');
      return;
    }

    print('✅ main.dart.js updated');
  }

  /* -------------------------------------------------------------------------- */
  /*                                WebSocket reload                             */
  /* -------------------------------------------------------------------------- */

  Future<void> _handleWebSocket(HttpRequest request) async {
    final socket = await WebSocketTransformer.upgrade(request);
    _reloadClients.add(socket);

    socket.done.then((_) {
      _reloadClients.remove(socket);
    });
  }

  void _notifyReload() {
    for (final socket in _reloadClients) {
      socket.add('reload');
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                  HTTP serve                                 */
  /* -------------------------------------------------------------------------- */

  Future<void> _handleRequest(
    HttpRequest request,
    Directory webDir, {
    required bool injectReload,
  }) async {
    final path = request.uri.path;

    if (path == '/' || path.isEmpty) {
      return _serveIndex(request, webDir, injectReload);
    }

    final file = File('${webDir.path}$path');

    if (file.existsSync() &&
        file.statSync().type == FileSystemEntityType.file) {
      return _serveFile(request, file);
    }

    // SPA fallback
    return _serveIndex(request, webDir, injectReload);
  }

  Future<void> _serveIndex(
    HttpRequest request,
    Directory webDir,
    bool injectReload,
  ) async {
    final index = File('${webDir.path}/index.html');
    var html = await index.readAsString();

    if (injectReload) {
      html = html.replaceFirst('</body>', '''
<script>
(() => {
  const ws = new WebSocket('ws://' + location.host + '/__pulsar_ws');
  ws.onmessage = (e) => {
    if (e.data === 'reload') location.reload();
  };
})();
</script>
</body>
''');
    }

    request.response.headers.contentType = ContentType.html;
    request.response.write(html);
    await request.response.close();
  }

  Future<void> _serveFile(HttpRequest request, File file) async {
    request.response.headers.contentType = ContentType.parse(
      _mimeType(file.path),
    );

    await request.response.addStream(file.openRead());
    await request.response.close();
  }

  String _mimeType(String path) {
    if (path.endsWith('.js')) return 'application/javascript';
    if (path.endsWith('.css')) return 'text/css';
    if (path.endsWith('.html')) return 'text/html';
    if (path.endsWith('.svg')) return 'image/svg+xml';
    if (path.endsWith('.json')) return 'application/json';
    return 'application/octet-stream';
  }
}
