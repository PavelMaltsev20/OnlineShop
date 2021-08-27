import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:shopapp/providers/orders.dart';
import 'package:shopapp/widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = "/cart-screen";

  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Chip(
                      label: Text(
                        "${cart.totalAmount..toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6!
                              .color,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  ElevatedButton(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text("Order now"),
                    onPressed: (cart.totalAmount <= 0 || _isLoading)
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });

                            await Provider.of<OrderProvider>(context,
                                    listen: false)
                                .addOrder(
                              cart.items.values.toList(),
                              cart.totalAmount,
                            );

                            setState(() {
                              _isLoading = false;
                            });
                            cart.clear();
                          },
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemCount: cart.itemCount,
            itemBuilder: (_, index) {
              var currentCartItem = cart.items.values.toList()[index];
              return CartItem(
                  id: currentCartItem.id,
                  productId: cart.items.keys.toList()[index],
                  title: currentCartItem.title,
                  price: currentCartItem.price,
                  quantity: currentCartItem.quantity);
            },
          ))
        ],
      ),
    );
  }
}
