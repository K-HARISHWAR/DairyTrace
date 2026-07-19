import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';

import '../../data/repositories/public_trace_repository.dart';

final publicBatchProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, token) async {
  return ref.watch(publicTraceRepositoryProvider).getPublicBatchTrace(token);
});

class PublicBatchScreen extends ConsumerWidget {
  final String publicToken;

  const PublicBatchScreen({super.key, required this.publicToken});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchAsync = ref.watch(publicBatchProvider(publicToken));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Provenance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Because we used pushReplacement to get here, we might need to go to welcome
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.welcome);
            }
          },
        ),
      ),
      body: batchAsync.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Batch not found or token invalid.'));
          }
          return const Center(child: Text('Batch Details will be shown here.'));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Could not load batch data.\n\n$err')),
      ),
    );
  }
}
