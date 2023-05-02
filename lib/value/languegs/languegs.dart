import 'package:get/get.dart';
import 'package:whatsapp_sticker_maker/value/my_str.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          ValueTranslate.titleText: " Sticker Maker",
          ValueTranslate.btnNavText: "Make your Stickers ",
          ValueTranslate.errImage: "You must add 3 or more photos",
          ValueTranslate.setName: "Add Name For packet",
          ValueTranslate.textFild: "For example my sticker",
          ValueTranslate.addbtn: "Add",
          ValueTranslate.errName: "You must add Name for packet",
          ValueTranslate.usecamera: "camera",
          ValueTranslate.usegalray: "gallery",
          ValueTranslate.delete: "delete",
          ValueTranslate.install: "Please install WhatsApp",
          ValueTranslate.telegram: "Telegram",
          ValueTranslate.whatsApp: "whatsApp",
          ValueTranslate.which: "which one",
          ValueTranslate.notGifErr: "Not Supported Gif ",
        },
        'fa_IR': {
          ValueTranslate.titleText: "استیکر",
          ValueTranslate.btnNavText: "افزودن استیکر ",
          ValueTranslate.errImage: "شما باید سه یا بیشتر از سه عکس اضافه کنید",
          ValueTranslate.setName: "نام بسته استیکر",
          ValueTranslate.textFild: "به عنوان مثال استیکر من",
          ValueTranslate.addbtn: "افزودن",
          ValueTranslate.errName: "لطفا یک نام برای پکت خود بنویسید",
          ValueTranslate.usecamera: "دوربین",
          ValueTranslate.usegalray: "گالری",
          ValueTranslate.delete: "حذف",
          ValueTranslate.install: "لطفا واتساپ را نصب کنید",
          ValueTranslate.telegram: "تلگرام",
          ValueTranslate.whatsApp: "واتساپ",
          ValueTranslate.which: "کدام یک",
          ValueTranslate.notGifErr: "عکس با نوع گیف پشتیبانی نمیشود:( ",
        }
      };
}
