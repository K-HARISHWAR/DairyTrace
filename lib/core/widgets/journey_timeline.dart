import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineEvent {
  final String stage;
  final DateTime? occurredAt;
  final String? locationName;
  final String? remarks;

  const TimelineEvent({
    required this.stage,
    this.occurredAt,
    this.locationName,
    this.remarks,
  });

  factory TimelineEvent.fromMap(Map<String, dynamic> event) {
    return TimelineEvent(
      stage: event['stage']?.toString() ?? 'Unknown',
      occurredAt: event['occurred_at'] != null
          ? DateTime.tryParse(event['occurred_at'].toString())?.toLocal()
          : null,
      locationName: event['location_name']?.toString(),
      remarks:
          event['public_remarks']?.toString() ?? event['remarks']?.toString(),
    );
  }
}

class JourneyTimeline extends StatelessWidget {
  final List<TimelineEvent> events;

  const JourneyTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No timeline events available.')),
      );
    }

    final dateFormat = DateFormat('MMM dd, hh:mm a');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isFirst = index == 0;
        final isLast = index == events.length - 1;

        final dateStr = event.occurredAt != null
            ? dateFormat.format(event.occurredAt!)
            : '';

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line & dot
              SizedBox(
                width: 30,
                child: Column(
                  children: [
                    Container(
                      width: 2,
                      height: 20,
                      color: isFirst
                          ? Colors.transparent
                          : Colors.blue.shade200,
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isFirst ? Colors.blue : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isLast
                            ? Colors.transparent
                            : Colors.blue.shade200,
                      ),
                    ),
                  ],
                ),
              ),
              // Timeline content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 24, top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _formatStage(event.stage),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (event.locationName != null &&
                          event.locationName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.locationName!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (event.remarks != null && event.remarks!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.remarks!,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatStage(String stage) {
    if (stage.isEmpty) return 'Unknown';
    return stage
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }
}
