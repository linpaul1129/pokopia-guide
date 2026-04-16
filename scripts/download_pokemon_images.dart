import 'dart:io';
import 'dart:convert';

void main() async {
  final htmlFile = File('imgSrc.html');
  final content = await htmlFile.readAsString();

  // 擷取所有 pokemon 圖片的 alt(中文名) 和 src(英文檔名) 對應
  final imgRegex = RegExp(
    r'<img\s+alt="([^"]+)"[^>]*\s+src="(https://assets\.pokopiaguide\.com/pokemon/([^"]+\.png))"',
  );

  final matches = imgRegex.allMatches(content).toList();
  print('共找到 ${matches.length} 筆寶可夢圖片');

  // 建立中文名稱 → 英文檔名的對應表
  final nameMap = <String, String>{};
  for (final m in matches) {
    final chineseName = m.group(1)!;
    final filename = m.group(3)!; // e.g. bulbasaur.png
    nameMap[chineseName] = filename;
  }

  // 儲存對應表 JSON
  final mapFile = File('assets/data/pokemon_name_map.json');
  await mapFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(nameMap),
  );
  print('已儲存對應表 → assets/data/pokemon_name_map.json');

  // 下載所有圖片
  final outputDir = Directory('assets/images/pokemon');
  if (!await outputDir.exists()) await outputDir.create(recursive: true);

  final client = HttpClient();
  int success = 0;
  int skip = 0;
  int fail = 0;

  for (final entry in nameMap.entries) {
    final filename = entry.value;
    final outFile = File('assets/images/pokemon/$filename');

    if (await outFile.exists()) {
      skip++;
      continue;
    }

    final url = 'https://assets.pokopiaguide.com/pokemon/$filename';
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateBytes(response);
        await outFile.writeAsBytes(bytes);
        success++;
        print('[$success] 下載 $filename (${entry.key})');
      } else {
        fail++;
        print('失敗 HTTP ${response.statusCode}: $filename');
      }
    } catch (e) {
      fail++;
      print('錯誤: $filename → $e');
    }
  }

  client.close();
  print('\n完成！成功: $success，略過: $skip，失敗: $fail');
}

Future<List<int>> consolidateBytes(HttpClientResponse response) async {
  final chunks = <List<int>>[];
  await for (final chunk in response) {
    chunks.add(chunk);
  }
  return chunks.expand((c) => c).toList();
}
