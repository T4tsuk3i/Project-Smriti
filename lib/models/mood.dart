import 'package:flutter/material.dart';

import '../app_theme.dart';

class Mood {
  const Mood({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
    required this.soft,
  });

  final String id;
  final String label;
  final String emoji;
  final Color color;
  final Color soft;
}

const List<Mood> moods = [
  Mood(
    id: 'good',
    label: 'Good',
    emoji: '😊',
    color: AppColors.sage,
    soft: AppColors.sageSoft,
  ),
  Mood(
    id: 'okay',
    label: 'Okay',
    emoji: '🙂',
    color: AppColors.yellow,
    soft: AppColors.yellowSoft,
  ),
  Mood(
    id: 'low',
    label: 'Low',
    emoji: '😕',
    color: AppColors.orange,
    soft: AppColors.orangeSoft,
  ),
  Mood(
    id: 'heavy',
    label: 'Heavy',
    emoji: '😞',
    color: AppColors.rust,
    soft: AppColors.rustSoft,
  ),
  Mood(
    id: 'numb',
    label: 'Numb',
    emoji: '😐',
    color: AppColors.lilac,
    soft: AppColors.lilacSoft,
  ),
];

Mood? moodById(String? id) {
  if (id == null) return null;
  for (final mood in moods) {
    if (mood.id == id) return mood;
  }
  return null;
}
