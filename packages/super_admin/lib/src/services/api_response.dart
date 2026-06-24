import '../domain/exceptions/app_exception.dart';

class ApiResponse<T> {
  final T? data;
  final AppException? error;
  final bool isLoading;
  final bool isSuccess;

  const ApiResponse({
    this.data,
    this.error,
    this.isLoading = false,
    this.isSuccess = false,
  });

  factory ApiResponse.loading() => const ApiResponse(isLoading: true);

  factory ApiResponse.success(T data) => ApiResponse(data: data, isSuccess: true);

  factory ApiResponse.error(AppException error) => ApiResponse(error: error);

  bool get hasData => data != null;
  bool get hasError => error != null;
}
