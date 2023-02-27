import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/wishlist_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/price_widget.dart';
import 'package:socialv/screens/shop/screens/product_detail_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<WishlistModel> orderList = [];
  late Future<List<WishlistModel>> future;

  ScrollController _scrollController = ScrollController();

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = getList();
    super.initState();

    _scrollController.addListener(() {
      /// scroll down
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (appStore.showShopBottom) appStore.setShopBottom(false);
      }

      /// scroll up
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!appStore.showShopBottom) appStore.setShopBottom(true);
      }

      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;
          setState(() {});
          appStore.setLoading(true);
          future = getList();
        }
      }
    });
  }

  Future<List<WishlistModel>> getList({String? status}) async {
    appStore.setLoading(true);

    await getWishList(page: mPage).then((value) {
      if (mPage == 1) orderList.clear();

      mIsLastPage = value.length != 20;
      orderList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return orderList;
  }

  Future<void> onRefresh() async {
    isError = false;
    mPage = 1;
    future = getList();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
          titleSpacing: 0,
          title: Text(language.myWishlist, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            FutureBuilder<List<WishlistModel>>(
              future: future,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: isError ? language.somethingWentWrong : language.noDataFound,
                    onRetry: () {
                      onRefresh();
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
                        onRefresh();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center();
                  } else {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                      controller: _scrollController,
                      child: AnimatedWrap(
                        alignment: WrapAlignment.start,
                        itemCount: orderList.length,
                        spacing: 16,
                        runSpacing: 16,
                        slideConfiguration: SlideConfiguration(delay: 120.milliseconds),
                        itemBuilder: (ctx, index) {
                          WishlistModel product = orderList[index];

                          return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              ProductDetailScreen(id: product.proId.validate()).launch(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultAppButtonRadius)),
                              width: context.width() / 2 - 24,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      cachedImage(
                                        product.full.validate(),
                                        height: 150,
                                        width: context.width() / 2 - 24,
                                        fit: BoxFit.cover,
                                      ).cornerRadiusWithClipRRectOnly(topRight: defaultAppButtonRadius.toInt(), topLeft: defaultAppButtonRadius.toInt()),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(color: context.primaryColor, borderRadius: radiusOnly(topLeft: defaultAppButtonRadius, bottomRight: defaultAppButtonRadius)),
                                        child: Text(language.sale, style: secondaryTextStyle(size: 10, color: Colors.white)),
                                      ).visible(product.salePrice.validate().isNotEmpty),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: InkWell(
                                          onTap: () {
                                            orderList.removeWhere((element) => element.proId == product.proId);
                                            setState(() {});

                                            removeFromWishlist(productId: product.proId.validate()).then((value) {
                                              //
                                            }).catchError((e) {
                                              toast(e.toString());
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: context.primaryColor.withAlpha(30), shape: BoxShape.circle),
                                            child: Image.asset(
                                              ic_heart_filled,
                                              color: Colors.red,
                                              height: 18,
                                              width: 18,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  14.height,
                                  Text(product.name.validate().capitalizeFirstLetter(), style: boldTextStyle()).paddingSymmetric(horizontal: 10),
                                  4.height,
                                  PriceWidget(
                                    price: product.price,
                                    salePrice: product.salePrice,
                                    regularPrice: product.regularPrice,
                                    showDiscountPercentage: false,
                                  ).paddingSymmetric(horizontal: 10),
                                  14.height,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }
                return Observer(builder: (_) => LoadingWidget().visible(!appStore.isLoading));
              },
            ),
            Observer(
              builder: (_) {
                if (appStore.isLoading) {
                  return Positioned(
                    bottom: mPage != 1 ? 10 : null,
                    child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
                  );
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
