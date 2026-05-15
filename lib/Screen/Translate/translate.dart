import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TranslatePage extends StatelessWidget {
  const TranslatePage({super.key});

  static const List local = [
    {"name": "English", "locale": Locale("en", "Us")},
    {"name": "Brazil", "locale": Locale("br", "BR")},
    {"name": "Khmer", "locale": Locale("km", "KH")},
    {"name": "Vietnam", "locale": Locale("vi", "VI")},
  ];

  updatelanguage(Locale locale) {
    Get.updateLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Language".tr)),
      // body: Column(
      //   children: [
      //     ListTile(
      //         title: Text("English"),
      //         onTap: () {},
      //         trailing: Icon(
      //           Icons.check_box,
      //           color: Colors.green,
      //         )),
      //     ListTile(title: Text("Brazil"), onTap: () {}),
      //     ListTile(title: Text("Khmer"), onTap: () {}),
      //     ListTile(title: Text("Vietnam"), onTap: () {}),
      //   ],
      // ),
      body: ListView.builder(
        itemCount: local.length,
        itemBuilder: (context, index) {
          var data = local[index];
          return ListTile(
            trailing: Get.locale == data['locale']
                ? Icon(Icons.check, color: Colors.green)
                : SizedBox(),
            title: Text(data['name']),
            onTap: () {
              print(Get.locale);
              updatelanguage(data['locale']);
            },
          );
        },
      ),
    );
  }
}
