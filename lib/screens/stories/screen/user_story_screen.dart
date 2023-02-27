import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/story/story_response_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/stories/component/story_video_component.dart';
import 'package:socialv/screens/stories/screen/create_story_screen.dart';
import 'package:socialv/screens/stories/screen/story_page.dart';
import 'package:socialv/screens/stories/component/story_views_component.dart';
import 'package:socialv/utils/app_constants.dart';

class UserStoryScreen extends StatefulWidget {
  const UserStoryScreen({Key? key}) : super(key: key);

  @override
  State<UserStoryScreen> createState() => _UserStoryScreenState();
}

class _UserStoryScreenState extends State<UserStoryScreen> with SingleTickerProviderStateMixin {
  List<StoryResponseModel> list = [];
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = BottomSheet.createAnimationController(this);
    _animationController.duration = const Duration(milliseconds: 300);
    _animationController.drive(CurveTween(curve: Curves.easeOutQuad));

    super.initState();
    getStories();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> getStories() async {
    appStore.setLoading(true);
    list.clear();
    await getUserStories(userId: appStore.loginUserId.toInt()).then((value) {
      list.addAll(value);
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      log('error : ${e.toString()}');
      appStore.setLoading(false);
    });
  }

  Future<void> addStory() async {
    FileTypes? file = await showInDialog(
      context,
      contentPadding: EdgeInsets.symmetric(vertical: 16),
      title: Text(language.chooseAnAction, style: boldTextStyle()),
      builder: (p0) {
        return FilePickerDialog(isSelected: true);
      },
    );

    if (file == FileTypes.CAMERA) {
      await getImageSource(isCamera: true).then((value) {
        appStore.setLoading(false);
        CreateStoryScreen(cameraImage: value).launch(context, duration: 500.milliseconds).then((value) {
          if (value ?? false) {
            getStories();
            LiveStream().emit(GetUserStories);
          }
        });
      }).catchError((e) {
        appStore.setLoading(false);
      });
    } else {
      await getMultipleImages().then((value) {
        appStore.setLoading(false);

        if (value.isNotEmpty)
          CreateStoryScreen(mediaList: value).launch(context, duration: 500.milliseconds).then((value) {
            if (value ?? false) {
              getStories();
              LiveStream().emit(GetUserStories);
            }
          });
      }).catchError((e) {
        appStore.setLoading(false);
      });
    }
  }

  @override
  void dispose() {
    if(appStore.isLoading) appStore.setLoading(false);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
        title: Text(language.myStories, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) => Stack(
          children: [
            if (list.isNotEmpty)
              AnimatedListView(
                disposeScrollController: false,
                shrinkWrap: true,
                slideConfiguration: SlideConfiguration(
                  delay: 80.milliseconds,
                  verticalOffset: 300,
                ),
                itemCount: list.first.items.validate().length,
                padding: EdgeInsets.only(bottom: 60),
                itemBuilder: (ctx, index) {
                  StoryItem story = list.first.items.validate()[index];
                  return InkWell(
                    onTap: () {
                      StoryPage(
                        callback: () async {
                          await 500.milliseconds.delay;
                          getStories();
                          LiveStream().emit(GetUserStories);
                        },
                        fromUserStory: true,
                        initialIndex: 0,
                        initialStoryIndex: index,
                        stories: list,
                      ).launch(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            story.mediaType == MediaTypes.video
                                ? Container(
                                    decoration: BoxDecoration(borderRadius: radius(24)),
                                    height: 48,
                                    width: 48,
                                    child: ShowVideoThumbnail(videoUrl: story.storyMedia),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: story.storyMedia.validate(),
                                    fit: BoxFit.cover,
                                    height: 48,
                                    width: 48,
                                    memCacheHeight: 720,
                                    memCacheWidth: 720,
                                  ).cornerRadiusWithClipRRect(24),
                            16.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${story.viewCount.validate().toString()} ${language.views}', style: boldTextStyle()),
                                Text(timeStampToDate(story.time.validate()), style: secondaryTextStyle()),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              ic_show,
                              color: appColorPrimary,
                              width: 22,
                              height: 22,
                            ).onTap(() async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                transitionAnimationController: _animationController,
                                builder: (context) {
                                  return FractionallySizedBox(
                                    heightFactor: 0.93,
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
                                          child: StoryViewsScreen(
                                            storyId: story.id.validate(),
                                            viewCount: story.viewCount.validate(),
                                          ),
                                        ).expand(),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                            IconButton(
                              onPressed: () {
                                showConfirmDialogCustom(
                                  context,
                                  onAccept: (c) {
                                    ifNotTester(() {
                                      appStore.setLoading(true);

                                      deleteStory(storyId: story.id.validate()).then((value) {
                                        toast(value.message);
                                        list[0].items!.removeAt(index);
                                        setState(() {});
                                        appStore.setLoading(false);
                                        LiveStream().emit(GetUserStories);
                                      }).catchError((e) {
                                        appStore.setLoading(false);

                                        toast(e.toString());
                                      });
                                    });
                                  },
                                  dialogType: DialogType.DELETE,
                                  title: language.deleteStoryConfirmation,
                                  positiveText: language.delete,
                                );
                              },
                              icon: Image.asset(
                                ic_delete,
                                width: 24,
                                height: 24,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16, vertical: 8),
                  );
                },
              ),
            if ((list.isEmpty || list[0].items!.isEmpty) && !appStore.isLoading)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmptyPostLottieWidget(),
                  Text(
                    language.addStoryText,
                    style: secondaryTextStyle(),
                    textAlign: TextAlign.center,
                  ).paddingSymmetric(horizontal: 32),
                  16.height,
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                      side: MaterialStateProperty.all(BorderSide(color: appColorPrimary.withOpacity(0.5))),
                    ),
                    onPressed: () {
                      addStory();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 20, color: context.iconColor),
                        4.width,
                        Text(language.addYourStory, style: primaryTextStyle(size: 14)),
                      ],
                    ),
                  ),
                ],
              ).center(),
            LoadingWidget().center().visible(appStore.isLoading),
          ],
        ),
      ),
      floatingActionButton: list.isEmpty || list[0].items!.isEmpty
          ? Offstage()
          : FloatingActionButton(
              backgroundColor: appColorPrimary,
              onPressed: () {
                addStory();
              },
              child: Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
