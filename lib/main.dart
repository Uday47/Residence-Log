
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:residence_log/MapPage.dart';
import 'package:residence_log/WallPage.dart';
import 'package:residence_log/CamPage.dart';
import 'package:residence_log/auth.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:flutter/widgets.dart';



Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 300;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission != LocationPermission.whileInUse ||
      permission != LocationPermission.always) {
    LocationPermission permission = await Geolocator.requestPermission();
  }
  if (kReleaseMode) {
    CustomImageCache();
  }
  runApp(const MyApp());
}


class CustomImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    ImageCache imageCache = super.createImageCache();
    // Set your image cache size
    imageCache.maximumSizeBytes = 1024 * 1024 * 1000; // 100 MB
    return imageCache;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<AuthService>(
              create: (_) => AuthService(FirebaseAuth.instance)),
          StreamProvider(
              create: (tcontext) =>
                  tcontext.read<AuthService>().authStateChanges,
              initialData: null)
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Residence Log',
          darkTheme: ThemeData(
            fontFamily: 'Montserrat',
            brightness: Brightness.light,
          ),
          themeMode: ThemeMode.dark,
          home: AuthWrapper(),
          // initialRoute: '/',
          routes: {
            "/home": (context) => HomePage(),
            // "/map_page" : (context) => MapPage(),
          },
        ));
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseuser = context.watch<User>();
    if (firebaseuser != null) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).popAndPushNamed("/home");
      });
      return const Text("");
    } else {
      return SignInPage();
    }
    // return Container();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 1;
  final List<Widget> _pages = [WallPage(), MapPage(), CamPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(
                Icons.logout,
                semanticLabel: "LogOut",
              ),
              onPressed: () {
                context.read<AuthService>().signOut();
                SystemNavigator.pop();
              })
        ],
        title: const Text(
          "Residence Log",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic),
        ),
        toolbarHeight: 67,
        elevation: 0.0,
        bottomOpacity: 0.0,
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: _pages[currentIndex],
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavyBar(
        containerHeight: 60,
        backgroundColor: Colors.black,
        selectedIndex: currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        onItemSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.rss_feed),
            title: const Text(
              'Wall',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.map),
            title: const Text(
              'Map',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.camera_alt),
            title: const Text(
              'Upload',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: const Text(
      //     "Map-idence!",
      //     style: TextStyle(
      //         color: Colors.white,
      //         fontSize: 50,
      //         fontFamily: 'Montserrat',
      //         fontWeight: FontWeight.w700,
      //         fontStyle: FontStyle.italic),
      //   ),
      //   backgroundColor: Colors.black,
      //   toolbarHeight: MediaQuery.of(context).size.height * 0.25,
      //   elevation: 0.0,
      //   bottomOpacity: 0.0,
      //   centerTitle: true,
      // ),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Container(
            child: const Text(
              "Residence Log",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic),
            ),
          )),
          const SizedBox(
            width: 50,
            height: 20,
          ),
          Container(
            child: const Text(
              "Map your journey to/at residence with pictures.",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(
            width: 100,
            height: 70,
          ),
          SizedBox(
            width: 360,
            height: 100,
            child: TextField(
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500),
              controller: emailController,
              decoration: const InputDecoration(
                fillColor: Colors.white10,
                filled: true,
                labelText: "Email",
                labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(
            width: 360,
            height: 100,
            child: TextField(
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500),
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                fillColor: Colors.white10,
                filled: true,
                labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(
              width: 120,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    onSurface: Colors.black),
                onPressed: () {
                  context.read<AuthService>().signIn(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                },
                child: const Text(
                  "Sign in",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700),
                ),
              )),
        ],
      )),
    );
  }
}
