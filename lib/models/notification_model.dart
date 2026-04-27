import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String type; // 'timetable_update', 'cancellation', 'holiday', 'mess', 'bus'
  final String title;
  final String message;
  bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(Map<String, dynamic> data, String id) {
    return AppNotification(
      id: id,
      type: data['type'] ?? 'general',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Color get iconColor {
    switch (type) {
      case 'timetable_update':
        return const Color(0xFF2196F3);
      case 'cancellation':
        return const Color(0xFFF44336);
      case 'holiday':
        return const Color(0xFF4CAF50);
      case 'mess':
        return const Color(0xFFFF9800);
      case 'bus':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData get icon {
    switch (type) {
      case 'timetable_update':
        return Icons.schedule;
      case 'cancellation':
        return Icons.cancel;
      case 'holiday':
        return Icons.celebration;
      case 'mess':
        return Icons.restaurant;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.notifications;
    }
  }
}
