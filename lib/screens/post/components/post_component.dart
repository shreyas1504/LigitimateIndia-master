import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socialv/components/like_button_widget.dart';
import 'package:socialv/components/quick_view_post_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/posts/get_post_likes_model.dart';
import 'package:socialv/models/posts/post_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/blockReport/components/show_report_dialog.dart';
import 'package:socialv/screens/groups/screens/group_detail_screen.dart';
import 'package:socialv/screens/post/components/post_media_component.dart';
import 'package:socialv/screens/post/screens/add_post_screen.dart';
import 'package:socialv/screens/post/screens/comment_screen.dart';
import 'package:socialv/screens/post/screens/post_likes_screen.dart';
import 'package:socialv/screens/post/screens/single_post_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/html_widget.dart';
import 'package:socialv/utils/overlay_handler.dart';

import '../../../utils/app_constants.dart';

// ignore: must_be_immutable
class PostComponent extends StatefulWidget {
  final PostModel post;
  final VoidCallback? callback;
  int? count;
  final bool fromGroup;
  final int? groupId;
  final bool showHidePostOption;
  final bool childPost;
  final Color? color;

  PostComponent({required this.post, this.callback, this.count, this.fromGroup = false, this.groupId, this.showHidePostOption = false, this.childPost = false, this.color});

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  OverlayHandler _overlayHandler = OverlayHandler();
  PageController pageController = PageController();

  List<GetPostLikesModel> postLikeList = [];
  bool isLiked = false;
  int postLikeCount = 0;
  int index = 0;

