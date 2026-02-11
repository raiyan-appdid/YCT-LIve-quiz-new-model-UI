enum GameStatus { upcoming, open, active, completed }

class Game {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startTime;
  final DateTime? _endTime;
  final double entryFee;
  final int maxCapacity;
  final int currentParticipants;
  final GameStatus status;

  /// Returns the end time, or startTime + 30 minutes if not provided
  DateTime get endTime => _endTime ?? startTime.add(const Duration(minutes: 30));

  Game({
    required this.id,
    required this.title,
    this.description = '',
    this.imageUrl = '',
    required this.startTime,
    DateTime? endTime,
    required this.entryFee,
    required this.maxCapacity,
    required this.currentParticipants,
    required this.status,
  }) : _endTime = endTime;
}

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final int timeLimitSeconds;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.timeLimitSeconds,
  });
}

class User {
  final String id;
  final String name;
  final String avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });
}

class LeaderboardEntry {
  final User user;
  final int rank;
  final int totalPoints;
  final double avgResponseTime;
  final int correctAnswers;

  LeaderboardEntry({
    required this.user,
    required this.rank,
    required this.totalPoints,
    required this.avgResponseTime,
    required this.correctAnswers,
  });
}
