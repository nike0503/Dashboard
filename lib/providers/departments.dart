import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './department.dart';
import './category.dart';
import './product.dart';
import './cart.dart';

class Departments with ChangeNotifier {
  List<Department> _departments = [];
  List<Category> _categories = [];
  List<Product> _products = [];

  Future<void> getDepts() async {
    List<Department> _departmentList = [];
    List _departList = await Firestore.instance
        .collection('Departments')
        .getDocuments()
        .then((snap) => snap.documents);

    for (int i = 0; i < _departList.length; i++) {
      _departmentList.add(Department(
        name: _departList[i]['name'],
      ));
    }

    _departments = _departmentList;
    notifyListeners();
  }

  Future<void> getCats(String deptName) async {
    List<Category> _categoriesList = [];
    List _catList = await Firestore.instance
        .collection('Departments')
        .document(deptName)
        .collection('Categories')
        .getDocuments()
        .then((snap) => snap.documents);

    for (int i = 0; i < _catList.length; i++) {
      _categoriesList.add(Category(
        name: _catList[i]['name'],
      ));
    }

    _categories = _categoriesList;
    notifyListeners();
  }

  Future<void> getProds(String deptName, String catName) async {
    List<Product> _productsList = [];
    List _prodList = await Firestore.instance
        .collection('Departments')
        .document(deptName)
        .collection("Categories")
        .document(catName)
        .collection('Products')
        .getDocuments()
        .then((snap) => snap.documents);

    for (int i = 0; i < _prodList.length; i++) {
      _productsList.add(Product(
        adminName: _prodList[i]['admin'],
        name: _prodList[i]['name'],
        price: _prodList[i]['price'],
        quantity: _prodList[i]['quantity'],
        isAvailable: _prodList[i]['isAvailable'],
        description: _prodList[i]['description'],
        imageUrl: _prodList[i]['imageUrl'],
      ));
    }

    _products = _productsList;
    notifyListeners();
  }

  Future<Product> getProdById(String name) async {
    Product prod;
    List _departList = await Firestore.instance
        .collection('Departments')
        .getDocuments()
        .then((snap) => snap.documents);
    for (int i = 0; i < _departList.length; i++) {
      List _catList = await Firestore.instance
          .collection('Departments')
          .document(_departList[i].documentID.toString())
          .collection('Categories')
          .getDocuments()
          .then((snap) => snap.documents);
      for (int j = 0; j < _catList.length; j++) {
        List _prodList = await Firestore.instance
            .collection('Departments')
            .document(_departList[i].documentID.toString())
            .collection('Categories')
            .document(_catList[j].documentID.toString())
            .collection('Products')
            .getDocuments()
            .then((snap) => snap.documents);
        for (int k = 0; k < _prodList.length; k++) {
          if (_prodList[k]['name'] == name) {
            prod = Product(
              adminName: _prodList[k]['admin'],
              name: _prodList[k]['name'],
              price: _prodList[k]['price'],
              quantity: _prodList[k]['quantity'],
              isAvailable: _prodList[k]['isAvailable'],
              description: _prodList[k]['description'],
              imageUrl: _prodList[k]['imageUrl'],
            );
          }
        }
      }
    }
    notifyListeners();
    return prod;
  }

  Future<void> updateQuant(List<CartItem> prods) async {
    List _departList = await Firestore.instance
        .collection('Departments')
        .getDocuments()
        .then((snap) => snap.documents);
    for (int l = 0; l < prods.length; l++) {
      for (int i = 0; i < _departList.length; i++) {
        List _catList = await Firestore.instance
            .collection('Departments')
            .document(_departList[i].documentID.toString())
            .collection("Categories")
            .getDocuments()
            .then((snap) => snap.documents);
        for (int j = 0; j < _catList.length; j++) {
          List _prodList = await Firestore.instance
              .collection('Departments')
              .document(_departList[i].documentID.toString())
              .collection("Categories")
              .document(_catList[j].documentID.toString())
              .collection('Products')
              .getDocuments()
              .then((snap) => snap.documents);
          for (int k = 0; k < _prodList.length; k++) {
            if (_prodList[k]['name'] == prods[l].prodName) {
              Firestore.instance
                  .collection('Departments')
                  .document(_departList[i].documentID.toString())
                  .collection("Categories")
                  .document(_catList[j].documentID.toString())
                  .collection('Products')
                  .document(_prodList[k].documentID.toString())
                  .updateData({
                'quantity': _prodList[k]['quantity'] - prods[l].quantity,
                'isAvailable': _prodList[k]['quantity'] - prods[l].quantity != 0
              });
            }
          }
        }
      }
    }
    notifyListeners();
  }

  List<Department> get departments {
    return [..._departments];
  }

  List<Category> get categories {
    return [..._categories];
  }

  List<Product> get products {
    return [..._products];
  }
}
