import 'package:flutter/material.dart';

import './category.dart';

class Department with ChangeNotifier{
  final String name;
  final String id;
  final List<Category> categories;

  Department({
    @required this.id,
    @required this.name,
    @required this.categories,
  });
}
