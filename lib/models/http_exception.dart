class HttpException implements Exception {
  // from abstract class which is cant directly instantiate it thats why using implement to force it
  final String message;
  HttpException(this.message);

  @override
  String toString() {
    return message;
    // return super.toString();
  }

  
}
