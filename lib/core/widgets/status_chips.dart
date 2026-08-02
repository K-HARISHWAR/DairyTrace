import 'package:flutter/material.dart';
import '../enums/batch_status.dart';
import '../enums/delivery_status.dart';
import '../../features/alerts/data/models/alert_model.dart';

class StatusChipBase extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChipBase({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class BatchStatusChip extends StatelessWidget {
  final BatchStatus? status;
  final String? rawStatus; // fallback for unknown strings

  const BatchStatusChip({super.key, this.status, this.rawStatus});

  @override
  Widget build(BuildContext context) {
    String label = 'Unknown';
    Color color = Colors.grey;
    IconData icon = Icons.help_outline;

    if (status != null) {
      switch (status!) {
        case BatchStatus.inProgress:
          label = 'In Progress';
          color = Colors.blue;
          icon = Icons.sync;
          break;
        case BatchStatus.pendingQuality:
          label = 'Pending Quality';
          color = Colors.orange;
          icon = Icons.science;
          break;
        case BatchStatus.accepted:
          label = 'Accepted';
          color = Colors.green;
          icon = Icons.check_circle;
          break;
        case BatchStatus.rejected:
          label = 'Rejected';
          color = Colors.red;
          icon = Icons.cancel;
          break;
        case BatchStatus.spoiled:
          label = 'Spoiled';
          color = Colors.red.shade900;
          icon = Icons.warning;
          break;
        case BatchStatus.delivered:
          label = 'Delivered';
          color = Colors.teal;
          icon = Icons.local_shipping;
          break;
      }
    } else if (rawStatus != null) {
      label = rawStatus!.toUpperCase();
    }

    return StatusChipBase(label: label, color: color, icon: icon);
  }
}

class QualityStatusChip extends StatelessWidget {
  final String? qualityStatus; // typically 'pending', 'passed', 'failed', 'warning'

  const QualityStatusChip({super.key, this.qualityStatus});

  @override
  Widget build(BuildContext context) {
    String label = 'Unknown';
    Color color = Colors.grey;
    IconData icon = Icons.help_outline;

    switch (qualityStatus?.toLowerCase()) {
      case 'passed':
      case 'accepted':
        label = 'Passed';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'failed':
      case 'rejected':
        label = 'Failed';
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'warning':
        label = 'Warning';
        color = Colors.orange;
        icon = Icons.warning_amber;
        break;
      case 'pending':
        label = 'Pending';
        color = Colors.blue;
        icon = Icons.hourglass_empty;
        break;
      default:
        label = qualityStatus?.toUpperCase() ?? 'UNKNOWN';
        break;
    }

    return StatusChipBase(label: label, color: color, icon: icon);
  }
}

class DeliveryStatusChip extends StatelessWidget {
  final DeliveryStatus? status;
  final String? rawStatus;

  const DeliveryStatusChip({super.key, this.status, this.rawStatus});

  @override
  Widget build(BuildContext context) {
    String label = 'Unknown';
    Color color = Colors.grey;
    IconData icon = Icons.help_outline;

    if (status != null) {
      switch (status!) {
        case DeliveryStatus.assigned:
          label = 'Assigned';
          color = Colors.indigo;
          icon = Icons.assignment;
          break;
        case DeliveryStatus.pickedUp:
          label = 'Picked Up';
          color = Colors.blue;
          icon = Icons.outbox;
          break;
        case DeliveryStatus.inTransit:
          label = 'In Transit';
          color = Colors.orange;
          icon = Icons.directions_car;
          break;
        case DeliveryStatus.delivered:
          label = 'Delivered';
          color = Colors.green;
          icon = Icons.check_circle;
          break;
        case DeliveryStatus.delayed:
          label = 'Delayed';
          color = Colors.red;
          icon = Icons.error_outline;
          break;
      }
    } else if (rawStatus != null) {
      label = rawStatus!.toUpperCase();
    }

    return StatusChipBase(label: label, color: color, icon: icon);
  }
}

class AlertSeverityChip extends StatelessWidget {
  final AlertSeverity? severity;

  const AlertSeverityChip({super.key, this.severity});

  @override
  Widget build(BuildContext context) {
    String label = 'Info';
    Color color = Colors.blue;
    IconData icon = Icons.info;

    switch (severity) {
      case AlertSeverity.critical:
        label = 'Critical';
        color = Colors.red.shade900;
        icon = Icons.report;
        break;
      case AlertSeverity.high:
        label = 'High';
        color = Colors.red;
        icon = Icons.error;
        break;
      case AlertSeverity.medium:
        label = 'Medium';
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case AlertSeverity.low:
        label = 'Low';
        color = Colors.yellow.shade700;
        icon = Icons.low_priority;
        break;
      case AlertSeverity.info:
      default:
        break;
    }

    return StatusChipBase(label: label, color: color, icon: icon);
  }
}
