import 'dart:io';
import 'dart:convert';

final httpClient = HttpClient();

Future<void> downloadImage(String url, String savePath) async {
  final file = File(savePath);
  if (await file.exists()) return;
  try {
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode == 200) {
      await response.pipe(file.openWrite());
    } else {
      print('  [WARN] HTTP ${response.statusCode} $url');
    }
  } catch (e) {
    print('  [ERROR] $url => $e');
  }
}

String filenameFromUrl(String url) => url.split('/').last;

void main() async {
  final content = await File('materials.html').readAsString();

  // ── Regex patterns ─────────────────────────────────────────────────────────
  final articleSplit = RegExp(r'(?=<article[\s>])');

  // item image src (items/)
  final imgRe = RegExp(
    r'<img\s[^>]*src="(https://pokopiaguide\.com/images/items/[^"]+)"',
  );

  // h3 name
  final nameRe = RegExp(r'<h3[^>]*>\s*([^<\s][^<]*?)\s*</h3>');

  // description – the italic 11px paragraph
  final descRe = RegExp(
    r'<p\s[^>]*class="text-\[11px\] italic[^"]*"[^>]*>\s*([\s\S]*?)\s*</p>',
  );

  // each acquisition branch paragraph
  final sourceRe = RegExp(
    r'<p\s[^>]*class="text-xs font-semibold[^"]*"[^>]*>\s*([\s\S]*?)\s*</p>',
  );

  // ── Parse ──────────────────────────────────────────────────────────────────
  final articles = content.split(articleSplit);
  final result = <String, Map<String, dynamic>>{};

  for (final block in articles) {
    final imgMatch = imgRe.firstMatch(block);
    if (imgMatch == null) continue;

    final imageUrl = imgMatch.group(1)!.trim();
    final imageFile = filenameFromUrl(imageUrl);

    final nameMatch = nameRe.firstMatch(block);
    if (nameMatch == null) continue;
    final name = nameMatch.group(1)!.trim();

    final descMatch = descRe.firstMatch(block);
    final description = descMatch?.group(1)?.trim() ?? '';

    final sources = sourceRe
        .allMatches(block)
        .map((m) => m.group(1)!.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    result[name] = {
      'image': imageFile,
      'description': description,
      'sources': sources,
    };
  }

  // ── Download any images not yet in assets/images/materials/ ───────────────
  final matDir = Directory('assets/images/materials');
  await matDir.create(recursive: true);

  // Collect all image URLs from the parsed articles
  int downloaded = 0;
  final urlMap = <String, String>{}; // filename -> url (rebuilt from html)
  for (final block in articles) {
    final imgMatch = imgRe.firstMatch(block);
    if (imgMatch == null) continue;
    final url = imgMatch.group(1)!.trim();
    urlMap[filenameFromUrl(url)] = url;
  }

  for (final entry in urlMap.entries) {
    final path = '${matDir.path}/${entry.key}';
    if (!File(path).existsSync()) {
      await downloadImage(entry.value, path);
      downloaded++;
    }
  }

  // ── Write materials.json ───────────────────────────────────────────────────
  final encoder = JsonEncoder.withIndent('  ');
  await File('assets/data/materials.json')
      .writeAsString(encoder.convert(result), encoding: utf8);

  httpClient.close();

  print('Done!');
  print('  Parsed ${result.length} materials');
  print('  Downloaded $downloaded new images');
  print('  Written assets/data/materials.json');

  // Preview first 3
  for (final e in result.entries.take(3)) {
    print('\n[${e.key}]');
    print('  image: ${e.value['image']}');
    print('  description: ${e.value['description']}');
    print('  sources: ${e.value['sources']}');
  }
}
