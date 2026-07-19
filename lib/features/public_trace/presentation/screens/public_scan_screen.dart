import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PublicScanScreen extends StatefulWidget {
  const PublicScanScreen({super.key});

  @override
  State<PublicScanScreen> createState() => _PublicScanScreenState();
}

class _PublicScanScreenState extends State<PublicScanScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        setState(() => _isProcessing = true);
        
        // Example format: dairytrace://scan/{uuid} or just the uuid
        String token = code;
        if (code.contains('dairytrace://scan/')) {
          token = code.split('dairytrace://scan/').last;
        }

        // Navigate to public batch details screen
        // using push replacement so we don't go back to camera instantly without user action
        if (mounted) {
          context.pushReplacement('/public_batch/$token');
        }
        break; // Process only one
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Point camera at a DairyTrace QR Code on your milk carton',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}
