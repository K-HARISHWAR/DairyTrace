import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../batches/data/repositories/batch_repository.dart';
import '../../../farms/data/models/farm_model.dart';
import '../providers/collection_active_farms_provider.dart';

class CollectionCreateBatchScreen extends ConsumerStatefulWidget {
  const CollectionCreateBatchScreen({super.key});

  @override
  ConsumerState<CollectionCreateBatchScreen> createState() =>
      _CollectionCreateBatchScreenState();
}

class _CollectionCreateBatchScreenState
    extends ConsumerState<CollectionCreateBatchScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Source
  FarmModel? _selectedFarm;
  final _notesController = TextEditingController();

  // Step 2: Quantity
  final _quantityController = TextEditingController();

  // Step 3: Quality
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();
  final _tempController = TextEditingController();
  bool _purityPassed = true;
  final _qualityRemarksController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _quantityController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _tempController.dispose();
    _qualityRemarksController.dispose();
    super.dispose();
  }

  void _submit() async {
    final user = ref.read(authStateProvider).value;
    if (user?.collectionCentreId == null) return;

    if (_selectedFarm == null ||
        _quantityController.text.isEmpty ||
        _fatController.text.isEmpty ||
        _snfController.text.isEmpty ||
        _tempController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields in previous steps.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final batch = await ref
          .read(batchRepositoryProvider)
          .createBatchTransaction(
            farmId: _selectedFarm!.id,
            collectionCentreId: user!.collectionCentreId!,
            quantityLitres: double.parse(_quantityController.text),
            collectionTime: DateTime.now(),
            fatPercentage: double.parse(_fatController.text),
            snfPercentage: double.parse(_snfController.text),
            temperature: double.parse(_tempController.text),
            purityPassed: _purityPassed,
            qualityRemarks: _qualityRemarksController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch registered successfully!')),
        );
        // Navigate to details and replace so user can't hit back to form
        context.pushReplacementNamed(
          RouteNames.collectionBatchDetails,
          extra: batch,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Batch')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            context.pop();
          }
        },
        steps: [
          Step(
            title: const Text('Source'),
            isActive: _currentStep >= 0,
            content: _buildSourceStep(),
          ),
          Step(
            title: const Text('Quantity'),
            isActive: _currentStep >= 1,
            content: _buildQuantityStep(),
          ),
          Step(
            title: const Text('Quality Check'),
            isActive: _currentStep >= 2,
            content: _buildQualityStep(),
          ),
          Step(
            title: const Text('Review'),
            isActive: _currentStep >= 3,
            content: _buildReviewStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ref
            .watch(activeFarmsDropdownProvider)
            .when(
              data: (farms) => DropdownButtonFormField<FarmModel>(
                value: _selectedFarm,
                decoration: const InputDecoration(labelText: 'Select Farm *'),
                items: farms
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(
                          '${f.farmName} (${f.farmCode}) - ${f.ownerName}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedFarm = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading farms: $e'),
            ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Collection Notes (Optional)',
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildQuantityStep() {
    return TextFormField(
      controller: _quantityController,
      decoration: const InputDecoration(
        labelText: 'Quantity (Litres) *',
        suffixText: 'L',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildQualityStep() {
    return Column(
      children: [
        const Text(
          'Initial Quality Check (Triggers DB Evaluation)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(
                  labelText: 'Fat % *',
                  suffixText: '%',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _snfController,
                decoration: const InputDecoration(
                  labelText: 'SNF % *',
                  suffixText: '%',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tempController,
          decoration: const InputDecoration(
            labelText: 'Temperature (°C) *',
            suffixText: '°C',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Purity Check Passed'),
          subtitle: const Text('Free from adulterants'),
          value: _purityPassed,
          onChanged: (val) => setState(() => _purityPassed = val),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _qualityRemarksController,
          decoration: const InputDecoration(
            labelText: 'Quality Remarks (Optional)',
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please review the details before submitting. Once submitted, the batch is finalized and quality will be evaluated by the database.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              _buildReviewRow('Farm', _selectedFarm?.farmName ?? 'None'),
              _buildReviewRow('Quantity', '${_quantityController.text} L'),
              _buildReviewRow('Fat', '${_fatController.text}%'),
              _buildReviewRow('SNF', '${_snfController.text}%'),
              _buildReviewRow('Temp', '${_tempController.text}°C'),
              _buildReviewRow('Purity', _purityPassed ? 'Passed' : 'Failed'),
            ],
          );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
