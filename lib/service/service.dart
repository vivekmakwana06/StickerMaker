import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MatrialAppService extends GetxService {
  GetStorage getStorage = GetStorage();

  getLanguegs() {
    return getStorage.read("langueg") == "fa"
        ? const Locale("fa", "IR")
        : const Locale("en", "US");
  }

  Future getInit() async {
    await GetStorage.init();
  }
}
