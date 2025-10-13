import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> copyTemplate(String template, Directory destination) async {
  final Directory templateDir = Directory(
    p.join('lib', 'src', 'templates', '${template}_template'),
  );

  if (!templateDir.existsSync()) {
    throw Exception('Template "$template" not found');
  }
  await for (final entity in templateDir.list(recursive: true)) {
    if (entity is File) {
      final relativePath = p.relative(entity.path, from: templateDir.path);
      final newFile = File(p.join(destination.path, relativePath));
      await newFile.create(recursive: true);
      await newFile.writeAsBytes(await entity.readAsBytes());
    }
  }
}
