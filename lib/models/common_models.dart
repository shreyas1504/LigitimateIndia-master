import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';

import '../utils/app_constants.dart';

class DrawerModel {
  String? title;
  String? image;

  DrawerModel({this.image, this.title});
}

List<DrawerModel> getDrawerOptions() {
  List<DrawerModel> list = [];

  list.add(DrawerModel(image: ic_story, title: language.myStories));
  list.add(DrawerModel(image: ic_two_user, title: language.friends));
  list.add(DrawerModel(image: ic_three_user, title: language.groups));
  list.add(DrawerModel(image: ic_document, title: language.forums));
  list.add(DrawerModel(image: ic_store, title: language.shop));
  list.add(DrawerModel(image: ic_buy, title: language.cart));
  list.add(DrawerModel(image: ic_heart, title: language.wishlist));
  list.add(DrawerModel(image: ic_bag, title: language.myOrders));
  list.add(DrawerModel(image: ic_setting, title: language.settings));

  return list;
}

class FilterModel {
  String? title;
  String? value;

  FilterModel({this.value, this.title});
}

List<FilterModel> getProductFilters() {
  List<FilterModel> list = [];

  list.add(FilterModel(value: ProductFilters.date, title: language.latest));
  list.add(FilterModel(value: ProductFilters.rating, title: language.averageRating));
  list.add(FilterModel(value: ProductFilters.popularity, title: language.popularity));
  list.add(FilterModel(value: ProductFilters.price, title: language.price));

  return list;
}

List<FilterModel> getOrderStatus() {
  List<FilterModel> list = [];

  list.add(FilterModel(value: OrderStatus.any, title: language.any));
  list.add(FilterModel(value: OrderStatus.pending, title: language.pending));
  list.add(FilterModel(value: OrderStatus.processing, title: language.processing));
  list.add(FilterModel(value: OrderStatus.onHold, title: language.onHold));
  list.add(FilterModel(value: OrderStatus.completed, title: language.completed));
  list.add(FilterModel(value: OrderStatus.cancelled, title: language.cancelled));
  list.add(FilterModel(value: OrderStatus.refunded, title: language.refunded));
  list.add(FilterModel(value: OrderStatus.failed, title: language.failed));
  list.add(FilterModel(value: OrderStatus.trash, title: language.trash));

  return list;
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', subTitle: 'English', languageCode: 'en', fullLanguageCode: 'en_en-US', flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', subTitle: 'हिंदी', languageCode: 'hi', fullLanguageCode: 'hi_hi-IN', flag: 'assets/flag/ic_hi.png'),
    LanguageDataModel(id: 3, name: 'Arabic', subTitle: 'عربي', languageCode: 'ar', fullLanguageCode: 'ar_ar-AR', flag: 'assets/flag/ic_ar.png'),
    LanguageDataModel(id: 4, name: 'French', subTitle: 'français', languageCode: 'fr', fullLanguageCode: 'fr_fr-FR', flag: 'assets/flag/ic_fr.png'),
    LanguageDataModel(id: 5, name: 'Spanish', subTitle: 'español', languageCode: 'es', fullLanguageCode: 'es_es-ES', flag: 'assets/flag/ic_es.png'),
    LanguageDataModel(id: 6, name: 'German', subTitle: 'Deutsch', languageCode: 'de', fullLanguageCode: 'de_de-De', flag: 'assets/flag/ic_de.png'),
    LanguageDataModel(id: 6, name: 'Portuguese', subTitle: 'Português', languageCode: 'pt', fullLanguageCode: 'pt_pt-PT', flag: 'assets/flag/ic_pt.jpg'),
  ];
}
