import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/utils/app_constants.dart';

class CartCouponsComponent extends StatefulWidget {
  final List<CartCouponModel>? couponsList;

  CartCouponsComponent({this.couponsList});

  @override
  State<CartCouponsComponent> createState() => _CartCouponsComponentState();
}

class _CartCouponsComponentState extends State<CartCouponsComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.appliedCoupons, style: boldTextStyle(size: 18)).paddingSymmetric(horizontal: 16),
        16.height,
        ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.couponsList!.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, couponIndex) {
            CartCouponModel coupon = widget.couponsList!.validate()[couponIndex];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: '${language.code}: ',
                    style: boldTextStyle(fontFamily: fontFamily),
                    children: <TextSpan>[
                      TextSpan(text: coupon.code.validate(), style: primaryTextStyle(fontFamily: fontFamily)),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: '${language.discount}: ',
                    style: boldTextStyle(fontFamily: fontFamily),
                    children: <TextSpan>[
                      TextSpan(text: '${coupon.totals!.currencySymbol.validate()}${getPrice(coupon.totals!.totalDiscount.validate())}', style: primaryTextStyle(fontFamily: fontFamily)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        16.height,
      ],
    );
  }
}
