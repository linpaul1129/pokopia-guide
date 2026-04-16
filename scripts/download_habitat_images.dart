import 'dart:io';
import 'dart:convert';

void main() async {
  // 從 HTML 中解析棲息地 id → 圖片檔名對應
  final htmlFile = File('habitatsSrc.html');
  final content = await htmlFile.readAsString();

  // 擷取所有棲息地圖片的 alt(中文名) 和 src 中的 habitat_id
  final imgRegex = RegExp(
    r'<img\s+alt="([^"]+)"[^>]*\s+src="https://pokopiaguide\.com/images/habitats/(habitat_(\d+)\.png)"',
  );

  final matches = imgRegex.allMatches(content).toList();
  print('共找到 ${matches.length} 筆棲息地圖片');

  // 建立 id → filename 對應
  final idToFilename = <int, String>{};
  final nameToId = <String, int>{};
  for (final m in matches) {
    final chineseName = m.group(1)!;
    final filename = m.group(2)!;   // habitat_1.png
    final id = int.parse(m.group(3)!);
    idToFilename[id] = filename;
    nameToId[chineseName] = id;
  }

  // 下載圖片
  final outputDir = Directory('assets/images/habitats');
  if (!await outputDir.exists()) await outputDir.create(recursive: true);

  final client = HttpClient();
  int success = 0;
  int skip = 0;
  int fail = 0;

  for (final entry in idToFilename.entries) {
    final filename = entry.value;
    final outFile = File('assets/images/habitats/$filename');

    if (await outFile.exists()) {
      skip++;
      continue;
    }

    final url = 'https://pokopiaguide.com/images/habitats/$filename';
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateBytes(response);
        await outFile.writeAsBytes(bytes);
        success++;
        print('[$success] 下載 $filename');
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
  print('\n圖片下載完成！成功: $success，略過: $skip，失敗: $fail\n');

  // 更新 habitats.json，加入 image 欄位
  final jsonFile = File('assets/data/habitats.json');
  final jsonContent = await jsonFile.readAsString();
  final data = jsonDecode(jsonContent) as Map<String, dynamic>;
  final habitats = (data['habitats'] as List).cast<Map<String, dynamic>>();

  int updated = 0;
  int notFound = 0;

  for (final habitat in habitats) {
    final id = habitat['id'] as int;
    if (idToFilename.containsKey(id)) {
      habitat['image'] = idToFilename[id];
      updated++;
    } else {
      print('找不到圖片: id=$id name=${habitat['name']}');
      notFound++;
    }
  }

  await jsonFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(data),
  );

  print('habitats.json 更新完成！已更新: $updated，找不到圖片: $notFound');
}

Future<List<int>> consolidateBytes(HttpClientResponse response) async {
  final chunks = <List<int>>[];
  await for (final chunk in response) {
    chunks.add(chunk);
  }
  return chunks.expand((c) => c).toList();
}
