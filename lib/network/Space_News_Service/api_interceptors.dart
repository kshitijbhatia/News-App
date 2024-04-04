import 'dart:developer';
import 'package:dio/dio.dart';

class GetInterceptor extends Interceptor{

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('Inside Request Interceptor');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('Inside Response Interceptor');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('Inside Error Interceptor');
    super.onError(err, handler);
  }
}