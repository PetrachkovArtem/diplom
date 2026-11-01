class StationAddModel {
  StationAddModel({
    this.isLoading = false,
    this.errorMessage = '',
    this.successMessage = '',
    this.urlTemplate = '',
    this.bindToken = '',
  });

  final bool isLoading;
  final String errorMessage;
  final String successMessage;
  final String urlTemplate;
  final String bindToken;

  StationAddModel copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? urlTemplate,
    String? bindToken,
  }) =>
      StationAddModel(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        successMessage: successMessage ?? this.successMessage,
        urlTemplate: urlTemplate ?? this.urlTemplate,
        bindToken: bindToken ?? this.bindToken,
      );
}
