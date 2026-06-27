import 'package:intl/intl.dart';

import '../constants/text_strings.dart';

/// VALIDATION CLASS
class TValidator {
  /// Empty Text Validation
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب.';
    }

    return null;
  }

  static String? validatePinCode(String? pinCode) {
    if (pinCode == null || pinCode.isEmpty) {
      return 'الرمز البريدي مطلوب.';
    }

    // Check for minimum pinCode length
    if (pinCode.length < 6) {
      return 'يجب أن يحتوي الرمز البريدي على 6 أرقام.';
    }

    return null;
  }

  static String? validateAge(String? input) {
    if (input == null || input.isEmpty) {
      return 'تاريخ الميلاد مطلوب.';
    }

    try {
      // Parse the input date in the 'dd-MMM-yyyy' format
      final DateFormat format = DateFormat('dd-MMM-yyyy');
      final DateTime dateOfBirth = format.parse(input);

      final DateTime today = DateTime.now();
      final int age =
          today.year -
          dateOfBirth.year -
          ((today.month < dateOfBirth.month ||
                  (today.month == dateOfBirth.month &&
                      today.day < dateOfBirth.day))
              ? 1
              : 0);

      if (age < 18) {
        return TTexts.dateOfBirthError;
      }
    } catch (e) {
      return 'تنسيق التاريخ غير صالح. استخدم dd-MMM-yyyy.';
    }

    return null;
  }

  /// Username Validation
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'اسم المستخدم مطلوب.';
    }

    // Define a regular expression pattern for the username.
    const pattern = r"^[a-zA-Z0-9_-]{3,20}$";

    // Create a RegExp instance from the pattern.
    final regex = RegExp(pattern);

    // Use the hasMatch method to check if the username matches the pattern.
    bool isValid = regex.hasMatch(username);

    // Check if the username doesn't start or end with an underscore or hyphen.
    if (isValid) {
      isValid =
          !username.startsWith('_') &&
          !username.startsWith('-') &&
          !username.endsWith('_') &&
          !username.endsWith('-');
    }

    if (!isValid) {
      return 'اسم المستخدم غير صالح.';
    }

    return null;
  }

  /// Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح.';
    }

    return null;
  }

  /// Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة.';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل.';
    }

    return null;
  }

  /// Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب.';
    }

    final returnValue = validatePhoneNumberFormat(value);

    return returnValue;
  }

  static String? validatePhoneNumberFormat(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Regular expression for phone number validation (assuming a 10-digit US phone number format)
    final phoneRegExp = RegExp(r'^\d{10}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'تنسيق رقم الهاتف غير صالح. يجب أن يحتوي على 10 أرقام.';
    }

    return null;
  }

  // Add more custom validators as needed for your specific requirements.
}
