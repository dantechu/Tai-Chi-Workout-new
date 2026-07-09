import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/entities/flash_card.dart';
import '../../../core/utils/localization_helper.dart';
import '../../widgets/banner_ad_widget.dart';

/// Page for flashcard study sessions with spaced repetition-style rating.
///
/// Features:
/// - Tap to flip card (front/back)
/// - Rate answers: Again, Hard (wrong) / Good, Easy (correct)
/// - Progress tracking with correct/wrong counts
/// - Results screen with score
/// - Support for multilingual content
class FlashcardPage extends StatefulWidget {
  final Video lesson;

  const FlashcardPage({
    super.key,
    required this.lesson,
  });

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  int _currentCardIndex = 0;
  bool _showingAnswer = false;
  bool _sessionCompleted = false;
  int _correctCount = 0;
  int _wrongCount = 0;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  List<FlashCard> get cards => widget.lesson.cards ?? [];
  FlashCard? get currentCard =>
      cards.isNotEmpty && _currentCardIndex < cards.length
          ? cards[_currentCardIndex]
          : null;
  int get totalCards => cards.length;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _showAnswer() {
    if (_flipController.isAnimating) return;
    _flipController.forward();
    setState(() {
      _showingAnswer = true;
    });
  }

  void _hideAnswer() {
    if (_flipController.isAnimating) return;
    _flipController.reverse();
    setState(() {
      _showingAnswer = false;
    });
  }

  void _rateCard(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });

    // Move to next card or complete session
    if (_currentCardIndex < totalCards - 1) {
      _flipController.reverse().then((_) {
        setState(() {
          _currentCardIndex++;
          _showingAnswer = false;
        });
      });
    } else {
      setState(() {
        _sessionCompleted = true;
      });
    }
  }

  void _restartSession() {
    _flipController.reset();
    setState(() {
      _currentCardIndex = 0;
      _showingAnswer = false;
      _sessionCompleted = false;
      _correctCount = 0;
      _wrongCount = 0;
    });
  }

  double get scorePercentage => totalCards > 0
      ? (_correctCount / totalCards) * 100
      : 0;

  bool get passed => scorePercentage >= 70;

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizationHelper.getCurrentLanguageCode(context);
    final title = widget.lesson.getLocalizedTitle(languageCode);

    if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Text('No flashcards available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      bottomNavigationBar: _sessionCompleted
          ? const SafeArea(child: BannerAdWidget())
          : null,
      body: _sessionCompleted
          ? _buildResultsView(context)
          : _buildStudyView(context, languageCode),
    );
  }

  Widget _buildStudyView(BuildContext context, String languageCode) {
    final description = widget.lesson.getLocalizedDescription(languageCode);

    return SafeArea(
      child: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentCardIndex + 1) / totalCards,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            ),
          ),

          // Card counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Card ${_currentCardIndex + 1} of $totalCards',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  _showingAnswer ? 'Tap to flip back' : 'Tap to reveal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),

          // Description
          if (description != null && description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Flashcard
          Expanded(
            child: GestureDetector(
              onTap: _showingAnswer ? _hideAnswer : _showAnswer,
              child: Center(
                child: _buildFlipCard(context, languageCode),
              ),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: _showingAnswer
                ? _buildRatingButtons(context)
                : _buildShowAnswerButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(BuildContext context, String languageCode) {
    final card = currentCard!;
    final frontText = card.getLocalizedFrontText(languageCode);
    final backText = card.getLocalizedBackText(languageCode);

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * math.pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        // Determine which side to show based on angle
        final showingFront = angle < (math.pi / 2);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.all(24),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: showingFront
                        ? [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                          ]
                        : [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
                          ],
                  ),
                ),
                // Counter-rotate the entire content on the back side
                child: Transform(
                  transform: showingFront
                      ? Matrix4.identity()
                      : (Matrix4.identity()..rotateY(math.pi)),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Side indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          showingFront ? 'FRONT' : 'BACK',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Card content
                      Text(
                        showingFront ? frontText : backText,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),

                      // Tap hint - white icon
                      Icon(
                        Icons.touch_app,
                        size: 32,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShowAnswerButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _showAnswer,
        icon: const Icon(Icons.visibility_outlined),
        label: const Text(
          'Show Answer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildRatingButtons(BuildContext context) {
    return Column(
      children: [
        // Top row: Again, Hard
        Row(
          children: [
            Expanded(
              child: _buildRatingButton(
                context,
                label: 'Again',
                icon: Icons.close,
                color: const Color(0xFFE91E63), // Pink
                onPressed: () => _rateCard(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRatingButton(
                context,
                label: 'Hard',
                icon: Icons.remove,
                color: const Color(0xFFFF9800), // Orange
                onPressed: () => _rateCard(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom row: Good, Easy
        Row(
          children: [
            Expanded(
              child: _buildRatingButton(
                context,
                label: 'Good',
                icon: Icons.check,
                color: const Color(0xFF2196F3), // Blue
                onPressed: () => _rateCard(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRatingButton(
                context,
                label: 'Easy',
                icon: Icons.done_all,
                color: const Color(0xFF4CAF50), // Green
                onPressed: () => _rateCard(true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildResultsView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Result icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: passed
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
              ),
              child: Icon(
                passed ? Icons.emoji_events : Icons.refresh,
                size: 60,
                color: passed ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Result text
            Text(
              passed ? 'Great Job!' : 'Keep Practicing!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: passed ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),

            // Score
            Text(
              'You scored ${scorePercentage.toInt()}%',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctCount correct, $_wrongCount wrong',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),

            // Action buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _restartSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Study Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back to Lessons',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
