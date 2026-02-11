import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/theme.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final int timeRemaining;
  final int totalTime;
  final int? selectedOptionIndex;
  final Function(int) onOptionSelected;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.timeRemaining,
    required this.totalTime,
    required this.selectedOptionIndex,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Timer Bar
        LinearProgressIndicator(
          value: timeRemaining / totalTime,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(
            timeRemaining < 3 ? AppColors.error : AppColors.timer,
          ),
          minHeight: 10,
        ),
        const SizedBox(height: 24),

        // Question Text
        Text(
          question.text,
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Options Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 3.5,
              mainAxisSpacing: 16,
            ),
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              return _buildOptionButton(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(int index) {
    bool isSelected = selectedOptionIndex == index;
    bool isTimeUp = timeRemaining == 0;
    bool isCorrect = index == question.correctOptionIndex;

    Color backgroundColor = AppColors.surface;
    Color textColor = Colors.white;

    if (isTimeUp) {
      if (isCorrect) {
        backgroundColor = AppColors.correct;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.incorrect;
      } else {
        backgroundColor = Colors.grey[800]!;
        textColor = Colors.grey;
      }
    } else if (isSelected) {
      backgroundColor = AppColors.secondary;
      textColor = AppColors.onSecondary;
    }

    return GestureDetector(
      onTap: isTimeUp || selectedOptionIndex != null ? null : () => onOptionSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        child: Text(
          question.options[index],
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
