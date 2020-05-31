import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/departments.dart';
import '../widgets/category_item.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import './cart_screen.dart';


class CategoryOverviewScreen extends StatelessWidget {
  static const routeName = '/category-names';

  @override
  Widget build(BuildContext context) {
    final deptId = ModalRoute.of(context).settings.arguments as String;
    final dept = Provider.of<Departments>(context)
        .departments
        .firstWhere((dept) => dept.id == deptId);
    return Scaffold(
      appBar: AppBar(
        title: Text(dept.name),
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
      body: GridView.builder(
          itemCount: dept.categories.length,
          padding: const EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: dept.categories[i],
                child: CategoryItem(deptId),
              )),
    );
  }
}
