class CValidator {
  // Empty field validation
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegExp = RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');

    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Invalid email address.';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  // Nigerian phone number validation
  // Accepts: 08031234567, +2348031234567, 2348031234567, 0803 123 4567
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }

    final phone = value.replaceAll(RegExp(r'[\s\-]'), '');
    final phoneRegExp = RegExp(r'^(\+?234|0)[789]\d{9}$');

    if (!phoneRegExp.hasMatch(phone)) {
      return 'Invalid phone number.';
    }
    return null;
  }
}
