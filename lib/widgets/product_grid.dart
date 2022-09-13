import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavorite;

  ProductsGrid(this.showOnlyFavorite);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context); // listen from provider
    final products =
        showOnlyFavorite ? productData.favoriteItems : productData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        // create: (ctx) => products[index],
        value: products[index],
        child: ProductItem(
            // products[index].id,
            // products[index].title,
            // products[index].imageUrl,
            ),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //that 2 colums
        childAspectRatio: 3 / 2, // mean taller than wide
        crossAxisSpacing: 10, // width spacing between horizontal
        mainAxisSpacing: 10, // width spacing between vertical
      ),
    );
  }
}
