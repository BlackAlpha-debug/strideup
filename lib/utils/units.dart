const kilometersToMiles = 0.621371192237334;
double displayDistance(double km, bool useKilometers) =>
    useKilometers ? km : km * kilometersToMiles;
String distanceUnit(bool useKilometers) => useKilometers ? 'km' : 'mi';

String displayPace(Duration duration, double distanceKm, bool useKilometers) {
  final distance = displayDistance(distanceKm, useKilometers);
  if (distance <= 0 || duration.inSeconds <= 0) return '--';
  final seconds = (duration.inSeconds / distance).round();
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')} /${distanceUnit(useKilometers)}';
}

List<DateTime> rollingWeekDates(DateTime now, {int weeksAgo = 0}) =>
    List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day - 6 + i - weeksAgo * 7),
    );
String weekdayLabel(DateTime day) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1];
