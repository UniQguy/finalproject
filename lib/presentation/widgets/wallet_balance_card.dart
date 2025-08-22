import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/providers/wallet_provider.dart';


class WalletBalanceCard extends StatelessWidget {
  final double scale;

  const WalletBalanceCard({Key? key, required this.scale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletBalance = context.watch<WalletProvider>().balance;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 20 * scale,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.7),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, size: 42, color: Colors.white),
          SizedBox(width: 20 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Wallet Balance",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "₹${walletBalance.toStringAsFixed(2)}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28 * scale,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
