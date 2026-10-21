class RegisterModel {
  RegisterModel({
    this.isSending = false,
    this.consent = false,
    this.errorMessage = '',
  });

  final bool isSending;
  final bool consent;
  final String errorMessage;

  RegisterModel copyWith({bool? isSending, bool? consent, String? errorMessage}) => RegisterModel(
        isSending: isSending ?? this.isSending,
        consent: consent ?? this.consent,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
