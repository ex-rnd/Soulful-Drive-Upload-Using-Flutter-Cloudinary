import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CackleBubble extends StatelessWidget {

  const CackleBubble(
      {
        super.key,
        required this.text,
        required this.isSender,
        required this.isLast
      }
      );

  final String text;
  final bool isSender;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom:  10, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSender) const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isSender ? const Color(0xFF276bfd) : const Color(0xFF343145),
                  ),
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 9,
                  left: 14,
                  right: 12,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              )
            ],
          )
        ],

      ),
    );
  }
}

// Emotion Map -> Psychology State
enum Emotion { neutral, happy, sad, angry, disgust, fear, pleasure }

final Map<Emotion, List<Color>> emotionShades = {
  Emotion.neutral : [Colors.grey[400]!, Colors.grey[600]!],
  Emotion.happy   : [Colors.yellow[700]!, Colors.orange[300]!],
  Emotion.sad     : [Colors.blue[800]!, Colors.blue[400]!],
  Emotion.angry   : [Colors.red[800]!, Colors.redAccent],
  Emotion.disgust : [Colors.green[700]!, Colors.lime[600]!],
  Emotion.fear    : [Colors.purple[700]!, Colors.deepPurple[400]!],
  Emotion.pleasure: [Colors.pink[300]!, Colors.pinkAccent],
};

class WaveBubble extends StatefulWidget {
  const WaveBubble(
      {
        super.key,
        this.isSender = false,
        this.isPlayable = true,
        //required this.emotion,
        this.emotion = Emotion.angry,
        this.index,
        this.path,
        this.width,
        required this.appDirectory
      }
      );

  final Emotion emotion;
  final bool isSender;
  final bool isPlayable;
  final int? index;
  final String? path;
  final double? width;
  final Directory appDirectory;





  @override
  State<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends State<WaveBubble> with TickerProviderStateMixin {
  File? file;

  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;

  late final AnimationController _colorController;
  late final Animation<Color?> _colorAnim;

  bool _isPlayable = true;

  Emotion currentEmotion = Emotion.angry; //happy;


  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  @override
  void initState() {
    //
    controller = PlayerController();
    _preparePlayer();
    playerStateSubscription = controller
        .onPlayerStateChanged
        .listen(
        (_) {
          setState(() {

          });
        }
    );
    controller.setFinishMode(finishMode: FinishMode.pause);

    _colorController = AnimationController(
        vsync: this,
      duration: Duration(seconds: 3),
    )..addListener(() => setState(() {}));

    // _colorAnim = ColorTween(
    //   begin: Colors.blue,
    //   end: Colors.purple,
    // ).animate(_colorController);

    // final shades = emotionShades[currentEmotion]!;
    // _colorAnim = ColorTween(begin: shades[0], end: shades[1])
    //     .animate(_colorController);

    setState(() {
      currentEmotion = Emotion.angry;
      //currentEmotion = widget.emotion;
      // re-tween so we pick up new colors
      final shades = emotionShades[currentEmotion]!;
      _colorAnim = ColorTween(begin: shades[0], end: shades[1])
          .animate(_colorController);
    });

    _colorController.forward();



    super.initState();

  }



  
  void _preparePlayer() async {
    if (widget.index != null) {
      final name = 'audio${widget.index}.wav';
      file = File('${widget.appDirectory.path}/$name');


      //file = File('${widget.appDirectory.path}/${widget.index}.wav'); //.mp3
      await file?.writeAsBytes(
          (await rootBundle.load('assets/audios/audio${widget.index}.wav')
      ).buffer.asUint8List(),
      );
    }

    if (widget.index == null && widget.path == null && file?.path == null) {
      return;
    }
    
    await controller.preparePlayer(
      path: widget.path ?? file!.path,
      shouldExtractWaveform: widget.index?.isEven ?? true,
    );

    if (widget.index?.isOdd ?? false) {
      controller.extractWaveformData(
          path: widget.path ?? file!.path,
          noOfSamples: playerWaveStyle.getSamplesForWidth(widget.width ?? 200)
      )
      .then(
              (
                  wavefromData) =>
                  debugPrint(wavefromData.toString(),
      )
      )
      ;
    }

  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    _colorController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final filePath = widget.path ?? file?.path ?? 'Unknown';

    if (controller.playerState.isPlaying) {
      _colorController.repeat(reverse: true);
    } else {
      _colorController.stop();
    }



    return widget.path != null || file?.path != null
        ?
        Align(
          key: ValueKey(filePath),
          alignment: widget.isSender
          ? Alignment.centerRight
          : Alignment.centerLeft,

          child: Container(
            padding: EdgeInsets.only(
                top: 2, //6,
                bottom: 2, //6,
                left: 3, //40,
                right: widget.isSender
                  ? 0
                  : 3, //10,
            ),

            margin: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.isSender
                ? Color(0xFF276bfd)
                : Color(0xFF343145),
            ),

            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
              
                  if (!controller.playerState.isStopped)
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.all(1),
                      constraints: BoxConstraints(
                        minWidth: 5,
                        minHeight: 5,
                      ),

                      onPressed:
                        _isPlayable
                        ? () async {
                          controller.playerState.isPlaying
                              ? await controller.pausePlayer()
                              : await controller.startPlayer(); //finishMode: FinishMode.loop,
                          // missing
                          setState(() {_isPlayable = false;});
                        }
                        : null,
              
                      icon:
                        Icon(
                          // if the button is disabled, show 🚫
                          !_isPlayable
                              ? Icons.block
                          // otherwise show ▶️ or ⏸ depending on play state
                              : (controller.playerState.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow),
                          color: _isPlayable ? Colors.blue : Colors.grey,


                        ),
                        color: _isPlayable ? Colors.blue : Colors.grey,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        ),
                  
                  ShaderMask(
                      shaderCallback: (bounds) {
                        final base = _colorAnim.value
                        ?? emotionShades[currentEmotion]![0];

                        return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          base,
                          base.withOpacity(0.6),
                        ],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      );
                  },
                    blendMode: BlendMode.srcATop,
                    child: AudioFileWaveforms(
                        size: Size(MediaQuery.of(context).size.width*0.4, 30),
                        playerController: controller,
                        waveformType: WaveformType.fitWidth,
                        playerWaveStyle: playerWaveStyle,
                        enableSeekGesture: true //false, //true,
                    ),
                  ),
              
                  if (widget.isSender)
                    const SizedBox(
                      width: 5,
                    ),
              
              
                ],
              ),
            )
            ,

          ),

        )

        : const SizedBox.shrink()
    ;
  }
}


