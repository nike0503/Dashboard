import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  var orderTitle = '';
  var fullName = '';

  @override
  Widget build(BuildContext context) {
    String name = '';
    for (int i = 0; i < widget.order.products.length - 1; i++) {
      name += '${widget.order.products[i].prodName}, ';
    }
    name +=
        '${widget.order.products[widget.order.products.length - 1].prodName}';
    setState(() {
      fullName = name;
    });
    if (widget.order.products.length < 3) {
      if (widget.order.products.length == 1) {
        setState(() {
          orderTitle = widget.order.products[0].prodName;
        });
      } else if (widget.order.products.length == 2) {
        setState(() {
          orderTitle =
              '${widget.order.products[0].prodName}, ${widget.order.products[1].prodName}';
        });
      }
    } else {
      setState(() {
        orderTitle =
            '${widget.order.products[0].prodName}, ${widget.order.products[1].prodName}, ${widget.order.products[2].prodName.substring(0, 2)}...';
      });
    }
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_expanded)
                    AutoSizeText(
                      '$orderTitle',
                      style: TextStyle(fontSize: 18),
                      maxLines: 2,
                    ),
                  if (_expanded)
                    AutoSizeText(
                      '$fullName',
                      style: TextStyle(fontSize: 18),
                      maxLines: 2,
                    ),
                ],
              ),
              subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy hh:mm')
                          .format(widget.order.dateTime),
                    ),
                  ]),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
          ),
          if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min((widget.order.products.length + 1) * 30.0 + 10, 200),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ListView(children: [
                  ...widget.order.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              prod.prodName,
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prod.quantity}x ₹${prod.price}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                      .toList(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.order.amount}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order ID',
                        style: TextStyle(
                          fontSize: 12,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.order.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ]),
              ),
            )
        ],
      ),
    );
  }
}
