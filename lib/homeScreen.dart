import 'package:crafto/bottom_navbar.dart';
import 'package:crafto/profile_page.dart';
import 'package:crafto/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // For downloading functionality
import 'dart:typed_data'; // For image manipulation
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    refreshAccessToken(context);
  }

  final List<Map<String, String>> posts = [
    {
      'image': 'assets/post1.jpg',
      'description': 'A beautiful sunset at the beach!',
      'category': 'Happy',
    },
    {
      'image': 'assets/post2.jpg',
      'description': 'Amazing hike in the mountains.',
      'category': 'Sad',
    },
    {
      'image': 'assets/post3.jpg',
      'description': 'Had a great day with friends!',
      'category': 'Grateful',
    },
    {
      'image': 'assets/post4.jpg',
      'description': 'Relaxing by the lake.',
      'category': 'Surprised',
    },
  ];

  // List of categories with emojis
  final List<Map<String, String?>> categories = [
    {'name': 'Happy', 'emoji': '😊'},
    {'name': 'Sad', 'emoji': '😢'},
    {'name': 'Emotional', 'emoji': '😌'},
    {'name': 'Holi', 'emoji': '🎨'},
    {'name': 'Angry', 'emoji': '😡'},
    {'name': 'Surprised', 'emoji': '😮'},
    {'name': 'Bored', 'emoji': null},
    {'name': 'Confused', 'emoji': '🤔'},
    {'name': 'Relaxed', 'emoji': '😌'},
    {'name': 'Nervous', 'emoji': '😬'},
    {'name': 'Content', 'emoji': '🙂'},
    {'name': 'Curious', 'emoji': '🤨'},
    {'name': 'Anxious', 'emoji': '😟'},
    {'name': 'Grateful', 'emoji': '🙏'},
    {'name': 'Hopeful', 'emoji': '🌱'},
    {'name': 'Fearful', 'emoji': '😨'},
    {'name': 'Proud', 'emoji': '😎'},
    {'name': 'Guilty', 'emoji': '😔'},
  ];

  String selectedCategory = 'All';

  List<Map<String, String>> getFilteredPosts() {
    if (selectedCategory == 'All') {
      return posts;
    } else {
      return posts
          .where((post) => post['category']?.trim() == selectedCategory)
          .toList();
    }
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  bool showAllCategories = false;

  Future<void> _shareOnWhatsApp(String message) async {
    final Uri waUrl = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(message)}',
    ); // WhatsApp URL
    final Uri playStoreUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.whatsapp',
    ); // Play Store link
    final Uri appStoreUrl = Uri.parse(
      'https://apps.apple.com/us/app/whatsapp-messenger/id310633997',
    ); // App Store link

    try {
      // Check if WhatsApp is installed
      if (await canLaunchUrl(waUrl)) {
        // WhatsApp is installed, proceed to share
        await launchUrl(waUrl);
      } else {
        // WhatsApp is not installed, redirect to the store
        if (await canLaunchUrl(playStoreUrl)) {
          // Android - redirect to Play Store
          await launchUrl(playStoreUrl);
        } else if (await canLaunchUrl(appStoreUrl)) {
          // iOS - redirect to App Store
          await launchUrl(appStoreUrl);
        } else {
          throw 'Could not open the app store.';
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _shareOnInstagram(String message) async {
    final Uri instaUrl = Uri.parse(
      'https://www.instagram.com/share?text=${Uri.encodeComponent(message)}',
    ); // Instagram share URL
    final Uri playStoreUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.instagram.android',
    ); // Play Store link
    final Uri appStoreUrl = Uri.parse(
      'https://apps.apple.com/us/app/instagram/id389801252',
    ); // App Store link

    try {
      // Try opening Instagram app
      if (await canLaunchUrl(instaUrl)) {
        await launchUrl(instaUrl);
      } else {
        // Instagram is not installed, redirect to the store
        if (await canLaunchUrl(playStoreUrl)) {
          await launchUrl(playStoreUrl);
        } else if (await canLaunchUrl(appStoreUrl)) {
          await launchUrl(appStoreUrl);
        } else {
          throw 'Could not open Instagram or App Store.';
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _shareOnSnapchat(String message) async {
    final Uri snapUrl = Uri.parse(
      'https://www.snapchat.com/snapcode?text=${Uri.encodeComponent(message)}',
    ); // Snapchat share URL
    final Uri playStoreUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.snapchat.android',
    ); // Play Store link
    final Uri appStoreUrl = Uri.parse(
      'https://apps.apple.com/us/app/snapchat/id447188370',
    ); // App Store link

    try {
      // Try opening Snapchat app
      if (await canLaunchUrl(snapUrl)) {
        await launchUrl(snapUrl);
      } else {
        // Snapchat is not installed, redirect to the store
        if (await canLaunchUrl(playStoreUrl)) {
          await launchUrl(playStoreUrl);
        } else if (await canLaunchUrl(appStoreUrl)) {
          await launchUrl(appStoreUrl);
        } else {
          throw 'Could not open Snapchat or App Store.';
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  final PageController _pageController = PageController();
  Future<void> _downloadImageWithAvatar() async {
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    final image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    // Save the image to a file, or send it to the server to enable downloading
    // You can use the 'path_provider' and 'image_gallery_saver' packages to save the image locally or export it.
    // Example:
    // final directory = await getApplicationDocumentsDirectory();
    // final filePath = '${directory.path}/image_with_avatar.png';
    // final file = File(filePath)..writeAsBytesSync(uint8List);
    // You can implement file-saving functionality here.
  }

  final String userAvatarUrl = 'assets/avatar.jpg';

  final List<String> fonts = [
    'Roboto',
    'Arial',
    'Times New Roman',
    'Courier New',
    'Georgia',
    'Verdana',
  ];

  final List<Color> backgroundColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
  ];
  @override
  Widget build(BuildContext context) {
    final random = Random();

    String randomFont = fonts[random.nextInt(fonts.length)];
    Color randomColor =
        backgroundColors[random.nextInt(backgroundColors.length)];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade800],
              transform: const GradientRotation(1.7708),
            ),
          ),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3), // Transparent white
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.search, color: Colors.white),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              showComingSoonDialog(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Material(
              color: Colors.transparent, // Make sure the button is transparent
              shape: CircleBorder(), // Make the button round
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  30,
                ), // Set the radius for the rounded button
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              ProfilePage(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
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
                },
                child: CircleAvatar(
                  radius: 20, // Adjust the size of the avatar
                  backgroundImage: AssetImage('assets/avatar.jpg'),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 16.0,
          bottom: 16.0,
          left: 5.0,
          right: 5.0,
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 90,
              ), // Adjust this value to control the spacing from the app bar

              Padding(
                padding: EdgeInsets.only(bottom: 5, right: 6, left: 6, top: 6),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          onCategorySelected('All');
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color:
                                selectedCategory == 'All'
                                    ? Colors.blue
                                    : Colors.grey,
                            width: selectedCategory == 'All' ? 2.0 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(
                            6,
                          ), // Smaller border-radius
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 4, // Further reduced vertical padding
                          horizontal: 12, // Reduced horizontal padding
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'All',
                              style: TextStyle(
                                fontSize: 10, // Smaller font size
                                fontWeight: FontWeight.bold,
                                color:
                                    selectedCategory == 'All'
                                        ? Colors.blue
                                        : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ...(showAllCategories
                            ? categories
                            : categories.take(12).toList())
                        .map((category) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                onCategorySelected(category['name']!);
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color:
                                      selectedCategory == category['name']
                                          ? Colors.blue
                                          : Colors.grey,
                                  width:
                                      selectedCategory == category['name']
                                          ? 2.0
                                          : 1.0,
                                ),
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Slightly reduced border-radius
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 4, // Smaller vertical padding
                                horizontal: 8, // Smaller horizontal padding
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (category['emoji'] != null)
                                    Text(
                                      category['emoji']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ), // Smaller emoji size
                                    ),
                                  SizedBox(
                                    width: 4,
                                  ), // Space between emoji and text
                                  Text(
                                    category['name']!,
                                    style: TextStyle(
                                      fontSize: 10, // Smaller font size
                                      fontWeight: FontWeight.bold,
                                      color:
                                          selectedCategory == category['name']
                                              ? Colors.blue
                                              : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                    !showAllCategories
                        ? GestureDetector(
                          onTap: () {
                            setState(() {
                              showAllCategories = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              border: Border.all(
                                color: Colors.white38,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // Slightly smaller border-radius
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 5, // Reduced vertical padding
                              horizontal: 12, // Reduced horizontal padding
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View More',
                                  style: TextStyle(
                                    fontSize: 10, // Smaller font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : GestureDetector(
                          onTap: () {
                            setState(() {
                              showAllCategories = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // Slightly smaller border-radius
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 5, // Reduced vertical padding
                              horizontal: 10, // Reduced horizontal padding
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Less',
                                  style: TextStyle(
                                    fontSize: 10, // Smaller font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Set background color if needed
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10), // Round bottom-left corner
                    bottomRight: Radius.circular(
                      10,
                    ), // Round bottom-right corner
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      offset: Offset(
                        0,
                        5,
                      ), // Horizontal and vertical offset (vertical offset below the container)
                      blurRadius: 5,
                      spreadRadius: 0, // Spread of the shadow
                    ),
                  ],
                ),
                child: Divider(
                  color: Colors.white38, // Gray color for the divider
                  thickness: 0, // Set the thickness of the divider
                  indent: 0, // Left indentation
                  endIndent: 0, // Right indentation
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Set background color if needed
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10), // Round top-left corner
                    topRight: Radius.circular(10), // Round top-right corner
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      offset: Offset(
                        0,
                        -5,
                      ), // Vertical offset above the container (negative value for upward shadow)
                      blurRadius: 5, // Blur radius for the shadow
                      spreadRadius: 0, // Spread of the shadow
                    ),
                  ],
                ),
                child: Divider(
                  color: Colors.white38, // Gray color for the divider
                  thickness: 0, // Set the thickness of the divider
                  indent: 0, // Left indentation
                  endIndent: 0, // Right indentation
                ),
              ),
              Center(
                child:
                    getFilteredPosts().isEmpty
                        ? Expanded(
                          child: SizedBox(
                            height: 300,
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center, // Centers content vertically
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .center, // Centers content horizontally
                              children: [
                                Icon(
                                  Icons
                                      .sentiment_dissatisfied, // You can replace this with a Font Awesome icon if using `font_awesome_flutter`
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height: 16,
                                ), // Add some spacing between the icon and text
                                Text(
                                  'No content found for this tag',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : Expanded(
                          child: Container(
                            height: 620,

                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.red),
                            ),
                            child: Container(
                              child:
                              getFilteredPosts().isEmpty
                                  ? Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sentiment_dissatisfied,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          'No posts found for this tag',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                                  : Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: PageView.builder(
                                    scrollDirection: Axis.vertical,
                                    controller: _pageController,
                                    itemCount:
                                    getFilteredPosts().length,
                                    itemBuilder: (context, index) {
                                      final post =
                                      getFilteredPosts()[index];
                                      return Column(
                                        children: [
                                          Expanded(
                                            child: AspectRatio(
                                              aspectRatio:
                                              16 /
                                                  9, // Maintain a 16:9 aspect ratio for the image
                                              child: Image.asset(
                                                post['image']!,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),

                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                  left: 0.0,
                                                  right: 5.0,
                                                ), // Adjust button position
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    side: MaterialStateProperty.all<
                                                        BorderSide
                                                    >(
                                                      BorderSide(
                                                        color:
                                                        Colors
                                                            .purple, // Purple border color
                                                        width:
                                                        2.0, // Border width
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color
                                                    >(
                                                      Colors
                                                          .white, // Background color of the button
                                                    ),
                                                    foregroundColor:
                                                    MaterialStateProperty.all<
                                                        Color
                                                    >(
                                                      Colors
                                                          .purple, // Text and icon color
                                                    ),
                                                    padding:
                                                    MaterialStateProperty.all<
                                                        EdgeInsets
                                                    >(
                                                      EdgeInsets.symmetric(
                                                        horizontal:
                                                        16,
                                                        vertical: 8,
                                                      ), // Padding
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (_pageController
                                                        .page! <
                                                        getFilteredPosts()
                                                            .length -
                                                            1) {
                                                      _pageController.nextPage(
                                                        duration: Duration(
                                                          milliseconds:
                                                          300,
                                                        ), // Animation duration
                                                        curve:
                                                        Curves
                                                            .easeInOut, // Animation curve
                                                      );
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                    MainAxisSize
                                                        .min,
                                                    children: [
                                                      Text('Next'),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios,
                                                        size: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.all(
                                              8.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                    Colors
                                                        .grey
                                                        .shade100, // Light background color to indicate scrollable area
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ), // Rounded corners for the container
                                                    border: Border.all(
                                                      color:
                                                      Colors
                                                          .grey
                                                          .shade300,
                                                    ), // Border around the container
                                                  ),
                                                  padding: EdgeInsets.all(
                                                    8,
                                                  ), // Padding inside the container
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                    Axis.horizontal, // Allow horizontal scrolling
                                                    child: Row(
                                                      children: [
                                                        // Download Button
                                                        Column(
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () {
                                                                // Handle download action
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                Colors.blue, // Blue color
                                                                shape:
                                                                CircleBorder(), // Makes the button circular
                                                                padding: EdgeInsets.all(
                                                                  10,
                                                                ), // Smaller padding for smaller buttons
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .download,
                                                                color:
                                                                Colors.white,
                                                                size:
                                                                24, // Smaller icon size
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4,
                                                            ), // Space between button and text
                                                            Text(
                                                              "Download",
                                                              style: TextStyle(
                                                                fontSize:
                                                                12,
                                                                color:
                                                                Colors.black45,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 16,
                                                        ), // Space between buttons
                                                        // Edit Button
                                                        Column(
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () {
                                                                // Handle edit action
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                Colors.orange, // Edit button color
                                                                shape:
                                                                CircleBorder(), // Makes the button circular
                                                                padding: EdgeInsets.all(
                                                                  10,
                                                                ), // Smaller padding for smaller buttons
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .edit,
                                                                color:
                                                                Colors.white,
                                                                size:
                                                                24, // Smaller icon size
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4,
                                                            ), // Space between button and text
                                                            Text(
                                                              "Edit",
                                                              style: TextStyle(
                                                                fontSize:
                                                                12,
                                                                color:
                                                                Colors.black45,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 16,
                                                        ),
                                                        // WhatsApp Button
                                                        Column(
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () => _shareOnWhatsApp(
                                                                post['image']!,
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                Colors.green, // WhatsApp green
                                                                shape:
                                                                CircleBorder(), // Makes the button circular
                                                                padding: EdgeInsets.all(
                                                                  10,
                                                                ), // Smaller padding for smaller buttons
                                                              ),
                                                              child: Icon(
                                                                FontAwesomeIcons
                                                                    .whatsapp,
                                                                color:
                                                                Colors.white,
                                                                size:
                                                                24, // Smaller icon size
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4,
                                                            ), // Space between button and text
                                                            Text(
                                                              "WhatsApp",
                                                              style: TextStyle(
                                                                fontSize:
                                                                12,
                                                                color:
                                                                Colors.black45,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 16,
                                                        ), // Space between buttons
                                                        // Instagram Button
                                                        Column(
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () => _shareOnInstagram(
                                                                post['image']!,
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                Colors.pink.shade500, // Instagram color
                                                                shape:
                                                                CircleBorder(), // Makes the button circular
                                                                padding: EdgeInsets.all(
                                                                  10,
                                                                ), // Smaller padding for smaller buttons
                                                              ),
                                                              child: Icon(
                                                                FontAwesomeIcons
                                                                    .instagram,
                                                                color:
                                                                Colors.white,
                                                                size:
                                                                24, // Smaller icon size
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4,
                                                            ), // Space between button and text
                                                            Text(
                                                              "Instagram",
                                                              style: TextStyle(
                                                                fontSize:
                                                                12,
                                                                color:
                                                                Colors.black45,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        SizedBox(
                                                          width: 16,
                                                        ),
                                                        Column(
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () => _shareOnSnapchat(
                                                                post['image']!,
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                Colors.blueAccent.shade400, // Snapchat color
                                                                shape:
                                                                CircleBorder(), // Makes the button circular
                                                                padding: EdgeInsets.all(
                                                                  10,
                                                                ), // Smaller padding for smaller buttons
                                                              ),
                                                              child: Icon(
                                                                FontAwesomeIcons
                                                                    .facebook,
                                                                color:
                                                                Colors.white,
                                                                size:
                                                                24, // Smaller icon size
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4,
                                                            ), // Space between button and text
                                                            Text(
                                                              "Facebook",
                                                              style: TextStyle(
                                                                fontSize:
                                                                12,
                                                                color:
                                                                Colors.black45,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 16,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavBar(
      //   selectedIndex: 1, // Pass the index you want to be selected initially
      //   onDestinationSelected: (int route) {
      //     print('Selected index: $route'); // Simple function to test selection
      //   },
      // ),
    );
  }
}
