import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/check_out.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/sign_in.dart';
import './cart_screen.dart';
import './login_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final curUser = Provider.of<Auth>(context).curUser;
    final cart = Provider.of<Cart>(context);
    final loadedProduct =
        ModalRoute.of(context).settings.arguments as Product; // is the id!
    return Scaffold(
      bottomNavigationBar: loadedProduct.isAvailable
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Builder(
                  builder: (BuildContext context) {
                    return FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text(
                        'ADD TO CART',
                        style: TextStyle(fontSize: 15),
                      ),
                      onPressed: () {
                        cart.addItem(loadedProduct.id, loadedProduct.price,
                            loadedProduct.name);
                        Scaffold.of(context).hideCurrentSnackBar();
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added item to cart!',
                            ),
                            duration: Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                cart.removeSingleItem(loadedProduct.id);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text(
                    'ORDER NOW',
                    style: TextStyle(fontSize: 15),
                  ),
                  onPressed: curUser == null
                      ? () {
                          Navigator.of(context)
                              .pushNamed(LoginScreen.routeName);
                        }
                      : () {
                          showModalBottomSheet(
                            context: context,
                            builder: (bCtx) {
                              return OrderForm(product: loadedProduct);
                            },
                          );
                        },
                ),
              ],
            )
          : Container(
              child: Text(
                'OUT OF STOCK',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25),
              ),
            ),
      appBar: AppBar(
        title: Text(loadedProduct.name),
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                'https://homepages.cae.wisc.edu/~ece533/images/watch.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                loadedProduct.description,
                softWrap: true,
                style: TextStyle(fontSize: 25),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Price: ',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(
                  width: 40,
                ),
                Chip(
                  label: Text(
                    '\$${loadedProduct.price}',
                    style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.title.color,
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                )
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                loadedProduct.isAvailable ? 'Available' : 'Out of Stock',
                softWrap: true,
                style: TextStyle(fontSize: 20,)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
