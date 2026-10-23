class SessionDto {
  SessionDto({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.connectorId,
    required this.connectorNumber,
    this.ocppTransactionId,
    this.startedAt,
    this.endedAt,
    this.meterStart,
    this.meterLast,
    this.energyKwh,
    this.batterySoc,
    this.pricePerKwh,
    this.cost,
    required this.isCurrent,
  });

  factory SessionDto.fromJson(Map<String, dynamic> json) => SessionDto(
        id: json['id'] as String,
        stationId: json['stationId'] as String,
        stationName: json['stationName'] as String? ?? '',
        connectorId: json['connectorId'] as String,
        connectorNumber: json['connectorNumber'] as int? ?? 0,
        ocppTransactionId: json['ocppTransactionId'] as String?,
        startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'] as String) : null,
        endedAt: json['endedAt'] != null ? DateTime.tryParse(json['endedAt'] as String) : null,
        meterStart: (json['meterStart'] as num?)?.toDouble(),
        meterLast: (json['meterLast'] as num?)?.toDouble(),
        energyKwh: (json['energyKwh'] as num?)?.toDouble(),
        batterySoc: (json['batterySoc'] as num?)?.toDouble(),
        pricePerKwh: (json['pricePerKwh'] as num?)?.toDouble(),
        cost: (json['cost'] as num?)?.toDouble(),
        isCurrent: json['isCurrent'] as bool? ?? false,
      );

  final String id;
  final String stationId;
  final String stationName;
  final String connectorId;
  final int connectorNumber;
  final String? ocppTransactionId;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final double? meterStart;
  final double? meterLast;
  final double? energyKwh;
  final double? batterySoc;
  final double? pricePerKwh;
  final double? cost;
  final bool isCurrent;
}

class PagedSessions {
  PagedSessions({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory PagedSessions.fromJson(Map<String, dynamic> json) => PagedSessions(
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => SessionDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        page: json['page'] as int? ?? 1,
        pageSize: json['pageSize'] as int? ?? 20,
        total: json['total'] as int? ?? 0,
      );

  final List<SessionDto> items;
  final int page;
  final int pageSize;
  final int total;
}
