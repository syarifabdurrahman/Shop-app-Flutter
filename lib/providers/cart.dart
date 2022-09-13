import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem(
      {required this.id,
      required this.title,
      required this.price,
      required this.quantity,
      required this.imageUrl});
}

class Cart with ChangeNotifier {
  late Map<String, CartItem> _itemsCart = {};

  Map<String, CartItem> get itemsCart {
    return {..._itemsCart};
  }

  int get itemCount {
    return _itemsCart == null ? 0 : _itemsCart.length;
  }

  double get totalAmount {
    var total = 0.0;
    _itemsCart.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title, String imageUrl) {
    if (_itemsCart.containsKey(productId)) {
      _itemsCart.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity + 1,
                imageUrl: existingCartItem.imageUrl,
              ));
    } else {
      _itemsCart.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                price: price,
                quantity: 1,
                imageUrl: imageUrl,
              ));
    }
    notifyListeners();
  }

  void removeItem(String prodId) {
    _itemsCart.remove(prodId);
    notifyListeners();
  }

  void removeSingleItem(String prodId) {
    if (!_itemsCart.containsKey(prodId)) {
      return;
    }

    if (_itemsCart[prodId]!.quantity > 1) {
      _itemsCart.update(
          prodId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity - 1,
              imageUrl: existingCartItem.imageUrl));
    } else {
      _itemsCart.remove(prodId);
    }
    notifyListeners();
  }

  void clear() {
    _itemsCart = {};
    notifyListeners();
  }
}
