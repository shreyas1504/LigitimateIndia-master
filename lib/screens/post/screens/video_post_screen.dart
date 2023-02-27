import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/screens/post/components/video_post_component.dart';

class VideoPostScreen extends StatelessWidget {
  final String videoUrl;
  final String postUploaderName;

  const VideoPostScreen(this.videoUrl, this.postUploaderName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: context.iconColor),
        title: Text(postUploaderName, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
      ),
      body: VideoPostComponent(videoURl: videoUrl),
    );
  }
}
