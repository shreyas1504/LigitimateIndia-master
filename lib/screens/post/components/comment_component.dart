import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models/post_mdeia_model.dart';
import 'package:socialv/models/posts/comment_model.dart';
import 'package:socialv/screens/post/screens/comment_reply_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class CommentComponent extends StatefulWidget {
  final CommentModel comment;
  final bool isParent;
  final bool fromReplyScreen;
  final int postId;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? callback;

  CommentComponent({
    required this.comment,
    required this.isParent,
    required this.postId,
    this.onReply,
    this.onDelete,
    this.fromReplyScreen = false,
    this.callback,
    this.onEdit,
  });

  @override
  State<CommentComponent> createState() => _CommentComponentState();
}

class _CommentComponentState extends State<CommentComponent> {
  bool isChange = false;
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          Row(
            children: [
              cachedImage(
                widget.comment.userImage.validate(),
                height: 36,
                width: 36,
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRect(100),
              16.width,
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '${widget.comment.userName.validate()} ', style: boldTextStyle(size: 14, fontFamily: fontFamily)),
                        if (widget.comment.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover)),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                  4.height,
                  Text(convertToAgo(widget.comment.dateRecorded.validate()), style: secondaryTextStyle(size: 12)),
                ],
              ).expand(),
            ],
          ).onTap(() {
            MemberProfileScreen(memberId: widget.comment.userId.validate().toInt()).launch(context);
          }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
          8.height,
          Text(parseHtmlString(widget.comment.content.validate()), style: primaryTextStyle()),
          8.height,
          if (widget.comment.medias.validate().isNotEmpty)
            SizedBox(
              height: 200,
              width: context.width(),
              child: PageView.builder(
                controller: pageController,
                itemCount: widget.comment.medias.validate().length,
                itemBuilder: (ctx, index) {
                  PostMediaModel media = widget.comment.medias.validate()[index];
                  return cachedImage(media.url, radius: defaultAppButtonRadius);
                },
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.comment.id != null)
                    IconButton(
                      onPressed: () {
                        if (!appStore.isLoading) {
                          isChange = true;
                          widget.onReply?.call();
                        }
                      },
                      icon: cachedImage(ic_reply, color: context.primaryColor, width: 16, height: 16),
                    ),
                  if (widget.comment.userId == appStore.loginUserId && widget.comment.id != null)
                    IconButton(
                      onPressed: () {
                        if (!appStore.isLoading) {
                          isChange = true;
                          widget.onDelete?.call();
                        }
                      },
                      icon: cachedImage(ic_delete, color: Colors.red, width: 16, height: 16),
                    ),
                  if (widget.comment.userId == appStore.loginUserId && widget.comment.id != null)
                    IconButton(
                      onPressed: () {
                        if (!appStore.isLoading) {
                          isChange = true;
                          widget.onEdit?.call();
                        }
                      },
                      icon: cachedImage(ic_edit, color: context.primaryColor, width: 16, height: 16),
                    ),
                ],
              ),
              if (!widget.isParent && widget.comment.children.validate().isNotEmpty)
                TextButton(
                  onPressed: () {
                    if (!appStore.isLoading) {
                      if (widget.fromReplyScreen) {
                        finish(context, isChange);
                      }
                      CommentReplyScreen(
                        callback: () {
                          widget.callback?.call();
                        },
                        postId: widget.postId,
                        comment: widget.comment,
                      ).launch(context).then((value) {
                        if (value ?? false) {
                          widget.callback?.call();
                        }
                      });
                    }
                  },
                  child: Text(' ${language.replies}(${widget.comment.children.validate().length.validate()})', style: secondaryTextStyle(size: 12)),
                )
            ],
          ),
        ],
      ),
    );
  }
}
