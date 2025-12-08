String formatPace(double metersPerSecond) {
  if (metersPerSecond <= 0) return '--\'--"';
  final secondsPerKm = 1000.0 / metersPerSecond;
  final m = (secondsPerKm / 60).floor();
  final s = (secondsPerKm % 60).round();
  return "$m'${s.toString().padLeft(2, '0')}\"";
}

String formatHms(int seconds) {
  final h = (seconds ~/ 3600).toString().padLeft(2, '0');
  final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}
