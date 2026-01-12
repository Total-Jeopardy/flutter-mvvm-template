class ApiResponse<T> {
  final int statusCode;
  final T data;

  const ApiResponse({required this.statusCode, required this.data});
}
