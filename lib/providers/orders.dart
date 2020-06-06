import 'package:flutter/material.dart';
import './cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String address;
  final String phone;
  final String id;
  final int amount;
  final List<CartItem> products;
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
        id: _orderList[i].documentID,
        amount: _orderList[i]['amount'],
        address: _orderList[i]['address'],
        phone: _orderList[i]['phone'],
        products: (_orderList[i]['products'] as List<dynamic>)
            .map(
              (item) => CartItem(
                prodName: item['prodName'],
                price: item['price'],
                productId: item['productId'],
                quantity: item['quantity'],
              ),
            )
            .toList(),
        dateTime: DateTime.parse(_orderList[i]['dateTime']),
      ));
    }
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<OrderItem> addOrder(
    List<CartItem> cartProducts,
    int total,
    String userId,
    String address,
    String phone,
  ) async {
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
      'products': cartProducts
          .map((cp) => {
                'price': cp.price,
                'prodName': cp.prodName,
                'productId': cp.productId,
                'quantity': cp.quantity,
              })
          .toList(),
    }).then((docRef) {
      docRef.updateData({
        'id': docRef.documentID,
      });
      return docRef;
    });
    _orders.insert(
        0,
        OrderItem(
            id: ref.documentID,
            amount: total,
            dateTime: timestamp,
            products: cartProducts,
            address: address,
            phone: phone));
    notifyListeners();
    return OrderItem(
        id: ref.documentID,
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
        address: address,
        phone: phone);
  }
}
