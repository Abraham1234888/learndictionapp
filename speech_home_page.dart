
import '../screens1/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/phrases.dart';


class SpeechHomePage extends StatefulWidget {
  const SpeechHomePage({super.key});

  @override
  State<SpeechHomePage> createState() => _SpeechHomePageState();
}

class _SpeechHomePageState extends State<SpeechHomePage> {
  int _phraseIndex = 0;

  List<Map<String, dynamic>> _history = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _spokenText = '';
  String selectedRegion = 'Africa';
  String selectedDifficulty = 'Beginner';

  
  late String _targetPhrase;


  final FlutterTts _flutterTts = FlutterTts();

  @override
void initState() {
  super.initState();
  _initSpeechAndTts();
  _targetPhrase = regionalPhrases[selectedRegion]![selectedDifficulty]![_phraseIndex];
}


  Future<void> _initSpeechAndTts() async {
    _speech = stt.SpeechToText();
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {},
        onError: (error) {},
      );
    } catch (_) {
      _speechAvailable = false;
    }

    try {
      await _flutterTts.setLanguage('en-US');
    } catch (_) {}

    setState(() {});
  }

  double _calculatePronunciationScore(String spoken, String target) {
    if (spoken.isEmpty) return 0.0;
    spoken = spoken.toLowerCase().trim();
    target = target.toLowerCase().trim();

    if (spoken == target) return 1.0;

    List<String> spokenWords = spoken.split(' ');
    List<String> targetWords = target.split(' ');

    int matchingWords = 0;
    for (String word in spokenWords) {
      if (targetWords.contains(word)) matchingWords++;
    }

    return matchingWords / targetWords.length;
  }

  void _startListening() async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize();
      setState(() {});
      if (!_speechAvailable) return;
    }

    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
        });

        // when final result available, calculate score and store to history
        if (result.finalResult) {
          final double score = _calculatePronunciationScore(_spokenText, _targetPhrase);
          _addToHistory(_targetPhrase, _spokenText, score);
        }
      },
      listenFor: const Duration(seconds: 6),
      pauseFor: const Duration(seconds: 2),
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _speakPhrase() async {
    try {
      await _flutterTts.speak(_targetPhrase);
    } catch (_) {}
  }

  void _updateRegion(String? region) {
    if (region != null) {
      setState(() {
        selectedRegion = region;
        _phraseIndex = 0;
        _targetPhrase = regionalPhrases[region]![selectedDifficulty]![0];
        _spokenText = '';
      });
    }
  }

  void _updateDifficulty(String? level) {
    if (level != null) {
      setState(() {
        selectedDifficulty = level;
        _phraseIndex = 0;
        _targetPhrase = regionalPhrases[selectedRegion]![selectedDifficulty]![_phraseIndex];
        _spokenText = '';
      });
    }
  }

  Widget _buildFeedback() {
    if (_spokenText.isEmpty) return Container();
    double score = _calculatePronunciationScore(_spokenText, _targetPhrase);
    String feedback;
    Color feedbackColor;

    if (score >= 0.9) {
      feedback = "✅ Excellent pronunciation!";
      feedbackColor = Colors.green;
    } else if (score >= 0.7) {
      feedback = "👍 Good attempt! Keep practicing!";
      feedbackColor = Colors.orange;
    } else {
      feedback = "❌ Try again: $_spokenText";
      feedbackColor = Colors.red;
    }

    return Text(
      feedback,
      style: TextStyle(fontSize: 18, color: feedbackColor),
    );
  }

  void _addToHistory(String phrase, String spoken, double score) {
    _history.insert(0, {
      'phrase': phrase,
      'spoken': spoken,
      'score': score,
      'time': DateTime.now(),
    });
    // cap history size to 200 entries
    if (_history.length > 200) _history = _history.sublist(0, 200);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LearnDictionApp')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedRegion,
              items: regionalPhrases.keys.map((String region) {
                return DropdownMenuItem(
                  value: region,
                  child: Text(region),
                );
              }).toList(),
              onChanged: _updateRegion
            ),

            const SizedBox(height: 16),
DropdownButton<String>(
  value: selectedDifficulty,
  items: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
    return DropdownMenuItem(
      value: level,
      child: Text(level),
    );
  }).toList(),
  
  onChanged: _updateDifficulty,

),

            const SizedBox(height: 20),
            const Text("Practice saying:", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(_targetPhrase, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up),
              label: const Text("Hear Phrase"),
              onPressed: _speakPhrase,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? "Stop Listening" : "Start Speaking"),
              onPressed: !_speechAvailable
                  ? null
                  : (_isListening ? _stopListening : _startListening),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.navigate_before),
                  label: const Text("Previous"),
                  onPressed: () {
                    List<String> phrases = regionalPhrases[selectedRegion]![selectedDifficulty]!;
                    setState(() {
                      _phraseIndex = (_phraseIndex - 1 + phrases.length) % phrases.length;
                      _targetPhrase = phrases[_phraseIndex];
                      _spokenText = '';
                    });
                  },
                ),
                Text(
                  'Phrase ${_phraseIndex + 1}/${regionalPhrases[selectedRegion]![selectedDifficulty]!.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.navigate_next),
                  label: const Text("Next"),
                  onPressed: () {
                    List<String> phrases = regionalPhrases[selectedRegion]![selectedDifficulty]!;
                    setState(() {
                      _phraseIndex = (_phraseIndex + 1) % phrases.length;
                      _targetPhrase = phrases[_phraseIndex];
                      _spokenText = '';
                    });
                  },
                ),
              ],
            ),



            const SizedBox(height: 20),
            _buildFeedback(),
            const SizedBox(height: 12),
            if (_spokenText.isNotEmpty) ...[
              Text('Recognized: $_spokenText', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Text('Score: ${( _calculatePronunciationScore(_spokenText, _targetPhrase) * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],

            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text("View History"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(history: _history),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
  
  
