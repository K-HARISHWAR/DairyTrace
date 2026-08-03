import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/batch_stage.dart';
import '../../../batches/data/models/batch_model.dart';
import '../../../batches/data/repositories/batch_repository.dart';
import '../providers/collection_batches_provider.dart';
import '../providers/collection_batch_details_provider.dart';

class CollectionBatchStageUpdateScreen extends ConsumerStatefulWidget {
  final BatchModel batch;

  const CollectionBatchStageUpdateScreen({super.key, required this.batch});

  @override
  ConsumerState<CollectionBatchStageUpdateScreen> createState() =>
      _CollectionBatchStageUpdateScreenState();
}

class _CollectionBatchStageUpdateScreenState
    extends ConsumerState<CollectionBatchStageUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  BatchStage? _selectedStage;
  final _eventTypeController = TextEditingController();
  final _statusController = TextEditingController(text: 'completed');
  final _locationController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _eventTypeController.dispose();
    _statusController.dispose();
    _locationController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  List<BatchStage> _getAllowedStages() {
    // Only pre-distribution stages
    return [BatchStage.chilling, BatchStage.processing, BatchStage.packaging];
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a stage')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(batchRepositoryProvider)
          .updateBatchStage(
            batchId: widget.batch.id,
            newStage: _selectedStage!,
            eventType: _eventTypeController.text.trim(),
            status: _statusController.text.trim(),
            locationName: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            remarks: _remarksController.text.trim().isEmpty
                ? null
                : _remarksController.text.trim(),
          );

      ref.invalidate(paginatedBatchesProvider);
      ref.invalidate(batchTrackingProvider(widget.batch.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stage updated successfully!')),
        );
        context.pop();
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
    if (widget.batch.overallStatus.value == 'rejected' ||
        widget.batch.overallStatus.value == 'spoiled') {
      return Scaffold(
        appBar: AppBar(title: const Text('Update Stage')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'This batch is terminal (rejected/spoiled) and cannot progress further.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Update ${widget.batch.batchCode}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<BatchStage>(
                value: _selectedStage,
                decoration: const InputDecoration(labelText: 'New Stage *'),
                items: _getAllowedStages()
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.value.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedStage = val),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _eventTypeController,
                decoration: const InputDecoration(
                  labelText: 'Event Type * (e.g. standard_chill, pasteurized)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Status *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location Name (Optional)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Confirm Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
