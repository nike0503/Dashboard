import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/products_overview_screen.dart';
import '../providers/category.dart';

class CategoryItem extends StatelessWidget {
  final deptId;

  CategoryItem(this.deptId);

  void selectCategory(BuildContext ctx, String catId, deptId) {
    Navigator.of(ctx).pushNamed(
      ProductOverviewScreen.routeName,
      arguments: [catId, deptId],
    );
  }


  @override
  Widget build(BuildContext context) {
    final category = Provider.of<Category>(context, listen: false);
    return InkWell(
      onTap: () {
        selectCategory(context, category.id, deptId);
      },
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Text(
          category.name,
          style: Theme.of(context).textTheme.title,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.7),
              Colors.red,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}