import 'dart:async';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/departments.dart';
import '../providers/sign_in.dart';
import '../widgets/product_item.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import './cart_screen.dart';

class ProductOverviewScreen extends StatefulWidget {
  static const routeName = '/products';

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isLoading = false;
  var _isInit = true;
  var ids;
  String catId;
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
      ids = ModalRoute.of(context).settings.arguments as List;
      catId = ids[0];
      deptId = ids[1];
      Provider.of<Departments>(context).getProds(deptId, catId).then((_) {
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

    Provider.of<Departments>(context).getProds(deptId, catId).then((_) {
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

  Widget build(BuildContext context) {
    final dept = Provider.of<Departments>(context);
    final curUser = Provider.of<Auth>(context).curUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(dept.categories.firstWhere((cat) => cat.id == catId).name),
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
      drawer: AppDrawer(),
      backgroundColor: Colors.white54,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                SizedBox(height: 10),
                Expanded(
                  child: LiquidPullToRefresh(
                    onRefresh: _handleRefresh,
                    color: Colors.teal,
                    showChildOpacityTransition: false,
                    child: ListView.builder(
                      itemCount: dept.products.length,
                      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                        value: dept.products[i],
                        child: ProductItem(),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
