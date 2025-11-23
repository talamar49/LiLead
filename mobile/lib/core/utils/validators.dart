class Validators {
  // Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Phone validation regex (international format)
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[\d\s\-()]{10,}$',
  );

  /// Validates email format
  /// Returns true if valid, false otherwise
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Validates email and returns error message
  /// Returns null if valid, error message otherwise
  static String? validateEmail(String? email, String emptyMessage, String invalidMessage) {
    if (email == null || email.isEmpty) {
      return emptyMessage;
    }
    if (!isValidEmail(email)) {
      return invalidMessage;
    }
    return null;
  }

  /// Validates password length
  /// Returns true if valid (at least minLength characters), false otherwise
  static bool isValidPassword(String? password, {int minLength = 6}) {
    if (password == null || password.isEmpty) return false;
    return password.length >= minLength;
  }

  /// Validates password and returns error message
  /// Returns null if valid, error message otherwise
  static String? validatePassword(
    String? password,
    String emptyMessage,
    String shortMessage, {
    int minLength = 6,
  }) {
    if (password == null || password.isEmpty) {
      return emptyMessage;
    }
    if (password.length < minLength) {
      return shortMessage;
    }
    return null;
  }

  /// Validates phone number format
  /// Returns true if valid, false otherwise
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    return _phoneRegex.hasMatch(phone.trim());
  }

  /// Validates phone and returns error message
  /// Returns null if valid, error message otherwise
  static String? validatePhone(String? phone, String emptyMessage, String invalidMessage) {
    if (phone == null || phone.isEmpty) {
      return emptyMessage;
    }
    if (!isValidPhone(phone)) {
      return invalidMessage;
    }
    return null;
  }

  /// Validates password confirmation
  /// Returns null if valid, error message otherwise
  static String? validatePasswordConfirm(
    String? password,
    String? confirmPassword,
    String emptyMessage,
    String mismatchMessage,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return emptyMessage;
    }
    if (confirmPassword != password) {
      return mismatchMessage;
    }
    return null;
  }

  /// Validates required field
  /// Returns null if valid, error message otherwise
  static String? validateRequired(String? value, String emptyMessage) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage;
    }
    return null;
  }
}

