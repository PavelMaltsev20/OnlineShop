import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/models/constansts.dart';
import 'package:shopapp/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus(
      String token, String userId, String productId) async {
    //Firstly updating ui
    isFavorite = !isFavorite;
    notifyListeners();
    final authToken = {"auth": token};

    //Init url
    final url = Uri.https(
        "fluttertests-aa4ff-default-rtdb.europe-west1.firebasedatabase.app",
        "/userFavorites/$userId/${id}.json",
        authToken);

    try {
      //Then updating server data because it
      //take more time and we use await annotation
      //take more time and we use await annotation
      await http.put(url, body: json.encode(isFavorite));
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw error;
    }
  }
}

class ProductsProvider with ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _userProducts = [];
  final String _authToken;
  final userId;

  ProductsProvider(this._authToken, this.userId, this._allProducts);

  //region Getters
  Map<String, String> get authParams {
    return {"auth": _authToken};
  }

  List<Product> get favoriteItems {
    return _allProducts.where((element) => element.isFavorite).toList();
  }

  List<Product> get getAllProducts {
    return [..._allProducts];
  }

  List<Product> get getUserProducts {
    return [..._userProducts];
  }

  Product getById(String id) {
    return _allProducts.firstWhere((element) => element.id == id);
  }

  //endregion

  Future<void> fetchAllProducts({bool manageProducts = false}) async {
    final List<Product> loadedProducts = [];

    var url = Uri.https(BASE_DATA_URL, PRODUCTS_PATH, authParams);

    try {
      final productResponse = await http.get(url);

      if (productResponse.body == "null") {
        return;
      }
      url = Uri.https(
          "fluttertests-aa4ff-default-rtdb.europe-west1.firebasedatabase.app",
          "/userFavorites/$userId.json",
          authParams);
      final favoriteResponse = await http.get(url);

      final extractedProduct =
          json.decode(productResponse.body) as Map<String, dynamic>;
      var extractedFavorites;
      if (favoriteResponse.body != "null") {
        extractedFavorites =
            json.decode(favoriteResponse.body) as Map<String, dynamic>;
      }
      extractedProduct.forEach((key, value) {
        loadedProducts.add(
          Product(
              id: key.toString(),
              title: value["title"].toString(),
              description: value["description"].toString(),
              price: value["price"],
              imageUrl: value["imageUrl"].toString(),
              isFavorite: extractedFavorites == null
                  ? false
                  : extractedFavorites[key.toString()] ?? false),
        );
      });

      _allProducts = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw ("Called from product disposed $error");
    }
  }

  Future<void> fetchUserProducts() async {
    final userProductsRequest = {
      'auth': _authToken,
      "orderBy": json.encode("creatorId"),
      "equalTo": json.encode("$userId")
    };

    final List<Product> loadedProducts = [];

    var url = Uri.https(
        "fluttertests-aa4ff-default-rtdb.europe-west1.firebasedatabase.app",
        "/products.json",
        userProductsRequest);

    try {
      final productResponse = await http.get(url);

      if (productResponse.body == "null") {
        return;
      }
      url = Uri.https(
          "fluttertests-aa4ff-default-rtdb.europe-west1.firebasedatabase.app",
          "/userFavorites/$userId.json",
          authParams);
      final favoriteResponse = await http.get(url);

      final extractedProduct =
          json.decode(productResponse.body) as Map<String, dynamic>;
      var extractedFavorites;
      if (favoriteResponse.body != "null") {
        extractedFavorites =
            json.decode(favoriteResponse.body) as Map<String, dynamic>;
      }

      extractedProduct.forEach((key, value) {
        loadedProducts.add(
          Product(
              id: key.toString(),
              title: value["title"].toString(),
              description: value["description"].toString(),
              price: value["price"],
              imageUrl: value["imageUrl"].toString(),
              isFavorite: extractedFavorites == null
                  ? false
                  : extractedFavorites[key.toString()] ?? false),
        );
      });

      _userProducts = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    //Initializing url object
    final url = Uri.https(
        "fluttertests-aa4ff-default-rtdb.europe-west1.firebasedatabase.app",
        "/products.json",
        authParams);

    try {
      //Uploading data to server
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title.toString(),
          "description": product.description.toString(),
          "imageUrl": product.imageUrl.toString(),
          "price": product.price,
          "creatorId": userId
        }),
      );

      //Saving data locale
      final newProduct = Product(
          id: json.decode(response.body)["name"],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _allProducts.add(newProduct);
      notifyListeners();
    } catch (error) {
      //Catching exception than may occurred while uploading
      throw error;
    }
  }

  Future<void> updateProduct(Product editedProduct) async {
    final url = Uri.https(
        BASE_DATA_URL, "/products/${editedProduct.id}.json", authParams);

    try {
      //Updating data in server
      await http.patch(url,
          body: json.encode({
            "title": editedProduct.title,
            "description": editedProduct.description,
            "price": editedProduct.price,
            "imageUrl": editedProduct.imageUrl,
            "isFavorite": editedProduct.isFavorite,
          }));

      //Updating data locale
      var index =
          _allProducts.indexWhere((prod) => prod.id == editedProduct.id);
      if (index >= 0) {
        _allProducts[index] = editedProduct;
        notifyListeners();
      } else {
        print("Some error in updateProduct method in ProductProvider.class");
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProduct(String productId) async {
    //Init url
    final url = Uri.https(
        "fluttertests-aa4ff-default-rtdb.europe-west1.firebasedatabase.app",
        "/products/${productId}.json",
        authParams);

    //Fetching old product
    final existingProduct =
        _allProducts.firstWhere((element) => element.id == productId);
    //Removing old product
    _allProducts.removeWhere((element) => element.id == productId);
    notifyListeners();

    //Removing product from server
    final response = await http.delete(url);

    //If removing in server failed, program will restore old product locale
    //In server side we don't need it because delete request failed
    if (response.statusCode >= 400) {
      _allProducts.add(existingProduct);
      throw HttpException("Failed to delete product.\n${response.body}");
    }
    notifyListeners();
  }
}
