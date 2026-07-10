import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_statistics.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStatistics extends StatisticsEvent {
  final StatisticsTimeFilter filter;
  final String? courseId;

  const LoadStatistics({
    this.filter = StatisticsTimeFilter.allTime,
    this.courseId,
  });

  @override
  List<Object?> get props => [filter, courseId];
}

class ChangeTimeFilter extends StatisticsEvent {
  final StatisticsTimeFilter filter;

  const ChangeTimeFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

class ChangeCourseFilter extends StatisticsEvent {
  final String? courseId;

  const ChangeCourseFilter(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class RefreshStatistics extends StatisticsEvent {
  const RefreshStatistics();
}
