class Activity {
  final String name;
  final bool isEnabled;
  final double energy;

  Activity({required this.energy, required this.isEnabled, required this.name});

  Activity copyWith({String? name, bool? isEnabled, double? energy}) {
    return Activity(
      energy: energy ?? this.energy,
      isEnabled: isEnabled ?? this.isEnabled,
      name: name ?? this.name,
    );
  }
}
