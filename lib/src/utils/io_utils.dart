import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;

Future<void> copyTemplate(String template, Directory destination) async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse('package:pulsar_cli/src/templates/$template'),
  );

  if (uri == null) {
    throw Exception('Template $template not found');
  }

  final Directory templateDir = Directory.fromUri(uri);

  if (!await templateDir.exists()) {
    throw Exception('Template "$template" not found');
  }
  await for (final entity in templateDir.list(recursive: true)) {
    if (entity is File) {
      final relativePath = p.relative(entity.path, from: templateDir.path);
      final newPath = p.join(destination.path, relativePath);
      final newFile = File(p.join(destination.path, relativePath));
      await newFile.create(recursive: true);
      await entity.copy(newPath);
    }
  }
  stdout.writeln('Project created from template $template.');
}
