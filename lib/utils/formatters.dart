final _numberGroupRegExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

String formatNumber(int n) {
  return n.toString().replaceAllMapped(_numberGroupRegExp, (m) => '${m[1]},');
}

String formatDate(DateTime d) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
}

String formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}

String formatPace(Duration perKm) {
  final minutes = perKm.inMinutes;
  final seconds = perKm.inSeconds % 60;
  return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
}

String formatCompactNumber(int n) {
  if (n >= 1000000) {
    final val = n / 1000000;
    return val == val.roundToDouble()
        ? '${val.round()}M'
        : '${val.toStringAsFixed(1)}M';
  }
  if (n >= 1000) {
    final val = n / 1000;
    return val == val.roundToDouble()
        ? '${val.round()}K'
        : '${val.toStringAsFixed(1)}K';
  }
  return n.toString();
}
