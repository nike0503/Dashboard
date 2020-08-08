import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../screens/product_detail_screen.dart';
import '../screens/departments_overview_screen.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/sign_in.dart';
import '../providers/orders.dart';
import '../providers/phone_number.dart';
import '../providers/departments.dart';

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

  @override
  void initState() {
    super.initState();
  }

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
                          onPressed: quantity > 1
                              ? () {
                                  setState(() {
                                    quantity -= 1;
                                  });
                                }
                              : () {})),
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
                            formKey: _formKey,
                            cart: widget.cart,
                            address: _addressController.text,
                            phone: _phoneController.text,
                          )
                        : OrderButton(
                            formKey: _formKey,
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
      @required this.formKey,
      @required this.cart,
      @required this.address,
      @required this.phone})
      : super(key: key);

  final GlobalKey<FormState> formKey;
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
    final phone = Provider.of<PhoneNumber>(context).phoneNumber;
    final auth = Provider.of<Auth>(context);
    final curUser = auth.curUser;
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (_isLoading)
          ? null
          : () async {
              if (!widget.formKey.currentState.validate()) {
                return;
              }
              setState(() {
                _isLoading = true;
              });
              List<OrderProd> prods = [];
              for (int i = 0; i < widget.cart.products.length; i++) {
                var product = await Provider.of<Departments>(context)
                    .getProdById(widget.cart.products[i].prodName);
                prods.add(OrderProd(
                  status: 'pending',
                  admin: product.adminName,
                  prodName: product.name,
                  price: product.price,
                  quantity: widget.cart.products[i].quantity,
                ));
              }
              var order =
                  await Provider.of<Orders>(context, listen: false).addOrder(
                prods,
                widget.cart.totalAmount(prods),
                curUser.email,
                widget.address,
                widget.phone,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear(curUser.email);
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text("Order Placed"),
                      content: Text(
                          "Your order ID is ${order.id}. Pay ₹${order.amount} to $phone and send a screenshot to this number along with your email and  order ID, your contact ${widget.phone}"),
                      actions: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            Clipboard.setData(
                                new ClipboardData(text: "${order.id}"));
                          },
                          child: Text('Copy ID'),
                        ),
                        MaterialButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                DepartmentOverviewScreen.routeName,
                                ModalRoute.withName('/'));
                          },
                          child: Text('Okay'),
                        ),
                      ],
                    );
                  });
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.formKey,
    @required this.product,
    @required this.address,
    @required this.phone,
    @required this.quantity,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
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
    final phone = Provider.of<PhoneNumber>(context).phoneNumber;
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (_isLoading)
          ? null
          : () async {
              if (!widget.formKey.currentState.validate()) {
                return;
              }
              if (widget.quantity > widget.product.quantity) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text('Error!'),
                      content: Text(
                          'Quantity entered for product ${widget.product.name} not available'),
                      actions: <Widget>[
                        MaterialButton(
                          onPressed: () => Navigator.popUntil(
                              context,
                              ModalRoute.withName(
                                  ProductDetailScreen.routeName)),
                          child: Text('Okay'),
                        )
                      ],
                    );
                  },
                );
              } else {
                setState(() {
                  _isLoading = true;
                });
                Provider.of<Departments>(context).updateQuant([
                  CartItem(
                    quantity: widget.quantity,
                    prodName: widget.product.name,
                  )
                ]);
                var order =
                    await Provider.of<Orders>(context, listen: false).addOrder(
                  [
                    OrderProd(
                      status: 'pending',
                      admin: widget.product.adminName,
                      prodName: widget.product.name,
                      quantity: widget.quantity,
                      price: widget.product.price,
                    )
                  ],
                  widget.quantity * widget.product.price,
                  curUser.email,
                  widget.address,
                  widget.phone,
                );
                setState(() {
                  _isLoading = false;
                });
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text("Order Placed"),
                        content: Text(
                            "Your order ID is ${order.id}.\nPay ₹${order.amount} to $phone and send a screenshot to this number along with your email and order ID"),
                        actions: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: "${order.id}"));
                            },
                            child: Text('Copy ID'),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  DepartmentOverviewScreen.routeName,
                                  ModalRoute.withName('/'));
                            },
                            child: Text('Okay'),
                          ),
                        ],
                      );
                    });
              }
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
