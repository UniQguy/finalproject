import 'package:flutter/foundation.dart';

/// Manages user's virtual wallet balance with deposit and withdrawal operations.
class WalletProvider extends ChangeNotifier {
  /// Initial wallet balance for new users (₹100,000).
  static const double initialBalance = 100000.0;

  double _balance = initialBalance;

  /// Returns the current wallet balance.
  double get balance => _balance;

  WalletProvider();

  /// Deposits the given [amount] into wallet.
  ///
  /// Does nothing if [amount] is non-positive.
  void deposit(double amount) {
    if (amount <= 0) return;
    _balance += amount;
    notifyListeners();
  }

  /// Withdraws the given [amount] from wallet if sufficient balance is available.
  ///
  /// Returns `true` if the withdrawal succeeded, `false` otherwise.
  bool withdraw(double amount) {
    if (amount <= 0 || amount > _balance) return false;
    _balance -= amount;
    notifyListeners();
    return true;
  }

  /// Resets wallet balance to initial default value.
  void resetWallet() {
    _balance = initialBalance;
    notifyListeners();
  }
}
