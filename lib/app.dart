import 'package:adaptive_theme/src/adaptive_theme_mode.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dcard/cubits/event/cubit/event_cubit.dart';
import 'package:dcard/cubits/event_scan/cubit/event_scan_cubit.dart';
import 'package:dcard/cubits/events/cubit/event_list_cubit.dart';
import 'package:dcard/features/auth/cubit/auth_cubit.dart';
import 'package:dcard/features/auth/login/cubit/login_cubit.dart';
import 'package:dcard/features/settings/cubit/language_cubit.dart';
import 'package:dcard/features/settings/helpers/app_language.dart';
import 'package:dcard/page/Auth/login_screen.dart';
import 'package:dcard/page/Auth/onboarding/onboarding_screen.dart';
import 'package:dcard/page/home_page.dart';
import 'package:dcard/utils/custom_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nb_utils/nb_utils.dart';

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;
  final bool firstRun;
  const MyApp(this.firstRun, {super.key, this.savedThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: Themes.light,
      dark: Themes.dark,
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (BuildContext context) =>
                  LanguageCubit()..getSavedLanguage(),
                  
            ),
            BlocProvider(
              create: (context) => LoginCubit(),
            ),
            BlocProvider(
              create: (context) => AuthCubit(),
            ),
            BlocProvider(create: (context) => EventListCubit()),
            BlocProvider(create: (context) => EventCubit()),
            BlocProvider(create: (context) => EventScanCubit())
          ],
          child: BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, state) {
              if (state is ChangeLanguageState) {
                return MaterialApp(
                  locale: state.locale,
                  title: 'D-Card',
                  showPerformanceOverlay: false,
                  theme: theme,
                  darkTheme: darkTheme,
                  debugShowCheckedModeBanner: false,
                  supportedLocales: const [
                    Locale('en', ""),
                    Locale("sw", ""),
                  ],
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: (currentLocal, supportedLocales) {
                    for (var locale in supportedLocales) {
                      if (currentLocal != null &&
                          currentLocal.languageCode == locale.languageCode) {
                        return currentLocal;
                      }
                    }
                    return supportedLocales.first;
                  },
                  home: BlocBuilder<AuthCubit, AuthState>(
                    bloc: AuthCubit()..isAuthenticated(),
                    builder: (context, state) {
                      return state.maybeWhen(success: (isAuth) {
                        return (widget.firstRun)
                            ? OnBoardingScreen()
                            : (isAuth)
                                ? const HomePage()
                                : const LoginScreen();
                      }, orElse: () {
                        return Scaffold(
                          body: Center(
                            child: Loader(
                              size: 50,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        );
      },
    );
  }
}
