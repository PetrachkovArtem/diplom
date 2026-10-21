class LoginModel {
  LoginModel({
    this.isSending = false,
    this.errorMessage = '',
  });

  final bool isSending;
  final String errorMessage;

  LoginModel copyWith({bool? isSending, String? errorMessage}) => LoginModel(
        isSending: isSending ?? this.isSending,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
