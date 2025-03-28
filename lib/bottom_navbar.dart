import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex; // Changed to int
  final ValueChanged<int> onDestinationSelected; // Changed to int

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: onDestinationSelected,
        indicatorColor: Colors.purple, // The purple indicator when selected
        selectedIndex: selectedIndex, // Now correctly an int
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: Colors.white), // White when selected
            icon: Icon(Icons.home_outlined, color: Colors.black),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications_sharp, color: Colors.white), // White when selected
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            label: 'Notifications',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle, color: Colors.white), // Changed to white for consistency
            icon: Icon(Icons.add_circle_outlined, color: Colors.black),
            label: 'Create',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings, color: Colors.white), // White when selected
            icon: Icon(Icons.settings_outlined, color: Colors.black),
            label: 'Settings',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle, color: Colors.white), // White when selected
            icon: Icon(Icons.account_circle_outlined, color: Colors.black),
            label: 'Profile',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, // Show labels by default
      ),
      floatingActionButton: CreateButton(), // Added the CreateButton to the layout
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Position the FAB
    );
  }
}

class CreateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Handle "Create" button press here
      },
      backgroundColor: Colors.purple,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}