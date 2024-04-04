class CustomError{
  int statusCode;
  String message;
  String description;

  CustomError({
    this.statusCode = 0,
    this.message = "Unknown Error",
    this.description = "",
  });

  @override
  String toString() {
    return '''
    Status Code : $statusCode
    Message : $message
    Description : $description
    ''';
  }
}