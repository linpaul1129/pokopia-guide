import 'dart:io';
import 'dart:convert';

final httpClient = HttpClient();

Future<void> downloadImage(String url, String savePath) async {
  final file = File(savePath);
  if (await file.exists()) return;
  try {
    final req = await httpClient.getUrl(Uri.parse(url));
    final res = await req.close();
    if (res.statusCode == 200) {
      await res.pipe(file.openWrite());
    } else {
      print('  [WARN] HTTP ${res.statusCode} $url');
    }
  } catch (e) {
    print('  [ERROR] $url => $e');
  }
}

String fname(String url) => url.split('/').last;

// Extract attribute value from raw img-tag content
String? attr(String tag, String name) =>
    RegExp('$name="([^"]+)"').firstMatch(tag)?.group(1);

void main() async {
  final content = await File('cubeMaterial.html').readAsString();
  final articles = content.split(RegExp(r'(?=<article[\s>])'));

  final cubeDir = Directory('assets/images/cubeMaterials');
  final matDir = Directory('assets/images/materials');
  await cubeDir.create(recursive: true);
  await matDir.create(recursive: true);

  // ── All img tag inner content ─────────────────────────────────────────────
  // Captures everything between <img and the closing >
  final imgTagRe = RegExp(r'<img([\s\S]+?)(?:/>|>)', dotAll: true);
  final altRe = RegExp(r'alt="([^"]+)"');
  final srcRe = RegExp(r'src="(https://pokopiaguide\.com/images/items/[^"]+)"');

  // Quantity: multiplication sign (U+00D7), × entity, or plain x
  final qtyRe = RegExp('[\u00D7×x](\\d+)');

  // Unlock condition paragraphs
  final unlockRe = RegExp(
    r'<p\s[^>]*class="text-xs font-semibold[^"]*"[^>]*>\s*([\s\S]*?)\s*</p>',
    dotAll: true,
  );

  // h3 name
  final nameRe = RegExp(r'<h3[^>]*>\s*([^<\s][^<]*?)\s*</h3>');

  final result = <String, Map<String, dynamic>>{};
  final cubeUrlMap = <String, String>{};
  final matUrlMap = <String, String>{};

  for (final block in articles) {
    // ── 1. Find cube item image (has drop-shadow-sm) ────────────────────────
    String? cubeName;
    String? cubeUrl;

    for (final m in imgTagRe.allMatches(block)) {
      final tagContent = m.group(1)!;
      if (!tagContent.contains('drop-shadow-sm')) continue;
      final srcM = srcRe.firstMatch(tagContent);
      if (srcM == null) continue;
      cubeUrl = srcM.group(1)!.trim();
      final altM = altRe.firstMatch(tagContent);
      if (altM != null) cubeName = altM.group(1)!.trim();
      break; // first drop-shadow-sm img is the cube item
    }
    if (cubeUrl == null) continue;

    // Override name with h3 if present
    final nameM = nameRe.firstMatch(block);
    if (nameM != null) cubeName = nameM.group(1)!.trim();
    if (cubeName == null || cubeName.isEmpty) continue;

    cubeUrlMap[fname(cubeUrl)] = cubeUrl;

    // ── 2. Split into sections ───────────────────────────────────────────────
    final idxMat = block.indexOf('所需材料');
    final idxUnlock = block.indexOf('配方解鎖條件');

    final matSection = (idxMat >= 0)
        ? block.substring(idxMat, idxUnlock > idxMat ? idxUnlock : block.length)
        : '';
    final condSection = idxUnlock >= 0 ? block.substring(idxUnlock) : '';

    // ── 3. Parse materials ───────────────────────────────────────────────────
    // Find material images (no drop-shadow-sm) in matSection
    final matImgMatches = <(String, String)>[]; // (name, url)
    for (final m in imgTagRe.allMatches(matSection)) {
      final tagContent = m.group(1)!;
      if (tagContent.contains('drop-shadow-sm')) continue;
      final srcM = srcRe.firstMatch(tagContent);
      if (srcM == null) continue;
      final matUrl = srcM.group(1)!.trim();
      final altM = altRe.firstMatch(tagContent);
      final matName = altM?.group(1)?.trim() ?? '';
      matImgMatches.add((matName, matUrl));
    }

    // Find quantities in matSection (same count order as images)
    final qtys = qtyRe.allMatches(matSection).toList();

    final materials = <Map<String, dynamic>>[];
    for (var i = 0; i < matImgMatches.length; i++) {
      final (matName, matUrl) = matImgMatches[i];
      final qty = i < qtys.length
          ? int.tryParse(qtys[i].group(1)!) ?? 1
          : 1;
      matUrlMap[fname(matUrl)] = matUrl;
      materials.add({
        'name': matName,
        'image': fname(matUrl),
        'quantity': qty,
      });
    }

    // ── 4. Parse unlock conditions ───────────────────────────────────────────
    final unlockConditions = unlockRe
        .allMatches(condSection)
        .map((m) => m.group(1)!.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    result[cubeName] = {
      'image': fname(cubeUrl),
      'materials': materials,
      'unlockConditions': unlockConditions,
    };
  }

  // ── Download cube images ──────────────────────────────────────────────────
  print('Downloading ${cubeUrlMap.length} cube images...');
  int n = 0;
  for (final e in cubeUrlMap.entries) {
    await downloadImage(e.value, '${cubeDir.path}/${e.key}');
    if (++n % 50 == 0) print('  $n / ${cubeUrlMap.length}');
  }

  print('Checking ${matUrlMap.length} material images...');
  for (final e in matUrlMap.entries) {
    await downloadImage(e.value, '${matDir.path}/${e.key}');
  }

  // ── Write JSON ────────────────────────────────────────────────────────────
  await File('assets/data/cubeMaterials.json').writeAsString(
    JsonEncoder.withIndent('  ').convert(result),
    encoding: utf8,
  );

  httpClient.close();

  print('\nDone!');
  print('  Parsed ${result.length} cube items');
  print('  assets/data/cubeMaterials.json');
  print('  assets/images/cubeMaterials/ (${cubeUrlMap.length} images)');

  for (final e in result.entries.take(5)) {
    print('\n[${e.key}]');
    print('  image: ${e.value['image']}');
    print('  materials: ${e.value['materials']}');
    print('  unlock: ${(e.value['unlockConditions'] as List).take(1)}');
  }
}
