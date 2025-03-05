import 'package:crafto/helpers/user_preferences.dart';
import 'package:crafto/homeScreen.dart';
import 'package:crafto/services/user_service.dart';
import 'package:crafto/user_handle_creation.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart'; // Import the animated text kit
import 'package:country_code_picker/country_code_picker.dart';
import 'dart:async';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(MaterialApp(home: SplashScreen()));
}

// Splash Screen Widget
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
    refreshAccessToken(context);
  }

  Future<void> _checkTokenAndNavigate() async {
    // Delay for 3 seconds
    await Future.delayed(Duration(seconds: 3));

    // Check for the access token
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null && accessToken.isNotEmpty) {
      print('Access token exists');
      // Token exists, navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Token doesn't exist, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple, // Splash screen background color
      body: Center(
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Crafto', // The text to be displayed
              textStyle: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
                letterSpacing: 2.0,
              ),
              speed: Duration(
                milliseconds: 100,
              ), // Speed of the typewriter effect
            ),
          ],
          totalRepeatCount: 1, // Repeat the animation only once
          pause: Duration(seconds: 1), // Pause after the animation
        ),
      ),
    );
  }
}

// Home Screen Widget
class HomeScreen extends StatefulWidget {
  //const HomeScreen({super.key});c

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> userData = {};
  @override
  void initState() {
    super.initState();
    _loadData();
   _loadUserData();
  }

  Future<void> _loadData() async {
    await syncDataWithBackend(); // Sync data with backend and update SharedPreferences
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic> data = await UserPreferences.loadUserData();
    setState(() {
      userData = data;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isButtonPressed = false;
  bool _isOtpSent = false;
  bool _canResendOtp = false;
  int _remainingTime = 59;
  final Dio dio = Dio();
  String _countryCode = '+91';
  String _otp = '';
  bool _validateOtp(String otp) {
    if (otp.length != 6) {
      return false; // Not 6 digits
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return false; // Contains non-numeric characters
    }
    return true; // Valid OTP
  }
  bool _isLoginActive = false;
  final storage = FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  Timer? _timer;
  Future<void> _generateToken({required String phoneNumber}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await dio.post(
        '${dotenv.env['SESSION_CREATION_ROUTE']}',
        data: {'phoneNumber': phoneNumber},
        options: Options(
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200) {
        // Token generated successfully
        print('Token generated successfully');

        // Extract tokens from cookies and JSON
        _extractTokens(response);

        // Store tokens securely using flutter_secure_storage
        await _storeTokens();

        // Extract user verification status

        _navigateToNextScreen(response.data['redirectTo']);
      } else {
        // Error generating token
        print('Error generating token: ${response.statusCode}');
        print('Response data: ${response.data}');
        _showErrorDialog('Error generating token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      print('Error generating token: $e');
      _showErrorDialog(
        'An error occurred. Please check your connection and try again.',
      );
    } catch (e) {
      // Handle other exceptions
      print('Error generating token: $e');
      _showErrorDialog(
        'An error occurred. Please check your connection and try again.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToNextScreen(String redirectTo) {
    // Replace this with your actual navigation logic
    if (redirectTo == '/user-handle-creation') {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => UserHandleCreation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
    else if (redirectTo == '/home') {
      Navigator.pushAndRemoveUntil(
        context,
          MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
      );
    }
    else {
      // Handle other routes or default route
      print('Unknown route: $redirectTo');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserHandleCreation(),
        ), // Replace NextScreen with your actual screen
      );
    }
  }

  void _startOtpTimer() {
    _canResendOtp = false; // Disable resend button initially
    _remainingTime = 59;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _canResendOtp = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _triggerHapticFeedback() {
    HapticFeedback.vibrate();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _isButtonPressed = true;
      });

      try {
        // Prepare the request payload
        final Map<String, String> body = {
          'phoneNumber': '$_countryCode${_phoneController.text}',
          'password': _passwordController.text,
        };

        // Define the endpoint URL
        final String url = '${dotenv.env['INITIAL_SIGNUP_ROUTE']}';

        // Make the POST request
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode(body),
        );

        // Check the response status code
        if (response.statusCode == 201) {
          // Backend successfully received data and sent OTP
          print('OTP sent successfully');
          setState(() {
            _isLoading = false;
            _isOtpSent = true;
          });
          _startOtpTimer();
        } else {
          // Backend returned an error
          print('Error sending data to backend: ${response.statusCode}');
          _showErrorDialog(
            'Error sending data to backend: ${response.statusCode}',
          );
          setState(() {
            _isLoading = false;
            _isButtonPressed = false;
          });
        }
      } catch (e) {
        // Handle errors such as network issues or unexpected errors
        print('Error sending data to backend: $e');
        _showErrorDialog(
          'An error occurred. Please check your connection and try again.',
        );
        setState(() {
          _isLoading = false;
          _isButtonPressed = false;
        });
      }

      print("Form is valid");

    } else {
      _triggerHapticFeedback();
      setState(() {
        _isButtonPressed = false;
      });
      print("Form is not valid");
    }
  }

  Future<void> _submitLoginForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _isButtonPressed = true;
      });

      try {
        // Prepare the request payload
        final Map<String, String> body = {
          'phoneNumber': '$_countryCode${_phoneController.text}',
          'password': _passwordController.text,
        };

        // Define the endpoint URL
        final String url = '${dotenv.env['LOGIN_ROUTE']}';

        // Make the POST request
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode(body),
        );

        // Check the response status code
        if (response.statusCode == 201) {
          // Backend successfully received data and sent OTP
          print('OTP sent successfully');
          setState(() {
            _isLoading = false;
            _isOtpSent = true;
          });
          _startOtpTimer();
        } else {
          // Backend returned an error
          print('Error sending data to backend: ${response.statusCode}');
          _showErrorDialog(
            'Error sending data to backend: ${response.statusCode}',
          );
          setState(() {
            _isLoading = false;
            _isButtonPressed = false;
          });
        }
      } catch (e) {
        // Handle errors such as network issues or unexpected errors
        print('Error sending data to backend: $e');
        _showErrorDialog(
          'An error occurred. Please check your connection and try again.',
        );
        setState(() {
          _isLoading = false;
          _isButtonPressed = false;
        });
      }

