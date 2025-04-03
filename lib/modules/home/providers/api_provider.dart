import 'dart:developer';

import 'package:crud_authentication_task/core/constant/app_variable.dart';
import 'package:crud_authentication_task/widgets/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiProvider extends ChangeNotifier {
  final String apiUrl =
      "https://caff34b586307cc3d780.free.beeceptor.com/api/users/";

  List<dynamic> _datas = [];
  List<dynamic> get datas => _datas;

  final Box localBox = Hive.box('localData');

  List<dynamic> filteredData = [];
  bool _isFetchingData = false;

  Future<void> fetchData() async {
    if (_isFetchingData) return;
    _isFetchingData = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        _datas = json.decode(response.body);
        localBox.put('cachedData', _datas);
        filteredData = List.from(_datas);
      } else {
        log("Get Api Status code : ${response.statusCode.toString()}");
      }
    } catch (e) {
      print("Error fetching datas: $e");
      _datas = localBox.get('cachedData', defaultValue: []);
    }
    _isFetchingData = false;
    notifyListeners();
  }

  Future<void> addData(String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"title": title, "body": body}),
      );
      if (response.statusCode == 200) {
        showSnackBar(isSuccess: true, message: "Create Successfully");
        sendPushNotification("New Data Added", "$title - $body", token ?? "");
        await fetchData();
      } else {
        log("Post Api Status code : ${response.statusCode.toString()}");
      }
    } catch (e) {
      showSnackBar(message: "Error adding data: $e");
    }
  }

  Future<void> updateData(String id, String title, String body) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"title": title, "body": body}),
      );
      if (response.statusCode == 200) {
        showSnackBar(isSuccess: true, message: "Update successfully");
        sendPushNotification("Data Updated", "$title - $body", token ?? "");
        await fetchData();
      } else {
        log("Put Api Status code : ${response.statusCode.toString()}");
      }
    } catch (e) {
      showSnackBar(message: "Error updating data: $e");
    }
  }

  Future<void> updateAllData(String id, String title, String body) async {
    try {
      final response = await http.patch(
        Uri.parse("$apiUrl$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"title": title, "body": body, "id": id}),
      );
      if (response.statusCode == 200) {
        showSnackBar(isSuccess: true, message: "Update successfully");
        await fetchData();
      } else {
        log("Patch Api Status code : ${response.statusCode.toString()}");
      }
    } catch (e) {
      showSnackBar(message: "Error updating data: $e");
    }
  }

  Future<void> deleteData(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl$id"),
        headers: {"Content-Type": "application/json"},
      );
      log("$apiUrl$id");
      if (response.statusCode == 200) {
        log("${response.body}");
        showSnackBar(isSuccess: true, message: "Record remove successfully");
        sendPushNotification(
          "Data Deleted",
          "A record was removed",
          token ?? "",
        );
        await fetchData();
      } else {
        log("Delete Api Status code : ${response.statusCode.toString()}");
      }
    } catch (e) {
      showSnackBar(message: "Error updating data: $e");
    }
  }

  void sendPushNotification(String title, String body, String token) async {
    const String serverKey = "AIzaSyDlFzt_w7tL7jM7cQbWvvUfOvaRIbGyMbw";
    const String fcmUrl = "https://fcm.googleapis.com/fcm/send";

    final Map<String, dynamic> notificationData = {
      "to": token,
      "notification": {"title": title, "body": body, "sound": "default"},
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "status": "done",
        "title": title,
        "body": body,
      },
    };

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$serverKey",
        },
        body: json.encode(notificationData),
      );

      if (response.statusCode == 200) {
        print("Push notification sent successfully!");
      } else {
        print("Failed to send push notification: ${response.body}");
      }
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  void searchData(String query) {
    if (query.isEmpty) {
      filteredData = List.from(_datas);
    } else {
      filteredData =
          _datas
              .where(
                (item) =>
                    item["title"].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
    notifyListeners();
  }
}
