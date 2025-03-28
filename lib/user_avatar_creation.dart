import 'package:crafto/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserAvatarCreation extends StatefulWidget {
  const UserAvatarCreation({super.key});

  @override
  State<UserAvatarCreation> createState() => _UserAvatarCreationState();
}

class _UserAvatarCreationState extends State<UserAvatarCreation> {
  final _formKey = GlobalKey<FormState>();
  File? _avatarImage;
  bool _isLoading = false;

  // Function to pick an image from the gallery
// Function to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

// Submit the image
  Future<void> _submitForm() async {
    final storage = FlutterSecureStorage();
    String? refreshToken = await storage.read(key: 'refreshToken');

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare form data with the correct MIME type
        final formData = FormData.fromMap({
          'avatar': _avatarImage != null
              ? await MultipartFile.fromFile(_avatarImage!.path, filename: 'avatar.jpg', contentType: DioMediaType('image', 'jpeg')) // Specify the correct MIME type
              : null,
        });

        // Send the request to the backend
        final dio = Dio();
        final response = await dio.put(
          '${dotenv.env['UPDATE_AVATAR_ROUTE']}',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        if (response.statusCode == 200) {
          _showSuccessDialog('Avatar updated successfully!');

        } else {
          _showErrorDialog('Failed to update avatar. Please try again.');
        }
      } catch (e) {
        print('Error: $e');
        _showErrorDialog('An error occurred. Please check your connection and try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                Navigator.of(context).pop(); // Close the dialog

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }


  // Function to show an error dialog
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
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Create Your Avatar',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Avatar Section
                GestureDetector(
                  onTap: _pickImage, // Trigger image picker on tap
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _avatarImage != null
                          ? FileImage(_avatarImage!)
                          : null,
                      child: _avatarImage == null
                          ? Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.deepPurple,
                      )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Choose a profile picture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.deepPurple)
                      : Text(
                    'Upload Avatar',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}