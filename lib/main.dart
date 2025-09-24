import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/content/domain/entities/content.dart';
import 'features/content/data/content_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Firebase使う前のおまじない

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: ShadowingApp(),
    ),
  );
}

class ShadowingApp extends ConsumerWidget {
  const ShadowingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'シャドーイング学習アプリ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeTab(),
          ContentTab(),
          ProgressTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'コンテンツ'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: '進捗'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}

class HomeTab extends ConsumerWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentListAsync = ref.watch(contentListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('シャドーイング学習'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ユーザー情報カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ようこそ！', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('学習者さん', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard('連続学習', '0日', Icons.local_fire_department, Colors.orange),
                        _StatCard('総学習時間', '0分', Icons.access_time, Colors.blue),
                        _StatCard('平均スコア', '-点', Icons.star, Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // おすすめコンテンツセクション
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('おすすめコンテンツ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    // コンテンツタブに切り替え
                  },
                  child: const Text('すべて見る'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // コンテンツ表示
            contentListAsync.when(
              data: (contents) {
                // 最初の3つのコンテンツを表示
                final recommendedContents = contents.take(3).toList();
                return Column(
                  children: recommendedContents.map((content) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getLevelColor(content.level).withOpacity(0.2),
                          child: Icon(
                            Icons.play_arrow,
                            color: _getLevelColor(content.level),
                          ),
                        ),
                        title: Text(content.title),
                        subtitle: Text('${content.levelDisplayName} • ${content.formattedDuration} • ${content.genreDisplayName}'),
                        trailing: Text(
                          content.formattedDuration,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        onTap: () {
                          _showContentDetail(context, content);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Text('コンテンツの読み込みに失敗しました'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(ContentLevel level) {
    switch (level) {
      case ContentLevel.beginner:
        return Colors.green;
      case ContentLevel.intermediate:
        return Colors.orange;
      case ContentLevel.advanced:
        return Colors.red;
    }
  }

  void _showContentDetail(BuildContext context, Content content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(content.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content.description),
              const SizedBox(height: 12),
              Text('レベル: ${content.levelDisplayName}'),
              Text('ジャンル: ${content.genreDisplayName}'),
              Text('時間: ${content.formattedDuration}'),
              Text('推定TOEIC: ${content.difficulty.estimatedToeicScore}点'),
              const SizedBox(height: 12),
              const Text('スクリプト:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(content.script.fullText),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LearningPage(content: content),
                ),
              );
            },
            child: const Text('学習開始'),
),
        ],
      ),
    );
  }
}

// 統計カード用のウィジェット
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class ContentTab extends ConsumerWidget {
  const ContentTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentListAsync = ref.watch(contentListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('コンテンツ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: contentListAsync.when(
        data: (contents) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contents.length,
          itemBuilder: (context, index) {
            final content = contents[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getLevelColor(content.level).withOpacity(0.2),
                  child: Icon(
                    Icons.play_arrow,
                    color: _getLevelColor(content.level),
                  ),
                ),
                title: Text(content.title),
                subtitle: Text('${content.levelDisplayName} • ${content.formattedDuration} • ${content.genreDisplayName}'),
                trailing: Text(
                  content.formattedDuration,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                onTap: () {
                  _showContentDetail(context, content);
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('コンテンツの読み込みに失敗しました'),
              const SizedBox(height: 8),
              Text('$error', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(ContentLevel level) {
    switch (level) {
      case ContentLevel.beginner:
        return Colors.green;
      case ContentLevel.intermediate:
        return Colors.orange;
      case ContentLevel.advanced:
        return Colors.red;
    }
  }

  void _showContentDetail(BuildContext context, Content content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(content.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content.description),
              const SizedBox(height: 12),
              Text('レベル: ${content.levelDisplayName}'),
              Text('ジャンル: ${content.genreDisplayName}'),
              Text('時間: ${content.formattedDuration}'),
              Text('推定TOEIC: ${content.difficulty.estimatedToeicScore}点'),
              const SizedBox(height: 12),
              const Text('スクリプト:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(content.script.fullText),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('学習機能は開発中です')),
              );
            },
            child: const Text('学習開始'),
          ),
        ],
      ),
    );
  }
}

class ProgressTab extends StatelessWidget {
  const ProgressTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('進捗')),
      body: const Center(child: Text('進捗機能', style: TextStyle(fontSize: 18))),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: const Center(child: Text('設定機能', style: TextStyle(fontSize: 18))),
    );
  }
}

// 基本学習画面
class LearningPage extends StatefulWidget {
  final Content content;
  
  const LearningPage({Key? key, required this.content}) : super(key: key);

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  bool _isScriptVisible = true;
  bool _isPlaying = false;
  bool _isRecording = false;
  double _currentPosition = 0.0; // 0.0 - 1.0
  double _playbackSpeed = 1.0;
  Timer? _playbackTimer;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isScriptVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isScriptVisible = !_isScriptVisible;
              });
            },
            tooltip: 'スクリプト表示切替',
          ),
        ],
      ),
      body: Column(
        children: [
          // コンテンツ情報ヘッダー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(widget.content.levelDisplayName),
                      backgroundColor: _getLevelColor(widget.content.level),
                    ),
                    Chip(
                      label: Text(widget.content.genreDisplayName),
                      backgroundColor: Colors.blue.withOpacity(0.2),
                    ),
                    Chip(
                      label: Text(widget.content.formattedDuration),
                      backgroundColor: Colors.purple.withOpacity(0.2),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // スクリプト表示エリア
          if (_isScriptVisible)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'スクリプト',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        widget.content.script.fullText,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 語彙リスト
                    const Text(
                      'キーワード',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.content.vocabulary.map((vocab) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vocab.word,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(vocab.definition),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

          // 学習コントロールエリア
          // 学習コントロールエリア
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    border: Border(top: BorderSide(color: Colors.grey[300]!)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, -2),
      ),
    ],
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 進捗バー
      Row(
        children: [
          Text(
            _formatTime(_currentPosition * widget.content.duration),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Expanded(
            child: Slider(
              value: _currentPosition,
              onChanged: (value) {
                setState(() {
                  _currentPosition = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey[300],
            ),
          ),
          Text(
            widget.content.formattedDuration,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      
      const SizedBox(height: 16),
      
      // 音声コントロールボタン
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 再生速度ボタン
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: _togglePlaybackSpeed,
              child: Text(
                '${_playbackSpeed}x',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // 10秒戻るボタン
          IconButton(
            onPressed: _rewind,
            icon: const Icon(Icons.replay_10, size: 32),
            color: Colors.grey[600],
          ),
          
          // 再生/一時停止ボタン
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _togglePlayback,
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 40,
              ),
              color: Colors.white,
            ),
          ),
          
          // 10秒進むボタン
          IconButton(
            onPressed: _fastForward,
            icon: const Icon(Icons.forward_10, size: 32),
            color: Colors.grey[600],
          ),
          
          // 録音ボタン
          Container(
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _toggleRecording,
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 32,
              ),
              color: _isRecording ? Colors.white : Colors.red,
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 16),
      
      // ステータス表示
      if (_isRecording)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radio_button_checked, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              const Text(
                '録音中... タップで停止',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Color _getLevelColor(ContentLevel level) {
    switch (level) {
      case ContentLevel.beginner:
        return Colors.green.withOpacity(0.2);
      case ContentLevel.intermediate:
        return Colors.orange.withOpacity(0.2);
      case ContentLevel.advanced:
        return Colors.red.withOpacity(0.2);
    }
  }

  void _startLearning() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('音声再生機能は次のフェーズで実装予定です'),
      duration: Duration(seconds: 2),
    ),
  );
}

// ここから下を追加してください
String _formatTime(double seconds) {
  final int minutes = (seconds / 60).floor();
  final int remainingSeconds = (seconds % 60).floor();
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

void _togglePlayback() {
  setState(() {
    _isPlaying = !_isPlaying;
  });
  
  if (_isPlaying) {
    _startPlaybackSimulation();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('音声再生開始（${_playbackSpeed}x速度）'),
        duration: const Duration(seconds: 1),
      ),
    );
  } else {
    _stopPlaybackSimulation();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('音声一時停止'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

void _togglePlaybackSpeed() {
  setState(() {
    if (_playbackSpeed == 1.0) {
      _playbackSpeed = 0.5;
    } else if (_playbackSpeed == 0.5) {
      _playbackSpeed = 0.75;
    } else if (_playbackSpeed == 0.75) {
      _playbackSpeed = 1.25;
    } else if (_playbackSpeed == 1.25) {
      _playbackSpeed = 1.5;
    } else {
      _playbackSpeed = 1.0;
    }
  });
  
  if (_isPlaying) {
    _stopPlaybackSimulation();
    _startPlaybackSimulation();
  }
}

void _rewind() {
  setState(() {
    _currentPosition = (_currentPosition - (10.0 / widget.content.duration)).clamp(0.0, 1.0);
  });
}

void _fastForward() {
  setState(() {
    _currentPosition = (_currentPosition + (10.0 / widget.content.duration)).clamp(0.0, 1.0);
  });
}

void _toggleRecording() {
  setState(() {
    _isRecording = !_isRecording;
  });
  
  if (_isRecording) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 録音開始！シャドーイングを始めてください'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('録音停止。評価機能は次のフェーズで実装予定です'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

void _startPlaybackSimulation() {
  const baseInterval = Duration(milliseconds: 100);
  final adjustedInterval = Duration(
    milliseconds: (baseInterval.inMilliseconds / _playbackSpeed).round(),
  );
  
  _playbackTimer = Timer.periodic(adjustedInterval, (timer) {
    if (_currentPosition >= 1.0) {
      setState(() {
        _isPlaying = false;
        _currentPosition = 0.0;
      });
      timer.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('再生完了！'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      setState(() {
        _currentPosition += (1.0 / widget.content.duration) * (baseInterval.inMilliseconds / 1000) * _playbackSpeed;
        _currentPosition = _currentPosition.clamp(0.0, 1.0);
      });
    }
  });
}

void _stopPlaybackSimulation() {
  _playbackTimer?.cancel();
}
}