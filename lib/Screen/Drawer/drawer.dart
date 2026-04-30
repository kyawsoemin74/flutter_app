// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/constent.dart';

import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AboutFootball/aboutfootball.dart';
import '../Privacy_Policy/privacypolicy.dart';
import '../Privacy_Policy/tearmscondition.dart';
import '../Translate/translate.dart';

enum Availability { loading, available, unavailable }

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  final InAppReview _inAppReview = InAppReview.instance;
  final ChromeSafariBrowser browser = ChromeSafariBrowser();

  Future loadabout() async {
    await browser.open(
      url: WebUri("https://codecanyon.net/user/arup1990"),
      settings: ChromeSafariBrowserSettings(
          shareState: CustomTabsShareState.SHARE_STATE_OFF,
          isSingleInstance: false,
          isTrustedWebActivity: false,
          keepAliveEnabled: true,
          startAnimations: [
            AndroidResource.anim(name: "slide_in_left", defPackage: "android"),
            AndroidResource.anim(name: "slide_out_right", defPackage: "android")
          ],
          exitAnimations: [
            AndroidResource.anim(
                name: "abc_slide_in_top",
                defPackage: "com.pichillilorenzo.flutter_inappwebviewexample"),
            AndroidResource.anim(
                name: "abc_slide_out_top",
                defPackage: "com.pichillilorenzo.flutter_inappwebviewexample")
          ],
          dismissButtonStyle: DismissButtonStyle.CLOSE,
          presentationStyle: ModalPresentationStyle.OVER_FULL_SCREEN),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppConfig.scaffoldBgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 35.h),
          Container(
            padding: EdgeInsets.all(10.r),
            child: Text( // Changed to use AppConfig.appName
              "${AppConfig.appName}".tr,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ),
          menu(
              icon: Icons.privacy_tip,
              name: "About".tr,
              onTap: () async {
                // loadabout();
                // const uri =
                //     'https://drive.google.com/file/d/13YJqAeb7Fh4IYi6_jIxFJV4d6mRv1rm2/view';
                // if (await canLaunch(uri)) {
                //   await launch(uri);
                // } else {
                //   throw 'Could not launch $uri';
                // }
                // redirectpage(ChromeSafariBrowserExampleScreen());
                redirectpage(AboutFootballPage());
              }),
          const Divider(),
          menu(
              icon: Icons.privacy_tip,
              name: "Privacy Policy".tr,
              onTap: () {
                redirectpage(const PrivacyPolicyPage());
              }),
          const Divider(),
          menu(
              icon: Icons.security,
              name: "Terms and Condition".tr,
              onTap: () {
                redirectpage(const TearmconditionPagePage());
              }),
          // const Divider(),
          // menu(
          //     icon: Icons.translate,
          //     name: "Language".tr,
          //     onTap: () {
          //       redirectpage(TranslatePage());
          //     }),
          // const Divider(),
          // menu(
          //     icon: Icons.telegram,
          //     name: "Telegram".tr,
          //     onTap: () async {
          //       String url = "https://t.me/livefootballnewtips";
          //       try {
          //         await launchUrl(Uri.parse(url),
          //             mode: LaunchMode.externalApplication);
          //       } catch (e) {}
          //     }),
          const Divider(),
          menu(
              icon: Icons.privacy_tip,
              name: "Rate us".tr,
              onTap: () async {
                await _inAppReview.isAvailable();
                setState(() {
                  _inAppReview.requestReview();
                });
              }),
          const Divider(),
          menu(
              icon: Icons.security,
              name: "Feedback".tr,
              onTap: () async {
                const uri =
                    'mailto:****@gmail.com?cc=bar@example.com&subject=Greetings%20from%20Cupertino!&body=Wish%20you%20were%20here!';
                if (await canLaunch(uri)) {
                  await launch(uri);
                } else {
                  throw 'Could not launch $uri';
                }
              }),
        ],
      ),
    );
  }

  Widget menu({GestureTapCallback? onTap, IconData? icon, String? name}) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: size.width * 0.7,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 25.r,
                  color: Colors.white,
                ),
                const SizedBox(width: 20),
                Text(
                  name!,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void redirectpage(Widget name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => name,
      ),
    );
  }

  Widget fidbackdialog() {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: const Text(
              "Feedback",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: const Text(
                "Our team is continually working to improve WicketScore to give you the best possible experience. If you have any feedback or suggestions we'd love to hear from you, just email us."),
          ),
          textbox("Your e-mail address"),
          textbox("Your feedback", maxline: 5),
          Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              "Feedback",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget textbox(String hintname, {int maxline = 1}) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        maxLines: maxline,
        decoration: InputDecoration(
            fillColor: Colors.grey[200],
            isDense: true,
            filled: true,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(5)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(5)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(5)),
            hintText: hintname),
      ),
    );
  }
}
