class ChangePasswordModel {
  ChangePasswordModel({
    this.isSending = false,
    this.errorMessage = '',
    this.successMessage = '',
  });

  final bool isSending;
  final String errorMessage;
  final String successMessage;

  ChangePasswordModel copyWith({
    bool? isSending,
    String? errorMessage,
    String? successMessage,
  }) =>
      ChangePasswordModel(
        isSending: isSending ?? this.isSending,
        errorMessage: errorMessage ?? this.errorMessage,
        successMessage: successMessage ?? this.successMessage,
      );
}
