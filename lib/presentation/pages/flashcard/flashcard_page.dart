import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/entities/flash_card.dart';
import '../../../core/utils/localization_helper.dart';

/// Page for flashcard lessons with flip animation.
///
/// Features:
/// - Tap to flip card (front/back)
/// - Swipe gestures for next/previous
/// - Progress tracking
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
  bool _showFront = true;
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

  void _flipCard() {
    if (_flipController.isAnimating) return;

    if (_showFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  void _nextCard() {
    if (_currentCardIndex < totalCards - 1) {
      setState(() {
        _currentCardIndex++;
        _showFront = true;
        _flipController.reset();
      });
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _showFront = true;
        _flipController.reset();
      });
    }
  }

  void _resetCards() {
    setState(() {
      _currentCardIndex = 0;
      _showFront = true;
      _flipController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = LocalizationHelper.getCurrentLanguageCode(context);
    final title = widget.lesson.getLocalizedTitle(languageCode);
    final description = widget.lesson.getLocalizedDescription(languageCode);

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
      body: SafeArea(
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
                    _showFront ? 'Tap to reveal' : 'Tap to flip back',
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
                onTap: _flipCard,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < -100) {
                      _nextCard();
                    } else if (details.primaryVelocity! > 100) {
                      _previousCard();
                    }
                  }
                },
                child: Center(
                  child: _buildFlipCard(context, languageCode),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Previous button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _currentCardIndex > 0 ? _previousCard : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Next/Complete button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _currentCardIndex < totalCards - 1
                            ? _nextCard
                            : _resetCards,
                        icon: Icon(
                          _currentCardIndex < totalCards - 1
                              ? Icons.arrow_forward
                              : Icons.refresh,
                        ),
                        label: Text(
                          _currentCardIndex < totalCards - 1
                              ? 'Next'
                              : 'Restart',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
                          ]
                        : [
                            Theme.of(context).colorScheme.secondaryContainer,
                            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.8),
                          ],
                  ),
                ),
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
                        color: showingFront
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                            : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        showingFront ? 'FRONT' : 'BACK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: showingFront
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Card content (mirrored on back)
                    Transform(
                      transform: showingFront
                          ? Matrix4.identity()
                          : (Matrix4.identity()..rotateY(math.pi)),
                      alignment: Alignment.center,
                      child: Text(
                        showingFront ? frontText : backText,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: showingFront
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(),

                    // Tap hint
                    Icon(
                      Icons.touch_app,
                      size: 32,
                      color: (showingFront
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSecondaryContainer)
                          .withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
