import 'package:charging_app/core/models/station_models.dart';

class SessionStartModel {
  SessionStartModel({
    required this.station,
    this.isSending = false,
    this.errorMessage = '',
  });

  final StationDto station;
  final bool isSending;
  final String errorMessage;

  SessionStartModel copyWith({
    StationDto? station,
    bool? isSending,
    String? errorMessage,
  }) =>
      SessionStartModel(
        station: station ?? this.station,
        isSending: isSending ?? this.isSending,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
