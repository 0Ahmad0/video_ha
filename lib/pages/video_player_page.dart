import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ViderPlayerScreen extends StatefulWidget {
  const ViderPlayerScreen({Key? key, required this.controller}) : super(key: key);
  final VideoPlayerController controller;

  @override
  State<ViderPlayerScreen> createState() => _ViderPlayerScreenState();
}

class _ViderPlayerScreenState extends State<ViderPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: VideoPlayer(
              widget.controller
            ),
          ),
          VideoProgressIndicator(
              widget.controller,
              allowScrubbing: true,
              colors:VideoProgressColors(
              )
          ),
          Row(
            children: [
              IconButton(
                  onPressed: (){
                    if(widget.controller.value.isPlaying){
                      widget.controller.pause();
                    }else{
                      widget.controller.play();
                    }

                    setState(() {

                    });
                  },
                  icon:Icon(widget.controller.value.isPlaying?Icons.pause:Icons.play_arrow)
              ),

              IconButton(
                  onPressed: (){
                    widget.controller.seekTo(Duration(seconds: 0));

                    setState(() {

                    });
                  },
                  icon:Icon(Icons.stop)
              )
            ],
          )

        ],
      ),
    );
  }
}
