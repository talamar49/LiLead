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
  static Future<bool> launchGoogleCalendar({
    String? title,
    String? details,
    DateTime? startDateTime,
    DateTime? endDateTime,
    List<String>? emails,
  }) async {
    // Format dates for Google Calendar URL (YYYYMMDDTHHmmssZ)
    String? dates;
    if (startDateTime != null && endDateTime != null) {
      final start = startDateTime.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first + 'Z';
      final end = endDateTime.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first + 'Z';
      dates = '$start/$end';
    }

    // Build web URL with parameters
    final queryParams = <String, String>{
      'action': 'TEMPLATE',
      if (title != null) 'text': title,
      if (details != null) 'details': details,
      if (dates != null) 'dates': dates,
      if (emails != null && emails.isNotEmpty) 'add': emails.join(','),
    };

    final webUri = Uri.https('calendar.google.com', '/calendar/render', queryParams);
    
    // Try to launch web URL directly as it's more reliable for pre-filling data
    if (await canLaunchUrl(webUri)) {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
