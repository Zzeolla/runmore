String formatPaceFromMPerSec(double metersPerSecond) {
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

String formatElapsed(int seconds) {
  if (seconds <= 0) return '0:00';

  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;

  if (h > 0) {
    return '${h.toString().padLeft(1, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  } else {
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

String formatPaceFromSecPerKm(int secPerKm) {
  if (secPerKm <= 0) return '-';
  final m = secPerKm ~/ 60;
  final s = secPerKm % 60;
  return "$m'${s.toString().padLeft(2, '0')}\"";
}

String formatDate(DateTime dt) {
  return '${dt.month}/${dt.day} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
