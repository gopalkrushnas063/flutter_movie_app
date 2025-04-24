// lib/data/https.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Https {
  static Dio get apiURL {
    Dio dio = Dio();
    try {
      dio.options.baseUrl = "https://reqres.in/api/";
      dio.interceptors.addAll([
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.next(options),
          onResponse: (response, handler) => handler.next(response),
          onError: (e, handler) => handler.next(e),
        ),
      ]);
    } catch (e) {
      debugPrint("Dio initialization error: $e");
    }
    return dio;
  }

  static Dio get movieApiURL {
    Dio dio = Dio();
    try {
      dio.options.baseUrl = "https://api.themoviedb.org/3/";
      dio.interceptors.addAll([
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.queryParameters['api_key'] = '2bb6427016a1701f4d730bde6d366c84';
            return handler.next(options);
          },
          onResponse: (response, handler) => handler.next(response),
          onError: (e, handler) => handler.next(e),
        ),
      ]);
    } catch (e) {
      debugPrint("Movie Dio initialization error: $e");
    }
    return dio;
  }
}