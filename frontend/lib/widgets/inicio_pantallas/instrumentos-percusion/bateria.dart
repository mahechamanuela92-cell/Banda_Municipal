import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BateriaItem extends StatefulWidget {
  const BateriaItem({super.key});

  @override
  State<BateriaItem> createState() => _BateriaItemState();
}

class _BateriaItemState extends State<BateriaItem> {
  late AudioPlayer _audioPlayer;
  bool estaReproduciendo = false;
  Duration duracionTotal = Duration.zero;
  Duration posicionActual = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          estaReproduciendo = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duracionTotal = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          posicionActual = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (estaReproduciendo) {
      await _audioPlayer.pause();
    } else {
      // Ajusta la ruta del archivo MP3 de la flauta píccolo si cambia de nombre
      await _audioPlayer.play(AssetSource('audios/bateria.mp3'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      iconColor: Colors.white70,
      collapsedIconColor: Colors.white70,
      title: const Text(
        "Bateria",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'Serif',
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  'assets/images/bateria.jpg',
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 170,
                      color: Colors.white10,
                      child: const Icon(Icons.music_note, color: Colors.white38, size: 50),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),

              // Descripción
              const Text(
                "La batería es un conjunto de instrumentos de percusión, clasificado como multi-percusión, diseñado para ser tocado por una sola persona",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 15),

              const Text(
                "Su sonido es así:",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),

              // Reproductor de Audio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        estaReproduciendo ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: _toggleAudio,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          activeColor: Colors.orange,
                          inactiveColor: Colors.white30,
                          min: 0.0,
                          max: duracionTotal.inSeconds.toDouble() > 0 
                              ? duracionTotal.inSeconds.toDouble() 
                              : 2.0,
                          value: posicionActual.inSeconds.toDouble().clamp(
                            0.0, 
                            duracionTotal.inSeconds.toDouble() > 0 
                                ? duracionTotal.inSeconds.toDouble() 
                                : 2.0,
                          ),
                          onChanged: (value) async {
                            final position = Duration(seconds: value.toInt());
                            await _audioPlayer.seek(position);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }
}