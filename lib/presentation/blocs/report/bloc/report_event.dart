abstract class ReportsEvent {}

class LoadReportsEvent extends ReportsEvent {}

class RefreshReportsEvent extends ReportsEvent {}

class SearchReportsEvent extends ReportsEvent {
  final String query;
  SearchReportsEvent(this.query);
}

class SelectProjectEvent extends ReportsEvent {
  final String? projectId;
  SelectProjectEvent(this.projectId);
}

class ClearSearchEvent extends ReportsEvent {}
