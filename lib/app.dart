import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/booking/bloc/booking_cubit.dart';
import 'features/favorites/bloc/favorites_cubit.dart';
import 'features/home/bloc/cars_cubit.dart';
import 'features/inspection/bloc/inspection_cubit.dart';
import 'features/messages/bloc/messages_cubit.dart';
import 'features/rental/bloc/rental_cubit.dart';
import 'features/wizard/bloc/wizard_cubit.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class DriveTNApp extends StatelessWidget {
  const DriveTNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CarsCubit()),
        BlocProvider(create: (_) => FavoritesCubit()),
        BlocProvider(create: (_) => BookingCubit()),
        BlocProvider(create: (_) => InspectionCubit()),
        BlocProvider(create: (_) => MessagesCubit()),
        BlocProvider(create: (_) => RentalCubit()),
        BlocProvider(create: (_) => WizardCubit()),
      ],
      child: MaterialApp.router(
        title: 'DriveTN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: AppRouter.router,
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('ar', 'TN'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
