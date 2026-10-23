class ProfileModel {
  ProfileModel({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage = '',
    this.successMessage = '',
    this.email = '',
    this.pricePerKwh = '',
  });

  final bool isLoading;
  final bool isSaving;
  final String errorMessage;
  final String successMessage;
  final String email;
  final String pricePerKwh;

  ProfileModel copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    String? email,
    String? pricePerKwh,
  }) =>
      ProfileModel(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        errorMessage: errorMessage ?? this.errorMessage,
        successMessage: successMessage ?? this.successMessage,
        email: email ?? this.email,
        pricePerKwh: pricePerKwh ?? this.pricePerKwh,
      );
}
