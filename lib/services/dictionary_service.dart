import 'dart:convert';
import 'package:http/http.dart' as http;

/// 联网校验/纠正模糊识别的英文单词
/// 使用 Free Dictionary API 做单词有效性校验和释义查询
class DictionaryService {
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en/';

  /// 校验单词是否存在，返回词性列表（若不存在返回空列表）
  Future<List<String>> lookupPartsOfSpeech(String word) async {
    try {
      final resp = await http.get(Uri.parse('$_baseUrl${word.trim().toLowerCase()}'));
      if (resp.statusCode != 200) return [];
      final data = json.decode(resp.body) as List;
      final Set<String> pos = {};
      for (final entry in data) {
        final meanings = entry['meanings'] as List?;
        if (meanings != null) {
          for (final m in meanings) {
            if (m['partOfSpeech'] != null) pos.add(m['partOfSpeech'] as String);
          }
        }
      }
      return pos.toList();
    } catch (_) {
      return [];
    }
  }

  /// 编辑距离算法，用于从候选词库中找出与 OCR 残缺结果最接近的单词
  int editDistance(String a, String b) {
    final la = a.length, lb = b.length;
    final dp = List.generate(la + 1, (i) => List<int>.filled(lb + 1, 0));
    for (int i = 0; i <= la; i++) dp[i][0] = i;
    for (int j = 0; j <= lb; j++) dp[0][j] = j;
    for (int i = 1; i <= la; i++) {
      for (int j = 1; j <= lb; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce((x, y) => x < y ? x : y);
        }
      }
    }
    return dp[la][lb];
  }

  /// 从候选词列表中找出编辑距离最小的匹配（用于纠正模糊 OCR 结果）
  String? findClosestMatch(String ocrGuess, List<String> candidates) {
    if (candidates.isEmpty) return null;
    String? best;
    int bestDist = 999;
    for (final c in candidates) {
      final d = editDistance(ocrGuess.toLowerCase(), c.toLowerCase());
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    return best;
  }
}
