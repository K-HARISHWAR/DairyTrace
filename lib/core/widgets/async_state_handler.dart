import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncStateHandler<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  final Widget Function()? emptyBuilder;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;

  const AsyncStateHandler({
    super.key,
    required this.value,
    required this.dataBuilder,
    this.emptyBuilder,
    this.emptyMessage,
    this.emptyIcon,
    this.onRetry,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) {
        final bool isDataEmpty = isEmpty?.call(data) ?? 
            (data is List ? (data as List).isEmpty : false) || 
            (data is Map ? (data as Map).isEmpty : data == null);

        if (isDataEmpty) {
          if (emptyBuilder != null) return emptyBuilder!();
          return _buildEmptyState(context);
        }

        return dataBuilder(data);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, st) => _buildErrorState(context, err),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon ?? Icons.inbox,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'No data found',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to connect or load data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
