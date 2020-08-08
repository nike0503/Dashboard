import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_dialog/progress_dialog.dart';


import '../providers/cart.dart';
import '../providers/sign_in.dart';

class CartItem extends StatefulWidget {
  final int quantity;
  final int price;
  final String name;

  CartItem(
    this.name,
    this.price,
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
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: FittedBox(
                child: Text('₹${widget.price}'),
              ),
            ),
          ),
          title: Text(
            widget.name,
            style: TextStyle(fontSize: 20),
          ),
          subtitle: Text(
            'Total: ₹${(widget.price * widget.quantity)}',
            style: TextStyle(fontSize: 16),
          ),
          trailing: Container(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          pr.show();
                          Provider.of<Cart>(context)
                              .removeSingleItem(curUser.email, widget.name).then((value) => pr.hide());
                        })),
                Expanded(
                    child: Text(
                  '${widget.quantity}',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                )),
                Expanded(
                    child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          pr.show();
                          Provider.of<Cart>(context)
                              .addCartElement(curUser.email, widget.name).then((value) => pr.hide());
                        })),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
