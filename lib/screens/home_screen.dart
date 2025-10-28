// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../utils/constants.dart';
import '../widgets/balance_card.dart';
import '../widgets/hub_card.dart';
import '../widgets/ride_history_preview.dart';
import '../providers/user_provider.dart';
import 'mock_scanner_screen.dart';
import 'active_ride_screen.dart';
import 'code_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Convert trip objects to displayable maps
  List<Map<String, dynamic>> _convertTripsToMap(List<Trip> trips) {
    return trips.map((trip) {
      return {
        'date':
        '${trip.startTime.day}/${trip.startTime.month}/${trip.startTime.year}',
        'distance': '${trip.distance.toStringAsFixed(1)} km',
        'cost': '\$${trip.cost.toStringAsFixed(2)}',
        'scooterId': trip.scooterId,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _getHubs() {
    return [
      {'name': 'Main Campus Hub', 'availableScooters': 5, 'distance': '0.2 km'},
      {'name': 'Library Hub', 'availableScooters': 3, 'distance': '0.5 km'},
      {
        'name': 'Sports Complex Hub',
        'availableScooters': 7,
        'distance': '1.2 km'
      },
    ];
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('View Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSnack(context, 'Profile screen coming soon!');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_outlined),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.pop(context);
                    _logout(context);
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  Future<void> _scanQRCode(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isProfileCompleted) {
      _showSnack(context, 'Please complete your profile before scanning.');
      return;
    }

    if (userProvider.user.balance < 1.0) {
      _showSnack(context, 'Insufficient balance. Please add funds.');
      return;
    }

    final hasActiveRide = userProvider.user.tripHistory.isNotEmpty &&
        userProvider.user.tripHistory.last.endTime == null;
    if (hasActiveRide) {
      _showSnack(context, 'You already have an active ride.');
      return;
    }

    final String? scannedScooterId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MockScannerScreen()),
    );

    if (scannedScooterId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveRideScreen(
            scooterId: scannedScooterId,
            qrCode: 'scanned_qr_${DateTime.now().millisecondsSinceEpoch}',
          ),
        ),
      );
    }
  }

  Future<void> _enterCodeManually(BuildContext context) async {
    final String? enteredCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CodeInputScreen()),
    );

    if (enteredCode != null) {
      await _startRideWithCode(enteredCode, context);
    }
  }

  Future<void> _startRideWithCode(String code, BuildContext context) async {
    try {
      if (code.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(code)) {
        _showSnack(context, 'Invalid code format. Use a 6-digit number.');
        return;
      }

      final scooterId = 'SCOOT-${code.substring(0, 3)}-${code.substring(3)}';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveRideScreen(
            scooterId: scooterId,
            qrCode: 'manual_code_$code',
          ),
        ),
      );
    } catch (e) {
      _showSnack(context, 'Failed to start ride: $e');
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildActiveRidePanel(Trip activeTrip) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.electric_scooter, color: Colors.deepOrange),
              const SizedBox(width: 8),
              Text(
                'Active Ride',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoItem('Scooter ID', activeTrip.scooterId),
              _infoItem(
                'Started At',
                '${activeTrip.startTime.hour}:${activeTrip.startTime.minute.toString().padLeft(2, '0')}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveRideScreen(
                      scooterId: activeTrip.scooterId,
                      qrCode: 'resume_${activeTrip.id}',
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View Active Ride'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style:
        TextStyle(fontSize: 13, color: AppColors.textDark.withOpacity(0.6)),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ],
  );

  Widget _buildPromotionsBanner() {
    return InkWell(
      onTap: () => _showSnack(context, 'Promo applied! 20% off next ride 🎉'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '🎉  Get 20% off your next ride with code: CAMPUS20',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final activeTrip = user.tripHistory.isNotEmpty &&
        user.tripHistory.last.endTime == null
        ? user.tripHistory.last
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scooter Service'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BalanceCard(balance: user.balance),
              const SizedBox(height: 24),

              // Unlock Section
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Unlock a Scooter',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose how you want to unlock your scooter',
                        style: TextStyle(
                            color: AppColors.textDark.withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      FilledButton.icon(
                        onPressed: () => _scanQRCode(context),
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text('Scan QR Code'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: AppColors.textDark.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: () => _enterCodeManually(context),
                        icon: const Icon(Icons.keyboard_alt_outlined),
                        label: const Text('Enter Code Manually'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (activeTrip != null) ...[
                _buildActiveRidePanel(activeTrip),
                const SizedBox(height: 24),
              ],

              Text(
                'Nearby Hubs',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ..._getHubs()
                  .map(
                    (hub) => GestureDetector(
                  onTap: () => _showSnack(context,
                      'Opening ${hub['name']} - ${hub['availableScooters']} scooters available'),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HubCard(
                      name: hub['name'],
                      availableScooters: hub['availableScooters'],
                      distance: hub['distance'],
                    ),
                  ),
                ),
              )
                  .toList(),

              const SizedBox(height: 24),
              RideHistoryPreview(rides: _convertTripsToMap(user.tripHistory)),
              const SizedBox(height: 20),
              _buildPromotionsBanner(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
