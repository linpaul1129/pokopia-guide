import 'dart:io';
import 'dart:convert';

void main() async {
  final itemsDir = Directory('assets/images/items');
  await itemsDir.create(recursive: true);

  final merged = <String, dynamic>{};

  // ── materials.json → category: 材料 ──────────────────────────────────────
  final matStr = await File('assets/data/materials.json').readAsString();
  final matMap = json.decode(matStr) as Map<String, dynamic>;
  for (final e in matMap.entries) {
    final v = Map<String, dynamic>.from(e.value as Map);
    v['category'] = '材料';
    merged[e.key] = v;
  }

  // ── cubeMaterials.json → category: 方塊 ──────────────────────────────────
  final cubeStr = await File('assets/data/cubeMaterials.json').readAsString();
  final cubeMap = json.decode(cubeStr) as Map<String, dynamic>;
  for (final e in cubeMap.entries) {
    final v = Map<String, dynamic>.from(e.value as Map);
    v['category'] = '方塊';
    merged[e.key] = v;
  }

  // ── Write items.json ──────────────────────────────────────────────────────
  await File('assets/data/items.json').writeAsString(
    JsonEncoder.withIndent('  ').convert(merged),
    encoding: utf8,
  );
  print('Written assets/data/items.json (${merged.length} entries)');

  // ── Copy images: materials/ + cubeMaterials/ → items/ ────────────────────
  int copied = 0;
  for (final srcDir in [
    Directory('assets/images/materials'),
    Directory('assets/images/cubeMaterials'),
  ]) {
    if (!await srcDir.exists()) continue;
    await for (final entity in srcDir.list()) {
      if (entity is File) {
        final dest = File('${itemsDir.path}/${entity.uri.pathSegments.last}');
        if (!await dest.exists()) {
          await entity.copy(dest.path);
          copied++;
        }
      }
    }
  }
  print('Copied $copied images → assets/images/items/');
  print('Total images in items/: ${await itemsDir.list().length}');
}

extension on Stream<FileSystemEntity> {
  Future<int> get length async {
    int n = 0;
    await for (final _ in this) n++;
    return n;
  }
}
