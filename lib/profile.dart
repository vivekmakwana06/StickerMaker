import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_sticker_maker/functions.dart';
import 'package:whatsapp_sticker_maker/image.dart';
import 'package:whatsapp_sticker_maker/textstyle.dart';

enum Availability { loading, available, unavailable }

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final InAppReview _inAppReview = InAppReview.instance;

  String _appStoreId = 'com.aven.wpstickermaker';

  Availability _availability = Availability.loading;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setAvailability();
      loadProfileImage(); // Load profile image when the app starts
    });
  }

  Future<void> setAvailability() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      try {
        final isAvailable = await _inAppReview.isAvailable();
        p("isAvailable", isAvailable);
        if (mounted) {
          setState(() {
            _availability = isAvailable && Platform.isAndroid
                ? Availability.available
                : Availability.unavailable;
          });
        }
      } catch (e) {
        p("catch", _availability);
        if (mounted) {
          setState(() => _availability = Availability.unavailable);
        }
      }
    });
  }

  Future<void> _requestReview() => _inAppReview.requestReview();

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: _appStoreId,
      );
  Future<void> share() async {
    await FlutterShare.share(
        title: 'Whattsapp Sticker Maker App',
        text: 'Whattsapp Sticker Maker App',
        linkUrl:
            'https://play.google.com/store/apps/details?id=com.aven.wpstickermaker',
        chooserTitle: 'Whattsapp Sticker Maker App');
  }

  // void changeTheme(BuildContext context, bool isDark) {
  //   ThemeProvider themeProvider =
  //       Provider.of<ThemeProvider>(context, listen: false);
  //   isDark ? themeProvider.setDarkTheme() : themeProvider.setLightTheme();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          buildSettingsItem1('Setting', () {}),
          Divider(),
          buildUserProfileSection(),
          Divider(),
          buildSettingsItem(Icons.share, "Share App", () {
            if (_availability == Availability.available) {
              share();
              p("AVAILABLE", "PRESS BUTTON");
            }
          }),
          Divider(),
        ],
      ),
    );
  }

  InkWell buildSettingsItem(IconData icon, String title, VoidCallback onTap,
      {String? endTitle,
      bool hasSwitch = false,
      bool switchValue = false,
      Function(bool)? onSwitchChanged}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Spacer(),
          if (hasSwitch)
            Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                endTitle ?? "",
                style: TextStyles.mcLarenStyle
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            )
        ]),
      ),
    );
  }

  Widget buildUserProfileSection() {
    return InkWell(
      onTap: () {
        if (_profileImage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FullScreenImageScreen(image: _profileImage!),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 120,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) as ImageProvider<Object>?
                      : null,
                ),
                if (_profileImage == null)
                  Positioned(
                    bottom: 0,
                    right: 3,
                    left: 3,
                    top: 0,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            size: 220,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showEditProfileBottomSheet();
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Edit Profile'),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _updateProfileImage(File(pickedFile.path));
      saveProfileImage(pickedFile.path); // Save profile image
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _updateProfileImage(File(pickedFile.path));
      saveProfileImage(pickedFile.path); // Save profile image
    }
  }

  void _updateProfileImage(File newImage) async {
    setState(() {
      _profileImage = newImage;
    });

    // Save profile image path to SharedPreferences
    saveProfileImage(newImage.path);
  }

  Future<void> saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', imagePath);
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImage');

    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  InkWell buildSettingsItem1(String title, VoidCallback onTap,
      {String? endTitle}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: GoogleFonts.roboto(
                  textStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                endTitle ?? "",
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
