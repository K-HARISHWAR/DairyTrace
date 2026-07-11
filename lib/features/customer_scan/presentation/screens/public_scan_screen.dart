import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/services/supabase_service.dart';

class PublicScanScreen extends ConsumerStatefulWidget {
  const PublicScanScreen({super.key});

  @override
  ConsumerState<PublicScanScreen> createState() => _PublicScanScreenState();
}

class _PublicScanScreenState extends ConsumerState<PublicScanScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.contains('dairytrace://scan/')) {
        setState(() => _isProcessing = true);
        final token = code.split('dairytrace://scan/').last;
        
        try {
          final result = await ref.read(supabaseServiceProvider).client.rpc('get_public_batch_trace', params: {'p_qr_token': token});
          
          if (mounted) {
            if (result == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid or unknown QR code')));
              setState(() => _isProcessing = false);
            } else {
              _showResultDialog(result as Map<String, dynamic>);
            }
          }
        } catch (e) {
           if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              setState(() => _isProcessing = false);
           }
        }
        break; // Process only one
      }
    }
  }

  void _showResultDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batch Provenance'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Farm: ${data['farmer_name']}'),
              Text('Batch Code: ${data['batch_code']}'),
              Text('Status: ${data['stage']}'),
              Text('Quality: ${data['quality_result']}'),
              Text('Quantity: ${data['quantity_liters']} L'),
              Text('Created: ${data['created_at']}'),
              const Divider(),
              const Text('Journey:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (data['journeys'] != null)
                ...(data['journeys'] as List).map((j) => Text('- ${j['stage']} at ${j['recorded_at']}')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isProcessing = false);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Scan'),
        actions: [
          TextButton(
            onPressed: () => context.goNamed(RouteNames.login),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Staff Login'),
          ),
        ],
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
              color: Colors.black54,
              child: const Text(
                'Point camera at a DairyTrace QR Code',
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
