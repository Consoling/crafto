import 'package:crafto/helpers/user_preferences.dart';
import 'package:crafto/services/user_service.dart';
import 'package:crafto/user_handle_creation.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _username;
  late String userID;
  late String phoneNumber;
  late String email;
  late String language;
  late String accountType;
  bool iSPremium = false;
  bool isVerified = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    refreshAccessToken(context);
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic> userData = await UserPreferences.loadUserData();
    setState(() {
      _username = userData['username'];
      userID = userData['userID'];
      phoneNumber = userData['phoneNumber'];
      email = userData['email'] ?? "Add Email";
      isVerified = userData['isVerified'];
      iSPremium = userData['isPremium'];
      language = userData['language'];
      accountType = '${userData['accountType']} Account';
      _isLoading = false;
    });
    await syncDataWithBackend();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            // Navigate back
            Navigator.pop(context);
          },
        ),

        centerTitle: false, // Allow custom layout to control centering
      ),

      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 20, left: 20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 20),
                              child: Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: 35,

                                  fontFamily: 'Montserrat',
                                  fontVariations: [FontVariation('wght', 700)],

                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Stack(
                              alignment:
                                  Alignment
                                      .bottomRight, // Aligns the edit icon to the bottom-right
                              children: [
                                // CircleAvatar with the profile image and grey border
                                Container(
                                  decoration: BoxDecoration(
                                    shape:
                                        BoxShape
                                            .circle, // Makes the container circular
                                    border: Border.all(
                                      color: Colors.grey, // Grey border color
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage(
                                      'assets/avatar.jpg',
                                    ), // Add your avatar image in assets
                                  ),
                                ),

                                // Edit icon
                                Container(
                                  padding: const EdgeInsets.all(
                                    4,
                                  ), // Adds some padding around the icon
                                  decoration: BoxDecoration(
                                    color:
                                        Colors
                                            .white, // Background color for the icon
                                    shape:
                                        BoxShape
                                            .circle, // Makes the container circular
                                    border: Border.all(
                                      color:
                                          Colors.grey.shade300, // Border color
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 16, // Size of the edit icon
                                    color:
                                        Colors
                                            .black54, // Color of the edit icon
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade50,
                                        // Light purple with transparency
                                        Colors.purple.shade50,
                                        // Lighter purple with transparency
                                      ],
                                      begin: Alignment.centerLeft,
                                      // Gradient starts from the left
                                      end:
                                          Alignment
                                              .centerRight, // Gradient ends at the right
                                    ),
                                    border: Border.all(
                                      color: Colors.white70, // White border
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // User icon
                                      Icon(
                                        Icons.person,
                                        color: Colors.grey[800],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 20),

                                      Text(
                                        _username,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          // Bold font
                                          color:
                                              Colors
                                                  .black54, // Lighter text color
                                        ),
                                      ),

                                      const Spacer(),

                                      // Pushes the arrow icon to the right
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,

                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => UserHandleCreation())
                                              );
                                            },
                                            child: Text(
                                              'Edit Username',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blueAccent[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade50,
                                        // Light purple with transparency
                                        Colors.purple.shade50,
                                        // Lighter purple with transparency
                                      ],
                                      begin: Alignment.centerLeft,
                                      // Gradient starts from the left
                                      end:
                                          Alignment
                                              .centerRight, // Gradient ends at the right
                                    ),
                                    border: Border.all(
                                      color: Colors.white70, // White border
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // User icon
                                      Icon(
                                        Icons.smartphone_outlined,
                                        color: Colors.grey[800],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 20),
                                      // Space between icon and text

                                      // Username in lighter font
                                      Text(
                                        phoneNumber,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          // Bold font
                                          color:
                                              Colors
                                                  .black54, // Lighter text color
                                        ),
                                      ),

                                      const Spacer(),
                                      // Pushes the arrow icon to the right

                                      // Right arrow icon (iOS style)
                                      isVerified
                                          ? Row(
                                            children: [
                                              Text(
                                                'Verified',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                            ],
                                          )
                                          : Row(
                                            children: [
                                              Text(
                                                'Verify',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blueAccent[700],
                                                ),
                                              ),
                                            ],
                                          ),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade50,
                                        // Light purple with transparency
                                        Colors.purple.shade50,
                                        // Lighter purple with transparency
                                      ],
                                      begin: Alignment.centerLeft,
                                      // Gradient starts from the left
                                      end:
                                          Alignment
                                              .centerRight, // Gradient ends at the right
                                    ),
                                    border: Border.all(
                                      color: Colors.white70, // White border
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // User icon
                                      Icon(
                                        Icons.email_sharp,
                                        color: Colors.grey[800],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 20),
                                      // Space between icon and text

                                      // Username in lighter font
                                      Text(
                                        email.isEmpty
                                            ? 'Add Email'
                                            : email, // If email is empty, show "Add Email"
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color:
                                              Colors
                                                  .black54, // Lighter text color
                                        ),
                                      ),

                                      const Spacer(),
                                      // Pushes the arrow icon to the right

                                      // Right arrow icon (iOS style)
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade50,
                                        // Light purple with transparency
                                        Colors.purple.shade50,
                                        // Lighter purple with transparency
                                      ],
                                      begin: Alignment.centerLeft,
                                      // Gradient starts from the left
                                      end:
                                          Alignment
                                              .centerRight, // Gradient ends at the right
                                    ),
                                    border: Border.all(
                                      color: Colors.white70, // White border
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // User icon
                                      Icon(
                                        Icons.link_outlined,
                                        color: Colors.grey[800],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 20),
                                      // Space between icon and text

                                      // Username in lighter font
                                      Text(
                                        'Social Media Link', // If email is empty, show "Add Email"
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color:
                                              Colors
                                                  .black54, // Lighter text color
                                        ),
                                      ),

                                      const Spacer(),
                                      // Pushes the arrow icon to the right

                                      // Right arrow icon (iOS style)
                                      iSPremium
                                          ? const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.grey,
                                            size: 18,
                                          )
                                          : IconButton(
                                            icon: const Icon(
                                              Icons.lock,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              showPlansComparisonDialog(
                                                context,
                                              );
                                            },
                                          ),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade50,
                                        // Light purple with transparency
                                        Colors.purple.shade50,
                                        // Lighter purple with transparency
                                      ],
                                      begin: Alignment.centerLeft,
                                      // Gradient starts from the left
                                      end:
                                          Alignment
                                              .centerRight, // Gradient ends at the right
                                    ),
                                    border: Border.all(
                                      color: Colors.white70, // White border
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // User icon
                                      Icon(
                                        Icons.manage_accounts_outlined,
                                        color: Colors.grey[800],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 20),
                                      // Space between icon and text

                                      // Username in lighter font
                                      Text(
                                        accountType,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          // Bold font
                                          color:
                                              Colors
                                                  .black54, // Lighter text color
                                        ),
                                      ),

                                      const Spacer(),

                                      // Right arrow icon (iOS style)
                                      Row(
                                        children: [
                                          Text(
                                            'Switch',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueAccent[700],
                                            ),
                                          ),
                                        ],
                                      ),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade50,
                                        // Light purple with transparency
                                        Colors.purple.shade50,
                                        // Lighter purple with transparency
                                      ],
                                      begin: Alignment.centerLeft,
                                      // Gradient starts from the left
                                      end:
                                          Alignment
                                              .centerRight, // Gradient ends at the right
                                    ),
                                    border: Border.all(
                                      color: Colors.white70, // White border
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // User icon
                                      Icon(
                                        Icons.workspace_premium_outlined,
                                        color: Colors.grey[800],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 20),

                                      Text(
                                        iSPremium
                                            ? 'Premium Member'
                                            : 'Free Member',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          // Bold font
                                          color:
                                              Colors
                                                  .black54, // Lighter text color
                                        ),
                                      ),

                                      const Spacer(),

                                      // Right arrow icon (iOS style)
                                      if (!iSPremium)
                                        Row(
                                          children: [
                                            Text(
                                              'Subscribe',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blueAccent[700],
                                              ),
                                            ),
                                          ],
                                        ),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade50,
                                        // Light purple with transparency
                                        Colors.purple.shade50,
                                        // Lighter purple with transparency
                                      ],
                                      begin: Alignment.centerLeft,
                                      // Gradient starts from the left
                                      end:
                                          Alignment
                                              .centerRight, // Gradient ends at the right
                                    ),
                                    border: Border.all(
                                      color: Colors.white70, // White border
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // User icon
                                      Icon(
                                        Icons.translate_outlined,
                                        color: Colors.grey[800],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 20),
                                      // Space between icon and text

                                      // Username in lighter font
                                      Text(
                                        language,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          // Bold font
                                          color:
                                              Colors
                                                  .black54, // Lighter text color
                                        ),
                                      ),

                                      const Spacer(),

                                      // Right arrow icon (iOS style)
                                      Row(
                                        children: [
                                          Text(
                                            'Change Language',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueAccent[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              signOut(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Red background
                              foregroundColor:
                                  Colors.white, // White text and icon
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 1,
                              ), // Button padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Rounded corners
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.exit_to_app, // Exit icon
                                    color: Colors.white, // Icon color,
                                    size: 20, // Icon size
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Space between icon and text
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
    );
  }

  void _editUsername() {}

  void _deleteAccount() {
    // Implement delete account logic
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
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
