import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import '../services/enhanced_currency_service.dart';
import '../services/notification_service.dart';
import '../widgets/collapsible_location_time_widget.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _selectedCurrency = 'IDR';
  String _userCountry = 'Indonesia';
  bool _isLocationEnabled = false;
  bool _notificationsEnabled = true;

  // Static user data
  static const String _userName = 'Ahmad Zakaria';
  static const String _userNIM = '123220077';
  static const String _userEmail = 'ahmad.zakaria@student.ac.id';
  static const String _userMajor = 'Teknik Informatika';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currency = await EnhancedCurrencyService.getDefaultCurrency();
    final locationData = await LocationService.getSavedLocationData();

    if (mounted) {
      setState(() {
        _selectedCurrency = currency;
        _userCountry = locationData['country'] ?? 'Indonesia';
        _isLocationEnabled = locationData['location'] != null;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });

        // Show notification for profile update
        await NotificationService.showDeckNotification(
          '📸 Profile Updated!',
          'Your profile picture has been updated successfully',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _testNotification() async {
    await NotificationService.showFavoriteAddedNotification('Test Card');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Test notification sent!')),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<AuthProvider>().logout();

                // Fixed navigation - use MaterialPageRoute instead of named route
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                  );
                }
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.purple[100],
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.purple[800],
                            )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.purple[800],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // User Info
                    Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'NIM: $_userNIM',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _userMajor,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Session Info
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return FutureBuilder<Duration>(
                  future: authProvider.getLoginDuration(),
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    final hours = duration.inHours;
                    final minutes = duration.inMinutes % 60;

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.access_time, color: Colors.green),
                        title: Text('Session Active'),
                        subtitle: Text('Logged in for ${hours}h ${minutes}m'),
                        trailing: Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                );
              },
            ),

            SizedBox(height: 16),

            // Notification Settings
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text('Push Notifications'),
                      subtitle: Text('Get notified when adding favorites or managing decks'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.notification_add),
                      title: Text('Test Notification'),
                      subtitle: Text('Send a test notification'),
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _testNotification,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Collapsible Location & Time Section
            CollapsibleLocationTimeWidget(),

            SizedBox(height: 16),

            // Currency Settings
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.attach_money),
                      title: Text('Default Currency'),
                      subtitle: Text('Used for card price display'),
                      trailing: DropdownButton<String>(
                        value: _selectedCurrency,
                        onChanged: (value) async {
                          if (value != null) {
                            await EnhancedCurrencyService.setDefaultCurrency(value);
                            setState(() {
                              _selectedCurrency = value;
                            });
                          }
                        },
                        items: [
                          DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                          DropdownMenuItem(value: 'IDR', child: Text('IDR (Rp)')),
                          DropdownMenuItem(value: 'JPY', child: Text('JPY (¥)')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // App Info
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow(Icons.apps, 'App Version', '1.0.0'),
                    _buildInfoRow(Icons.code, 'Build Number', '1'),
                    _buildInfoRow(Icons.developer_mode, 'Developer', 'Ahmad Zakaria'),
                    _buildInfoRow(Icons.school, 'Institution', 'Universitas Teknologi Yogyakarta'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple[800], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
