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

class WaveBubble extends StatefulWidget {
  const WaveBubble(
      {
        super.key,
        this.isSender = false,
        this.index,
        this.path,
        this.width,
        required this.appDirectory
      }
      );

  final bool isSender;
  final int? index;
  final String? path;
  final double? width;
  final Directory appDirectory;


  @override
  State<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends State<WaveBubble> {
  File? file;
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;

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
    super.initState();
  }




  void _preparePlayer() async {
    if (widget.index != null) {
      file = File('${widget.appDirectory.path}/${widget.index}.wav'); //.mp3
      await file?.writeAsBytes(
        (await rootBundle.load('assets/audios/audio${widget.index}.wav')
        ).buffer.asUint8List(),
      );
    }

    if (widget.index == null && widget.path == null && file?.path == null) {
      return;
    }

    controller.preparePlayer(
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
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return widget.path != null || file?.path != null
        ?
    Align(
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

                  onPressed: () async {
                    controller.playerState.isPlaying
                        ? await controller.pausePlayer()
                        : await controller.startPlayer(); //finishMode: FinishMode.loop,
                  },

                  icon:
                  Icon(
                    controller.playerState.isPlaying
                        ? Icons.stop
                        : Icons.play_arrow,
                  ),
                  color: Colors.white,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),

              AudioFileWaveforms(
                  size: Size(MediaQuery.of(context).size.width*0.4, 30),
                  playerController: controller,
                  waveformType: widget.index?.isOdd ?? false
                      ? WaveformType.fitWidth //long //fitWidth
                      : WaveformType.long,
                  playerWaveStyle: playerWaveStyle,
                  enableSeekGesture: true //false, //true,
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


