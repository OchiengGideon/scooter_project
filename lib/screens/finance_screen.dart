import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
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
                    SizedBox(height: 8),
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
            SizedBox(height: 24),
            Text(
              'Add Funds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAmountButton('\$5'),
                _buildAmountButton('\$10'),
                _buildAmountButton('\$20'),
                _buildAmountButton('\$50'),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add payment method
                },
                child: Text('Add Payment Method'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTransactionItem('Oct 15, 2023', 'Ride Payment', '-\$2.50'),
                  _buildTransactionItem('Oct 14, 2023', 'Wallet Top-up', '+\$20.00'),
                  _buildTransactionItem('Oct 12, 2023', 'Ride Payment', '-\$3.10'),
                  _buildTransactionItem('Oct 10, 2023', 'Wallet Top-up', '+\$10.00'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountButton(String amount) {
    return OutlinedButton(
      onPressed: () {
        // Add funds
      },
      child: Text(amount),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String date, String description, String amount) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(description),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amount.startsWith('+') ? AppColors.success : AppColors.error,
          ),
        ),
      ),
    );
  }
}