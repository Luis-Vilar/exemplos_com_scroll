import 'dart:convert';

import 'package:exemplos_com_scroll/app/data/model/product_model.dart';
import 'package:exemplos_com_scroll/app/data/service/product_service.dart';

class ProductController {
  final ProductService _productService = ProductService();
  late final List<ProductModel> products;

  ProductController() {
    final productsListMap =
        json.decode(_productService.getProducts()) as List<dynamic>;
    products = productsListMap
        .map((product) => ProductModel.fromJson(product))
        .toList();
  }

  List<ProductModel> search({required String searched}) {
    List<ProductModel> found = [];
    List<ProductModel> byName = products.where((product) {
      return product.name.toLowerCase().contains(searched.toLowerCase());
    }).toList();
    List<ProductModel> byCategory = products.where((product) {
      return product.category.toLowerCase().contains(searched.toLowerCase());
    }).toList();

    found = [...byName, ...byCategory];

    return found;
  }
}
