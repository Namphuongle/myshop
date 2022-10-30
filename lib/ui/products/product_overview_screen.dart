import 'package:flutter/material.dart';
import 'package:myshop/ui/cart/cart_sreen.dart';
import 'package:myshop/ui/products/products_grid.dart';
import 'package:myshop/ui/products/products_manager.dart';

import '../shared/app_drawer.dart';
//import 'product_grid_tile.dart';

import '../cart/cart_manager.dart';
import 'top_right_badge.dart';

import 'package:provider/provider.dart';

enum FilterOptions { favorite, all }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverViewScreenState();
}

class _ProductsOverViewScreenState extends State<ProductsOverviewScreen> {
  final _showOnlyFavorites = ValueNotifier<bool>(false);
  late Future<void> _fetchProducts;
  // var _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts = context.read<ProductsManager>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MyShop'),
          actions: <Widget>[
            buildProductFilterMenu(),
            buildShoppingCarIcon(),
          ],
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future: _fetchProducts,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ValueListenableBuilder<bool>(
                  valueListenable: _showOnlyFavorites,
                  builder: (context, onlyFavorites, child) {
                    return ProductsGrid(onlyFavorites);
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
        ));
  }

  Widget buildShoppingCarIcon() {
    return Consumer<CartManager>(
      builder: (ctx, cartManager, child) {
        return TopRightBadge(
          data: CartManager().productCount,
          child: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
          ),
        );
      },
    );
  }

  Widget buildProductFilterMenu() {
    return PopupMenuButton(
      onSelected: (FilterOptions selectedValue) {
        setState(() {
          if (selectedValue == FilterOptions.favorite) {
            _showOnlyFavorites.value = true;
          } else {
            _showOnlyFavorites.value = false;
          }
        });
      },
      icon: const Icon(
        Icons.more_vert,
      ),
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: FilterOptions.favorite,
          child: Text('Only favorites'),
        ),
        const PopupMenuItem(
          value: FilterOptions.all,
          child: Text('show All'),
        ),
      ],
    );
  }
}
