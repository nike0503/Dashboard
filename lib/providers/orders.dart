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
    print(userId);
    final List<OrderItem> loadedOrders = [];
    List _orderList = await Firestore.instance
        .collection('Orders')
        .document(userId)
        .collection('orders')
        .getDocuments()
        .then((snap) => snap.documents);
    print(_orderList[0]['amount']);
    if(_orderList == null) {
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
                id: item['id'],
                name: item['name'],
                quantity: item['quantity'],
                price: item['title'],
              ),
            )
            .toList(),
        dateTime: DateTime.parse(_orderList[i]['dateTime']),
      ));
    }
    _orders = loadedOrders.reversed.toList();

    notifyListeners();
  }

  Future<void> addOrder(
    List<CartItem> cartProducts,
    int total,
    String userId,
    String address,
    String phone,
  ) async {
    final timestamp = DateTime.now();
    DocumentReference ref = await Firestore.instance
        .collection('Orders')
        .document(userId)
        .collection('orders')
        .add({
      'amount': total,
      'dateTime': timestamp.toIso8601String(),
      'address': address,
      'phone': phone,
      'products': cartProducts
          .map((cp) => {
                'id': cp.id,
                'name': cp.name,
                'price': cp.price,
                'quantity': cp.quantity,
              })
          .toList(),
    });
    _orders.insert(
        0,
        OrderItem(
          id: ref.documentID,
          amount: total,
          dateTime: timestamp,
          products: cartProducts,
          address: address,
          phone: phone
        ));
    notifyListeners();
  }
}
