import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/forums/screens/my_forums_screen.dart';
import 'package:socialv/screens/groups/screens/group_screen.dart';
import 'package:socialv/screens/profile/screens/edit_profile_screen.dart';
import 'package:socialv/screens/profile/screens/profile_friends_screen.dart';
import 'package:socialv/screens/settings/screens/settings_screen.dart';
import 'package:socialv/screens/shop/screens/cart_screen.dart';
import 'package:socialv/screens/shop/screens/initial_shop_screen.dart';
import 'package:socialv/screens/shop/screens/orders_screen.dart';
import 'package:socialv/screens/shop/screens/wishlist_screen.dart';
import 'package:socialv/screens/stories/screen/user_story_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class UserDetailBottomSheetWidget extends StatefulWidget {
  final VoidCallback? callback;

  UserDetailBottomSheetWidget({this.callback});

  @override
  State<UserDetailBottomSheetWidget> createState() => _UserDetailBottomSheetWidgetState();
}

class _UserDetailBottomSheetWidgetState extends State<UserDetailBottomSheetWidget> {
  List<DrawerModel> options = getDrawerOptions();

  int selectedIndex = -1;
  bool isLoading = false;
  bool backToHome = true;

  @override
  void initState() {
    super.initState();
    if (appStore.isLoading) {
      isLoading = true;
      appStore.setLoading(false);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (isLoading && backToHome) widget.callback?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Stack(
        children: [
          Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        cachedImage(appStore.loginAvatarUrl, height: 62, width: 62, fit: BoxFit.cover).cornerRadiusWithClipRRect(100),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(appStore.loginFullName, style: boldTextStyle(size: 18)),
                            8.height,
                            Text(appStore.loginEmail, style: secondaryTextStyle(), overflow: TextOverflow.ellipsis, maxLines: 1),
                          ],
                        ).expand(),
                        IconButton(
                          icon: Image.asset(ic_edit, height: 16, width: 16, fit: BoxFit.cover, color: context.iconColor),
                          onPressed: () {
                            finish(context);
                            EditProfileScreen().launch(context);
                          },
                        ),
                      ],
                    ).paddingOnly(left: 16, right: 8, bottom: 16, top: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: options.map((e) {
                        int index = options.indexOf(e);
                        return SettingItemWidget(
                          decoration: BoxDecoration(color: selectedIndex == index ? context.primaryColor.withAlpha(30) : context.cardColor),
                          title: e.title.validate(),
                          titleTextStyle: boldTextStyle(size: 14),
                          leading: Image.asset(e.image.validate(), height: 22, width: 22, fit: BoxFit.fill, color: appColorPrimary),
                          onTap: () async {
                            selectedIndex = index;
                            setState(() {});

                            if (selectedIndex == 0) {
                              backToHome = false;
                              finish(context);
                              UserStoryScreen().launch(context);
                            } else if (selectedIndex == 1) {
                              backToHome = false;
                              finish(context);
                              ProfileFriendsScreen().launch(context);
                            } else if (selectedIndex == 2) {
                              backToHome = false;
                              finish(context);
                              GroupScreen().launch(context);
                            } else if (selectedIndex == 3) {
                              backToHome = false;
                              finish(context);
                              MyForumsScreen().launch(context);
                            } else if (selectedIndex == 4) {
                              backToHome = false;
                              finish(context);
                              InitialShopScreen().launch(context);
                            } else if (selectedIndex == 5) {
                              backToHome = false;
                              finish(context);
                              CartScreen(isFromHome: true).launch(context);
                            } else if (selectedIndex == 6) {
                              backToHome = false;
                              finish(context);
                              WishlistScreen().launch(context);
                            } else if (selectedIndex == 7) {
                              backToHome = false;
                              finish(context);
                              OrdersScreen().launch(context);
                            } else if (selectedIndex == 8) {
                              backToHome = false;
                              finish(context);
                              SettingsScreen().launch(context);
                            } else {
                              finish(context);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ).expand(),
              Column(
                children: [
                  VersionInfoWidget(prefixText: 'v'),
                  16.height,
                  TextButton(
                    onPressed: () {
                      showConfirmDialogCustom(
                        context,
                        primaryColor: appColorPrimary,
                        title: language.logoutConfirmation,
                        onAccept: (s) {
                          logout(context);
                        },
                      );
                    },
                    child: Text(language.logout, style: boldTextStyle(color: context.primaryColor)),
                  ),
                  20.height,
                ],
              ),
            ],
          ),
          LoadingWidget().center().visible(appStore.isLoading)
        ],
      ),
    );
  }
}
