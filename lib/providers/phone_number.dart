import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneNumber with ChangeNotifier {
  int phoneNumber;

  Future<void> getPhoneNo() async {
    phoneNumber = await Firestore.instance
        .collection('Contact')
        .document('Phone No')
        .get()
        .then((snap) => snap['phoneNo']);
    notifyListeners();
  }

  int get phoneNo {
    return phoneNumber;
  }
}
