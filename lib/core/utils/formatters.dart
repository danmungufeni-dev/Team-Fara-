import 'package:intl/intl.dart';

abstract class AppFormatters {
  static String currencyUgx(num amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return '${formatter.format(amount)} UGX';
  }

  static String currency(num amount, String code) {
    final formatter = NumberFormat('#,###', 'en_US');
    return '${formatter.format(amount)} $code';
  }

  static String distance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()} meters';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('dd MMM, HH:mm').format(dateTime);
  }

  static String maskPhone(String phone) {
    if (phone.length <= 6) return phone;
    final prefix = phone.substring(0, 4);
    final suffix = phone.substring(phone.length - 3);
    return '$prefix ••• $suffix';
  }
}