      print("Form is valid");
      print("Phone: ${_phoneController.text}");
      print("Password: ${_passwordController.text}");
    } else {
      _triggerHapticFeedback();
      setState(() {
        _isButtonPressed = false;
      });
      print("Form is not valid");
    }
  }

  void _extractTokens(Response response) {
    // Extract tokens from cookies
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      for (final cookie in cookies) {
        if (cookie.startsWith('refresh_token=')) {
          _refreshToken = cookie.split(';')[0].split('=')[1];
        }
      }
    }

    // Extract tokens from JSON if present
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      _accessToken = data['accessToken'];
      _userId = data['userId'];
    }

    print('Access Token: $_accessToken');
    print('Refresh Token: $_refreshToken');
  }

  Future<void> _storeTokens() async {
    if (_accessToken != null) {
      await storage.write(key: 'accessToken', value: _accessToken);
    }
    if (_refreshToken != null) {
      await storage.write(key: 'refreshToken', value: _refreshToken);
    }
    if (_userId != null) {
      await storage.write(key: 'userId', value: _userId);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void reverseStateLogin() {
    setState(() {
      _isLoginActive = !_isLoginActive;
    });
  }

  void _submitOtp() async {
    if (_validateOtp(_otp)) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        final response = await dio.post(
          '${dotenv.env['OTP_AUTH_ROUTE']}', // Replace with your backend endpoint
          data: {
            'phoneNumber':
                '$_countryCode${_phoneController.text}', // Send phone number
            'otp': _otp, // Send OTP
          },
          options: Options(
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
          ),
        );

        if (response.statusCode == 200) {
          // Navigate to the next screen or perform other actions
          _showSuccessDialog('OTP verification successful');
          await _generateToken(
            phoneNumber: '$_countryCode${_phoneController.text}',
          );
          setState(() {
            _isLoading = false;
          });
        } else {
          // OTP verification failed
          print('OTP verification failed: ${response.statusCode}');
          _showErrorDialog('OTP verification failed: ${response.statusCode}');
          setState(() {
            _isLoading = false;
          });
        }
      } on DioException catch (e) {
        // Handle Dio-specific errors
        print('Error verifying OTP: $e');
        _showErrorDialog(
          'An error occurred. Please check your connection and try again.',
        );
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        // Handle other exceptions
        print('Error verifying OTP: $e');
        _showErrorDialog(
          'An error occurred. Please check your connection and try again.',
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Invalid OTP
      _showErrorDialog('Please enter a valid 6-digit numeric OTP.');
    }
  }

  void _onSkipVerification() {
    _generateToken(phoneNumber: '$_countryCode${_phoneController.text}');
  }

  void _resendOtp() async {
    if (_canResendOtp) {
      setState(() {
        _isLoading = true; // Show loading indicator
        _canResendOtp = false; // Disable resend button temporarily
      });

      try {
        final response = await dio.post(
          '${dotenv.env['OTP_RESEND_ROUTE']}', // Replace with your backend endpoint
          data: {
            'phoneNumber':
                '$_countryCode${_phoneController.text}', // Send phone number
          },
          options: Options(
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
          ),
        );

        if (response.statusCode == 200) {
          // OTP resent successfully
          print('OTP resent successfully');
          _startOtpTimer(); // Restart the timer

          _showSuccessDialog('OTP resent successfully');
        } else {
          // Error resending OTP
          print('Error resending OTP: ${response.statusCode}');
          _showErrorDialog('Error resending OTP: ${response.statusCode}');
          setState(() {
            _canResendOtp = true; // Re-enable resend button on error
          });
        }
      } on DioException catch (e) {
        // Handle Dio-specific errors
        print('Error resending OTP: $e');
        _showErrorDialog(
          'An error occurred. Please check your connection and try again.',
        );
        setState(() {
          _canResendOtp = true; // Re-enable resend button on error
        });
      } catch (e) {
        // Handle other exceptions
        print('Error resending OTP: $e');
        _showErrorDialog(
          'An error occurred. Please check your connection and try again.',
        );
        setState(() {
          _canResendOtp = true;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Scaffold _buildSignupScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg-crafto.png'),
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.webp', height: 100.0, width: 100.0),
            ],
          ),
        ),
      ),
      bottomSheet: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: Container(
          color: Colors.white,
          height:
              _isOtpSent
                  ? MediaQuery.of(context).viewInsets.bottom > 0
                      ? 400
                      : 420
                  : MediaQuery.of(context).viewInsets.bottom > 0
                  ? 400
                  : 420,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.webp', height: 50, width: 50),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                    child: Text(
                      'Welcome to Crafto!',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        // color: Colors.deepPurple,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  // Phone number input field with country picker inside
                  if (!_isOtpSent) ...[
                    Row(
                      children: [
                        CountryCodePicker(
                          onChanged: (countryCode) {
                            setState(() {
                              _countryCode = countryCode.dialCode!;
                            });
                          },
                          initialSelection:
                              'IN', // Set India as initial selection
                          showFlag: true,
                          showDropDownButton: true,
                          padding: EdgeInsets.zero,
                          showFlagDialog: true,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'Enter your phone number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              } else if (value.length < 10) {
                                return 'Please enter 10 digits phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Password input field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.deepPurple,
                          ),
                          onPressed:
                              _togglePasswordVisibility, // Toggle visibility on press
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Create Account button
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      transform:
                          _isButtonPressed
                              ? Matrix4.translationValues(10.0, 0.0, 0.0)
                              : Matrix4.identity(),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isLoading
                                  ? Colors.deepPurple.shade300
                                  : Colors.deepPurple.shade700,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 50.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              CircularProgressIndicator(color: Colors.white),
                            if (!_isLoading)
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Already have an account? Login text
                    GestureDetector(
                      onTap: () {
                        // Show the login bottom sheet

                        reverseStateLogin();
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ] else ...[
                    // OTP input field and Submit button
                    Text(
                      'Please enter the 6-digit OTP sent to your phone number',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 25),

                    // 6 OTP Text Fields (Boxes)
                    OtpTextField(
                      numberOfFields: 6,
                      borderColor: Color(0xFF3949AB),
                      clearText: _canResendOtp ? true : false,
                      //set to true to show as box or false to show as dash
                      showFieldAsBox: true,
                      //runs when a code is typed in
                      onCodeChanged: (String code) {
                        //handle validation or checks here
                      },

                      onSubmit: (String submittedOTP) {
                        setState(() {
                          _otp = submittedOTP;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    // Timer text and Resend button
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceEvenly, // Distribute space between the timer/resend and skip text
                        children: [
                          // Timer text and Resend button
                          if (!_canResendOtp)
                            Text(
                              'Resend OTP in $_remainingTime seconds',
                              style: TextStyle(fontSize: 14),
                            ),
                          if (_canResendOtp)
                            TextButton(
                              onPressed: _resendOtp,
                              child: Text('Resend OTP'),
                            ),
                          // Skip Verification text
                          TextButton(
                            onPressed: () {
                              _onSkipVerification();
                            },
                            child: Text(
                              'Skip Verification',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Submit OTP button
                    ElevatedButton(
                      onPressed: _submitOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 50.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            CircularProgressIndicator(color: Colors.white),
                          if (!_isLoading)
                            Text(
                              'Submit OTP',
                              style: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Scaffold _buildLoginScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg-crafto.png'),
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.webp', height: 100.0, width: 100.0),
            ],
          ),
        ),
      ),
      bottomSheet: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: Container(
          color: Colors.white,
          height:
              _isOtpSent
                  ? MediaQuery.of(context).viewInsets.bottom > 0
                      ? 400
                      : 420
                  : MediaQuery.of(context).viewInsets.bottom > 0
                  ? 400
                  : 420, // Dynamically adjust height
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.webp', height: 50, width: 50),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                    child: Text(
                      'Welcome to Crafto!',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        // color: Colors.deepPurple,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  if (!_isOtpSent) ...[
                    Row(
                      children: [
                        CountryCodePicker(
                          onChanged: (countryCode) {
                            setState(() {
                              _countryCode = countryCode.dialCode!;
                            });
                          },
                          initialSelection:
                              'IN', // Set India as initial selection
                          showFlag: true,
                          showDropDownButton: true,
                          padding: EdgeInsets.zero,
                          showFlagDialog: true,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'Enter your phone number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              } else if (value.length < 10) {
                                return 'Please enter 10 digits phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Password input field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.deepPurple,
                          ),
                          onPressed:
                              _togglePasswordVisibility, // Toggle visibility on press
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Create Account button
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      transform:
                          _isButtonPressed
                              ? Matrix4.translationValues(10.0, 0.0, 0.0)
                              : Matrix4.identity(),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isLoading
                                  ? Colors.deepPurple.shade300
                                  : Colors.deepPurple.shade700,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 50.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          _submitLoginForm();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              CircularProgressIndicator(color: Colors.white),
                            if (!_isLoading)
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        reverseStateLogin();
                      },
                      child: Text(
                        'Don\'t have an account? Signup',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ] else ...[
                    // OTP input field and Submit button
                    Text(
                      'Please enter the 6-digit OTP sent to your phone number',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 25),

                    // 6 OTP Text Fields (Boxes)
                    OtpTextField(
                      numberOfFields: 6,
                      borderColor: Color(0xFF3949AB),
                      clearText: _canResendOtp ? true : false,
                      //set to true to show as box or false to show as dash
                      showFieldAsBox: true,
                      //runs when a code is typed in
                      onCodeChanged: (String code) {
                        //handle validation or checks here
                      },

                      onSubmit: (String submittedOTP) {
                        setState(() {
                          _otp = submittedOTP;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    // Timer text and Resend button
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceEvenly, // Distribute space between the timer/resend and skip text
                        children: [
                          // Timer text and Resend button
                          if (!_canResendOtp)
                            Text(
                              'Resend OTP in $_remainingTime seconds',
                              style: TextStyle(fontSize: 14),
                            ),
                          if (_canResendOtp)
                            TextButton(
                              onPressed: _resendOtp,
                              child: Text('Resend OTP'),
                            ),
                          // Skip Verification text
                          TextButton(
                            onPressed: () {
                              _onSkipVerification();
                            },
                            child: Text(
                              'Skip Verification',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Submit OTP button
                    ElevatedButton(
                      onPressed: _submitOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 50.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            CircularProgressIndicator(color: Colors.white),
                          if (!_isLoading)
                            Text(
                              'Submit OTP',
                              style: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: _isLoginActive ? _buildLoginScreen() : _buildSignupScreen(),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
        ),
      ),
    );
  }
}
