class ProfileModel {
  ProfileModel({
    this.isLoading = false,
    this.errorMessage = '',
    this.email = '',
  });

  final bool isLoading;
  final String errorMessage;
  final String email;

  ProfileModel copyWith({bool? isLoading, String? errorMessage, String? email}) => ProfileModel(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        email: email ?? this.email,
      );
}
