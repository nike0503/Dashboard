import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../providers/cart.dart';
import '../providers/departments.dart';
import '../providers/sign_in.dart';
import '../widgets/category_item.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import './cart_screen.dart';

class CategoryOverviewScreen extends StatefulWidget {
  static const routeName = '/category-names';

  @override
  _CategoryOverviewScreenState createState() => _CategoryOverviewScreenState();
}

class _CategoryOverviewScreenState extends State<CategoryOverviewScreen> {
  var _isLoading = false;
  var _isInit = true;
  String deptId;

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
      deptId = ModalRoute.of(context).settings.arguments as String;
      Provider.of<Departments>(context).getCats(deptId).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

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

    Provider.of<Departments>(context).getCats(deptId).then((_) {
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
        title:
            Text(dept.departments.firstWhere((dept) => dept.id == deptId).name),
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
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : LiquidPullToRefresh(
              color: Colors.teal,
              showChildOpacityTransition: false,
              onRefresh: _handleRefresh,
              child: GridView.builder(
                  itemCount: dept.categories.length,
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 5 / 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                        value: dept.categories[i],
                        child: CategoryItem(deptId),
                      )),
            ),
    );
  }
}
