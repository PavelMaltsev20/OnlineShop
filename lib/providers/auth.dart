import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/models/constansts.dart';

import '../models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String _token = "";
  DateTime _expiryDate = DateTime.now();
  String _userId = "";
  Timer? _authTimer;

  bool get isAuth {
    return token.isNotEmpty;
  }

  String get token {
    if (_expiryDate.isAfter(DateTime.now()) && _token.isNotEmpty) {
      return _token;
    }
    return "";
  }

  String get userId {
    return _userId;
  }

  Map<String, dynamic> get authKey {
    return {"auth": _token};
  }

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    final Map<String, String> authKey = {"key": "$API_KEY"};
    late final url;
    try {
      // final url = Uri.https(
      //     BASE_DATA_URL, "/products/${editedProduct.id}.json", authParams);
      url = Uri.https(
        "identitytoolkit.googleapis.com",
        "/v1/accounts:$urlSegment",
        authKey,
      );
    } catch (err) {
      throw err;
    }

    // Map<String, Object> params = {
    //   'email': email,
    //   'password': password,
    //   'returnSecureToken': true,
    // };

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(userAuth_sharedPref)) {
      return false;
    }

    final savedData = prefs.getString(userAuth_sharedPref);
    final extractedUserData = json.decode(savedData!) as Map<String, Object>;

    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'].toString());

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    // _token = "";
    // _userId = "";
    // _expiryDate = DateTime.now();
    // if (_authTimer != null) {
    //   _authTimer!.cancel();
    //   _authTimer = null;
    // }
    // notifyListeners();
    // final prefs = await SharedPreferences.getInstance();
    // // prefs.remove('userData');
    // prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
