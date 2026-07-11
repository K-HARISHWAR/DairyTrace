import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/enums/quality_result.dart';
import '../../data/repositories/batch_repository.dart';
import '../providers/batches_provider.dart';
import '../../../farms/presentation/providers/farms_provider.dart';

class CreateBatchScreen extends ConsumerStatefulWidget {
  const CreateBatchScreen({super.key});

  @override
  ConsumerState<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends ConsumerState<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFarmId;
  final _quantityController = TextEditingController();
  final _tempController = TextEditingController();
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _tempController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    super.dispose();
  }

  QualityResult _evaluateQuality(double temp, double fat, double snf) {
    // Configurable demo standards
    // Temp: 2 - 8 C
    // Fat: 3.5 - 6.0 %
    // SNF: > 8.5 %
    if (temp >= 2 && temp <= 8 && fat >= 3.5 && snf >= 8.5) {
      return QualityResult.pass;
    }
    return QualityResult.fail;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedFarmId != null) {
      setState(() => _isLoading = true);
      try {
        final qty = double.parse(_quantityController.text);
        final temp = double.parse(_tempController.text);
        final fat = double.parse(_fatController.text);
        final snf = double.parse(_snfController.text);
        
        final quality = _evaluateQuality(temp, fat, snf);

        final batch = await ref.read(batchRepositoryProvider).createBatch(
          farmId: _selectedFarmId!,
          quantityLiters: qty,
          temperature: temp,
          fat: fat,
          snf: snf,
          qualityResult: quality,
        );
        ref.read(batchesProvider.notifier).addBatch(batch);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Batch ${quality == QualityResult.pass ? "Accepted" : "Rejected"}')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (_selectedFarmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a farm')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmsState = ref.watch(farmsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Batch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              farmsState.when(
                data: (farms) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Farm'),
                    value: _selectedFarmId,
                    items: farms.map((f) => DropdownMenuItem(value: f.id, child: Text(f.farmerName))).toList(),
                    onChanged: (val) => setState(() => _selectedFarmId = val),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading farms: $e'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity (Liters)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tempController,
                decoration: const InputDecoration(labelText: 'Temperature (°C)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      decoration: const InputDecoration(labelText: 'Fat (%)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _snfController,
                      decoration: const InputDecoration(labelText: 'SNF (%)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Evaluate & Create',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
