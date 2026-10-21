import 'package:charging_app/core/models/session_models.dart';

class HistoryModel {
  HistoryModel({
    this.isLoading = false,
    this.errorMessage = '',
    this.items = const [],
    this.page = 1,
    this.total = 0,
    this.pageSize = 20,
  });

  final bool isLoading;
  final String errorMessage;
  final List<SessionDto> items;
  final int page;
  final int total;
  final int pageSize;

  int get totalPages => total == 0 ? 1 : ((total + pageSize - 1) ~/ pageSize);

  HistoryModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SessionDto>? items,
    int? page,
    int? total,
    int? pageSize,
  }) =>
      HistoryModel(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        items: items ?? this.items,
        page: page ?? this.page,
        total: total ?? this.total,
        pageSize: pageSize ?? this.pageSize,
      );
}
