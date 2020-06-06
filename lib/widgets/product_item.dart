import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/sign_in.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final curUser = Provider.of<Auth>(context).curUser;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            ProductDetailScreen.routeName,
            arguments: product,
          );
        },
        child: Card(
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                //backgroundImage: //=====isme daal de firbase se======,
                //radius: //= accordingly,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Image.network(
                    product.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              title: Text(product.name),
              subtitle: product.isAvailable
                  ? Text('Available   ₹${product.price}')
                  : Text('Out of stock'),
              trailing: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
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
                            cart.addCartElement(curUser.uid, product.id,
                                product.name, product.price);
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
                                        curUser.uid, product.id);
                                  },
                                ),
                              ),
                            );
                          },
                    color: Theme.of(context).accentColor,
                  ),
//                  Padding(
//                    padding: const EdgeInsets.all(8),//check accordingly
//                    child: Text('\$${product.price}'),
//                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
