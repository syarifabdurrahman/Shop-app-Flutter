import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA97MasthOwI52kzyn1TeSde3jRn3v1daU');
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

      final resonseData = json.decode(response.body);
      if (resonseData['error'] != null) {
        throw HttpException(resonseData['error']['message']);
      }

      _token = resonseData['idToken'] as String;
      _userId = resonseData['localId'] as String;
      _expiryDate = DateTime.now().add(
        Duration(minutes: int.parse(resonseData['expiresIn'])),
      );
      autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate?.toIso8601String(),
        'refreshToken': resonseData['refreshToken'],
      });
      prefs.setString('userData', userData);
      keepLoggedIn();

      print(prefs.getString('userData'));
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<void> keepLoggedIn() async {
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), tryAutoLogin);
  }

  Future<bool> tryAutoLogin() async {
    // this not called\
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData = prefs.getString('userData');
    final userData = json.decode(extractedUserData!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']);

    if (expiryDate.isAfter(DateTime.now())) {
      return refreshToken();
    }

    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;

    notifyListeners();

    print(_token);
    print(_userId);

    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<bool> refreshToken() async {
    // POST HTTP REQUEST
    final url = Uri.parse(
        'https://securetoken.googleapis.com/v1/token?key=AIzaSyA97MasthOwI52kzyn1TeSde3jRn3v1daU');

    final prefs = await SharedPreferences.getInstance();
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'grant_type': 'refresh_token',
            'refresh_token': extractedUserData['refreshToken'],
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        return false;
      }
      _token = responseData['id_token'];
      _userId = responseData['user_id'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expires_in'],
          ),
        ),
      );
      notifyListeners();

      // STORE DATA IN SHARED PREFERENCES
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);

      keepLoggedIn();
      return true;
    } catch (error) {
      return false;
    }
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inMinutes;
    _authTimer = Timer(Duration(seconds: timeToExpiry!), logout);
  }
}
