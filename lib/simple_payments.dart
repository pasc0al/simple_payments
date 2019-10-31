import 'dart:async';

import 'package:flutter/services.dart';

class SimplePayments {
  static const MethodChannel _channel =
      const MethodChannel('simple_payments');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> payWithPayPal({Map<String, dynamic> map}) async {
    final result = await _channel.invokeMethod('payWithPayPal', map);
    return result;
  }

  static Future<dynamic> payWithStripe({Map<String, dynamic> map}) async {
    final result = await _channel.invokeMethod('payWithStripe', map);
    return result;
  }
}
