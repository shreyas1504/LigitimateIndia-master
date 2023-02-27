import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/like_button_widget.dart';
import 'package:socialv/models/posts/post_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/post/components/post_component.dart';
import 'package:socialv/screens/post/components/post_media_component.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/html_widget.dart';

import '../main.dart';

class QuickViewPostWidget extends StatefulWidget {
  final PostModel postModel;
  final bool isPostLied;
  final Function()? onPostLike;
  final int? pageIndex;

  QuickViewPostWidget({this.pageIndex, required this.postModel, this.isPostLied = false, this.onPostLike});

  @override
  State<QuickViewPostWidget> createState() => _QuickViewPostWidgetState();
}

class _QuickViewPostWidgetState extends State<QuickViewPostWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String postContent = '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200), reverseDuration: const Duration(milliseconds: 700));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad);
    _animationController.forward();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3, tileMode: TileMode.repeated),
        child: Container(
          child: ScaleTransition(
            scale: _animation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: appStore.isDarkMode ? Colors.white12 : Colors.transparent),
              ),
              backgroundColor: context.cardColor,
              insetPadding: EdgeInsets.only(left: 12, top: 24, right: 12, bottom: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        cachedImage(
                          widget.postModel.userImage.validate(),
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ).cornerRadiusWithClipRRect(100),
                        12.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.postModel.userName.validate(), style: boldTextStyle()),
                            4.height,
                            Text(convertToAgo(widget.postModel.dateRecorded.validate()), style: secondaryTextStyle()),
                          ],
                        ),
                      ],
                    ).paddingOnly(left: 8, top: 8, right: 8),
                    Divider(),
                    if (widget.postModel.content.validate().isNotEmpty)
                      if (widget.postModel.type == PostActivityType.newBlogPost)
                        InkWell(
                          onTap: () async {
                            if (widget.postModel.blogId != null) {
                              appStore.setLoading(true);
                              await wpPostById(postId: widget.postModel.blogId.validate()).then((value) {
                                appStore.setLoading(false);
                                openWebPage(context, url: value.link.validate());
                              }).catchError((e) {
                                toast(language.canNotViewPost);
                                appStore.setLoading(false);
                              });
                            } else {
                              toast(language.canNotViewPost);
                            }
                          },
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: HtmlWidget(postContent: widget.postModel.content.validate()).paddingSymmetric(horizontal: 8),
                        )
                      else
                        Text(parseHtmlString(widget.postModel.content.validate().replaceAll("\n", '')), style: primaryTextStyle()).paddingSymmetric(horizontal: 8, vertical: 8),
                    PostMediaComponent(
                      mediaTitle: widget.postModel.userName.validate(),
                      mediaType: widget.postModel.mediaType.validate(),
                      mediaList: widget.postModel.medias.validate(),
                      isFromPostDetail: true,
                      initialPageIndex: widget.pageIndex.validate(),
                    ),
                    if (widget.postModel.childPost != null)
                      PostComponent(
                        post: widget.postModel.childPost!,
                        color: context.scaffoldBackgroundColor,
                        childPost: true,
                      ),
                    Row(
                      children: [
                        LikeButtonWidget(
                          onPostLike: () {
                            widget.onPostLike?.call();
                          },
                          isPostLiked: widget.isPostLied,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            ic_chat,
                            height: 22,
                            width: 22,
                            fit: BoxFit.cover,
                            color: context.iconColor,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
