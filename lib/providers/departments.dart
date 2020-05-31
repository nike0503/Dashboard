import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './department.dart';
import './category.dart';
import './product.dart';

class Departments with ChangeNotifier {
  List<Department> _departments = [];

  Future<void> getData() async {
    List<Department> _departmentList = [];
    List _departList = await Firestore.instance
        .collection('Departments')
        .getDocuments()
        .then((snap) => snap.documents);
    for (int i = 0; i < _departList.length; i++) {
      List<Category> _categories = [];
      List _catList = await Firestore.instance
          .collection('Departments')
          .document(_departList[i].documentID.toString())
          .collection("Categories")
          .getDocuments()
          .then((snap) => snap.documents);
      for (int j = 0; j < _catList.length; j++) {
        List<Product> _products = [];
        List _prodList = await Firestore.instance
            .collection('Departments')
            .document(_departList[i].documentID.toString())
            .collection("Categories")
            .document(_catList[j].documentID.toString())
            .collection('Products')
            .getDocuments()
            .then((snap) => snap.documents);
        for (int k = 0; k < _prodList.length; k++) {
          _products.add(Product(
              id: _prodList[k]['id'],
              name: _prodList[k]['name'],
              price: _prodList[k]['price'],
              quantity: _prodList[k]['quantity'],
              isAvailable: _prodList[k]['isAvailable']));
        }
        _categories.add(Category(
            id: _catList[j]['id'],
            name: _catList[j]['name'],
            products: _products));
      }
      _departmentList.add(Department(
          id: _departList[i]['id'],
          name: _departList[i]['name'],
          categories: _categories));
    }
    _departments = _departmentList;
    notifyListeners();
  }

  List<Department> get departments {
    return [..._departments];
  }

  List<Category> departCategories(String id) {
    List<Department> department =
        departments.where((dept) => dept.id == id).toList();
    return department[0].categories;
  }

  List<Product> categoryProducts(String deptId, String catId) {
    List<Category> categories = departCategories(deptId);
    List<Category> category =
        categories.where((cat) => cat.name == catId).toList();
    return category[0].products;
  }

  // void addData() {
  //   const url = 'https://shop-f09c8.firebaseio.com/departments.json';
  //   http.post(url, body: json.encode({'name': Department, 'categories': }));
  // }
}
