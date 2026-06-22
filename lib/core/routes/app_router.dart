import 'package:flutter/material.dart';
import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:hinam/features/admin/presentation/screens/pending_drivers_screen.dart';
import 'package:hinam/features/auth/presentation/models/otp_arguments.dart';
import 'package:hinam/features/auth/presentation/screens/login_screen.dart';
import 'package:hinam/features/auth/presentation/screens/otp_screen.dart';
import 'package:hinam/features/driver/presentation/screens/dashboard_screen.dart';
import 'package:hinam/features/auth/presentation/screens/splash_screen.dart';
import 'package:hinam/features/bus_stops/presentation/screens/manage_bus_stops_screen.dart';
import 'package:hinam/features/driver/presentation/screens/driver_registration_screen.dart';
import 'package:hinam/features/passenger/presentation/screens/passenger_map_screen.dart';
import 'package:hinam/features/school_bus/presentation/screens/parent_tracking_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.otp:
        final args = settings.arguments as OtpArguments;
        return MaterialPageRoute(
          builder: (_) => OtpScreen(
            phoneNumber: args.phoneNumber,
            verificationId: args.verificationId,
          ),
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case AppRoutes.driverRegistration:
        return MaterialPageRoute(
          builder: (_) => const DriverRegistrationScreen(),
        );

      case AppRoutes.passengerMap:
        return MaterialPageRoute(builder: (_) => const PassengerMapScreen());

      case AppRoutes.manageBusStops:
        return MaterialPageRoute(builder: (_) => const ManageBusStopsScreen());

      case AppRoutes.parentTracking:
        return MaterialPageRoute(builder: (_) => const ParentTrackingScreen());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case AppRoutes.pendingDrivers:
        return MaterialPageRoute(builder: (_) => const PendingDriversScreen());

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
