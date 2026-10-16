import 'package:flutter/material.dart';

class LevelInfo {
  final int level;
  final String name;
  final IconData icon;
  final int xpRequired;

  const LevelInfo({
    required this.level,
    required this.name,
    required this.icon,
    required this.xpRequired,
  });

  static const all = [
    LevelInfo(level: 1, name: 'Walker', icon: Icons.do_not_step, xpRequired: 0),
    LevelInfo(
      level: 2,
      name: 'Roamer',
      icon: Icons.directions_walk,
      xpRequired: 500,
    ),
    LevelInfo(
      level: 3,
      name: 'Pathfinder',
      icon: Icons.explore,
      xpRequired: 1500,
    ),
    LevelInfo(level: 4, name: 'Nomad', icon: Icons.hiking, xpRequired: 3000),
    LevelInfo(
      level: 5,
      name: 'Trailblazer',
      icon: Icons.landscape,
      xpRequired: 5000,
    ),
    LevelInfo(level: 6, name: 'Voyager', icon: Icons.public, xpRequired: 8000),
    LevelInfo(
      level: 7,
      name: 'Summit Seeker',
      icon: Icons.terrain,
      xpRequired: 12000,
    ),
    LevelInfo(
      level: 8,
      name: 'Endurance',
      icon: Icons.fitness_center,
      xpRequired: 18000,
    ),
    LevelInfo(level: 9, name: 'Titan', icon: Icons.shield, xpRequired: 26000),
    LevelInfo(
      level: 10,
      name: 'Legend',
      icon: Icons.auto_awesome,
      xpRequired: 36000,
    ),
  ];
}
