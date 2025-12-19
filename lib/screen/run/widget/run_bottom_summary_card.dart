import 'package:flutter/material.dart';
import 'package:runmore/screen/run/run_home_summary_loader.dart';
import 'package:runmore/util/run_format.dart';

class RunBottomSummaryCard extends StatelessWidget {
  final AsyncSnapshot<RunHomeSummary> snapshot;

  const RunBottomSummaryCard({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasData) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );
    }

    final data = snapshot.data!;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.15),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이번주 / 이번달
                Row(
                  children: [
                    Expanded(
                      child: _SummaryChip(
                        label: '이번주',
                        km: data.weekKm,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryChip(
                        label: '이번달',
                        km: data.monthKm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '최근 러닝',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // 최근 3개
                ...data.recentRuns.map((run) {
                  final distanceKm = (run.distanceMeters / 1000.0);
                  final elapsed = formatHms(run.elapsedSeconds);
                  final dateStr = formatDate(run.startedAt);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: Colors.blueGrey[100],
                            child: const Icon(Icons.map, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${distanceKm.toStringAsFixed(2)} km',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$elapsed · $dateStr',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double km;

  const _SummaryChip({
    required this.label,
    required this.km,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
          const Spacer(),
          Text(
            '${km.toStringAsFixed(1)} km',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
