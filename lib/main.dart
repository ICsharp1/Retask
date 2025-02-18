import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_themes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final notifications = FlutterLocalNotificationsPlugin();
  
  final storageService = StorageService(prefs);
  final notificationService = NotificationService(notifications);

  final themeProvider = ThemeProvider(prefs);
  await themeProvider.init();

  runApp(MyApp(
    storageService: storageService,
    notificationService: notificationService,
    prefs: prefs,
    themeProvider: themeProvider,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final NotificationService notificationService;
  final SharedPreferences prefs;
  final ThemeProvider themeProvider;

  const MyApp({super.key, 
    required this.storageService,
    required this.notificationService,
    required this.prefs,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(
            storageService, 
            notificationService,
            Provider.of<ThemeProvider>(context, listen: false),
          )
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'reTask',
          theme: themeProvider.theme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/add-task': (context) => const AddTaskScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
        ),
      ),
    );
  }
}