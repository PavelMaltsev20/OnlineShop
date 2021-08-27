import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/orders.dart';
import 'package:shopapp/widgets/drawer.dart';
import 'package:shopapp/widgets/odrder_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your orders"),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: Provider.of<OrderProvider>(context, listen: false)
              .fetchFromServer(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                return Center(
                  child: Text("An error occurred!"),
                );
              } else {
                return Consumer<OrderProvider>(
                    builder: (ctx, orderData, child) {
                  if (orderData.orders.isEmpty) {
                    return Center(
                      child: Text("You don't have orders yet"),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, index) => OrderItem(
                        orderData.orders[index],
                      ),
                    );
                  }
                });
              }
            }
          }),
    );
  }
}
