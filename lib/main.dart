import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openapi/secret.dart';
import 'package:openapi/apomodule.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var textController = TextEditingController();
  var scrollController = ScrollController();

  final HomePageController controller = Get.put(HomePageController());

  void postCall(String promptS) async {
    controller.isDataLoading(true);
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    var data =
        '{  "model": "text-davinci-003",  "prompt": "$promptS",  "max_tokens": 3000,  "temperature": 0}';

    var url = Uri.parse('https://api.openai.com/v1/completions');
    var res = await http.post(url, headers: headers, body: data);
    if (res.statusCode != 200) {
      controller.isDataLoading(false);
      if (kDebugMode) {
        throw ('http.post error: statusCode= ${res.statusCode}');
      }
    }
    if (kDebugMode) {
      controller.isDataLoading(false);
      print(res.body);
      AppModule appModule = appModuleFromJson(res.body);
      controller.updateString(appModule);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 20, 20),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 750,
              width: double.maxFinite,
              margin: EdgeInsets.only(left: 6, top: 20, right: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Obx(
                  () => controller.isDataLoading.value
                      ? Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          width: double.maxFinite,
                          child: Center(
                            child: DefaultTextStyle(
                              style: GoogleFonts.arimaMadurai(
                                  fontSize: 20.0, color: Colors.white),
                              child: AnimatedTextKit(
                                  isRepeatingAnimation: true,
                                  repeatForever: true,
                                  animatedTexts: [
                                    TyperAnimatedText(
                                      'Loading...',
                                      speed: Duration(milliseconds: 100),
                                    ),
                                  ]),
                            ),
                          ))
                      : Container(
                          height: controller.resul == null ? 250 : null,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Colors.black,
                          ),
                          child: DefaultTextStyle(
                            style: GoogleFonts.lato(
                                fontSize: 16.0,
                                color: Color.fromARGB(255, 224, 217, 217)),
                            child: AnimatedTextKit(
                                isRepeatingAnimation: false,
                                animatedTexts: [
                                  TyperAnimatedText(
                                      controller.resul == null
                                          ? 'Hi there! What are you looking for today'
                                          : controller.resul!.choices![0].text,
                                      speed: Duration(milliseconds: 10)),
                                ]),
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    width: 340,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25)),
                    child: TextField(
                      scrollPhysics: ScrollPhysics(),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                      controller: textController,
                      decoration: InputDecoration(
                          hintText: 'Enter here',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w200,
                          ),
                          border: InputBorder.none),
                    ),
                  ),
                  Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white),
                      child: IconButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            postCall(textController.text);
                          },
                          icon: Icon(
                            Icons.send_sharp,
                            size: 30,
                            color: Colors.black,
                          )))
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class HomePageController extends GetxController {
  AppModule? resul;
  var isDataLoading = false.obs;
  void updateString(AppModule temp) {
    resul = temp;
  }
}
