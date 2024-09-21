import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:news_app/logger.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/custom_error.dart';
import 'package:news_app/network/api_interceptors.dart';
import 'package:news_app/utils/constants.dart';

class ApiService{
  ApiService._();
  static final ApiService _instance = ApiService._();
  static ApiService get getInstance => _instance;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Accept' : 'application/json'
      },
    ),
  )..interceptors.add(GetInterceptor());

  // Get All Articles
  Future<Map<String, dynamic>> getArticles(String country) async {
    try{
      String method = 'GET';
      // await LoggerClass.saveLog("ApiService.getArticles_START");
      // NativeCommunication.callNativeMethod("api_call");
      Map<String, dynamic> queryParams = {
        'apiKey' : Constants.apiKey,
        'country' : country,
        'category' : Constants.newsCategory
      };

      final Response<Map<String, dynamic>> response = await _dio.request(
          Constants.getArticlesEndpoint,
          options: Options(method: method),
          queryParameters: queryParams
      );

      final Map<String, dynamic> resJson = response.data!;
      LoggerClass.saveLog("ApiService.getArticles_SUCCESS");
      return resJson;

    }catch(error, stackTrace){
      CustomError customError = _handleError(error);
      // LoggerClass.saveLog("ApiService.getArticles_FAILURE \n\t\t\tError - ${error.toString()} \n\t\t\tStack_Trace: ${stackTrace.toString()}");
      log('API_Service : ${customError.toString()}');
      throw(customError);
    }
  }

  static CustomError _handleError(dynamic error) {
    CustomError customError = CustomError();
    customError.description = error.toString();
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          customError.message = "Timeout occurred while sending or receiving";
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response!.statusCode;
          customError.statusCode = statusCode!;
          switch (statusCode) {
            case 400:
              customError.message = "Bad Request";
              break;
            case 401:
              customError.message = "Unauthorized";
              break;
            case 403:
              customError.message = "Forbidden";
              break;
            case 404:
              customError.message = "Not Found";
              break;
            case 409:
              customError.message = "Conflict";
            case 500:
              customError.message = "Internal Server Error";
              break;
          }
          break;
        case DioExceptionType.cancel:
          customError.message = "Request Cancelled";
          break;
        case DioExceptionType.connectionError:
          customError.message = "Connection Error";
        default:
          customError.message = "Unknown Error";
      }
    }
    return customError;
  }
}