import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eglamheelhangout_mobile/models/notifications.dart';
import 'package:eglamheelhangout_mobile/models/winner_notification_entity.dart';
import 'package:eglamheelhangout_mobile/providers/base_providers.dart';

class NotificationProvider extends BaseProvider<Notifications> {
  NotificationProvider() : super("UserNotifications");
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  @override
  Notifications fromJson(Map<String, dynamic> json) {
    return Notifications.fromJson(json);
  }

  
  Future<List<Notifications>> getUnreadNotifications({String? type}) async {
    var url = "$baseUrl$endpoint/unread";
    if (type != null) {
      url += "?type=$type";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    final response = await http!.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Notifications.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch unread notifications");
    }
  }

  

// Future<void> markAsRead(int id) async {
//    print("Pozivam markAsRead za notification id = $id");
//   var uri = Uri.parse('$baseUrl$endpoint/mark-read/$id');
//    var headers = createHeaders();
//   headers['Content-Type'] = 'application/json';
//   var response = await http!.put(uri, headers: headers);

//   if (response.statusCode != 200 && response.statusCode != 204) {
//     throw Exception('Failed to mark notification as read');
//   }
// }

Future<void> markAsRead(int id) async {
  print("Pozivam markAsRead za notification id = $id");
  var uri = Uri.parse('$baseUrl$endpoint/mark-read/$id');
  var headers = createHeaders();
  headers['Content-Type'] = 'application/json';
  var response = await http!.put(uri, headers: headers);

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Failed to mark notification as read');
  }

  await refreshUnreadCount(); 
}

Future<List<WinnerNotificationEntity>> getWinnerNotifications() async {
  var url = "$baseUrl/Giveaway/user/winner-notifications";
  var uri = Uri.parse(url);
  var headers = createHeaders(); // Osiguraj da se ispravno postavlja Auth header

  final response = await http!.get(uri, headers: headers);

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList
        .map((e) => WinnerNotificationEntity.fromJson(e))
        .toList();
  } else {
    debugPrint(">>> [getWinnerNotifications] failed: ${response.body}");
    throw Exception("Failed to fetch winner notifications");
  }
}

Future<bool> hasUnreadNotifications() async {
  final uri = Uri.parse("${baseUrl}UserNotifications/unread");
  final response = await http!.get(uri, headers: createHeaders());

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.any((n) => n["isRead"] == false); 
  } else {
    throw Exception("Failed to fetch unread notifications");
  }
}

Future<void> refreshUnreadCount() async {
  try {
    final unread = await getUnreadNotifications();
    _unreadCount = unread.length;
    notifyListeners(); 
  } catch (e) {
    debugPrint("Failed to refresh unread count: $e");
  }
}




}
