import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/departments.dart';
import '../widgets/product_item.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import './cart_screen.dart';

class ProductOverviewScreen extends StatelessWidget {
  static const routeName = '/products';

  Widget build(BuildContext context) {
    final ids = ModalRoute.of(context).settings.arguments as List;
    final catId = ids[0];
    final deptId = ids[1];
    final category = Provider.of<Departments>(context)
        .departments
        .firstWhere((dept) => deptId == dept.id)
        .categories
        .firstWhere((cat) => cat.id == catId);
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
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
      body: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: category.products.length,
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: category.products[i],
                child: ProductItem(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
