import 'package:charging_app/core/models/station_models.dart';

class StationListModel {
  StationListModel({
    this.isLoading = false,
    this.errorMessage = '',
    this.stations = const [],
  });

  final bool isLoading;
  final String errorMessage;
  final List<StationDto> stations;

  StationListModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<StationDto>? stations,
  }) =>
      StationListModel(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        stations: stations ?? this.stations,
      );
}
