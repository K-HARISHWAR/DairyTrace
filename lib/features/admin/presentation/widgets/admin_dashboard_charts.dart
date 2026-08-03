import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardVolumeChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const DashboardVolumeChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No volume data available.'));
    }

    final theme = Theme.of(context);
    double maxVolume = 0;
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < data.length; i++) {
      final volume = (data[i]['volume'] as num).toDouble();
      if (volume > maxVolume) maxVolume = volume;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: volume,
              color: theme.colorScheme.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVolume * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} L',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= data.length)
                    return const SizedBox.shrink();
                  final dateStr = data[value.toInt()]['date'] as String;
                  final date = DateTime.tryParse(dateStr);
                  final label = date != null
                      ? DateFormat('MM/dd').format(date)
                      : '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}

class DashboardStatusDoughnut extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DashboardStatusDoughnut({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final accepted = (stats['acceptedBatches'] as num?)?.toDouble() ?? 0;
    final rejected = (stats['rejectedBatches'] as num?)?.toDouble() ?? 0;
    final inTransit = (stats['inTransitDeliveries'] as num?)?.toDouble() ?? 0;

    final total = accepted + rejected + inTransit;

    if (total == 0) {
      return const Center(child: Text('No batches to display.'));
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            if (accepted > 0)
              PieChartSectionData(
                color: Colors.green,
                value: accepted,
                title: '${((accepted / total) * 100).toInt()}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (rejected > 0)
              PieChartSectionData(
                color: Colors.red,
                value: rejected,
                title: '${((rejected / total) * 100).toInt()}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (inTransit > 0)
              PieChartSectionData(
                color: Colors.blue,
                value: inTransit,
                title: '${((inTransit / total) * 100).toInt()}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
