import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                      onPressed: curUser == null
                          ? () {
                              Scaffold.of(context).hideCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Login to add items to cart',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : () {
                              cart.addCartElement(
                                  curUser.email, loadedProduct.name);
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
                                      cart.removeSingleItem(
                                          curUser.email, loadedProduct.name);
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: (MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height) *
                  0.45,
              width: double.infinity,
              child: loadedProduct.imageUrl == '' ? Text('No Image') : CachedNetworkImage(
                imageUrl: loadedProduct.imageUrl,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                placeholder: (context, url) => Center(
                  child: SizedBox(
                      height: 35,
                      width: 35,
                      child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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
                    '₹${loadedProduct.price}',
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
              child:
                  Text(loadedProduct.isAvailable ? 'Available' : 'Out of Stock',
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 20,
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
