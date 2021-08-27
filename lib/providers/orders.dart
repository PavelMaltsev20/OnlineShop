import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

class Order {
  final String id;
  final double amount;
  final List<Cart> products;
  final DateTime dateTime;

  Order({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class OrderProvider with ChangeNotifier {
  List<Order> _ordersList = [];
  final String _authToken;
  final String userId;

  OrderProvider(this._authToken, this.userId, this._ordersList);

  Map<String, String> get authKey {
    return {"auth": _authToken};
  }

  List<Order> get orders {
    return [..._ordersList];
  }

  Future<void> addOrder(List<Cart> cartItems, double total) async {
    final url = Uri.https(
        "fluttertests-aa4ff-default-rtdb.europe-west1.firebasedatabase.app",
        "/orders/$userId.json",
        authKey);

    final timestamp = DateTime.now();

    try {
      final response = await http.post(url,
          body: json.encode({
            "amount": total,
            "dateTime": timestamp.toIso8601String(),
            "product": cartItems
                .map((element) => {
                      "id": element.id,
                      "title": element.title,
                      "quantity": element.quantity,
                      "price": element.price
                    })
                .toList()
          }));

      _ordersList.insert(
          0,
          Order(
            dateTime: timestamp,
            amount: total,
            id: json.decode(response.body)["name"],
            products: cartItems,
          ));

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchFromServer() async {
    final url = Uri.https(
        "fluttertests-aa4ff-default-rtdb.europe-west1.firebasedatabase.app",
        "/orders/$userId.json",
        authKey);

    final response = await http.get(url);
    if (response.body == "null") {
      return;
    }
    final List<Order> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        //Adding new Order to list
        Order(
          id: orderId,
          dateTime: DateTime.parse(orderData["dateTime"].toString()),
          amount: orderData["amount"],
          products: (orderData["product"] as List<dynamic>)
              .map((item) => Cart(
                    id: item["id"],
                    productId: item["id"],
                    title: item["title"],
                    quantity: item["quantity"],
                    price: item["price"],
                  ))
              .toList(),
        ),
      );
    });

    _ordersList = loadedOrders;
    notifyListeners();
  }
}
