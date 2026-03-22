import 'dart:ui';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  final GetStorage _storage = GetStorage();
  final RxString currentLang = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    currentLang.value = _storage.read('language') ?? 'en';
  }

  void changeLanguage(String langCode) {
    currentLang.value = langCode;
    _storage.write('language', langCode);
    Get.updateLocale(Locale(langCode));
  }

  String get langName {
    switch (currentLang.value) {
      case 'mr':
        return 'मराठी';
      case 'hi':
        return 'हिंदी';
      default:
        return 'English';
    }
  }
}
