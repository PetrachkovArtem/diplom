class StationAddModel {
  StationAddModel({
    this.isLoading = false,
    this.errorMessage = '',
    this.urlTemplate = '',
    this.bindToken = '',
  });

  final bool isLoading;
  final String errorMessage;
  final String urlTemplate;
  final String bindToken;

  StationAddModel copyWith({
    bool? isLoading,
    String? errorMessage,
    String? urlTemplate,
    String? bindToken,
  }) =>
      StationAddModel(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        urlTemplate: urlTemplate ?? this.urlTemplate,
        bindToken: bindToken ?? this.bindToken,
      );
}
