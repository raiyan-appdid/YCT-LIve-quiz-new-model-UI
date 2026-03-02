enum GameStatus { upcoming, open, active, completed }

/// Represents the prize amount for a specific rank position
class PrizeDistribution {
  final int rank;
  final double amount;

  PrizeDistribution({required this.rank, required this.amount});
}

/// Represents a completed game's history entry for the current user
class GameHistory {
  final String gameId;
  final String title;
  final String imageUrl;
  final DateTime playedAt;
  final int rank;
  final int totalParticipants;
  final int correctAnswers;
  final int totalQuestions;
  final int totalPoints;
  final double avgResponseTime;
  final double? prizeWon;

  GameHistory({
    required this.gameId,
    required this.title,
    this.imageUrl = '',
    required this.playedAt,
    required this.rank,
    required this.totalParticipants,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.totalPoints,
    required this.avgResponseTime,
    this.prizeWon,
  });
}

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
  final int totalQuestions;
  final int timePerQuestionSeconds;
  final int pointsPerCorrectAnswer;
  final double prizePool;
  final List<PrizeDistribution>? _prizeDistribution;

  /// Returns the prize distribution list, never null
  List<PrizeDistribution> get prizeDistribution => _prizeDistribution ?? const [];

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
    this.totalQuestions = 10,
    this.timePerQuestionSeconds = 10,
    this.pointsPerCorrectAnswer = 100,
    this.prizePool = 5000,
    List<PrizeDistribution>? prizeDistribution,
  })  : _endTime = endTime,
        _prizeDistribution = prizeDistribution;
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
