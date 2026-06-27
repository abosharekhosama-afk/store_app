import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:untitled2_ecom/bindings/general_bindings.dart';
import 'package:untitled2_ecom/features/authentication/screens/onBoarding/onboarding.dart';
import 'package:untitled2_ecom/routes/app_routes.dart';
import 'package:untitled2_ecom/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      /// -- README(Docs[3]) -- Bindings
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      initialBinding: GeneralBindings(),
      getPages: AppRoutes.pages,

      /// -- README(Docs[4]) -- To use Screen Transitions here
      /// -- README(Docs[5]) -- Home Screen or Progress Indicator
      home: const Onboarding(),
    );
  }
}
