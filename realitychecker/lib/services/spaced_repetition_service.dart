import '../models/flashcard_model.dart';

/// SM-2 Spaced Repetition Algorithm
/// Quality ratings: 0=Again, 1=Hard, 2=Good, 3=Easy (mapped from 4 buttons to 0-5 scale internally)
class SpacedRepetitionService {
  /// Process a review with a quality score 0-5.
  /// Returns updated [FlashCard] (mutates in-place and returns it).
  static FlashCard processReview(FlashCard card, ReviewQuality quality) {
    final q = quality.score; // 0-5

    if (q < 3) {
      // Incorrect response — reset
      card.repetitions = 0;
      card.interval = 1;
    } else {
      // Correct response
      if (card.repetitions == 0) {
        card.interval = 1;
      } else if (card.repetitions == 1) {
        card.interval = 6;
      } else {
        card.interval = (card.interval * card.easeFactor).round();
      }
      card.repetitions += 1;
    }

    // Update ease factor: EF' = EF + (0.1 - (5-q) * (0.08 + (5-q)*0.02))
    card.easeFactor += 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
    if (card.easeFactor < 1.3) card.easeFactor = 1.3;

    // Clamp interval
    if (card.interval < 1) card.interval = 1;

    card.dueDate = DateTime.now().add(Duration(days: card.interval));
    card.totalReviews += 1;
    if (q >= 3) card.correctReviews += 1;

    return card;
  }
}

enum ReviewQuality {
  again(0),
  hard(2),
  good(4),
  easy(5);

  final int score;
  const ReviewQuality(this.score);

  String get label {
    switch (this) {
      case ReviewQuality.again:
        return 'Again';
      case ReviewQuality.hard:
        return 'Hard';
      case ReviewQuality.good:
        return 'Good';
      case ReviewQuality.easy:
        return 'Easy';
    }
  }
}
