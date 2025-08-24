import 'package:flutter/foundation.dart';
import '../models/cartitem.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, it) => sum + it.quantity);

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();

  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
  void updateQuantity(int index, int newQuantity) {
    _items[index].quantity = newQuantity;
    notifyListeners();
  }

  double get total => _items.fold(0, (sum, item) => sum + item.price * item.quantity);


}
