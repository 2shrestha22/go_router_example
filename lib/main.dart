import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

const spacer = SizedBox(height: 20);
final navigatorKey = GlobalKey<NavigatorState>();

/// The login information.
class LoginInfo extends ChangeNotifier {
  /// The username of login.
  String get userName => _userName;
  String _userName = '';

  /// Whether a user has logged in.
  bool get loggedIn => _userName.isNotEmpty;

  /// Logs in a user.
  void login(String userName) {
    _userName = userName;
    notifyListeners();
  }

  /// Logs out the current user.
  void logout() {
    _userName = '';
    notifyListeners();
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final LoginInfo _loginInfo = LoginInfo();

  late final _router = GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    refreshListenable: _loginInfo,
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, __) => const MyHomePage(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (_, __) => const ProfilePage(),
            redirect: authGuard,
          ),
          GoRoute(
            path: 'login',
            builder: (_, __) => const LoginPage(),
            redirect: (BuildContext context, GoRouterState state) {
              /// Redirects to next page after login
              /// /login?redirect_to=%2Fprofile
              /// return /profile
              if (_loginInfo.loggedIn) {
                if (state.queryParams['redirect_to']?.isNotEmpty ?? false) {
                  return state.queryParams['redirect_to']!;
                } else {
                  return '/';
                }
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    ],
  );

  String? authGuard(BuildContext context, GoRouterState state) {
    // If not logged in redirects to login page also providing
    // next page to redirect after login
    if (_loginInfo.loggedIn) {
      return null;
    } else {
      // return state.namedLocation(
      //   Routes.login,
      //   queryParams: {'redirect_to': state.location},
      // );
      // return GoRouter.of(context).namedLocation(
      //   Routes.login,
      //   queryParams: {'redirect_to': state.location},
      // );

      return Uri(
        path: '/login',
        queryParameters: {'redirect_to': state.location},
      ).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginInfo>.value(
      value: _loginInfo,
      child: Builder(builder: (context) {
        return MaterialApp.router(
          title: 'GoRouter Demo',
          theme: ThemeData(primarySwatch: Colors.blue),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void dispose() {
    debugPrint('home disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('HomePage'),
          spacer,
          ElevatedButton(
            onPressed: () {
              context.go('/profile');
            },
            child: const Text('Go to profile'),
          ),
        ],
      )),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 80),
            spacer,
            ElevatedButton(
              onPressed: () {
                context.read<LoginInfo>().logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Page'),
            spacer,
            ElevatedButton(
              onPressed: () {
                context.read<LoginInfo>().login('userName');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
