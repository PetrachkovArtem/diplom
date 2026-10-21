class ConnectorDto {
  ConnectorDto({
    required this.id,
    required this.evseId,
    required this.connectorNumber,
    required this.status,
  });

  factory ConnectorDto.fromJson(Map<String, dynamic> json) => ConnectorDto(
        id: json['id'] as String,
        evseId: json['evseId'] as int,
        connectorNumber: json['connectorNumber'] as int,
        status: json['status'] as String? ?? '',
      );

  final String id;
  final int evseId;
  final int connectorNumber;
  final String status;
}

class StationDto {
  StationDto({
    required this.id,
    required this.ocppChargePointId,
    required this.displayName,
    required this.isOnline,
    required this.connectorCount,
    required this.hasCurrentSession,
    required this.connectors,
  });

  factory StationDto.fromJson(Map<String, dynamic> json) => StationDto(
        id: json['id'] as String,
        ocppChargePointId: json['ocppChargePointId'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        isOnline: json['isOnline'] as bool? ?? false,
        connectorCount: json['connectorCount'] as int? ?? 0,
        hasCurrentSession: json['hasCurrentSession'] as bool? ?? false,
        connectors: (json['connectors'] as List<dynamic>? ?? [])
            .map((e) => ConnectorDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final String ocppChargePointId;
  final String displayName;
  final bool isOnline;
  final int connectorCount;
  final bool hasCurrentSession;
  final List<ConnectorDto> connectors;
}

class BindUrlResponse {
  BindUrlResponse({
    required this.bindToken,
    required this.urlTemplate,
  });

  factory BindUrlResponse.fromJson(Map<String, dynamic> json) => BindUrlResponse(
        bindToken: json['bindToken'] as String? ?? '',
        urlTemplate: json['urlTemplate'] as String? ?? '',
      );

  final String bindToken;
  final String urlTemplate;
}
