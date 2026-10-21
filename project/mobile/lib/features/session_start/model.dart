import 'package:charging_app/core/models/station_models.dart';

class SessionStartModel {
  SessionStartModel({
    required this.station,
    this.isSending = false,
    this.errorMessage = '',
    this.selectedConnectorId,
  });

  final StationDto station;
  final bool isSending;
  final String errorMessage;
  final String? selectedConnectorId;

  SessionStartModel copyWith({
    StationDto? station,
    bool? isSending,
    String? errorMessage,
    String? selectedConnectorId,
  }) =>
      SessionStartModel(
        station: station ?? this.station,
        isSending: isSending ?? this.isSending,
        errorMessage: errorMessage ?? this.errorMessage,
        selectedConnectorId: selectedConnectorId ?? this.selectedConnectorId,
      );
}
