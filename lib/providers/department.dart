import 'package:flutter/material.dart';

class Department with ChangeNotifier{
  final String name;
  final String id;

  Department({
    @required this.id,
    @required this.name,
  });
}
