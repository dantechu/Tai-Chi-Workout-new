import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_statistics.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final UserStatistics statistics;
  final StatisticsTimeFilter currentFilter;
  final String? selectedCourseId;

  const StatisticsLoaded({
    required this.statistics,
    this.currentFilter = StatisticsTimeFilter.allTime,
    this.selectedCourseId,
  });

  @override
  List<Object?> get props => [statistics, currentFilter, selectedCourseId];

  StatisticsLoaded copyWith({
    UserStatistics? statistics,
    StatisticsTimeFilter? currentFilter,
    String? selectedCourseId,
  }) {
    return StatisticsLoaded(
      statistics: statistics ?? this.statistics,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedCourseId: selectedCourseId,
    );
  }
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object> get props => [message];
}
