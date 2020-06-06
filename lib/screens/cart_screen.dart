import 'package:Dashboard/providers/departments.dart';
import 'package:Dashboard/providers/product.dart';
import 'package:Dashboard/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../providers/departments.dart';
import '../providers/sign_in.dart';
import '../widgets/cart_item.dart';
import '../widgets/check_out.dart';
import './login_screen.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final auth = Provider.of<Auth>(context);
    final curUser = auth.curUser;
    final dept = Provider.of<Departments>(context);
    // if (curUser != null) {
    //   _isLoading = true;
    //   cart.getCart(curUser.uid).then((_) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   });
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      drawer: AppDrawer(),
      body: curUser == null
          ? Center(
              child: Text('Login to view cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400])),
            )
          : _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(15),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Total',
                              style: TextStyle(fontSize: 20),
                            ),
                            Spacer(),
                            Chip(
                              label: Text(
                                '₹${cart.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .title
                                      .color,
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            //OrderButton(cart: cart)
                            FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              child: Text('ORDER NOW'),
                              onPressed: curUser == null
                                  ? () {
                                      Navigator.of(context)
                                          .pushNamed(LoginScreen.routeName);
                                    }
                                  : cart.products.length == 0
                                      ? () {}
                                      : () async {
                                          List<Product> errProd = [];
                                          for (int i = 0;
                                              i < cart.products.length;
                                              i++) {
                                            Product prod =
                                                await dept.getProdById(
                                                    cart.products[i].productId);
                                            if (cart.products[i].quantity >
                                                prod.quantity) {
                                              errProd.add(prod);
                                            }
                                          }
                                          if (errProd.length != 0) {
                                            String prodNames = '';
                                            for (int i = 0;
                                                i < errProd.length;
                                                i++) {
                                              prodNames +=
                                                  '${errProd[i].name}, ';
                                            }
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  title: Text('Error!'),
                                                  content: Text(
                                                      'Quantity entered for products ${prodNames}not available'),
                                                  actions: <Widget>[
                                                    MaterialButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: Text('Okay'),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            Provider.of<Departments>(context)
                                                .updateQuant(cart.products);
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (bCtx) {
                                                return OrderForm(cart: cart);
                                              },
                                            );
                                          }
                                        },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.products.length,
                        itemBuilder: (ctx, i) => CartItem(
                          cart.products[i].prodName,
                          cart.products[i].price,
                          cart.products[i].productId,
                          cart.products[i].quantity,
                        ),
                      ),
                    )
                  ],
                ),
    );
  }
}
