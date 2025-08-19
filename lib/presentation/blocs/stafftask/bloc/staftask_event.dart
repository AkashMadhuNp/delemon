import 'package:equatable/equatable.dart';
import 'package:delemon/domain/entities/task.dart';

abstract class StaffTaskEvent extends Equatable {
  const StaffTaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffTasks extends StaffTaskEvent {}

class RefreshStaffTasks extends StaffTaskEvent {}

class SearchTasks extends StaffTaskEvent {
  final String query;

  const SearchTasks(this.query);

  @override
  List<Object> get props => [query];
}


class FilterByPriority extends StaffTaskEvent {
  final TaskPriority? priority;

  const FilterByPriority(this.priority);

  @override
  List<Object?> get props => [priority];
}



class SortTasks extends StaffTaskEvent {
  final String sortBy;

  const SortTasks(this.sortBy);

  @override
  List<Object> get props => [sortBy];
}



class FilterByTab extends StaffTaskEvent {
  final int tabIndex;

  const FilterByTab(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}



class UpdateTaskStatus extends StaffTaskEvent {
  final Task task;
  final TaskStatus newStatus;

  const UpdateTaskStatus(this.task, this.newStatus);

  @override
  List<Object> get props => [task, newStatus];
}
