import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import './orders.dart';

class CartItem {
  final String prodName;
  int quantity;

  CartItem({
    @required this.prodName,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  List<CartItem> _products = [];
  int get itemCount {
    return _products.length;
  }

  List<CartItem> get products {
    return [..._products];
  }

  int totalAmount(List<OrderProd> products) {
    var total = 0;
    for (int i = 0; i < products.length; i++) {
      total += products[i].price * products[i].quantity;
    }
    return total;
  }

  Future<void> addCartElement(String userId, String prodName) async {
    DocumentSnapshot ref = await Firestore.instance
        .collection('Users')
        .document(userId)
        .collection('Cart')
        .document(prodName)
        .get();
    if (ref == null || !ref.exists) {
      _products.add(CartItem(quantity: 1, prodName: prodName));
      notifyListeners();
      Firestore.instance
          .collection('Users')
          .document(userId)
          .collection('Cart')
          .document(prodName)
          .setData({
        'prodName': prodName,
        'quantity': 1,
      });
    } else {
      CartItem prod =
          _products.firstWhere((prod) => prod.prodName == prodName);
      _products[_products.indexOf(prod)].quantity += 1;
      notifyListeners();
      await Firestore.instance
          .collection('Users')
          .document(userId)
          .collection('Cart')
          .document(prodName)
          .updateData({
        'quantity': ref.data['quantity'] + 1,
      });
    }
    notifyListeners();
  }

  Future<void> getCart(String userId) async {
    List<CartItem> _loadedItems = [];
    List _itemList = await Firestore.instance
        .collection('Users')
        .document(userId)
        .collection('Cart')
        .getDocuments()
        .then((snap) => snap.documents);
    for (int i = 0; i < _itemList.length; i++) {
      _loadedItems.add(CartItem(
        prodName: _itemList[i]['prodName'],
        quantity: _itemList[i]['quantity'],
      ));
    }
    _products = _loadedItems;
    notifyListeners();
  }

  Future<void> removeItem(String userId, String prodName) async {
    _products.removeWhere((prod) => prod.prodName == prodName);
    notifyListeners();
    await Firestore.instance
        .collection('Users')
        .document(userId)
        .collection('Cart')
        .document(prodName)
        .delete();
    notifyListeners();
  }

  Future<void> removeSingleItem(String userId, String prodName) async {
    CartItem prod = _products.firstWhere((prod) => prod.prodName == prodName);
    if (prod == null) {
      return null;
    } else if (prod.quantity > 1) {
      _products[_products.indexOf(prod)].quantity -= 1;
      notifyListeners();
      await Firestore.instance
          .collection('Users')
          .document(userId)
          .collection('Cart')
          .document(prodName)
          .updateData({
        'quantity': prod.quantity - 1,
      });
    } else {
      _products.removeWhere((prod) => prod.prodName == prodName);
      notifyListeners();
      await Firestore.instance
          .collection('Users')
          .document(userId)
          .collection('Cart')
          .document(prodName)
          .delete();
    }
    notifyListeners();
  }

  Future<void> clear(String userId) async {
    _products.clear();
    List docs = await Firestore.instance
        .collection('Users')
        .document(userId)
        .collection('Cart')
        .getDocuments()
        .then((snap) => snap.documents);
    for (int i = 0; i < docs.length; i++) {
      await Firestore.instance
          .collection('Users')
          .document(userId)
          .collection('Cart')
          .document(docs[i].documentID)
          .delete();
    }
    notifyListeners();
  }
}

