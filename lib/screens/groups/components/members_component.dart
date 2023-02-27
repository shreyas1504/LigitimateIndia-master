import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/members/member_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class MembersComponent extends StatelessWidget {
  final bool isAdmin;
  final MemberModel member;
  final int groupId;
  final VoidCallback? callback;
  final int creatorId;

  const MembersComponent({
    required this.member,
    required this.groupId,
    this.callback,
    required this.isAdmin,
    required this.creatorId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            cachedImage(
              member.userAvatar.validate(),
              height: 56,
              width: 56,
              fit: BoxFit.cover,
            ).cornerRadiusWithClipRRect(100),
            20.width,
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(member.userName.validate(), style: boldTextStyle()),
                    if (member.isAdmin.validate()) Icon(Icons.star, size: 18, color: Colors.amber).paddingSymmetric(horizontal: 4),
                  ],
                ),
                6.height,
                Text(member.mentionName.validate(), style: secondaryTextStyle()),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ],
        ),
        if (isAdmin && creatorId != member.userId.validate())
          Theme(
            data: Theme.of(context).copyWith(useMaterial3: false),
            child: PopupMenuButton(
              position: PopupMenuPosition.under,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
              onSelected: (val) {
                if (val == 2) {
                  showConfirmDialogCustom(
                    context,
                    onAccept: (c) {
                      ifNotTester(() {
                        removeGroupMember(groupId: groupId, memberId: member.userId.validate()).then((value) {
                          appStore.setLoading(false);
                          callback?.call();
                        }).catchError((e) {
                          appStore.setLoading(false);
                          toast(e.toString(), print: true);
                        });
                      });
                    },
                    dialogType: DialogType.CONFIRMATION,
                    title: language.areYouSureYou,
                    positiveText: language.remove,
                  );
                } else {
                  ifNotTester(() {
                    appStore.setLoading(true);
                    if (member.isAdmin.validate()) {
                      dismissMemberAsAdmin(groupId: groupId, memberId: member.userId.validate()).then((value) {
                        appStore.setLoading(false);
                        callback?.call();
                      }).catchError((e) {
                        appStore.setLoading(false);
                        toast(e.toString(), print: true);
                      });
                    } else {
                      makeMemberAdmin(groupId: groupId, memberId: member.userId.validate()).then((value) {
                        appStore.setLoading(false);
                        callback?.call();
                      }).catchError((e) {
                        appStore.setLoading(false);
                        toast(e.toString(), print: true);
                      });
                    }
                  });
                }
              },
              icon: Icon(Icons.more_horiz, color: context.iconColor),
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                  value: 1,
                  child: member.isAdmin.validate() ? Text(language.dismissAsAdmin) : Text(language.makeGroupAdmin),
                  textStyle: primaryTextStyle(),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text(language.removeFromGroup),
                  textStyle: primaryTextStyle(),
                ),
              ],
            ),
          ),
      ],
    ).onTap(() async {
      MemberProfileScreen(memberId: member.userId.validate()).launch(context);
    }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
  }
}
