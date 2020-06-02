import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/sign_in.dart';
import '../providers/orders.dart';
import '../screens/order_placed.dart';

class OrderForm extends StatefulWidget {
  const OrderForm({
    Key key,
    this.cart,
    this.product,
  }) : super(key: key);

  final Cart cart;
  final Product product;

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  int quantity = 1;
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          if (widget.product != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              quantity -= 1;
                            });
                          })),
                  Expanded(
                      child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                  )),
                  Expanded(
                      child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity += 1;
                            });
                          })),
                ],
              ),
            ),
          Container(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white.withOpacity(0.4),
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Address",
                            icon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "The address field cannot be empty";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white.withOpacity(0.4),
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Phone",
                            icon: Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "The phone field cannot be empty";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.product == null
                        ? OrderButtonCart(
                            cart: widget.cart,
                            address: _addressController.text,
                            phone: _phoneController.text,
                          )
                        : OrderButton(
                            product: widget.product,
                            address: _addressController.text,
                            phone: _phoneController.text,
                            quantity: quantity),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButtonCart extends StatefulWidget {
  const OrderButtonCart(
      {Key key,
      @required this.cart,
      @required this.address,
      @required this.phone})
      : super(key: key);

  final Cart cart;
  final String address;
  final String phone;

  @override
  _OrderButtonCartState createState() => _OrderButtonCartState();
}

class _OrderButtonCartState extends State<OrderButtonCart> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final curUser = auth.curUser;
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
                curUser.uid,
                widget.address,
                widget.phone,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
              Navigator.of(context).pushNamed(OrderPlaced.routeName, arguments: widget.cart.totalAmount);
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.product,
    @required this.address,
    @required this.phone,
    @required this.quantity,
  }) : super(key: key);

  final Product product;
  final String address;
  final String phone;
  final int quantity;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final curUser = auth.curUser;
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (widget.product.price * widget.quantity <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                [
                  CartItem(
                      productId: widget.product.id,
                      id: DateTime.now().toString(),
                      name: widget.product.name,
                      quantity: widget.quantity,
                      price: widget.product.price)
                ],
                widget.quantity * widget.product.price,
                curUser.uid,
                widget.address,
                widget.phone,
              );
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).pushNamed(OrderPlaced.routeName, arguments: widget.quantity * widget.product.price);
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
