import 'package:Dashboard/providers/departments.dart';
import 'package:Dashboard/providers/product.dart';
import 'package:Dashboard/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
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
  var _isLoading = true;
  var isEmpty = false;
  List<OrderProd> _products = [];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final curUser = auth.curUser;
    final dept = Provider.of<Departments>(context);
    final cart = Provider.of<Cart>(context);
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(
        message: 'Please Wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    List<OrderProd> prods = [];
    if (cart.products.length == 0) {
      _products = [];
      setState(() {
        _isLoading = false;
        isEmpty = true;
      });
    } else {
      setState(() {
        isEmpty = false;
      });
      for (int i = 0; i < cart.products.length; i++) {
        if(cart.products.length == 0) {
          break;
        }
        dept
            .getProdById(
                cart.products[i].prodName)
            .then((prod) {
          prods.add(OrderProd(
              status: 'pending',
              admin: prod.adminName,
              prodName: prod.name,
              price: prod.price,
              quantity: cart.products[i].quantity));
        }).then((_) {
          if (this.mounted) {
            setState(() {
              _products = prods;
              _isLoading = false;
            });
          }
        });
      }
    }
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
                              style: TextStyle(fontSize: 22),
                            ),
                            Spacer(),
                            Chip(
                              label: FittedBox(
                                child: Text(
                                  '₹${cart.totalAmount(_products).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .title
                                        .color,
                                  ),
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            //OrderButton(cart: cart)
                            FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              child: Text(
                                'ORDER NOW',
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: curUser == null
                                  ? () {
                                      Navigator.of(context)
                                          .pushNamed(LoginScreen.routeName);
                                    }
                                  : cart.products.length == 0
                                      ? () {}
                                      : () async {
                                          pr.show();
                                          List<Product> errProd = [];
                                          for (int i = 0;
                                              i < cart.products.length;
                                              i++) {
                                            if(cart.products.length == 0) {
                                              break;
                                            }
                                            Product prod =
                                                await dept.getProdById(
                                                    cart.products[i].prodName);
                                            if (cart.products[i].quantity >
                                                prod.quantity) {
                                              errProd.add(prod);
                                            }
                                          }
                                          pr.hide();
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
                    if (isEmpty)
                      Center(
                        child: Text('Cart Empty',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[400])),
                      ),
                    if (!isEmpty)
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _products.length,
                          itemBuilder: (ctx, i) => CartItem(
                            _products[i].prodName,
                            _products[i].price,
                            _products[i].quantity,
                          ),
                        ),
                      )
                  ],
                ),
    );
  }
}
