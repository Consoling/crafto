import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "JohnDoe"; // Example username
  String userID = 'abc_';
  String phoneNumber = '+918292933065';
  String email = 'abcd123@gmail.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade800],
              transform: const GradientRotation(1.5708), // 90 degrees in radians
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            // Navigate back
            Navigator.pop(context);
          },
        ),

        centerTitle: false, // Allow custom layout to control centering
      ),

      body:
      Container(
        color: Colors.purple.shade50.withOpacity(0.3),
        child: SingleChildScrollView(
          child:
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bold "Settings" text below the app bar
                Padding(padding: EdgeInsets.only(bottom: 25, right: 20, left: 20),
                    child:
                    Row(


                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children:[
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 20),
                          child:
                          Text(

                            'Profile',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/avatar.jpg'), // Add your avatar image in assets
                        ),
                      ],


                    )),


                Container(
                  decoration: BoxDecoration(
                    //color: Colors.grey.shade100, // Background color with transparency
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                  ),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [

                          Expanded(
                            child:
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade50, // Light purple with transparency
                                    Colors.purple.shade50, // Lighter purple with transparency
                                  ],
                                  begin: Alignment.centerLeft, // Gradient starts from the left
                                  end: Alignment.centerRight, // Gradient ends at the right
                                ),
                                border: Border.all(
                                  color: Colors.white70, // White border
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  // User icon
                                  Icon(Icons.face_6_outlined, color: Colors.grey[800], size: 24),
                                  const SizedBox(width: 20), // Space between icon and text

                                  // Username in lighter font
                                  Text(
                                    userID,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold, // Bold font
                                      color: Colors.black54, // Lighter text color
                                    ),
                                  ),

                                  const Spacer(), // Pushes the arrow icon to the right

                                  // Right arrow icon (iOS style)
                                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Username with transparent glass effect and white border
                          Expanded(
                            child:
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade50, // Light purple with transparency
                                    Colors.purple.shade50, // Lighter purple with transparency
                                  ],
                                  begin: Alignment.centerLeft, // Gradient starts from the left
                                  end: Alignment.centerRight, // Gradient ends at the right
                                ),
                                border: Border.all(
                                  color: Colors.white70, // White border
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  // User icon
                                  Icon(Icons.person, color: Colors.grey[800], size: 24),
                                  const SizedBox(width: 20), // Space between icon and text

                                  // Username in lighter font
                                  Text(
                                    username,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold, // Bold font
                                      color: Colors.black54, // Lighter text color
                                    ),
                                  ),

                                  const Spacer(), // Pushes the arrow icon to the right

                                  // Right arrow icon (iOS style)
                                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [

                          Expanded(
                            child:
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade50, // Light purple with transparency
                                    Colors.purple.shade50, // Lighter purple with transparency
                                  ],
                                  begin: Alignment.centerLeft, // Gradient starts from the left
                                  end: Alignment.centerRight, // Gradient ends at the right
                                ),
                                border: Border.all(
                                  color: Colors.white70, // White border
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  // User icon
                                  Icon(Icons.smartphone_outlined, color: Colors.grey[800], size: 24),
                                  const SizedBox(width: 20), // Space between icon and text

                                  // Username in lighter font
                                  Text(
                                    phoneNumber,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800, // Bold font
                                      color: Colors.black54, // Lighter text color
                                    ),
                                  ),

                                  const Spacer(), // Pushes the arrow icon to the right

                                  // Right arrow icon (iOS style)
                                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [

                          Expanded(
                            child:
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade50, // Light purple with transparency
                                    Colors.purple.shade50, // Lighter purple with transparency
                                  ],
                                  begin: Alignment.centerLeft, // Gradient starts from the left
                                  end: Alignment.centerRight, // Gradient ends at the right
                                ),
                                border: Border.all(
                                  color: Colors.white70, // White border
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  // User icon
                                  Icon(Icons.email_sharp, color: Colors.grey[800], size: 24),
                                  const SizedBox(width: 20), // Space between icon and text

                                  // Username in lighter font
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800, // Bold font
                                      color: Colors.black54, // Lighter text color
                                    ),
                                  ),

                                  const Spacer(), // Pushes the arrow icon to the right

                                  // Right arrow icon (iOS style)
                                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red background
                        foregroundColor: Colors.white, // White text and icon
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.exit_to_app, // Exit icon
                            color: Colors.white, // Icon color,
                            size: 20, // Icon size
                          ),
                          const SizedBox(width: 8), // Space between icon and text
                          const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

            ),
          ),
        ),
      )
    );
  }

  void _editUsername() {
    // Implement username editing logic
    showDialog(
      context: context,
      builder: (context) {
        String newUsername = username;
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            onChanged: (value) {
              newUsername = value;
            },
            decoration: const InputDecoration(hintText: "Enter new username"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  username = newUsername;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() {
    // Implement delete account logic
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                // Perform account deletion
                Navigator.pop(context);
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}