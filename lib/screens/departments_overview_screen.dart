import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/departments.dart';
import '../providers/cart.dart';
import '../widgets/department_item.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import './cart_screen.dart';

class DepartmentOverviewScreen extends StatefulWidget {
  @override
  _DepartmentOverviewScreenState createState() =>
      _DepartmentOverviewScreenState();
}

class _DepartmentOverviewScreenState extends State<DepartmentOverviewScreen> {
  var _isLoading = false;
  var _isInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Departments>(context).getData().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final departmentData = Provider.of<Departments>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Departments'),
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              itemCount: departmentData.departments.length,
              padding: const EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                  value: departmentData.departments[i],
                  child: DepartmentItem()),
            ),
      drawer: AppDrawer(),
    );
  }
}
