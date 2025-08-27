import 'package:flutter/foundation.dart';

/// Manages user's virtual wallet balance with add and deduct operations.
class WalletProvider extends ChangeNotifier {
  static const double initialBalance = 100000.0;

  double _balance = initialBalance;

  /// Current wallet balance getter
  double get balance => _balance;

  WalletProvider();

  /// Adds given amount to wallet balance if positive.
  void add(double amount) {
    if (amount <= 0) return;
    _balance += amount;
    notifyListeners();
  }

  /// Deducts given amount from balance if sufficient funds exist.
  ///
  /// Returns true if deduction succeeded, false if balance insufficient or invalid amount.
  bool deduct(double amount) {
    if (amount <= 0 || amount > _balance) return false;
    _balance -= amount;
    notifyListeners();
    return true;
  }

  /// Resets wallet balance to initial default value.
  void reset() {
    _balance = initialBalance;
    notifyListeners();
  }
}
