class MoodDimension {
  final String key;
  final String label;
  final String description;
  final String emoji;

  const MoodDimension({
    required this.key,
    required this.label,
    required this.description,
    required this.emoji,
  });
}

const List<MoodDimension> moodDimensions = [
  MoodDimension(
    key: 'happy',
    label: '开心',
    description: '活力充沛、心情愉悦',
    emoji: '😊',
  ),
  MoodDimension(
    key: 'tired',
    label: '疲惫',
    description: '需要治愈、放松、充电',
    emoji: '😮‍💨',
  ),
  MoodDimension(
    key: 'adventurous',
    label: '冒险',
    description: '想尝试新鲜事物、探索未知',
    emoji: '🎢',
  ),
  MoodDimension(
    key: 'comfort',
    label: '治愈',
    description: '需要温暖、安慰、被照顾',
    emoji: '🛋️',
  ),
  MoodDimension(
    key: 'social',
    label: '社交',
    description: '想和人一起吃饭、热闹',
    emoji: '🎉',
  ),
  MoodDimension(
    key: 'alone',
    label: '独处',
    description: '想一个人静静享受、自由自在',
    emoji: '🧘',
  ),
];

String getMoodLabel(String key) {
  for (final d in moodDimensions) {
    if (d.key == key) return d.label;
  }
  return key;
}

String getMoodEmoji(String key) {
  for (final d in moodDimensions) {
    if (d.key == key) return d.emoji;
  }
  return '';
}
