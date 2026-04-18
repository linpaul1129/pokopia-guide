import 'dart:convert';
import 'dart:io';

void main() async {
  final items =
      jsonDecode(File('assets/data/items.json').readAsStringSync())
          as Map<String, dynamic>;

  // Collect all image filenames from items.json
  final allImages = <String>{};
  for (final value in items.values) {
    final img = (value as Map<String, dynamic>)['image'] as String?;
    if (img != null) allImages.add(img);
  }

  // Find which are missing from assets/images/items/
  final itemsDir = Directory('assets/images/items');
  final existing = itemsDir.listSync().map((f) => File(f.path).uri.pathSegments.last).toSet();
  final missing = allImages.where((img) => !existing.contains(img)).toList()..sort();

  if (missing.isEmpty) {
    print('All images already exist. Nothing to download.');
    return;
  }

  print('Missing ${missing.length} images: $missing');

  // Parse items.html to find image URLs
  final html = File('items.html').readAsStringSync();
  final urlRegex = RegExp(r'src="(https://[^"]+/images/items/([^"]+))"');
  final urlMap = <String, String>{};
  for (final match in urlRegex.allMatches(html)) {
    urlMap[match.group(2)!] = match.group(1)!;
  }

  final client = HttpClient();
  int downloaded = 0;
  int notFound = 0;

  for (final img in missing) {
    final url = urlMap[img];
    if (url == null) {
      print('  [NOT IN HTML] $img');
      notFound++;
      continue;
    }

    try {
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        await File('assets/images/items/$img').writeAsBytes(bytes);
        print('  [OK] $img');
        downloaded++;
      } else {
        print('  [HTTP ${response.statusCode}] $img');
        notFound++;
      }
    } catch (e) {
      print('  [ERROR] $img: $e');
      notFound++;
    }
  }

  client.close();
  print('\nDone. Downloaded: $downloaded, Failed/Not found: $notFound');
}

Future<List<int>> consolidateHttpClientResponseBytes(
    HttpClientResponse response) async {
  final bytes = <int>[];
  await for (final chunk in response) {
    bytes.addAll(chunk);
  }
  return bytes;
}
