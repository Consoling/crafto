// Functionality: This file contains functions to fetch user data from the backend, sync data with the backend, and update user profile.
import 'dart:async';

import 'package:crafto/helpers/user_preferences.dart';
import 'package:crafto/main.dart';
import 'package:crafto/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart'; // For json.decode()


Dio dio = Dio(); // Dio instance

Future<Map<String, dynamic>> fetchUserDataFromBackend(String userID) async {
  String? token = await UserPreferences.getAccessToken();
  print('User iD main: $userID');
  print('${dotenv.env['FETCH_GLOBAL_DATA_ROUTE']}/$userID');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please log in first.');
  }
  print('${token}');

  try {
    Response response = await dio.get(
      '${dotenv.env['FETCH_GLOBAL_DATA_ROUTE']}/$userID',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Success');
      print(response.data);
      return response.data;


    } else {
      throw Exception('Failed to load user data');
    }
  } catch (e) {
    print("Error fetching user data: $e");
    throw Exception('Failed to fetch user data');
  }
}

// Function to sync data with the backend and save to SharedPreferences
Future<void> syncDataWithBackend() async {
  String? userID = await UserPreferences.getUserId();
  try {
    Map<String, dynamic> userDataFromBackend = await fetchUserDataFromBackend(userID!);

    // Save the fetched data to SharedPreferences
    await UserPreferences.saveUserData(
      username: userDataFromBackend['username'],
      userID: userDataFromBackend['userID'],
      phoneNumber: userDataFromBackend['phoneNumber'],
      email: userDataFromBackend['email'],
      language: userDataFromBackend['language'],
      accountType: userDataFromBackend['accountType'],
      isPremium: userDataFromBackend['isPremium'],
      isVerified: userDataFromBackend['isVerified'],
    );
  } catch (e) {
    print("Error syncing with backend: $e");
  }
}

// Function to update user profile (both backend and SharedPreferences) using Dio
Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
  String? token = await UserPreferences.getAccessToken();

  try {
    // Update the backend first
    Response response = await dio.post(
      '${dotenv.env['UPDATE_GLOBAL_DATA_ROUTE']}',
      data: json.encode(updatedData),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      // If update is successful, update SharedPreferences
      await UserPreferences.saveUserData(
        username: updatedData['username'],
        userID: updatedData['userID'],
        phoneNumber: updatedData['phoneNumber'],
        email: updatedData['email'],
        language: updatedData['language'],
        accountType: updatedData['accountType'],
        isPremium: updatedData['isPremium'],
        isVerified: updatedData['isVerified'],
      );
    }
  } catch (e) {
    print("Error updating user profile: $e");
  }
}


Future<void> signOut(BuildContext context) async {

  String? token = await UserPreferences.getAccessToken();

  if (token == null || token.isEmpty) {
    print('No token found, user is already logged out');
    return;
  }

  try {
    final response = await dio.post(
      '${dotenv.env['LOGOUT_ROUTE']}', // Replace with your backend logout route
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      await UserPreferences.deleteTokens();


      showLogoutDialog(context);

      // Redirect the user to the HomeScreen after a delay
      Future.delayed(Duration(seconds: 5), () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return FadeTransition(
                opacity: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      });
    } else {
      throw Exception('Failed to log out');
    }
  } catch (e) {
    print("Error signing out: $e");
    // Handle errors (e.g., show a dialog with the error message)
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing the dialog by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.green,),
            SizedBox(width: 20),
            Text('You have been logged out.'),
          ],
        ),
      );
    },
  );
}







void showComingSoonDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 50,
              color: Colors.blue,
            ),
            SizedBox(height: 10),
            Text(
              "Coming Soon",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              "Feature update: This will allow you to create your own post and upload it.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showPlansComparisonDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 50,
              color: Colors.orange,
            ),
            SizedBox(height: 10),
            Text(
              "Plans Comparison",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              "Free Plan:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            Text(
              "- Limited access to features\n- Basic support\n- Ads included",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Premium Plan:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            Text(
              "- Full access to all features\n- Priority support\n- Ad-free experience\n- Exclusive updates",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              "Subscribe to Premium",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // Add subscription logic here
              Navigator.of(context).pop();
              // Code to open subscription page, e.g., navigate to a new screen or show another dialog
            },
          ),
          CupertinoDialogAction(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}



void showUsernameChangeDialog(BuildContext context, String currentUsername) {
  final TextEditingController usernameController = TextEditingController(text: currentUsername);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 50,
              color: Colors.blue,
            ),
            SizedBox(width: 10),
            Text(
              "Change Username",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Username Text
              Text(
                "Current Username:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              Text(
                currentUsername,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),

              // New Username Input Field
              Text(
                "New Username:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Enter new username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Change Button
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Logic to update the username goes here
                    String newUsername = usernameController.text;
                    print('New Username: $newUsername');
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text(
                    "Change",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 20), // Space between buttons
                // Cancel Button
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

bool _isAccessTokenExpired(String token) {
  // Decode the token
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

  // Get the expiration time (exp) from the token payload
  int expiryDate = decodedToken['exp'];

  // Get the current time in seconds since Unix epoch
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // Check if the token has expired
  return expiryDate < currentTime;
}

Future<void> refreshAccessToken(BuildContext context) async {
  String? accessToken = await UserPreferences.getAccessToken();
  String? refreshToken = await UserPreferences.getRefreshToken();

  // Check if refresh token is available and the access token has expired
  if (accessToken != null && refreshToken != null && _isAccessTokenExpired(accessToken)) {
    print('Access token has expired, refreshing token...');

    try {
      final Dio dio = Dio();

      dio.options.headers['Authorization'] = 'Bearer $refreshToken';

      final response = await dio.post('${dotenv.env['REFRESH_TOKEN_ROUTE']}');

      if (response.statusCode == 200) {
        accessToken = response.data['accessToken'];

        await UserPreferences.setAccessToken(accessToken!);

        print('Access token refreshed successfully');
      } else {
        print('Failed to refresh access token');

        await signOut(context);
      }
    } catch (e) {
      print('Error refreshing access token: $e');

      await signOut(context);
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.signUp
      );

    }
  } else {
    print('No valid refresh token found or access token is not expired');
  }
}








