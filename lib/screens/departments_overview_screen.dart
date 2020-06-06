import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../providers/departments.dart';
import '../providers/cart.dart';
import '../providers/sign_in.dart';
import '../widgets/department_item.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import './cart_screen.dart';

class DepartmentOverviewScreen extends StatefulWidget {
  static const routeName = '/department-names';
  @override
  _DepartmentOverviewScreenState createState() =>
      _DepartmentOverviewScreenState();
}

class _DepartmentOverviewScreenState extends State<DepartmentOverviewScreen> {
  var _isLoading = false;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 3), () {
      completer.complete();
    });

    setState(() {
      _isLoading = true;
    });

    Provider.of<Departments>(context).getDepts().then((_) {
      setState(() {
        _isLoading = false;
      });
    });

    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: const Text('Refresh complete'),
          action: SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              })));
    });
  }

  @override
  Widget build(BuildContext context) {
    final dept = Provider.of<Departments>(context);
    final curUser = Provider.of<Auth>(context).curUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Departments'),
        actions: <Widget>[
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: curUser == null ? '0' : cart.itemCount.toString(),
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
      backgroundColor: Colors.white54,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : LiquidPullToRefresh(
              color: Colors.teal,
              onRefresh: _handleRefresh,
              showChildOpacityTransition: false,
              child: GridView.builder(
                itemCount: dept.departments.length,
                padding: const EdgeInsets.all(10.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 5 / 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                    value: dept.departments[i], child: DepartmentItem()),
              ),
            ),
      drawer: AppDrawer(),
    );
  }
}
