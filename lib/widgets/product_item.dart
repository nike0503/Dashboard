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
            padding: EdgeInsets.all(4),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                //backgroundImage: //=====isme daal de firbase se======,
                //radius: //= accordingly,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: product.imageUrl == "" ? Text('') : Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              title: Text(product.name, style: TextStyle(fontSize: 20),),
              subtitle: product.isAvailable
                  ? Text('Available   ₹${product.price}', style: TextStyle(fontSize: 15),)
                  : Text('Out of stock', style: TextStyle(fontSize: 15),),
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
                            cart.addCartElement(curUser.email,
                                product.name);
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
                                        curUser.email, product.name);
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
