import 'package:charging_app/core/models/session_models.dart';

class SessionCurrentModel {
  SessionCurrentModel({
    this.isLoading = false,
    this.isStopping = false,
    this.errorMessage = '',
    this.session,
  });

  final bool isLoading;
  final bool isStopping;
  final String errorMessage;
  final SessionDto? session;

  SessionCurrentModel copyWith({
    bool? isLoading,
    bool? isStopping,
    String? errorMessage,
    SessionDto? session,
    bool clearSession = false,
  }) =>
      SessionCurrentModel(
        isLoading: isLoading ?? this.isLoading,
        isStopping: isStopping ?? this.isStopping,
        errorMessage: errorMessage ?? this.errorMessage,
        session: clearSession ? null : (session ?? this.session),
      );
}
