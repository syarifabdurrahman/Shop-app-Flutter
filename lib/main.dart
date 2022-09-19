import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/screens/splash_screen.dart';

import '../providers/auth.dart';
import '../screens/auth_screen.dart';
import '../screens/edit_product_screen.dart';
import '../screens/order_screen.dart';
import '../screens/user_product_screen.dart';
import '../providers/orders.dart';
import '../providers/products_provider.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/products_overview_screen.dart';

void main(List<String> args) {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products(
              '',
              [],
              '',
            ),
            update: (ctx, auth, previousProduct) => Products(
              auth.token ?? '',
              previousProduct == null ? [] : previousProduct.items,
              auth.userId ?? '',
            ),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders(
              '',
              '',
              [],
            ),
            update: (ctx, auth, previousOrder) => Orders(
                auth.token ?? '',
                auth.userId ?? '',
                previousOrder == null ? [] : previousOrder.orders),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ShopApp',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.redAccent,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                    TargetPlatform.iOS: CustomPageTransitionBuilder(),
                  },
                )),
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScren.routeName: (ctx) => ProductDetailScren(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrderScreen.routeName: (ctx) => OrderScreen(),
              UserProductScreen.routeName: (ctx) => UserProductScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
      ),
      body: Center(
        child: Text('Hola'),
      ),
    );
  }
}
