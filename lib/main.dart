import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkntalk/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkntalk/presentation/profile/pages/profile_page.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

// class ProfileImageProvider extends ChangeNotifier {
//   String? _profileImageUrl;
//
//   String? get profileImageUrl => _profileImageUrl;
//
//   set profileImageUrl(String? url) {
//     _profileImageUrl = url;
//     notifyListeners();
//   }
//
//   Future<void> loadProfileImage() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//         final imageUrl = doc.data()?['profileImageUrl'] as String?;
//         if (imageUrl != null) {
//           profileImageUrl = imageUrl;
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error loading profile image: $e');
//       }
//     }
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);

  await FirebaseAppCheck.instance.activate(
    ///todo:store strings in constants/constants.dart file
    webProvider: ReCaptchaV3Provider('CC0CB3E4-971C-467F-9906-29C5D79C6F99'),
  );
  FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileImageProvider()),
      ],
      child: MaterialApp(
        title: 'Social',
        debugShowCheckedModeBanner: false,
        initialRoute: isLoggedIn ? 'home' : 'login',
        onGenerateRoute: (settings)
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (context) => MyHomePage());
            case 'splash':
              return MaterialPageRoute(builder: (context) => const SplashPage());
            case 'home':
              return MaterialPageRoute(builder: (context) => MyHomePage());
            case 'login':
              return MaterialPageRoute(builder: (context) => const MyLogin());
            case 'google':
              return MaterialPageRoute(builder: (context) => const Google());
            case 'register':
              return MaterialPageRoute(builder: (context) => const Myregister());
            case 'profile':
              return MaterialPageRoute(
                builder: (context) =>
                    ProfilePage(onEdit: () {
                      ///
                    }, onLogout: ()async {
                      //todo: make proper file and do that function there using provider preferably
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);
                    }),
              );
            case 'forgot_password':
              return MaterialPageRoute(builder: (context) => const ForgotPassword());
            case 'otp_screen':
              return MaterialPageRoute(builder: (context) => const OtpScreen());
            default:
              return MaterialPageRoute(builder: (context) => const MyLogin());
          }
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const MyLogin());
        },
      ),
    );
  }
}
