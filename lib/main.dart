import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_sticker_maker/home/controller/image_editing_provider.dart';
import 'package:whatsapp_sticker_maker/home/controller/textview.dart';
import 'package:whatsapp_sticker_maker/home/view/home_view.dart';
import 'package:whatsapp_sticker_maker/profile.dart';
import 'package:whatsapp_sticker_maker/value/languegs/languegs.dart';
import 'service/service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initial();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageEditProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          splash: Image.asset('assets/logo.png'),
          nextScreen: Phoenix(
            child: const MyApp(),
          ),
          splashTransition: SplashTransition.fadeTransition,
          duration: 1000,                         
          splashIconSize: 200,
          centered: true,
          animationDuration: Duration(milliseconds: 1000),
          backgroundColor: Colors.black,
        ),
      ),
    ),
  );
}

Future<void> initial() async {
  await Get.putAsync(() async => MatrialAppService());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    MatrialAppService matrialAppServies = Get.find<MatrialAppService>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: Messages(),
      locale: matrialAppServies.getLanguegs(),
      title: 'Sticker Maker',
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  late List<Widget> _pages; // Use late for the _pages variable

  @override
  Widget build(BuildContext context) {
    // Initialize _pages here after _imageData has been initialized
    _pages = [
      const HomeView(),
      SettingsPage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: Color.fromARGB(255, 75, 75, 251),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.sticky_note_2_sharp),
            title: const Text("Profile"),
            selectedColor: Color.fromARGB(255, 10, 198, 4),
          ),
        ],
      ),
    );
  }
}
