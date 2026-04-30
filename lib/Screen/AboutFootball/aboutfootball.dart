import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constent.dart';

class AboutFootballPage extends StatefulWidget {
  const AboutFootballPage({Key? key}) : super(key: key);

  @override
  State<AboutFootballPage> createState() => _AboutFootballPageState();
}

class _AboutFootballPageState extends State<AboutFootballPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Changed to use AppConfig.appName
      appBar: AppBar( 
        title:  Text("About ${AppConfig.appName}".tr),
        centerTitle: true,
      ),
      body:  Text(
        "this is live football app, and you everyone can see the live football match in this app. stay with us and enjoy the app".tr,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
