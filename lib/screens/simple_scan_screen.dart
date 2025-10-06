import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class SimpleScanScreen extends StatefulWidget {
  @override
  _SimpleScanScreenState createState() => _SimpleScanScreenState();
}

class _SimpleScanScreenState extends State<SimpleScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanning = true;
  String? _lastScannedCode;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isScanning) return;

      setState(() {
        _isScanning = false;
      });

      final String? code = scanData.code;
      if (code != null && code != _lastScannedCode) {
        _lastScannedCode = code;
        _processScannedCode(code);
      }
    });
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

      Navigator.pop(context, true);
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
              controller?.resumeCamera();
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
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: AppColors.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Align the QR code within the frame to scan',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}