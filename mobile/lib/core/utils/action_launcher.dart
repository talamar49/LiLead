import 'package:url_launcher/url_launcher.dart';

class ActionLauncher {
  // Launch WhatsApp
  static Future<bool> launchWhatsApp(String phoneNumber) async {
    // Remove any non-digit characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanNumber');
    
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  // Launch phone dialer
  static Future<bool> launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  // Launch email client
  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );
    
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // Launch Google Calendar
  static Future<bool> launchGoogleCalendar({String? title, String? details}) async {
    // Try to open Google Calendar app first, then fallback to web
    final appUri = Uri.parse('content://com.android.calendar/time');
    
    // If app doesn't work, use web URL
    final webUri = Uri.parse('https://calendar.google.com/calendar/r/eventedit');
    
    try {
      if (await canLaunchUrl(appUri)) {
        return await launchUrl(appUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Fallback to web
    }
    
    if (await canLaunchUrl(webUri)) {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
