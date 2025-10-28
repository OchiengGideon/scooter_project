// lib/screens/finance_screen.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current balance card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$25.50',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Add funds section
            const Text(
              'Add Funds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _AmountButton(amount: '\$5'),
                _AmountButton(amount: '\$10'),
                _AmountButton(amount: '\$20'),
                _AmountButton(amount: '\$50'),
              ],
            ),

            const SizedBox(height: 24),

            // Add payment method button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Integrate payment method flow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Payment Method'),
              ),
            ),

            const SizedBox(height: 24),

            // Transaction history section
            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: const [
                  _TransactionItem(
                    date: 'Oct 15, 2023',
                    description: 'Ride Payment',
                    amount: '-\$2.50',
                  ),
                  _TransactionItem(
                    date: 'Oct 14, 2023',
                    description: 'Wallet Top-up',
                    amount: '+\$20.00',
                  ),
                  _TransactionItem(
                    date: 'Oct 12, 2023',
                    description: 'Ride Payment',
                    amount: '-\$3.10',
                  ),
                  _TransactionItem(
                    date: 'Oct 10, 2023',
                    description: 'Wallet Top-up',
                    amount: '+\$10.00',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountButton extends StatelessWidget {
  final String amount;
  const _AmountButton({required this.amount});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // TODO: Handle adding funds
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(amount),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String date;
  final String description;
  final String amount;

  const _TransactionItem({
    required this.date,
    required this.description,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount.startsWith('+');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(description),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPositive ? AppColors.success : AppColors.error,
          ),
        ),
      ),
    );
  }
}
