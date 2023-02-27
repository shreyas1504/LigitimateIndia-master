import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/utils/app_constants.dart';

class PriceWidget extends StatelessWidget {
  final String? salePrice;
  final String? regularPrice;
  final String? priceHtml;
  final String? price;
  final bool showDiscountPercentage;
  final int? size;

  const PriceWidget({
    Key? key,
    this.salePrice,
    this.regularPrice,
    this.priceHtml,
    this.price,
    this.showDiscountPercentage = false,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (salePrice.validate().isNotEmpty && regularPrice.validate().isNotEmpty) {
      if (salePrice.validate() != regularPrice.validate())
        return RichText(
          text: TextSpan(
            text: '\$${salePrice.validate()} ',
            style: boldTextStyle(decoration: TextDecoration.none, color: context.primaryColor, size: 20, fontFamily: fontFamily),
            children: <TextSpan>[
              TextSpan(text: '\$${regularPrice.validate()}', style: secondaryTextStyle(decoration: TextDecoration.lineThrough, fontFamily: fontFamily)),
              if (showDiscountPercentage) TextSpan(text: '   ${(((regularPrice.toInt() - salePrice.toInt()) / regularPrice.toInt()) * 100).round()}% OFF', style: boldTextStyle(color: Colors.green, fontFamily: fontFamily)),
            ],
          ),
        );
      else
        return Text('\$${price.validate()}', style: boldTextStyle(decoration: TextDecoration.none, color: context.primaryColor, size: size ?? 18));
    } else if (priceHtml != null ? parseHtmlString(priceHtml).contains('–') : false) {
      return Text(parseHtmlString(priceHtml), style: secondaryTextStyle(size: 16), maxLines: 2, overflow: TextOverflow.ellipsis);
    } else {
      return Text('\$${price.validate()}', style: boldTextStyle(decoration: TextDecoration.none, color: context.primaryColor, size: size ?? 18));
    }
  }
}
