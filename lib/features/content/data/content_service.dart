import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/content.dart';

// コンテンツサービスのProvider
final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentService();
});

// コンテンツリストのFutureProvider
final contentListProvider = FutureProvider<List<Content>>((ref) async {
  final service = ref.read(contentServiceProvider);
  return service.getAllContents();
});

class ContentService {
  List<Content>? _cachedContents;

  /// すべてのコンテンツを取得
  Future<List<Content>> getAllContents() async {
    if (_cachedContents != null) {
      return _cachedContents!;
    }

    try {
      // アセットからJSONファイルを読み込み
      final String jsonString = await rootBundle.loadString('assets/data/sample_contents.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // JSONをContentオブジェクトに変換
      final List<dynamic> contentsJson = jsonData['contents'];
      _cachedContents = contentsJson.map((json) => Content.fromJson(json)).toList();
      
      return _cachedContents!;
    } catch (e) {
      print('コンテンツ読み込みエラー: $e');
      return [];
    }
  }

  /// 特定のコンテンツを取得
  Future<Content?> getContentById(String id) async {
    final allContents = await getAllContents();
    try {
      return allContents.firstWhere((content) => content.id == id);
    } catch (e) {
      return null;
    }
  }
}