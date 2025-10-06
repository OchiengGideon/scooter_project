import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _isScanning = true;
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() {
        _isScanning = false;
      });

      final String? code = barcodes.first.rawValue;
      if (code != null && code != _lastScannedCode) {
        _lastScannedCode = code;
        _processScannedCode(code);
      }
    }
  }

  void _processScannedCode(String code) {
    // Validate the QR code format (should be a scooter ID)
    if (!code.startsWith('SCOOT-')) {
      _showErrorDialog('Invalid QR code. Please scan a valid scooter QR code.');
      return;
    }

    // Start the ride
    _startRide(code);
  }

  Future<void> _startRide(String scooterId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Check if user has sufficient balance
      if (userProvider.user.balance < 1.0) {
        _showErrorDialog('Insufficient balance. Please add funds before starting a ride.');
        return;
      }

      // Start the trip
      await userProvider.startTrip(scooterId);

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scooter $scooterId unlocked! Have a safe ride.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true); // Return true to indicate successful scan
    } catch (error) {
      _showErrorDialog('Failed to start ride: $error');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
              });
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        actions: [
          // Flash toggle button
          IconButton(
            icon: StreamBuilder<bool>(
              stream: cameraController.torchState,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return Icon(Icons.flash_on, color: Colors.yellow);
                } else {
                  return Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
            onPressed: () {
              cameraController.toggleTorch();
            },
          ),
          // Camera switch button
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: () {
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcode,
          ),
          _buildScanOverlay(),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        Container(
          height: 300,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Text(
                  'Align QR code within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Text(
                  'Scan a scooter QR code to start riding',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

extension on MobileScannerController {
  Stream<bool>? get torchState => null;
}