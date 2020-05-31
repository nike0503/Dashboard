import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sign_in.dart';
import '../screens/order_screen.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final curUser = auth.curUser;
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: curUser != null
                ? Text('Hello ${curUser.displayName}')
                : Text('Welcome'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          Divider(),
          curUser != null
              ? loginLogout('Logout', auth)
              : loginLogout('Login', auth),
        ],
      ),
    );
  }

  Widget loginLogout(String text, Auth auth) {
    return ListTile(
      leading: Icon(Icons.exit_to_app),
      title: Text(text),
      onTap: text == 'Login'
          ? () {
              Navigator.of(context).pushNamed(LoginScreen.routeName);
            }
          : () {
              auth.signOutGoogle();
            },
    );
  }
}
