import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/auth.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/screen/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentProduct = Provider.of<Product>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailsScreen.routeName,
                arguments: currentProduct.id);
          },
          child: Hero(
            tag: currentProduct.id,
            child: FadeInImage(
              placeholder: AssetImage(
                "assets/images/product-placeholder.png",
              ),
              image: NetworkImage(
                currentProduct.imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (ctx, value, Widget? child) => IconButton(
              icon: Icon(
                value.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                currentProduct.toggleFavoriteStatus(
                  authProvider.token,
                  authProvider.userId,
                  currentProduct.id,
                );
              },
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart_rounded),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cartProvider.addItem(
                currentProduct.id,
                currentProduct.price,
                currentProduct.title,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "Added item to cart",
                ),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: "UNDO",
                  onPressed: () {
                    cartProvider.removeSingleItem(currentProduct.id);
                  },
                ),
              ));
            },
          ),
          backgroundColor: Colors.black87,
          title: Text(
            currentProduct.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
