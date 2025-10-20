import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MockScannerScreen extends StatefulWidget {
  const MockScannerScreen({super.key});

  @override
  _MockScannerScreenState createState() => _MockScannerScreenState();
}

class _MockScannerScreenState extends State<MockScannerScreen> {
  bool _isScanning = false;
  final List<String> _mockScooterIds = [
    'SCOOT-001',
    'SCOOT-002',
    'SCOOT-003',
    'SCOOT-004',
    'SCOOT-005'
  ];

  void _simulateScan(String scooterId) {
    setState(() {
      _isScanning = true;
    });

    // Simulate scanning delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context, scooterId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mock Scanner'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mock QR Scanner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Since QR scanning packages are causing compatibility issues, use this mock scanner for development.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 32),

            if (_isScanning) ...[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Simulating scan...'),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Available Scooters:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _mockScooterIds.length,
                  itemBuilder: (context, index) {
                    final scooterId = _mockScooterIds[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.electric_scooter,
                          color: AppColors.primary,
                        ),
                        title: Text(scooterId),
                        subtitle: Text('Tap to simulate scan'),
                        trailing: Icon(Icons.qr_code),
                        onTap: () => _simulateScan(scooterId),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}