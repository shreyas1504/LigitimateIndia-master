import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/cart_item_model.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/cart_coupons_component.dart';
import 'package:socialv/screens/shop/components/empty_cart_component.dart';
import 'package:socialv/screens/shop/components/price_widget.dart';
import 'package:socialv/screens/shop/screens/checkout_screen.dart';
import 'package:socialv/screens/shop/screens/product_detail_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class CartScreen extends StatefulWidget {
  final bool isFromHome;

  CartScreen({this.isFromHome = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItemModel> cartItemList = [];
  CartModel? cart;
  late Future<List<CartItemModel>> future;

  bool mIsLastPage = false;
  bool isError = false;

  int total = 0;

  TextEditingController couponController = TextEditingController();

  @override
  void initState() {
    future = getCart();
    super.initState();
  }

  Future<List<CartItemModel>> getCart({String? orderBy}) async {
    appStore.setLoading(true);
    cartItemList.clear();

    await getCartDetails().then((value) {
      cart = value;
      cartItemList.addAll(value.items.validate());
      total = value.totals!.totalPrice.validate().toInt();

      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return cartItemList;
  }

  Future<void> applyCouponToCart() async {
    if (couponController.text.isNotEmpty) {
      ifNotTester(() async {
        appStore.setLoading(true);
        await Future.forEach<CartItemModel>(cart!.items.validate(), (element) async {
          if (element.isQuantityChanged.validate()) {
            appStore.setLoading(true);
            await updateCartItem(productKey: element.key.validate(), quantity: element.quantity.validate()).then((value) async {
              log('item updated successfully');
            }).catchError((e) {
              appStore.setLoading(false);

              toast(e.toString(), print: true);
            });
          }
        }).then((value) async {
          appStore.setLoading(true);

          await applyCoupon(code: couponController.text).then((value) {
            cart = value;
            couponController.clear();
            future = getCart();
            setState(() {});
            appStore.setLoading(false);
          }).catchError((e) {
            couponController.clear();
            appStore.setLoading(false);
            toast(e.toString());
          });
        });
      });
    } else {
      toast(language.enterValidCouponCode);
    }
  }

  Future<void> onRefresh() async {
    isError = false;
    future = getCart();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
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
          title: Text(language.cart, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Observer(
          builder: (_) {
            if (appStore.isLoading) {
              return LoadingWidget();
            } else {
              return FutureBuilder<List<CartItemModel>>(
                future: future,
                builder: (ctx, snap) {
                  if (snap.hasError && !appStore.isLoading) {
                    return NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: isError ? language.somethingWentWrong : language.noDataFound,
                    ).center();
                  }
                  if (snap.hasData) {
                    if (snap.data.validate().isEmpty && !appStore.isLoading) {
                      return EmptyCartComponent(isFromHome: widget.isFromHome);
                    } else {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            AnimatedListView(
                              shrinkWrap: true,
                              listAnimationType: ListAnimationType.FadeIn,
                              slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: cartItemList.length,
                              itemBuilder: (context, index) {
                                CartItemModel cartItem = cartItemList[index];

                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        cachedImage(
                                          cartItem.images.validate().isNotEmpty ? cartItem.images!.first.src.validate() : '',
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        ).cornerRadiusWithClipRRect(defaultAppButtonRadius),
                                        16.width,
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(cartItem.name.validate().capitalizeFirstLetter(), style: boldTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis),
                                            PriceWidget(
                                              price: getPrice(cartItem.prices!.price.validate()),
                                              salePrice: getPrice(cartItem.prices!.salePrice.validate()),
                                              regularPrice: getPrice(cartItem.prices!.regularPrice.validate()),
                                            ),
                                          ],
                                        ).onTap(() {
                                          ProductDetailScreen(id: cartItem.id.validate()).launch(context);
                                        }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                        Image.asset(ic_delete, color: Colors.red, height: 20, width: 20, fit: BoxFit.cover).onTap(() {
                                          showConfirmDialogCustom(
                                            context,
                                            onAccept: (c) {
                                              cartItem.isQuantityChanged = true;

                                              total = total - (cartItem.prices!.price.validate().toInt() * cartItem.quantity!.toInt());

                                              cartItemList.remove(cartItem);
                                              setState(() {});
                                              toast(language.itemRemovedSuccessfully);

                                              removeCartItem(productKey: cartItem.key.validate()).then((value) {
                                                //getCart();
                                              }).catchError((e) {
                                                toast(e.toString(), print: true);
                                              });
                                            },
                                            dialogType: DialogType.CONFIRMATION,
                                            title: language.removeFromCartConfirmation,
                                            positiveText: language.remove,
                                          );
                                        }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                                      ],
                                    ),
                                    10.height,
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(borderRadius: radius(4), border: Border.all(color: appStore.isDarkMode ? bodyDark : bodyWhite)),
                                          child: Row(
                                            children: [
                                              Text('-', style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18)).paddingAll(2).onTap(() {
                                                if (cartItem.quantity.validate() > 1) {
                                                  cartItem.quantity = cartItem.quantity.validate() - 1;
                                                  cartItem.isQuantityChanged = true;

                                                  total = total - cartItem.prices!.price.validate().toInt();
                                                  setState(() {});
                                                }
                                              }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                                              Text(cartItem.quantity.toString(), style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 14)),
                                              Text('+', style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18)).paddingAll(2).onTap(() {
                                                cartItem.quantity = cartItem.quantity.validate() + 1;
                                                cartItem.isQuantityChanged = true;
                                                total = total + cartItem.prices!.price.validate().toInt();

                                                setState(() {});
                                              }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                                            ],
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                          ),
                                          width: 70,
                                          padding: EdgeInsets.zero,
                                        ),
                                        PriceWidget(price: getPrice((cartItem.prices!.price!.toInt() * cartItem.quantity.validate()).toString()), size: 20),
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    ),
                                    Divider(color: appStore.isDarkMode ? bodyDark.withOpacity(0.6) : bodyWhite.withOpacity(0.6), height: 32),
                                  ],
                                );
                              },
                            ),
                            16.height,
                            if (cart!.coupons.validate().isNotEmpty) CartCouponsComponent(couponsList: cart!.coupons.validate()),
                            Row(
                              children: [
                                Container(
                                  width: context.width() / 2 - 32,
                                  padding: EdgeInsets.zero,
                                  decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultAppButtonRadius)),
                                  child: AppTextField(
                                    enabled: !appStore.isLoading,
                                    controller: couponController,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.done,
                                    textFieldType: TextFieldType.NAME,
                                    textStyle: boldTextStyle(),
                                    maxLines: 1,
                                    decoration: inputDecorationFilled(context, label: language.couponCode, contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8), fillColor: context.cardColor),
                                    onFieldSubmitted: (text) async {
                                      await applyCouponToCart();
                                    },
                                  ),
                                ),
                                16.width,
                                AppButton(
                                  text: language.applyCoupon,
                                  textStyle: secondaryTextStyle(color: Colors.white, size: 14),
                                  onTap: () async {
                                    await applyCouponToCart();
                                  },
                                  elevation: 0,
                                  color: context.primaryColor,
                                ).expand(),
                              ],
                            ).paddingSymmetric(horizontal: 16),
                            100.height,
                          ],
                        ),
                      );
                    }
                  }

                  return LoadingWidget();
                },
              );
            }
          },
        ),
        bottomNavigationBar: cart != null
            ? cart!.items.validate().isNotEmpty
                ? Container(
                    color: context.cardColor,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${language.subTotal}', style: primaryTextStyle()),
                            PriceWidget(price: getPrice(total.toString()), size: 16),
                            //Text('${cart!.totals!.currencySymbol}${getPrice(cart!.totals!.totalItems.validate())}', style: primaryTextStyle()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${language.discount}', style: primaryTextStyle()),
                            Text(
                              '-${cart!.totals!.currencySymbol}${getPrice(cart!.totals!.totalDiscount.validate())}',
                              style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            PriceWidget(price: getPrice(total.toString()), size: 22).expand(),
                            AppButton(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
                              text: language.proceedToCheckout,
                              textStyle: secondaryTextStyle(color: Colors.white, size: 14),
                              onTap: () async {
                                if (!appStore.isLoading)
                                  ifNotTester(() async {
                                    await Future.forEach<CartItemModel>(cart!.items.validate(), (element) async {
                                      if (element.isQuantityChanged.validate()) {
                                        appStore.setLoading(true);
                                        await updateCartItem(productKey: element.key.validate(), quantity: element.quantity.validate()).then((value) async {
                                          log('item updated successfully');
                                          await getCart();
                                        }).catchError((e) {
                                          appStore.setLoading(false);
                                          log(e.toString());
                                        });
                                      }
                                    }).then((value) {
                                      CheckoutScreen(cartDetails: cart!).launch(context).then((value) async {
                                        if (value ?? false) {
                                          await getCart();
                                        }
                                      });
                                    });
                                  });
                              },
                              elevation: 0,
                              color: context.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Offstage()
            : Offstage(),
      ),
    );
  }
}
