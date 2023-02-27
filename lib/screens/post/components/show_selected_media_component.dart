import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/posts/media_model.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:video_player/video_player.dart';

class ShowSelectedMediaComponent extends StatefulWidget {
  final MediaModel mediaType;
  final List<File> mediaList;

  const ShowSelectedMediaComponent({required this.mediaType, required this.mediaList});

  @override
  State<ShowSelectedMediaComponent> createState() => _ShowSelectedMediaComponentState();
}

class _ShowSelectedMediaComponentState extends State<ShowSelectedMediaComponent> {
  List<VideoPlayerController> controller = [];

  @override
  void initState() {
    super.initState();

    if (widget.mediaType.type == MediaTypes.video)
      widget.mediaList.forEach((element) {
        controller.add(VideoPlayerController.network(element.path)
          ..initialize().then((_) {
            setState(() {});
          }));
      });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();

    controller.forEach((element) {
      element.dispose();
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaType.type == MediaTypes.photo) {
      return HorizontalList(
        itemCount: widget.mediaList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: index == 0 ? EdgeInsets.only(left: 8) : EdgeInsets.all(0),
            child: Stack(
              children: [
                Image.file(widget.mediaList[index], height: 80, width: 80, fit: BoxFit.cover).cornerRadiusWithClipRRect(commonRadius),
                Positioned(
                  child: Icon(Icons.cancel_outlined, color: context.primaryColor, size: 18).onTap(() {
                    if (!appStore.isLoading) {
                      widget.mediaList.remove(widget.mediaList[index]);
                      setState(() {});
                    }
                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                  right: 4,
                  top: 4,
                ),
              ],
            ),
          );
        },
      );
    } else if (widget.mediaType.type == MediaTypes.video) {
      return HorizontalList(
        itemCount: controller.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: index == 0 ? EdgeInsets.only(left: 8) : EdgeInsets.all(0),
            child: Stack(
              children: [
                controller[index].value.isInitialized
                    ? Container(
                        width: 80,
                        height: 80,
                        child: VideoPlayer(controller[index]).cornerRadiusWithClipRRect(commonRadius),
                      )
                    : Container(
                        decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(commonRadius)),
                        height: 80,
                        width: 80,
                        padding: EdgeInsets.all(20),
                        child: Image.asset(ic_video, height: 20, width: 20, fit: BoxFit.cover),
                      ),
                Positioned(
                  child: Icon(Icons.cancel_outlined, color: context.primaryColor, size: 18).onTap(() {
                    if (!appStore.isLoading) {
                      widget.mediaList.remove(widget.mediaList[index]);
                      controller.removeAt(index);
                      setState(() {});
                    }
                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                  right: 4,
                  top: 4,
                ),
              ],
            ),
          );
        },
      );
    } else if (widget.mediaType.type == MediaTypes.audio) {
      return HorizontalList(
        itemCount: widget.mediaList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: index == 0 ? EdgeInsets.only(left: 8) : EdgeInsets.all(0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(commonRadius)),
                  height: 80,
                  width: 80,
                  padding: EdgeInsets.all(20),
                  child: Image.asset(ic_voice, height: 20, width: 20, fit: BoxFit.cover),
                ),
                Positioned(
                  child: Icon(Icons.cancel_outlined, color: context.primaryColor, size: 18).onTap(() {
                    if (!appStore.isLoading) {
                      widget.mediaList.remove(widget.mediaList[index]);
                      setState(() {});
                    }
                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                  right: 4,
                  top: 4,
                ),
              ],
            ),
          );
        },
      );
    } else {
      return HorizontalList(
        itemCount: widget.mediaList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: index == 0 ? EdgeInsets.only(left: 8) : EdgeInsets.all(0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(commonRadius)),
                  height: 80,
                  width: 80,
                  padding: EdgeInsets.all(20),
                  child: Image.asset(ic_document, height: 20, width: 20, fit: BoxFit.cover),
                ),
                Positioned(
                  child: Icon(Icons.cancel_outlined, color: context.primaryColor, size: 18).onTap(() {
                    if (!appStore.isLoading) {
                      widget.mediaList.remove(widget.mediaList[index]);
                      setState(() {});
                    }
                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                  right: 4,
                  top: 4,
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
