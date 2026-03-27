import 'package:equatable/equatable.dart';
import '../../domain/value_objects/dashboard_view_mode.dart';
import '../../domain/value_objects/filter_values.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

class FilterAssets extends DashboardEvent {
  final AssetFilterCategory category;

  const FilterAssets(this.category);

  @override
  List<Object?> get props => [category];
}

class ChangeTimeRange extends DashboardEvent {
  final TimeRange range;

  const ChangeTimeRange(this.range);

  @override
  List<Object?> get props => [range];
}

class ToggleBalanceVisibility extends DashboardEvent {
  const ToggleBalanceVisibility();
}

class SetDashboardViewMode extends DashboardEvent {
  final DashboardViewMode mode;

  const SetDashboardViewMode(this.mode);

  @override
  List<Object?> get props => [mode];
}
