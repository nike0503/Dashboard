import 'package:Dashboard/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import './login_screen.dart';
import '../providers/orders.dart';
import '../providers/sign_in.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final auth = Provider.of<Auth>(context);
    final curUser = auth.curUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      drawer: AppDrawer(),
      body: Column(
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
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
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
                        : () {
                            _addOrder(context, cart);
                          },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItem(
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].name,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _addOrder(BuildContext ctx, Cart cart) {
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) {
        return OrderForm(cart: cart);
      },
    );
  }
}

class OrderForm extends StatefulWidget {
  const OrderForm({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
        child: ListView(
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
              child: OrderButton(
                cart: widget.cart,
                address: _addressController.text,
                phone: _phoneController.text,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton(
      {Key key,
      @required this.cart,
      @required this.address,
      @required this.phone})
      : super(key: key);

  final Cart cart;
  final String address;
  final String phone;

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
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
