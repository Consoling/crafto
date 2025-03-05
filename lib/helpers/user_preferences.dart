import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  //  keys
  static const String usernameKey = 'username';
  static const String userIDKey = 'userID';
  static const String phoneNumberKey = 'phoneNumber';
  static const String emailKey = 'email';
  static const String languageKey = 'language';
  static const String accountTypeKey = 'accountType';
  static const String isPremiumKey = 'isPremium';
  static const String isVerifiedKey = 'isVerified';

  // Save data to SharedPreferences
  static Future<void> saveUserData({
    required String username,
    required String userID,
    required String phoneNumber,
    required String email,
    required String language,
    required String accountType,
    required bool isPremium,
    required bool isVerified,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, username);
    await prefs.setString(userIDKey, userID);
    await prefs.setString(phoneNumberKey, phoneNumber);
    await prefs.setString(emailKey, email);
    await prefs.setString(languageKey, language);
    await prefs.setString(accountTypeKey, accountType);
    await prefs.setBool(isPremiumKey, isPremium);
    await prefs.setBool(isVerifiedKey, isVerified);
  }

  // Load data from SharedPreferences
  static Future<Map<String, dynamic>> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString(usernameKey) ?? '';
    String userID = prefs.getString(userIDKey) ?? '';
    String phoneNumber = prefs.getString(phoneNumberKey) ?? '';
    String email = prefs.getString(emailKey) ?? '';
    String language = prefs.getString(languageKey) ?? 'English';
    String accountType = prefs.getString(accountTypeKey) ?? 'Personal';
    bool isPremium = prefs.getBool(isPremiumKey) ?? false;
    bool isVerified = prefs.getBool(isVerifiedKey) ?? false;

    return {
      'username': username,
      'userID': userID,
      'phoneNumber': phoneNumber,
      'email': email,
      'language': language,
      'accountType': accountType,
      'isPremium': isPremium,
      'isVerified': isVerified,
    };
  }
}
