import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CartItem {
  final String prodName;
  final String productId;
  final int price;
  int quantity;

  CartItem({
    @required this.prodName,
    @required this.price,
    @required this.productId,
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

  int get totalAmount {
    var total = 0;
    for (int i = 0; i < _products.length; i++) {
      total += _products[i].price * _products[i].quantity;
    }
    return total;
  }

  Future<void> addCartElement(
      String userId, String productId, String prodName, int price) async {
    DocumentSnapshot ref = await Firestore.instance
        .collection('Users')
        .document(userId)
        .collection('Cart')
        .document(productId)
        .get();
    if (ref == null || !ref.exists) {
      _products.add(CartItem(
          productId: productId, quantity: 1, price: price, prodName: prodName));
      Firestore.instance
          .collection('Users')
          .document(userId)
          .collection('Cart')
          .document(productId)
          .setData({
        'prodName': prodName,
        'productId': productId,
        'quantity': 1,
        'price': price,
      });
    } else {
      CartItem prod =
          _products.firstWhere((prod) => prod.productId == productId);
      _products[_products.indexOf(prod)].quantity += 1;
      await Firestore.instance
          .collection('Users')
          .document(userId)
          .collection('Cart')
          .document(productId)
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
        price: _itemList[i]['price'],
        productId: _itemList[i]['productId'],
        quantity: _itemList[i]['quantity'],
      ));
    }
    _products = _loadedItems;
    notifyListeners();
  }

  Future<void> removeItem(String userId, String productId) async {
    _products.removeWhere((prod) => prod.productId == productId);
    await Firestore.instance
        .collection('Users')
        .document(userId)
        .collection('Cart')
        .document(productId)
        .delete();
    notifyListeners();
  }

  Future<void> removeSingleItem(String userId, String productId) async {
    CartItem prod = _products.firstWhere((prod) => prod.productId == productId);
    if (prod == null) {
      return null;
    } else if (prod.quantity > 1) {
      _products[_products.indexOf(prod)].quantity -= 1;
      await Firestore.instance
          .collection('Users')
          .document(userId)
          .collection('Cart')
          .document(productId)
          .updateData({
        'quantity': prod.quantity - 1,
      });
    } else {
      _products.removeWhere((prod) => prod.productId == productId);
      await Firestore.instance
          .collection('Users')
          .document(userId)
          .collection('Cart')
          .document(productId)
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

// class Cart with ChangeNotifier {
//   Map<String, CartItem> _items = {};

//   Map<String, CartItem> get items {
//     return {..._items};
//   }

//   int get itemCount {
//     return _items.length;
//   }

//   int get totalAmount {
//     var total = 0;
//     _items.forEach((key, cartItem) {
//       Departments().getProdById(cartItem.productId);
//       total += Departments().getProductById().price * cartItem.quantity;
//     });
//     return total;
//   }

//   addItem(
//     String productId,
//   ) {
//     if (_items.containsKey(productId)) {
//       // change quantity...
//       _items.update(
//         productId,
//         (existingCartItem) => CartItem(
//           productId: productId,
//           id: existingCartItem.id,
//           quantity: existingCartItem.quantity + 1,
//         ),
//       );
//     } else {
//       _items.putIfAbsent(
//         productId,
//         () => CartItem(
//           productId: productId,
//           id: DateTime.now().toString(),
//           quantity: 1,
//         ),
//       );
//     }
//     notifyListeners();
//   }

//   void removeItem(String productId) {
//     _items.remove(productId);
//     notifyListeners();
//   }

//   void removeSingleItem(String productId) {
//     if (!_items.containsKey(productId)) {
//       return;
//     }
//     if (_items[productId].quantity > 1) {
//       _items.update(
//           productId,
//           (existingCartItem) => CartItem(
//                 productId: productId,
//                 id: existingCartItem.id,
//                 quantity: existingCartItem.quantity - 1,
//               ));
//     } else {
//       _items.remove(productId);
//     }
//     notifyListeners();
//   }

//   void clear() {
//     _items = {};
//     notifyListeners();
//   }
// }
