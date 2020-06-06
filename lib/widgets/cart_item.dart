import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/sign_in.dart';

class CartItem extends StatefulWidget {
  final String productId;
  final int quantity;
  final int price;
  final String name;

  CartItem(
    this.name,
    this.price,
    this.productId,
    this.quantity,
  );

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final curUser = auth.curUser;
    return Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  child: Text('₹${widget.price}'),
                ),
              ),
            ),
            title: Text(widget.name),
            subtitle: Text('Total: ₹${(widget.price * widget.quantity)}'),
            trailing: Container(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: IconButton(
                          icon: Icon(Icons.remove, color: Colors.red,),
                          onPressed: () {
                            Provider.of<Cart>(context).removeSingleItem(curUser.uid,widget.productId);
                          })),
                  Expanded(
                      child: Text(
                    '${widget.quantity}',
                    textAlign: TextAlign.center,
                  )),
                  Expanded(
                      child: IconButton(
                          icon: Icon(Icons.add, color: Colors.green,),
                          onPressed: () {
                            Provider.of<Cart>(context).addCartElement(curUser.uid,widget.productId,widget.name,widget.price);

                          })),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
