import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/models/woo_commerce/category_model.dart';
import 'package:socialv/models/woo_commerce/product_list_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/product_card_component.dart';

import '../../../utils/app_constants.dart';

class ShopScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const ShopScreen({this.categoryId, this.categoryName});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<ProductListModel> productList = [];
  List<CategoryModel> categoryList = [];
  late Future<List<ProductListModel>> future;

  List<FilterModel> filterOptions = getProductFilters();

  ScrollController _scrollController = ScrollController();

  FilterModel? dropDownValue;
  CategoryModel? selectedCategory;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = getProducts(categoryId: widget.categoryId != null ? widget.categoryId.validate() : null);
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
          future = getProducts(categoryId: widget.categoryId != null ? widget.categoryId.validate() : null);
        }
      }
    });

    getCategories();
  }

  Future<List<ProductListModel>> getProducts({String? orderBy, int? categoryId}) async {
    if (mPage == 1) productList.clear();
    appStore.setLoading(true);

    await getProductsList(page: mPage, categoryId: categoryId, orderBy: orderBy == null ? ProductFilters.date : orderBy).then((value) {
      mIsLastPage = value.length != PER_PAGE;
      productList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return productList;
  }

  Future<void> getCategories() async {
    await getCategoryList().then((value) {
      categoryList.addAll(value);
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    isError = false;
    mPage = 1;
    future = getProducts(categoryId: widget.categoryId != null ? widget.categoryId.validate() : null);
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
          title: Text(widget.categoryName != null ? widget.categoryName.validate() : language.shop, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Observer(
          builder: (_) => Stack(
            alignment: Alignment.topCenter,
            children: [
              FutureBuilder<List<ProductListModel>>(
                future: future,
                builder: (ctx, snap) {
                  if (snap.hasError && !appStore.isLoading) {
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
                    if (snap.data.validate().isEmpty && !appStore.isLoading) {
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
                        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 60),
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<CategoryModel>(
                                        borderRadius: BorderRadius.circular(commonRadius),
                                        icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                        elevation: 8,
                                        style: primaryTextStyle(),
                                        onChanged: (CategoryModel? newValue) {
                                          selectedCategory = newValue!;

                                          mPage = 1;
                                          future = getProducts(categoryId: newValue.id.validate());

                                          setState(() {});
                                        },
                                        hint: Text(language.selectCategory, style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite)),
                                        items: categoryList.map<DropdownMenuItem<CategoryModel>>((CategoryModel value) {
                                          return DropdownMenuItem<CategoryModel>(
                                            value: value,
                                            child: Text(value.name.validate(), style: primaryTextStyle()),
                                          );
                                        }).toList(),
                                        value: selectedCategory,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<FilterModel>(
                                        borderRadius: BorderRadius.circular(commonRadius),
                                        icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                        elevation: 8,
                                        style: primaryTextStyle(),
                                        onChanged: (FilterModel? newValue) {
                                          dropDownValue = newValue!;

                                          mPage = 1;
                                          future = getProducts(orderBy: newValue.value);

                                          setState(() {});
                                        },
                                        hint: Text(language.sortBy, style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite)),
                                        items: filterOptions.map<DropdownMenuItem<FilterModel>>((FilterModel value) {
                                          return DropdownMenuItem<FilterModel>(
                                            value: value,
                                            child: Text(value.title.validate(), style: primaryTextStyle()),
                                          );
                                        }).toList(),
                                        value: dropDownValue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 8,
                              runSpacing: 14,
                            ),
                            20.height,
                            AnimatedWrap(
                              alignment: WrapAlignment.start,
                              itemCount: productList.length,
                              spacing: 16,
                              runSpacing: 16,
                              slideConfiguration: SlideConfiguration(delay: 120.milliseconds),
                              itemBuilder: (ctx, index) {
                                return ProductCardComponent(product: productList[index]);
                              },
                            ),
                            16.height,
                          ],
                        ),
                      );
                    }
                  }
                  return LoadingWidget().visible(!appStore.isLoading);
                },
              ),
              Positioned(
                bottom: mPage != 1 ? context.navigationBarHeight + 8 : null,
                child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
              ).visible(appStore.isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
