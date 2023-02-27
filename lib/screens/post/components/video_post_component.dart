import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class VideoPostComponent extends StatefulWidget {
  final String videoURl;
  final bool isShowControllers;
  final VoidCallback? callBack;

  VideoPostComponent({required this.videoURl, this.isShowControllers = true, this.callBack});

  @override
  State<VideoPostComponent> createState() => _VideoPostComponentState();
}

class _VideoPostComponentState extends State<VideoPostComponent> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;

  @override
  void initState() {
    super.initState();

    videoPlayerController = VideoPlayerController.network(widget.videoURl)..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
    );

    widget.callBack?.call();
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      height: context.height() * 0.8,
      child: CustomVideoPlayer(customVideoPlayerController: _customVideoPlayerController),
    ).center();
  }
}
