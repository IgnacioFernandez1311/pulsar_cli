import 'dart:async';
import 'dart:io';

import './pulsar_compiler.dart';
import 'dev_logger.dart';

class DevServer {
  final int port;
  final bool watch;

  DevServer({required this.port, required this.watch});

  final _reloadClients = <WebSocket>[];
  Timer? _debounce;
  bool _isBuilding = false;

  late final Directory _root;
  late final Directory _webDir;
  late final Directory _libDir;

  late final PulsarCompiler _compiler;

  /* -------------------------------------------------------------------------- */
  /*                                    START                                   */
  /* -------------------------------------------------------------------------- */

  Future<void> start() async {
    _root = Directory.current;
    _webDir = Directory('${_root.path}/web');
    _libDir = Directory('${_root.path}/lib');

    if (!_webDir.existsSync()) {
      DevLogger.error('web/ directory not found');
      exit(1);
    }

    _compiler = PulsarCompiler(root: _root, mode: CompileMode.dev);

    await _build(initial: true);

    if (watch) {
      _startWatcher();
    } else {
      _listenForManualReload();
    }

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

    DevLogger.banner(port, watch);

    await for (final request in server) {
      if (request.uri.path == '/__pulsar_ws') {
        await _handleWebSocket(request);
        continue;
      }

      await _handleRequest(request);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                   BUILD                                    */
  /* -------------------------------------------------------------------------- */

  Future<void> _build({bool initial = false}) async {
    if (_isBuilding) return;
    _isBuilding = true;

    DevLogger.buildStart(initial ? 'Compiling Dart → JS' : 'Rebuilding...');

    final result = await _compiler.compile();

    if (!result.success) {
      DevLogger.buildFail('Compilation failed');
      if (result.error != null) {
        stderr.write(result.error);
      }
      _isBuilding = false;
      return;
    }

    DevLogger.buildSuccess(
      'Build completed in ${result.duration.inMilliseconds}ms',
    );

    _isBuilding = false;
  }

  /* -------------------------------------------------------------------------- */
  /*                                   WATCH                                    */
  /* -------------------------------------------------------------------------- */

  void _startWatcher() {
    DevLogger.watch('Watching for file changes');

    void onChange(FileSystemEvent event) {
      if (_isBuilding) return;

      if (event.path.contains('.dart_tool')) return;

      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () async {
        await _build();
        _notifyReload();
      });
    }

    _webDir.watch(recursive: true).listen(onChange);
    _libDir.watch(recursive: true).listen(onChange);
  }

  /* -------------------------------------------------------------------------- */
  /*                             MANUAL RELOAD MODE                             */
  /* -------------------------------------------------------------------------- */

  void _listenForManualReload() {
    DevLogger.info('Press "r" to rebuild, "q" to quit.');

    stdin.lineMode = false;
    stdin.echoMode = false;

    stdin.listen((data) async {
      final char = String.fromCharCodes(data);

      if (char == 'r') {
        await _build();
        _notifyReload();
      }

      if (char == 'q') {
        DevLogger.info('Shutting down...');
        exit(0);
      }
    });
  }

  /* -------------------------------------------------------------------------- */
  /*                                HTTP HANDLING                               */
  /* -------------------------------------------------------------------------- */

  Future<void> _handleRequest(HttpRequest request) async {
    final path = request.uri.path;

    if (path == '/main.dart.js') {
      return _serveFile(request, _compiler.jsOutput);
    }

    if (path == '/pulsar.css') {
      return _serveFile(request, _compiler.cssOutput);
    }

    if (path == '/' || path.isEmpty) {
      return _serveIndex(request);
    }

    final file = File('${_webDir.path}$path');

    if (file.existsSync() &&
        file.statSync().type == FileSystemEntityType.file) {
      return _serveFile(request, file);
    }

    // SPA fallback
    return _serveIndex(request);
  }

  Future<void> _serveIndex(HttpRequest request) async {
    final index = File('${_webDir.path}/index.html');
    var html = await index.readAsString();

    html = html.replaceFirst('</head>', '''
<link rel="stylesheet" href="/pulsar.css">
</head>
''');

    if (watch) {
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
    if (!file.existsSync()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    request.response.headers.contentType = ContentType.parse(
      _mimeType(file.path),
    );

    await request.response.addStream(file.openRead());
    await request.response.close();
  }

  /* -------------------------------------------------------------------------- */
  /*                                 WEBSOCKET                                  */
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
  /*                                   UTILS                                    */
  /* -------------------------------------------------------------------------- */

  String _mimeType(String path) {
    if (path.endsWith('.js')) return 'application/javascript';
    if (path.endsWith('.css')) return 'text/css';
    if (path.endsWith('.html')) return 'text/html';
    if (path.endsWith('.svg')) return 'image/svg+xml';
    if (path.endsWith('.json')) return 'application/json';
    return 'application/octet-stream';
  }
}
