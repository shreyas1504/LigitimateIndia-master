import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/product_review_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/update_review_component.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class ProductReviewComponent extends StatefulWidget {
  final int productId;

  const ProductReviewComponent({required this.productId});

  @override
  State<ProductReviewComponent> createState() => _ProductReviewComponentState();
}

class _ProductReviewComponentState extends State<ProductReviewComponent> {
  final reviewFormKey = GlobalKey<FormState>();

  TextEditingController controller = TextEditingController();

  double rating = 0.0;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void addReview() {
    if (reviewFormKey.currentState!.validate()) {
      reviewFormKey.currentState!.save();
      hideKeyboard(context);

      if (rating > 0) {
        ifNotTester(() async {
          appStore.setLoading(true);
          Map request = {
            "product_id": widget.productId.toString(),
            "review": controller.text,
            "reviewer": appStore.loginFullName,
            "reviewer_email": appStore.loginEmail,
            "rating": rating.toInt(),
          };
          await addProductReview(request: request).then((value) async {
            toast('${language.reviewAddedSuccessfully}');
            controller.clear();
            rating = 0.0;
            appStore.setLoading(false);
          }).catchError((e) {
            appStore.setLoading(false);
            toast(e.toString(), print: true);
          });
        });
      } else {
        toast('${language.pleaseAddRating}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SnapHelperWidget<List<ProductReviewModel>>(
          future: getProductReviews(productId: widget.productId),
          onSuccess: (snap) {
            if (snap.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${language.reviews}', style: boldTextStyle()),
                  12.height,
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snap.length,
                    itemBuilder: (ctx, index) {
                      ProductReviewModel review = snap[index];
                      return Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  cachedImage(review.reviewerAvatarUrls!.full, height: 40, width: 40, fit: BoxFit.cover).cornerRadiusWithClipRRect(20),
                                  16.width,
                                  Column(
                                    children: [
                                      Text(review.reviewer.validate(), style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      RatingBarWidget(
                                        onRatingChanged: (x) {
                                          //
                                        },
                                        activeColor: Colors.amber,
                                        inActiveColor: Colors.amber,
                                        rating: review.rating.validate().toDouble(),
                                        size: 14,
                                        allowHalfRating: true,
                                        disable: true,
                                      ),
                                    ],
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  ).expand(),
                                  6.width,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(convertToAgo(review.dateCreated.validate()), style: secondaryTextStyle()),
                                      if (review.reviewer == appStore.loginFullName)
                                        Text('${language.editReview}', style: secondaryTextStyle(color: context.primaryColor, size: 12)).onTap(() {
                                          showInDialog(
                                            context,
                                            contentPadding: EdgeInsets.zero,
                                            builder: (p0) {
                                              return UpdateReviewComponent(
                                                rating: review.rating.validate(),
                                                review: review.review,
                                                reviewId: review.id.validate(),
                                              );
                                            },
                                          );
                                        }),
                                    ],
                                  ),
                                ],
                              ),
                              8.height,
                              Text(parseHtmlString(review.review.validate()), style: secondaryTextStyle()).paddingLeft(58),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            }
            return Offstage();
          },
          errorWidget: Offstage(),
          loadingWidget: ThreeBounceLoadingWidget(),
        ),
        16.height,
        Text('${language.addAReview}', style: boldTextStyle()),
        16.height,
        RichText(
          text: TextSpan(
            style: secondaryTextStyle(fontFamily: fontFamily),
            children: [
              TextSpan(text: '${language.rating} '),
              TextSpan(text: '*', style: TextStyle(color: Colors.red, fontFeatures: [FontFeature.subscripts()], fontFamily: fontFamily)),
            ],
          ),
        ),
        6.height,
        RatingBarWidget(
          onRatingChanged: (val) {
            rating = val;
            setState(() {});
          },
          activeColor: Colors.amber,
          inActiveColor: Colors.amber,
          rating: rating,
          size: 30,
          allowHalfRating: true,
        ),
        16.height,
        RichText(
          text: TextSpan(
            style: secondaryTextStyle(),
            children: [
              TextSpan(text: '${language.writeReview} '),
              TextSpan(text: '*', style: TextStyle(color: Colors.red, fontFeatures: [FontFeature.subscripts()])),
            ],
          ),
        ),
        4.height,
        Form(
          key: reviewFormKey,
          child: AppTextField(
            enabled: !appStore.isLoading,
            controller: controller,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            textFieldType: TextFieldType.MULTILINE,
            textStyle: boldTextStyle(),
            minLines: 5,
            maxLines: 5,
            decoration: inputDecorationFilled(context, fillColor: context.cardColor),
            onFieldSubmitted: (text) {
              //addReview();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return language.pleaseAddReview;
              }
              return null;
            },
          ),
        ),
        16.height,
        Align(
          alignment: Alignment.bottomRight,
          child: AppButton(
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
            text: language.submit,
            textStyle: secondaryTextStyle(color: Colors.white, size: 14),
            onTap: () async {
              addReview();
            },
            elevation: 0,
            color: context.primaryColor,
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 16, vertical: 16);
  }
}
