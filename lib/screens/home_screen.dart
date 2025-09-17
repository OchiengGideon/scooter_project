import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/balance_card.dart';
import '../widgets/scan_button.dart';
import '../widgets/hub_card.dart';
import '../widgets/ride_history_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data - in a real app, this would come from an API or database
  final double userBalance = 25.50;
  final bool isRiding = false;
  final List<Map<String, dynamic>> hubs = [
    {
      'name': 'Main Campus Hub',
      'availableScooters': 5,
      'distance': '0.2 km',
    },
    {
      'name': 'Library Hub',
      'availableScooters': 3,
      'distance': '0.5 km',
    },
    {
      'name': 'Sports Complex Hub',
      'availableScooters': 7,
      'distance': '1.2 km',
    },
  ];

  final List<Map<String, dynamic>> recentRides = [
    {
      'date': 'Today, 10:30 AM',
      'distance': '2.3 km',
      'cost': '\$2.30',
    },
    {
      'date': 'Yesterday, 4:15 PM',
      'distance': '1.7 km',
      'cost': '\$1.70',
    },
    {
      'date': 'Oct 12, 2:45 PM',
      'distance': '3.1 km',
      'cost': '\$3.10',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Scooter Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to profile screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Card
            BalanceCard(balance: userBalance),

            SizedBox(height: 24),

            // Scan to Unlock Button
            ScanButton(
              onTap: () {
                // For now, show a dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Scan Feature'),
                    content: Text('QR scanning will be implemented in the next steps.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 24),

            // Active Ride Panel (conditional)
            if (isRiding) ...[
              _buildActiveRidePanel(),
              SizedBox(height: 24),
            ],

            // Scooter Hub Availability
            Text(
              'Nearby Hubs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 12),
            ...hubs.map((hub) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: HubCard(
                name: hub['name'],
                availableScooters: hub['availableScooters'],
                distance: hub['distance'],
              ),
            )).toList(),

            SizedBox(height: 24),

            // Ride History Preview
            RideHistoryPreview(rides: recentRides),

            SizedBox(height: 16),

            // Promotions Banner
            _buildPromotionsBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRidePanel() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.electric_scooter,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Active Ride',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '1.2 km',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Fare',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '\$1.20',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // End ride functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('End Ride'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionsBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9F1C).withOpacity(0.8), Color(0xFFFF9F1C)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Get 20% off your next ride with code: CAMPUS20',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}