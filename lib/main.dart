import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/departments_overview_screen.dart';
import './screens/categories_overview_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/login_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/departments.dart';
import './providers/cart.dart';
import './providers/sign_in.dart';
import './providers/orders.dart';
import './providers/phone_number.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        ),
        ChangeNotifierProvider.value(
          value: PhoneNumber(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rahul Enterprises',
        theme: ThemeData(
          primaryColor: Colors.teal,
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
        home: SplashScreen(),
        routes: {
          DepartmentOverviewScreen.routeName: (ctx) =>
              DepartmentOverviewScreen(),
          CategoryOverviewScreen.routeName: (ctx) => CategoryOverviewScreen(),
          ProductOverviewScreen.routeName: (ctx) => ProductOverviewScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
        },
      ),
    );
  }
}
