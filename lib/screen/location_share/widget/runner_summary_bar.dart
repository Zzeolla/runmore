import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runmore/provider/live_share_provider.dart';
import 'package:runmore/util/color_hex.dart';
import 'package:runmore/util/run_format.dart';

class RunnerSummaryBar extends StatelessWidget {
  const RunnerSummaryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final live = context.watch<LiveShareProvider>();

    if (!live.isInRoom || live.runners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: live.runners.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final runner = live.runners[index];
            final segments = live.segmentsByRunner[runner.id] ?? [];
            final latest = segments.isNotEmpty ? segments.first : null;

            final distanceM = latest?.distanceM ?? 0.0;
            final elapsed = latest?.elapsedS ?? 0;
            final pace = latest?.avgPaceSPerKm ?? 0;

            return _RunnerSummaryChip(
                runnerName: runner.displayName,
                colorHex: runner.color ?? '#03A9F4',
                distanceKm: distanceM / 1000,
                elapsedSeconds: elapsed,
                paceSecPerKm: pace,
                onTap: () {
                  context.read<LiveShareProvider>().focusRunner(runner.id);
                }
            );
          },
        ),
      ),
    );
  }
}

class _RunnerSummaryChip extends StatelessWidget {
  final String runnerName;
  final String colorHex;
  final double distanceKm;
  final int elapsedSeconds;
  final int paceSecPerKm;
  final VoidCallback? onTap;

  const _RunnerSummaryChip({
    required this.runnerName,
    required this.colorHex,
    required this.distanceKm,
    required this.elapsedSeconds,
    required this.paceSecPerKm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorHex.toColorOrDefault();

    return InkWell(
      onTap: onTap, // 👈 여기에 연결
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.8), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: color,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    runnerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${distanceKm.toStringAsFixed(2)} km',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
            Text(
              '${formatElapsed(elapsedSeconds)} • ${formatPaceFromSecPerKm(paceSecPerKm)}',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}