import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderProd {
  final String prodName;
  final int price;
  final int quantity;
  final String admin;
  final String status;

  OrderProd({
    @required this.status,
    @required this.admin,
    @required this.prodName,
    @required this.price,
    @required this.quantity,
  });
}

class OrderItem {
  final String address;
  final String phone;
  final String id;
  final int amount;
  final List<OrderProd> products;
  final DateTime dateTime;

  OrderItem({
    @required this.address,
    @required this.phone,
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders(String userId) async {
    final List<OrderItem> loadedOrders = [];
    List _orderList = await Firestore.instance
        .collection('Users')
        .document(userId)
        .collection('Orders')
        .getDocuments()
        .then((snap) => snap.documents);
    if (_orderList == null) {
      return null;
    }
    for (int i = 0; i < _orderList.length; i++) {
      loadedOrders.add(OrderItem(
        id: _orderList[i]['id'],
        amount: _orderList[i]['amount'],
        address: _orderList[i]['address'],
        phone: _orderList[i]['phone'],
        products: (_orderList[i]['products'] as List<dynamic>)
            .map(
              (item) => OrderProd(
                status: item['status'],
                admin: item['admin'],
                prodName: item['prodName'],
                price: item['price'],
                quantity: item['quantity'],
              ),
            )
            .toList(),
        dateTime: DateTime.parse(_orderList[i]['dateTime']),
      ));
    }
    loadedOrders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<OrderItem> addOrder(
    List<OrderProd> products,
    int total,
    String userId,
    String address,
    String phone,
  ) async {
    var rn = new Random();
    String id = (100001 + rn.nextInt(899999)).toString();
    final timestamp = DateTime.now();
    DocumentReference ref = await Firestore.instance
        .collection('Users')
        .document(userId)
        .collection('Orders')
        .add({
      'amount': total,
      'dateTime': timestamp.toIso8601String(),
      'address': address,
      'phone': phone,
      'products': products
          .map((cp) => {
                'status': cp.status,
                'admin': cp.admin,
                'price': cp.price,
                'prodName': cp.prodName,
                'quantity': cp.quantity,
              })
          .toList(),
    }).then((docRef) {
      docRef.updateData({
        'id': id
      });
      return docRef;
    });
    _orders.insert(
        0,
        OrderItem(
            id: id,
            amount: total,
            dateTime: timestamp,
            products: products,
            address: address,
            phone: phone));
    notifyListeners();
    return OrderItem(
        id: id,
        amount: total,
        dateTime: timestamp,
        products: products,
        address: address,
        phone: phone);
  }
}
