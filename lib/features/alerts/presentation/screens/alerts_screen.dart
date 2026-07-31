import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/alert_model.dart';
import '../providers/alerts_provider.dart';
import '../../data/repositories/alert_repository.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return const Center(child: Text('No active alerts.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return _buildAlertCard(context, ref, alerts[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, WidgetRef ref, AlertModel alert) {
    Color borderColor;
    Color iconColor;
    Color bgColor = Colors.white;
    IconData icon;

    switch (alert.severity) {
      case AlertSeverity.critical:
        borderColor = Colors.red.shade900;
        iconColor = Colors.red.shade900;
        bgColor = Colors.red.shade50;
        icon = Icons.error;
        break;
      case AlertSeverity.high:
        borderColor = Colors.red.shade400;
        iconColor = Colors.red.shade400;
        icon = Icons.warning;
        break;
      case AlertSeverity.medium:
        borderColor = Colors.amber.shade600;
        iconColor = Colors.amber.shade600;
        icon = Icons.warning_amber;
        break;
      case AlertSeverity.low:
        borderColor = Colors.grey.shade300;
        iconColor = Colors.grey.shade600;
        icon = Icons.info_outline;
        break;
      case AlertSeverity.info:
      default:
        borderColor = Colors.blue.shade200;
        iconColor = Colors.blue;
        icon = Icons.info;
        break;
    }

    final isCritical = alert.severity == AlertSeverity.critical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isCritical ? 2.0 : 1.0,
        ),
        boxShadow: isCritical
            ? [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 8, spreadRadius: 1)]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: iconColor, size: isCritical ? 36 : 28),
        title: Text(
          alert.title,
          style: TextStyle(
            fontWeight: isCritical ? FontWeight.bold : FontWeight.w600,
            color: isCritical ? Colors.red.shade900 : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert.message),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(alert.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          tooltip: 'Mark Resolved',
          onPressed: () async {
            try {
              await ref.read(alertRepositoryProvider).resolveAlert(alert.id);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to resolve: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
