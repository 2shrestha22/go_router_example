import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

const spacer = SizedBox(height: 20);

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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginInfo>.value(
      value: _loginInfo,
      child: MaterialApp.router(
        title: 'GoRouter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: _getRouter(_loginInfo),
        debugShowCheckedModeBanner: false,
      ),
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
              context.goNamed(Routes.profile);
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

GoRouter _getRouter(LoginInfo loginInfo) {
  /// Returs login path if not logged in else returns null;
  String? authGuard(BuildContext context, GoRouterState state) {
    // If not logged in redirects to login page also providing
    // next page to redirect after login
    if (loginInfo.loggedIn) {
      return null;
    } else {
      // return state.namedLocation(
      //   Routes.login,
      //   queryParams: {'redirect_to': state.location},
      // );
      return GoRouter.of(context).namedLocation(
        Routes.login,
        queryParams: {'redirect_to': state.location},
      );
    }
  }

  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: loginInfo,
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: Routes.home,
        builder: (_, __) => const MyHomePage(),
        routes: [
          GoRoute(
            path: 'login',
            name: Routes.login,
            builder: (_, __) => const LoginPage(),
            redirect: (BuildContext context, GoRouterState state) {
              /// Redirects to next page after login
              if (loginInfo.loggedIn) {
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
          GoRoute(
            path: 'profile',
            name: Routes.profile,
            builder: (_, __) => const ProfilePage(),
            redirect: authGuard,
          ),
        ],
      ),
    ],
  );
}

class Routes {
  const Routes._();

  static const home = 'home';
  static const login = 'login';

  static const profile = 'profile';
}
