import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/groups/group_response.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/groups/screens/group_detail_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key? key}) : super(key: key);

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  List<GroupResponse> groupList = [];

  late Future<List<GroupResponse>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = getGroupsList();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  Future<List<GroupResponse>> getGroupsList() async {
    appStore.setLoading(true);
    await getUserGroups(page: mPage, searchScreen: false).then((value) {
      mIsLastPage = value.length != 20;
      if (mPage == 1) groupList.clear();
      groupList.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      toast(e.toString());
      appStore.setLoading(false);
    });
    setState(() {});

    return groupList;
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: context.iconColor),
        title: Text(language.groups, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          FutureBuilder<List<GroupResponse>>(
            future: future,
            builder: (ctx, snap) {
              if (snap.hasError) {
                return NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: isError ? language.somethingWentWrong : language.noDataFound,
                  onRetry: () {
                    future = getGroupsList();
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ).center();
              }
              if (snap.hasData) {
                if (snap.data.validate().isEmpty) {
                  return NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: isError ? language.somethingWentWrong : language.noDataFound,
                    onRetry: () {
                      future = getGroupsList();
                    },
                    retryText: '   ${language.clickToRefresh}   ',
                  ).center();
                } else {
                  return AnimatedListView(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    slideConfiguration: SlideConfiguration(
                      delay: 120.milliseconds,
                    ),
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                    itemCount: groupList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          GroupDetailScreen(groupId: groupList[index].id.validate()).launch(context);
                        },
                        child: Row(
                          children: [
                            cachedImage(
                              groupList[index].avatarUrls!.full.validate(),
                              height: 56,
                              width: 56,
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(100),
                            20.width,
                            Column(
                              children: [
                                Text(groupList[index].name.validate(), style: boldTextStyle()),
                                6.height,
                                Text(
                                  groupList[index].description!.raw.validate(),
                                  style: secondaryTextStyle(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ).expand(),
                          ],
                        ).paddingSymmetric(vertical: 8),
                      );
                    },
                    onNextPage: () {
                      if (!mIsLastPage) {
                        mPage++;
                        future = getGroupsList();
                      }
                    },
                  );
                }
              }

              return Offstage();
            },
          ),
          Observer(builder: (_) {
            return Positioned(
              bottom: mPage != 1 ? 10 : null,
              child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
            ).visible(appStore.isLoading);
          }),
        ],
      ),
    );
  }
}
