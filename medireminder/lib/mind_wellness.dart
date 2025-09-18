import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MindWellnessPage extends StatefulWidget {
  @override
  _MindWellnessPageState createState() => _MindWellnessPageState();
}

class _MindWellnessPageState extends State<MindWellnessPage> {
  final List<String> mindfulnessTips = [
    "Take a deep breath, let go of stress.",
    "Gratitude rewires your brain for happiness.",
    "A 5-minute walk refreshes the mind.",
    "Pause. Reflect. Be present in the moment.",
    "Laughter is the best stress reliever.",
    "Drink water, hydrate your thoughts!"
  ];

  int _currentTipIndex = 0;
  late Timer _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _startTipRotation();
  }

  void _startTipRotation() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % mindfulnessTips.length;
      });
    });
  }

  void _playRelaxSound() async {
    if (!_isPlaying) {
      await _audioPlayer.play(AssetSource("relax.mp3"));
      setState(() => _isPlaying = true);
    } else {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mind & Wellness"), backgroundColor: Colors.purple),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple.shade100, Colors.blue.shade200]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBreathingAnimation(),
            SizedBox(height: 20),
            _buildMindfulnessTip(),
            SizedBox(height: 20),
            _buildRelaxationSoundButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    return Container(
      width: 150,
      height: 150,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.7, end: 1.2),
        duration: Duration(seconds: 4),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        onEnd: () {
          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.purple.withOpacity(0.7),
          ),
          child: Center(
            child: Text(
              "Breathe",
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMindfulnessTip() {
    return AnimatedSwitcher(
      duration: Duration(seconds: 1),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Card(
        key: ValueKey<int>(_currentTipIndex),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            mindfulnessTips[_currentTipIndex],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildRelaxationSoundButton() {
    return ElevatedButton.icon(
      onPressed: _playRelaxSound,
      icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow, color: Colors.white),
      label: Text(_isPlaying ? "Stop Relaxation" : "Play Relaxation"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
    );
  }
}