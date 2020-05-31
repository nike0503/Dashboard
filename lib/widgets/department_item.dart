import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/department.dart';
import '../screens/categories_overview_screen.dart';

class DepartmentItem extends StatelessWidget {
 
  void selectDepartment(BuildContext ctx, String id) {
    Navigator.of(ctx).pushNamed(
      CategoryOverviewScreen.routeName,
      arguments: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final department = Provider.of<Department>(context);
    return InkWell(
      onTap: () {
        selectDepartment(context, department.id);
      },
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Text(
          department.name,
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
