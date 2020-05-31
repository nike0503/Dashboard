import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String name;
  final String id;
  final int price;
  final int quantity;
  final bool isAvailable;
  
  Product({
    @required this.id,
    @required this.name,
    @required this.price,
    @required this.quantity,
    @required this.isAvailable, 
  });
}