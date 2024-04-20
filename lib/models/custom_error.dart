class CustomError{
  int statusCode;
  String message;
  String description;
  String errorType;

  CustomError({
    this.statusCode = 0,
    this.message = "Unknown Error",
    this.description = "",
    this.errorType = ""
  });

  @override
  String toString() {
    return '''
    Status Code : $statusCode
    Message : $message
    Description : $description
    Error Type : $errorType
    ''';
  }
}