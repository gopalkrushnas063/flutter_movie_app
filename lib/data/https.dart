// // lib/data/https.dart
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';

// class Https {
//   static Dio get apiURL {
//     Dio dio = Dio();
//     try {
//       dio.options.baseUrl = "https://reqres.in/api/";
//       dio.interceptors.addAll([
//         InterceptorsWrapper(
//           onRequest: (options, handler) => handler.next(options),
//           onResponse: (response, handler) => handler.next(response),
//           onError: (e, handler) => handler.next(e),
//         ),
//       ]);
//     } catch (e) {
//       debugPrint("Dio initialization error: $e");
//     }
//     return dio;
//   }

//   static Dio get movieApiURL {
//     Dio dio = Dio();
//     try {
//       dio.options.baseUrl = "https://api.themoviedb.org/3/";
//       dio.interceptors.addAll([
//         InterceptorsWrapper(
//           onRequest: (options, handler) {
//             options.queryParameters['api_key'] = '2bb6427016a1701f4d730bde6d366c84';
//             return handler.next(options);
//           },
//           onResponse: (response, handler) => handler.next(response),
//           onError: (e, handler) => handler.next(e),
//         ),
//       ]);
//     } catch (e) {
//       debugPrint("Movie Dio initialization error: $e");
//     }
//     return dio;
//   }
// }

//--------------------------------------------------------------

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Https {
  static Dio get apiURL {
    final dio = Dio();
    try {
      // Base configuration
      dio.options = BaseOptions(
        baseUrl: "https://reqres.in/api/",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      );

      // Interceptors
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            // Add any request modifications here
            debugPrint('Request to ${options.uri}');
            return handler.next(options);
          },
          onResponse: (Response response, ResponseInterceptorHandler handler) {
            // Process response here
            debugPrint('Response from ${response.requestOptions.uri}');
            return handler.next(response);
          },
          onError: (DioException error, ErrorInterceptorHandler handler) {
            // Handle errors here
            debugPrint('Error occurred: ${error.message}');
            return handler.next(error);
          },
        ),
      );
    } catch (e) {
      debugPrint("Dio initialization error: $e");
    }
    return dio;
  }

  static Dio get movieApiURL {
    final dio = Dio();
    try {
      // Base configuration
      dio.options = BaseOptions(
        baseUrl: "https://api.themoviedb.org/3/",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      );

      // Interceptors
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            // Add API key to all requests
            options.queryParameters['api_key'] =
                '2bb6427016a1701f4d730bde6d366c84';

            // Log request
            debugPrint('Movie API request to ${options.uri}');

            return handler.next(options);
          },
          onResponse: (Response response, ResponseInterceptorHandler handler) {
            // Process successful responses
            debugPrint(
              'Movie API response from ${response.requestOptions.uri}',
            );
            return handler.next(response);
          },
          onError: (DioException error, ErrorInterceptorHandler handler) {
            // Handle API errors
            debugPrint('Movie API error: ${error.message}');

            // You could add retry logic here if needed
            return handler.next(error);
          },
        ),
      );

      // Add logging interceptor for debugging
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    } catch (e) {
      debugPrint("Movie Dio initialization error: $e");
    }
    return dio;
  }

  static Dio get omdbApiURL {
    final dio = Dio();
    try {
      // Base configuration
      dio.options = BaseOptions(
        baseUrl: "http://www.omdbapi.com/",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      );

      // Interceptors
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            // Add API key to all requests
            options.queryParameters['apikey'] = '1e5920fc';

            // Log request
            debugPrint('OMDB API request to ${options.uri}');

            return handler.next(options);
          },
          onResponse: (Response response, ResponseInterceptorHandler handler) {
            // Process successful responses
            debugPrint('OMDB API response from ${response.requestOptions.uri}');
            return handler.next(response);
          },
          onError: (DioException error, ErrorInterceptorHandler handler) {
            // Handle API errors
            debugPrint('OMDB API error: ${error.message}');
            return handler.next(error);
          },
        ),
      );

      // Add logging interceptor for debugging
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    } catch (e) {
      debugPrint("OMDB Dio initialization error: $e");
    }
    return dio;
  }
}
