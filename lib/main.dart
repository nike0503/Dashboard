import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/departments_overview_screen.dart';
import './screens/categories_overview_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/login_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_screen.dart';
import './providers/departments.dart';
import './providers/cart.dart';
import './providers/sign_in.dart';
import './providers/orders.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Departments(),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Orders(),
        )
      ],
      child: MaterialApp(
        title: 'Shop',
        theme: ThemeData(
          primaryColor: Colors.pink,
          accentColor: Colors.amber,
          canvasColor: Color.fromRGBO(255, 254, 229, 1),
          textTheme: ThemeData.light().textTheme.copyWith(
                body1: TextStyle(
                  color: Color.fromRGBO(20, 51, 51, 1),
                ),
                body2: TextStyle(
                  color: Color.fromRGBO(20, 51, 51, 1),
                ),
                title: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        home: DepartmentOverviewScreen(),
        routes: {
          CategoryOverviewScreen.routeName: (ctx) => CategoryOverviewScreen(),
          ProductOverviewScreen.routeName: (ctx) => ProductOverviewScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
        },
      ),
    );
  }
}
