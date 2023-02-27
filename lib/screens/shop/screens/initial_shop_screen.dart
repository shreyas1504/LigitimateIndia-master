import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/screens/shop/screens/cart_screen.dart';
import 'package:socialv/screens/shop/screens/shop_screen.dart';
import 'package:socialv/screens/shop/screens/wishlist_screen.dart';

import '../../../utils/app_constants.dart';

class InitialShopScreen extends StatefulWidget {
  const InitialShopScreen({Key? key}) : super(key: key);

  @override
  State<InitialShopScreen> createState() => _InitialShopScreenState();
}

class _InitialShopScreenState extends State<InitialShopScreen> {
  int selectedIndex = 0;
  List<Widget> appFragments = [];

  bool change = false;

  @override
  void initState() {
    appFragments.addAll(
      [
        ShopScreen(),
        SizedBox(),
        WishlistScreen(),
      ],
    );

    super.initState();
    afterBuildCreated(() async {
      appStore.setShopBottom(true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appFragments[selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Observer(
        builder: (_) => AnimatedSlide(
          offset: appStore.showShopBottom ? Offset.zero : Offset(0, 1),
          duration: Duration(milliseconds: 350),
          child: Container(
            width: context.width() * 0.5,
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    selectedIndex = 0;
                    setState(() {});
                  },
                  icon: Image.asset(selectedIndex == 0 ? ic_store_filled : ic_store, height: 24, width: 24, color: context.primaryColor, fit: BoxFit.cover),
                ),
                IconButton(
                  onPressed: () {
                    CartScreen().launch(context);
                  },
                  icon: Image.asset(ic_bag, height: 24, width: 24, color: context.primaryColor, fit: BoxFit.cover),
                ),
                IconButton(
                  onPressed: () {
                    selectedIndex = 2;
                    setState(() {});
                  },
                  icon: Image.asset(
                    selectedIndex == 2 ? ic_heart_filled : ic_heart,
                    height: selectedIndex == 2 ? 22 : 24,
                    width: selectedIndex == 2 ? 24 : 24,
                    color: context.primaryColor,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
