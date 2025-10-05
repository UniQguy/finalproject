import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Manages user's virtual wallet balance with add, deduct, credit,
/// and persistence using Firebase Firestore.
class WalletProvider extends ChangeNotifier {
  static const double initialBalance = 100000.0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  double _balance = initialBalance;

  /// Current wallet balance getter
  double get balance => _balance;

  WalletProvider({required this.userId}) {
    if (userId.isNotEmpty) {
      _loadBalance();
    }
  }

  /// Loads wallet balance from Firestore on startup or user change.
  Future<void> _loadBalance() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('walletBalance')) {
          final wb = data['walletBalance'];
          if (wb is num) {
            _balance = wb.toDouble();
            notifyListeners();
            return;
          }
        }
      }
      // If no data or invalid, set default and save it
      await _saveBalance(initialBalance);
      _balance = initialBalance;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading wallet balance: $e');
      }
    }
  }

  /// Saves the wallet balance to Firestore.
  Future<void> _saveBalance(double balance) async {
    if (userId.isEmpty) return;
    try {
      await _firestore.collection('users').doc(userId).set({
        'walletBalance': balance,
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving wallet balance: $e');
      }
    }
  }

  /// Adds given amount to wallet balance if positive, persists change.
  Future<void> credit(double amount) async {
    if (amount <= 0) return;
    _balance += amount;
    notifyListeners();
    await _saveBalance(_balance);
  }

  /// Deducts given amount from balance if sufficient funds exist.
  ///
  /// Returns true if deduction succeeded, false if balance insufficient or invalid amount.
  Future<bool> deduct(double amount) async {
    if (amount <= 0 || amount > _balance) return false;
    _balance -= amount;
    notifyListeners();
    await _saveBalance(_balance);
    return true;
  }

  /// Resets wallet balance to initial default value and persists change.
  Future<void> reset() async {
    _balance = initialBalance;
    notifyListeners();
    await _saveBalance(_balance);
  }
}
