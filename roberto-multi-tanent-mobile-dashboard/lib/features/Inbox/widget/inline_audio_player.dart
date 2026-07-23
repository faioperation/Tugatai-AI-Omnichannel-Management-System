import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class InlineAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const InlineAudioPlayer({
    Key? key,
    required this.audioUrl,
    required this.isMe,
  }) : super(key: key);

  @override
  State<InlineAudioPlayer> createState() => _InlineAudioPlayerState();
}

class _InlineAudioPlayerState extends State<InlineAudioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isMe ? Colors.white : Theme.of(context).primaryColor;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            color: color,
            size: 32,
          ),
          onPressed: () async {
            if (_isPlaying) {
              await _audioPlayer.pause();
            } else {
              await _audioPlayer.play(UrlSource(widget.audioUrl));
            }
          },
        ),
        SizedBox(
          width: 100,
          child: SliderTheme(
            data: SliderThemeData(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              trackHeight: 2.0,
            ),
            child: Slider(
              min: 0.0,
              max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
              value: _position.inMilliseconds > 0 && _position.inMilliseconds <= _duration.inMilliseconds
                  ? _position.inMilliseconds.toDouble()
                  : 0.0,
              onChanged: (value) async {
                final position = Duration(milliseconds: value.toInt());
                await _audioPlayer.seek(position);
              },
              activeColor: color,
              inactiveColor: color.withOpacity(0.3),
            ),
          ),
        ),
        Text(
          _formatDuration(_position),
          style: TextStyle(color: color, fontSize: 12),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
