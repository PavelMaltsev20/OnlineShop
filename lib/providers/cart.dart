import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Cart {
  final String id;
  final String productId;
  final String title;
  final double price;
  int quantity;

  Cart(
      {required this.id,
      required this.productId,
      required this.title,
      required this.price,
      required this.quantity});
}

class CartProvider with ChangeNotifier {
  var _items = <String, Cart>{};

  Map<String, Cart> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity * cartItem.price;
    });
    return total;
  }

  void addItem(String id, double price, String title) {
    if (_items.containsKey(id)) {
      _items.update(
          id,
          (oldValue) => Cart(
                id: oldValue.id,
                productId: oldValue.productId,
                title: oldValue.title,
                price: oldValue.price,
                quantity: oldValue.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
        id,
        () => Cart(
            id: DateTime.now().toString(),
            productId: id,
            title: title,
            quantity: 1,
            price: price),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String key) {
    if (!_items.containsKey(key)) {
      return;
    }

    if (_items[key]!.quantity > 1) {
      _items.update(
          key,
          (value) => Cart(
              id: value.id,
              productId: value.productId,
              price: value.price,
              quantity: value.quantity - 1,
              title: value.title));
    } else {
      _items.remove(key);
    }
    notifyListeners();
  }
}