  bool isPostHidden = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isPostHidden = false;
    postLikeList = widget.post.usersWhoLiked.validate();
    postLikeCount = widget.post.likeCount.validate();
    isLiked = widget.post.isLiked.validate();
    setState(() {});
  }

  Future<void> postLike() async {
    ifNotTester(() async {
      isLiked = !isLiked;

      if (isLiked) {
        if (postLikeList.length < 3 && isLiked) {
          postLikeList.add(GetPostLikesModel(
            userId: appStore.loginUserId,
            userAvatar: appStore.loginAvatarUrl,
            userName: appStore.loginFullName,
          ));
        }
        postLikeCount++;
        setState(() {});

        await likePost(postId: widget.post.activityId.validate()).then((value) {
          //
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      } else {
        if (postLikeList.length <= 3) {
          postLikeList.removeWhere((element) => element.userId == appStore.loginUserId);
        }
        postLikeCount--;
        setState(() {});
        await likePost(postId: widget.post.activityId.validate()).then((value) {
          //
        }).catchError((e) {
          log('Error: ${e.toString()}');
        });
      }
    });
  }

  Future<void> onHidePost() async {
    toast(language.thisPostIsNowHidden);

    isPostHidden = true;
    setState(() {});

    await hidePost(id: widget.post.activityId.validate()).then((value) {
      //
    }).catchError((e) {
      log("Error:" + e.toString());
    });
  }

  Future<void> onReportPost() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
              ),
              8.height,
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: ShowReportDialog(
                  isPostReport: true,
                  postId: widget.post.activityId.validate(),
                  userId: widget.post.userId.validate(),
                ),
              ).expand(),
            ],
          ),
        );
      },
    );
  }

  Future<void> onDeletePost() async {
    showConfirmDialogCustom(
      context,
      onAccept: (c) {
        ifNotTester(() {
          appStore.setLoading(true);

          deletePost(postId: widget.post.activityId.validate()).then((value) {
            appStore.setLoading(false);
            toast(language.postDeleted);
            widget.callback?.call();
            setState(() {});
          }).catchError((e) {
            appStore.setLoading(false);
            toast(e.toString());
          });
        });
      },
      dialogType: DialogType.CONFIRMATION,
      title: language.deletePostConfirmation,
      positiveText: language.remove,
    );
  }

  Future<void> onUnfriend() async {
    showConfirmDialogCustom(
      context,
      onAccept: (c) async {
        ifNotTester(() async {
          appStore.setLoading(true);
          await removeExistingFriendConnection(friendId: widget.post.userId.toString(), passRequest: true).then((value) {
            appStore.setLoading(false);
            widget.callback?.call();
            setState(() {});
          }).catchError((e) {
            appStore.setLoading(false);
            log(e.toString());
          });
        });
      },
      dialogType: DialogType.CONFIRMATION,
      title: language.unfriendConfirmation,
      positiveText: language.remove,
    );
  }

  Future<void> onViewBlogPost() async {
    if (widget.post.blogId != null) {
      appStore.setLoading(true);
      await wpPostById(postId: widget.post.blogId.validate()).then((value) {
        appStore.setLoading(false);
        openWebPage(context, url: value.link.validate());
      }).catchError((e) {
        toast(language.canNotViewPost);
        appStore.setLoading(false);
      });
    } else {
      toast(language.canNotViewPost);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _overlayHandler.removeOverlay(context);
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count == 0) {
      init();
      widget.count = widget.count.validate() + 1;
    }

    if (!isPostHidden) {
      return GestureDetector(
        onTap: () {
          if (widget.post.type.validate() == PostActivityType.newBlogPost) {
            onViewBlogPost();
          } else {
            SinglePostScreen(postId: widget.post.activityId.validate()).launch(context).then((value) {
              if (value ?? false) widget.callback?.call();
            });
          }
        },
        onPanEnd: (s) {
          if (!widget.childPost.validate()) _overlayHandler.removeOverlay(context);
        },
        onLongPress: () {
          if (!widget.childPost.validate())
            _overlayHandler.insertOverlay(
              context,
              OverlayEntry(
                builder: (context) {
                  return QuickViewPostWidget(
                    postModel: widget.post,
                    isPostLied: isLiked,
                    onPostLike: () async {
                      postLike();
                      widget.callback!.call();
                    },
                    pageIndex: index,
                  );
                },
              ),
            );
        },
        onLongPressEnd: (details) {
          if (!widget.childPost.validate()) _overlayHandler.removeOverlay(context);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(borderRadius: radius(commonRadius), color: widget.color ?? context.cardColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  cachedImage(
                    widget.post.userImage.validate(),
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ).cornerRadiusWithClipRRect(100),
                  12.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.post.userName.validate()}',
                            style: boldTextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).flexible(flex: 1),
                          if (widget.post.isUserVerified.validate()) Image.asset(ic_tick_filled, width: 18, height: 18, color: blueTickColor).paddingSymmetric(horizontal: 4),
                        ],
                      ),
                      4.height,
                      Text(convertToAgo(widget.post.dateRecorded.validate()), style: secondaryTextStyle()),
                    ],
                  ).expand(),
                  if (!widget.childPost.validate())
                    Theme(
                      data: Theme.of(context).copyWith(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        useMaterial3: false,
                      ),
                      child: PopupMenuButton(
                        enabled: !appStore.isLoading,
                        position: PopupMenuPosition.under,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
                        onSelected: (val) async {
                          if (val == 1) {
                            onDeletePost();
                          } else if (val == 2) {
                            onReportPost();
                          } else if (val == 3) {
                            AddPostScreen(
                              showMediaOptions: widget.post.type == PostActivityType.activityShare ? false : true,
                              post: widget.post,
                              groupId: widget.groupId,
                              component: widget.groupId != null ? Component.groups : Component.members,
                              callback: () {
                                widget.callback?.call();
                              },
                            ).launch(context);
                          } else if (val == 4) {
                            onHidePost();
                          } else {
                            AddPostScreen(
                              showMediaOptions: false,
                              parentPostId: widget.post.activityId.validate().toString(),
                              groupId: widget.groupId,
                              component: widget.groupId != null ? Component.groups : Component.members,
                              callback: () {
                                widget.callback?.call();
                              },
                            ).launch(context);
                          }
                        },
                        icon: Icon(Icons.more_horiz),
                        itemBuilder: (context) => <PopupMenuEntry>[
                          if (widget.post.userId.validate().toString() == appStore.loginUserId)
                            PopupMenuItem(
                              value: 1,
                              child: Text(language.deletePost),
                              textStyle: primaryTextStyle(),
                            ),
                          if (widget.post.userId.validate().toString() != appStore.loginUserId)
                            PopupMenuItem(
                              value: 2,
                              child: Text(language.reportPost),
                              textStyle: primaryTextStyle(),
                            ),
                          if (widget.post.userId.validate().toString() == appStore.loginUserId)
                            PopupMenuItem(
                              value: 3,
                              child: Text(language.editPost),
                              textStyle: primaryTextStyle(),
                            ),
                          if (widget.post.userId.validate().toString() != appStore.loginUserId && widget.showHidePostOption)
                            PopupMenuItem(
                              value: 4,
                              child: Text(language.hidePost),
                              textStyle: primaryTextStyle(),
                            ),
                          PopupMenuItem(
                            value: 5,
                            child: Text(language.shareOnActivity),
                            textStyle: primaryTextStyle(),
                          ),
                        ],
                      ),
                    ),
                ],
              ).paddingOnly(left: 8, top: 8, right: 8).onTap(() {
                MemberProfileScreen(memberId: widget.post.userId.validate()).launch(context);
              }, borderRadius: radius(8)),
              8.height,
              if (!widget.fromGroup)
                if (widget.post.postIn == Component.groups && widget.post.groupName.validate().isNotEmpty)
                  InkWell(
                    onTap: () {
                      if (widget.post.groupId != 0) GroupDetailScreen(groupId: widget.post.groupId.validate()).launch(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '${widget.post.userName.validate()} ', style: boldTextStyle(fontFamily: fontFamily, size: 14)),
                          TextSpan(text: '${language.postedAnUpdateInTheGroup} ', style: primaryTextStyle(fontFamily: fontFamily, size: 14)),
                          TextSpan(text: '${widget.post.groupName.validate()} ', style: boldTextStyle(fontFamily: fontFamily, size: 14)),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ).paddingSymmetric(horizontal: 8),
                  ),
              Divider(),
              if (widget.post.content.validate().isNotEmpty)
                if (widget.post.type == PostActivityType.newBlogPost)
                  InkWell(
                    onTap: () async {
                      onViewBlogPost();
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: HtmlWidget(postContent: widget.post.content.validate()),
                  )
                else
                  Text(parseHtmlString(widget.post.content.validate().replaceAll("\n", '')), style: primaryTextStyle()).paddingSymmetric(horizontal: 8, vertical: 8),
              PostMediaComponent(
                mediaTitle: widget.post.userName.validate(),
                mediaType: widget.post.mediaType.validate(),
                mediaList: widget.post.medias.validate(),
                onPageChange: (i) {
                  index = i;
                },
              ),
              if (widget.post.type == PostActivityType.activityShare && widget.post.childPost != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: PostComponent(post: widget.post.childPost!, childPost: true, color: context.scaffoldBackgroundColor),
                ),
              if (widget.childPost.validate())
                TextButton(
                  onPressed: () {
                    SinglePostScreen(postId: widget.post.activityId.validate()).launch(context).then((value) {
                      if (value ?? false) widget.callback?.call();
                    });
                  },
                  child: Text(language.viewPost, style: primaryTextStyle(color: context.primaryColor)),
                ),
              if (!widget.childPost.validate())
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        LikeButtonWidget(
                          key: ValueKey(isLiked),
                          onPostLike: () {
                            postLike();
                          },
                          isPostLiked: isLiked,
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (!appStore.isLoading) {
                                CommentScreen(postId: widget.post.activityId.validate()).launch(context).then((value) {
                                  if (value ?? false) widget.callback?.call();
                                });
                              }
                            },
                            icon: Image.asset(
                              ic_chat,
                              height: 22,
                              width: 22,
                              fit: BoxFit.cover,
                              color: context.iconColor,
                            ),
                          ),
                        ),
                        Image.asset(
                          ic_send,
                          height: 22,
                          width: 22,
                          fit: BoxFit.cover,
                          color: context.iconColor,
                        ).onTap(() {
                          if (!appStore.isLoading) {
                            String saveUrl = "$DOMAIN_URL/${widget.post.activityId.validate()}";
                            Share.share(saveUrl);
                          }
                        }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        CommentScreen(postId: widget.post.activityId.validate()).launch(context).then(
                          (value) {
                            if (value ?? false) widget.callback?.call();
                          },
                        );
                      },
                      child: Text('${widget.post.commentCount} ${language.comments}', style: secondaryTextStyle()),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 8),
              if (!widget.childPost.validate())
                if (postLikeList.isNotEmpty)
                  Row(
                    children: [
                      Stack(
                        children: postLikeList.validate().take(3).map(
                          (e) {
                            return Container(
                              width: 32,
                              height: 32,
                              margin: EdgeInsets.only(left: 18 * postLikeList.validate().indexOf(e).toDouble()),
                              child: cachedImage(
                                postLikeList.validate()[postLikeList.validate().indexOf(e)].userAvatar.validate(),
                                fit: BoxFit.cover,
                              ).cornerRadiusWithClipRRect(100),
                            );
                          },
                        ).toList(),
                      ),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: language.likedBy,
                          style: secondaryTextStyle(size: 12, fontFamily: fontFamily),
                          children: <TextSpan>[
                            TextSpan(
                              text: postLikeList.first.userId.validate() == appStore.loginUserId ? ' ${language.you}' : ' ${postLikeList.first.userName.validate()}',
                              style: boldTextStyle(size: 12, fontFamily: fontFamily),
                            ),
                            if (postLikeList.length > 1) TextSpan(text: ' ${language.and} ', style: secondaryTextStyle(size: 12, fontFamily: fontFamily)),
                            if (postLikeList.length > 1) TextSpan(text: '${postLikeCount - 1} ${language.others}', style: boldTextStyle(size: 12, fontFamily: fontFamily)),
                          ],
                        ),
                      ).paddingAll(8).onTap(() {
                        PostLikesScreen(postId: widget.post.activityId.validate()).launch(context);
                      }, highlightColor: Colors.transparent, splashColor: Colors.transparent).expand()
                    ],
                  ).paddingOnly(left: 8, right: 8, bottom: 8),
            ],
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: context.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: context.dividerColor)),
        ),
        child: Column(
          children: [
            16.height,
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            8.height,
            Text(
              language.hiddenPostText,
              style: secondaryTextStyle(),
              textAlign: TextAlign.center,
            ).paddingSymmetric(horizontal: 16),
            16.height,
            InkWell(
              onTap: () {
                onReportPost();
              },
              child: Container(
                width: context.width(),
                decoration: BoxDecoration(color: context.cardColor, border: Border.symmetric(horizontal: BorderSide(color: context.dividerColor))),
                child: Text(language.reportPost, style: primaryTextStyle()).center(),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (widget.post.isFriend.validate())
              InkWell(
                onTap: () {
                  onUnfriend();
                },
                child: Container(
                  width: context.width(),
                  decoration: BoxDecoration(color: context.cardColor, border: Border(bottom: BorderSide(color: context.dividerColor))),
                  child: Text(language.unfriend + " " + widget.post.userName.validate(), style: primaryTextStyle()).center(),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      );
    }
  }
}
