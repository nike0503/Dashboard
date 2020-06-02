import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import './cart_screen.dart';

class OrderPlaced extends StatelessWidget {
  static const String routeName = '/order-placed';
  @override
  Widget build(BuildContext context) {
    int price = ModalRoute.of(context).settings.arguments as int;
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
         actions: <Widget>[
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Center(
              child: Text(
                'Pay $price at this to 9999999999 via paytm',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 40), 
              ),
            ),
    );
  }
}