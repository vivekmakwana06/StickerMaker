import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:whatsapp_sticker_maker/home/view/home_view.dart';
import 'package:whatsapp_sticker_maker/themes/themes.dart';
import 'package:whatsapp_sticker_maker/value/languegs/languegs.dart';
import 'service/service.dart';

Future<void> main() async {
  await initilal();
  await Get.find<MatrialAppService>().getInit();
  runApp(
    Phoenix(
      child: const MyApp(),
    ),
  );
}

Future initilal() async {
  Get.put(MatrialAppService());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MatrialAppService matrialAppServies = Get.find<MatrialAppService>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: Messages(),
      locale: matrialAppServies.getLanguegs(),
      title: 'sticker maker',
      theme: Themes.lightTheme,
      home: const HomeView(),
    );
  }
}
