class UserProfile {
  final String name;
  final int stepGoal;
  final bool useKilometers;
  final bool locationTracking;
  final bool pushNotifications;

  const UserProfile({
    this.name = 'Alex Rivera',
    this.stepGoal = 10000,
    this.useKilometers = true,
    this.locationTracking = true,
    this.pushNotifications = true,
  });

  UserProfile copyWith({
    String? name,
    int? stepGoal,
    bool? useKilometers,
    bool? locationTracking,
    bool? pushNotifications,
  }) {
    return UserProfile(
      name: name ?? this.name,
      stepGoal: stepGoal ?? this.stepGoal,
      useKilometers: useKilometers ?? this.useKilometers,
      locationTracking: locationTracking ?? this.locationTracking,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}
