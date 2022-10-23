import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../orders/orders_screen.dart';
import '../orders/order_manager.dart';

import 'cart_item_card.dart';
import 'cart_manager.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartManager>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('your Cart'),
      ),
      body: Column(
        children: <Widget>[
          buildCartSummary(cart, context),
          const SizedBox(height: 10),
          Expanded(
            child: buildCartDetails(cart),
          )
        ],
      ),
    );
  }

  Widget buildCartDetails(CartManager cart) {
    return ListView(
      children: cart.productEntries
          .map(
            (entry) => CartItemCard(
              productId: entry.key,
              cardItem: entry.value,
            ),
          )
          .toList(),
    );
  }

  Widget buildCartSummary(CartManager cart, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Total',
              style: TextStyle(fontSize: 20),
            ),
            const Spacer(),
            Chip(
              label: Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.headline6?.color,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            TextButton(
              onPressed: cart.totalAmount <= 0
                  ? null
                  : () {
                      context
                          .read<OrdersManager>()
                          .addOrder(cart.product, cart.totalAmount);

                      final snackBar = SnackBar(
                        // ignore: prefer_const_constructors
                        content: Text(
                          'Thanh toán thành công!!!',
                          textAlign: TextAlign.center,
                        ),
                        action: SnackBarAction(
                            label: 'Sang trang order',
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(OrderScreen.routeName);
                            }),
                      );
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                    },
              style: TextButton.styleFrom(
                  textStyle: TextStyle(color: Theme.of(context).primaryColor)),
              child: const Text('ORDER NOW'),
            )
          ],
        ),
      ),
    );
  }
}
