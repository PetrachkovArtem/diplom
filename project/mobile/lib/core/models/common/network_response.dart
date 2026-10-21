class NetworkResponse {
  NetworkResponse(this.status);

  bool isSuccess() => status >= 200 && status < 300;

  int status;
  String? errorMessage;
}

class NetworkResponseWithResult extends NetworkResponse {
  NetworkResponseWithResult(super.status);
  Map<String, dynamic>? result;
}

class NetworkResponseWithListResult extends NetworkResponse {
  NetworkResponseWithListResult(super.status);
  List? result;
}
