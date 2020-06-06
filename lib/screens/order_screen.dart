import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../providers/sign_in.dart';
import '../providers/cart.dart';
import './cart_screen.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    final auth = Provider.of<Auth>(context);
    final curUser = auth.curUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
         actions: <Widget>[
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: curUser == null ? '0' : cart.itemCount.toString(),
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
      body: curUser == null
          ? Center(
              child: Text(
                'Login to view previous orders',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400])
              ),
            )
          : FutureBuilder(
              future: Provider.of<Orders>(context,listen: false)
                  .fetchAndSetOrders(curUser.uid.toString()),
              builder: (ctx, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (dataSnapshot.error != null) {
                    // ...
                    // Do error handling stuff
                    return Center(
                      child: Text('An error occurred!'),
                    );
                  } else {
                    return Consumer<Orders>(
                      builder: (ctx, orderData, child) => ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                      ),
                    );
                  }
                }
              },
            ),
    );
  }
}
