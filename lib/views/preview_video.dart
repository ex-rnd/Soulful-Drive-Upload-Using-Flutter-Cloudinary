import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {
  final String videoUrl;
  const PreviewVideo({super.key, required this.videoUrl});

  @override
  State<PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview Video"),
      ),

      body: Center(
        child: _controller.value.isInitialized
        ? AspectRatio(aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),)
        : Container()
          ),


      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
        child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),

    );
  }
}
