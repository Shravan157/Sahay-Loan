class NotificationModel {
  final String id;
  final String loanId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.loanId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      loanId: json['loan_id'] ?? json['data']?['loan_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['is_read'] ?? json['read'] ?? false,
      createdAt: json['created_at'] != null && json['created_at'].toString().isNotEmpty
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_id': loanId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? loanId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

enum NotificationType {
  loanUpdate,
  emiReminder,
  paymentConfirmed,
  applicationStatus,
  general;

  String get value {
    switch (this) {
      case NotificationType.loanUpdate:
        return 'loan_update';
      case NotificationType.emiReminder:
        return 'emi_reminder';
      case NotificationType.paymentConfirmed:
        return 'payment_confirmed';
      case NotificationType.applicationStatus:
        return 'application_status';
      case NotificationType.general:
        return 'general';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'loan_update':
        return NotificationType.loanUpdate;
      case 'emi_reminder':
        return NotificationType.emiReminder;
      case 'payment_confirmed':
        return NotificationType.paymentConfirmed;
      case 'application_status':
        return NotificationType.applicationStatus;
      default:
        return NotificationType.general;
    }
  }
}
