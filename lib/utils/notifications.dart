import 'package:flutter/material.dart';

enum NotificationType { info, success, error }

void showAppNotification(BuildContext context, String message,
    {NotificationType type = NotificationType.info, Duration? duration}) {
  final color = _colorForType(context, type);
  final icon = _iconForType(type);

  final snack = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    elevation: 6,
    backgroundColor: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: duration ?? const Duration(seconds: 3),
    content: Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snack);
}

Color _colorForType(BuildContext context, NotificationType type) {
  switch (type) {
    case NotificationType.success:
      return Colors.green.shade700;
    case NotificationType.error:
      return Colors.red.shade700;
    case NotificationType.info:
      return Theme.of(context).primaryColor;
  }
}

IconData _iconForType(NotificationType type) {
  switch (type) {
    case NotificationType.success:
      return Icons.check_circle_outline;
    case NotificationType.error:
      return Icons.error_outline;
    case NotificationType.info:
      return Icons.info_outline;
  }
}
