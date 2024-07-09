import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/services.dart';

class MyNativeFunction {
  static const platform = MethodChannel("com.example/customChannel");

  static Future<String> setTagScannedListener(
      Function(String epc) onTagScanned) async {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onTagScanned') {
        final String epc = call.arguments;
        onTagScanned(epc);
        return epc;
      }
      return null;
    });
    return "Listening";
  }

  static Future<String> getReaderActiveState() async {
    try {
      final result = await platform.invokeMethod('getServiceVersion');
      return result;
    } catch (e) {
      print('Error123: $e');
      return 'Error';
    }
  }

  static Future<bool> GetConnection() async {
    try {
      final result = await platform.invokeMethod('Connection');

      return result;
    } catch (e) {
      print(e);
      return Future.error(false);
    }
  }

  static Future<dynamic> GetBatteryLifePercent() async {
    try {
      final result = await platform.invokeMethod('GetBattery');
      print(jsonEncode(result));
      return result;
    } catch (e) {
      print(e);
      return Future.error(false);
    }
  }

  static Future<dynamic> GetTrgMode() async {
    try {
      final result = await platform.invokeMethod('TrgMode');
      print(jsonEncode(result));
      return result;
    } catch (e) {
      print("Error this ${e}");
      return Future.error(e);
    }
  }

  static Future<dynamic> SetTrgMode(bool status) async {
    try {
      final result =
          await platform.invokeMethod('TrgMode', {"statusTrg": status});
      print(jsonEncode(result));
      return result;
    } catch (e) {
      print("Error this ${e}");
      return Future.error(e);
    }
  }

  static Future<dynamic> GetSwtichStatus() async {
    try {
      final result = await platform.invokeMethod('GetRFIDSwitchStatus');
      print("Test Json ${jsonEncode(result)}");
      return result;
    } catch (e) {
      print("Error this ${e}");
      return Future.error(e);
    }
  }

  static void GetDeviecInfo() async {
    try {
      final result = await platform.invokeMethod('DeviceInfo');
      print(result);
    } catch (e) {
      print("Error this ${e}");
    }
  }

  static void GetWorkMode() async {
    try {
      final result = await platform.invokeMethod('GetWorkMode');
      print(result);
    } catch (e) {
      print("Error this ${e}");
    }
  }

  static Future<String> SetWorkMode(String mode) async {
    try {
      final result =
          await platform.invokeMethod('SetWorkMode', {'mode': 'MultiTagMode'});
      print(result);
      return result;
    } catch (e) {
      throw Exception();
    }
  }

  static Future<dynamic> SetSoftScanTrgMode(bool status) async {
    try {
      final result =
          await platform.invokeMethod('SetSoftScanTrgMode', {"status": status});
      print(result);
      return result;
    } catch (e) {
      print("Error this ${e}");
      return Future.error(e);
    }
  }

  static Future<dynamic> StartInventoryRound(int count) async {
    try {
      final result =
          await platform.invokeMethod('StartInventoryRound', {"count": count});
      print("Start ${result}");
      return result;
    } catch (e) {
      print("Error this ${e}");
      return Future.error(e);
    }
  }

  static Future<dynamic> StopInventoryRound() async {
    try {
      GetWorkMode();
      final result = await platform.invokeMethod('StopInventoryRound');
      print("Stop ${result}");
      return result;
    } catch (e) {
      print("Error this ${e}");
      return Future.error(e);
    }
  }

  static Future<String> GetScanMode() async {
    try {
      final result = await platform.invokeMethod('GetScanMode');
      print("JsonGetScanMode ${result}");
      return result.toString();
    } catch (e) {
      print("Error this ${e}");
      return Future.error(e);
    }
  }

  static Future<String> SetScanMode(String mode) async {
    try {
      print("Send Mode$mode");
      final result = await platform
          .invokeMethod('SetScanMode', {'mode': mode.toLowerCase()});
      print("Status Result = ${result}");
      return result;
    } catch (e) {
      throw Exception();
    }
  }
}
