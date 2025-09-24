class Content {
  final String id;
  final String title;
  final String description;
  final String genre;
  final ContentLevel level;
  final int duration;
  final ContentDifficulty difficulty;
  final ContentScript script;
  final List<Vocabulary> vocabulary;
  final ContentStats stats;

  Content({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.level,
    required this.duration,
    required this.difficulty,
    required this.script,
    required this.vocabulary,
    required this.stats,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      genre: json['genre'],
      level: ContentLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => ContentLevel.intermediate,
      ),
      duration: json['duration'],
      difficulty: ContentDifficulty.fromJson(json['difficulty']),
      script: ContentScript.fromJson(json['script']),
      vocabulary: (json['vocabulary'] as List)
          .map((v) => Vocabulary.fromJson(v))
          .toList(),
      stats: ContentStats.fromJson(json['stats']),
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get levelDisplayName {
    switch (level) {
      case ContentLevel.beginner:
        return '初級';
      case ContentLevel.intermediate:
        return '中級';
      case ContentLevel.advanced:
        return '上級';
    }
  }

  String get genreDisplayName {
    switch (genre) {
      case 'news':
        return 'ニュース';
      case 'business':
        return 'ビジネス';
      case 'tech':
        return 'テック';
      case 'entertainment':
        return 'エンタメ';
      case 'lifestyle':
        return 'ライフスタイル';
      default:
        return genre;
    }
  }
}

enum ContentLevel { beginner, intermediate, advanced }

class ContentDifficulty {
  final int vocabularyLevel;
  final int estimatedToeicScore;

  ContentDifficulty({
    required this.vocabularyLevel,
    required this.estimatedToeicScore,
  });

  factory ContentDifficulty.fromJson(Map<String, dynamic> json) {
    return ContentDifficulty(
      vocabularyLevel: json['vocabularyLevel'],
      estimatedToeicScore: json['estimatedToeicScore'],
    );
  }
}

class ContentScript {
  final String fullText;
  final List<ScriptSentence> sentences;

  ContentScript({
    required this.fullText,
    required this.sentences,
  });

  factory ContentScript.fromJson(Map<String, dynamic> json) {
    return ContentScript(
      fullText: json['fullText'],
      sentences: (json['sentences'] as List)
          .map((s) => ScriptSentence.fromJson(s))
          .toList(),
    );
  }
}

class ScriptSentence {
  final int id;
  final String text;
  final double startTime;
  final double endTime;

  ScriptSentence({
    required this.id,
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  factory ScriptSentence.fromJson(Map<String, dynamic> json) {
    return ScriptSentence(
      id: json['id'],
      text: json['text'],
      startTime: json['startTime'].toDouble(),
      endTime: json['endTime'].toDouble(),
    );
  }
}

class Vocabulary {
  final String word;
  final String definition;
  final int difficulty;

  Vocabulary({
    required this.word,
    required this.definition,
    required this.difficulty,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      word: json['word'],
      definition: json['definition'],
      difficulty: json['difficulty'],
    );
  }
}

class ContentStats {
  final double averageScore;
  final double completionRate;

  ContentStats({
    required this.averageScore,
    required this.completionRate,
  });

  factory ContentStats.fromJson(Map<String, dynamic> json) {
    return ContentStats(
      averageScore: json['averageScore'].toDouble(),
      completionRate: json['completionRate'].toDouble(),
    );
  }
}