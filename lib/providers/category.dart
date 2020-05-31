import 'package:flutter/material.dart';

import './product.dart';

class Category with ChangeNotifier{
  final String id;
  final String name;
  final List<Product> products;

  Category({
    @required this.id,
    @required this.name,
    @required this.products,
  });
}