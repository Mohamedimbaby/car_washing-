import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/localization/locale_provider.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/booking/presentation/cubit/booking_cubit.dart';
import 'features/cars/presentation/cubit/car_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await configureDependencies();

  runApp(const CarWashApp());
}

class CarWashApp extends StatefulWidget {
  const CarWashApp({super.key});

  @override
  State<CarWashApp> createState() => _CarWashAppState();
}

class _CarWashAppState extends State<CarWashApp> {
  final _localeProvider = LocaleProvider();

  @override
  void initState() {
    super.initState();
    // Initialize notifications after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      NotificationService().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => getIt<BookingCubit>()),
        BlocProvider(create: (_) => getIt<CarCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
      ],
      child: AnimatedBuilder(
        animation: _localeProvider,
        builder: (context, child) {
          return MaterialApp(
            title: 'غسيل السيارات / Car Wash',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // locale: _localeProvider.locale,
            // localizationsDelegates: const [
            //   AppLocalizations.delegate,
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            //   GlobalCupertinoLocalizations.delegate,
            // ],
            // supportedLocales: const [
            //   Locale('en'),
            //   Locale('ar'),
            // ],
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
