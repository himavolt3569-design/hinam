import 'package:flutter/material.dart';
import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:hinam/features/admin/presentation/screens/pending_drivers_screen.dart';
import 'package:hinam/features/auth/presentation/models/otp_arguments.dart';
import 'package:hinam/features/auth/presentation/screens/login_screen.dart';
import 'package:hinam/features/auth/presentation/screens/otp_screen.dart';
import 'package:hinam/features/auth/presentation/screens/splash_screen.dart';
import 'package:hinam/features/bus_stops/presentation/screens/manage_bus_stops_screen.dart';
import 'package:hinam/features/driver/presentation/screens/dashboard_screen.dart';
import 'package:hinam/features/driver/presentation/screens/driver_registration_screen.dart';
import 'package:hinam/features/fleet/presentation/screens/manage_assignments_screen.dart';
import 'package:hinam/features/fleet/presentation/screens/manage_buses_screen.dart';
import 'package:hinam/features/passenger/presentation/screens/public_bus_list_screen.dart';
import 'package:hinam/features/passenger/presentation/screens/single_bus_map_screen.dart';
import 'package:hinam/features/school_bus/presentation/screens/school_bus_list_screen.dart';

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
        return MaterialPageRoute(builder: (_) => const DriverRegistrationScreen());

      case AppRoutes.publicBusList:
        return MaterialPageRoute(builder: (_) => const PublicBusListScreen());

      case AppRoutes.schoolBusList:
        return MaterialPageRoute(builder: (_) => const SchoolBusListScreen());

      case AppRoutes.singleBusMap:
        final driverId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SingleBusMapScreen(driverId: driverId),
        );

      case AppRoutes.manageBusStops:
        return MaterialPageRoute(builder: (_) => const ManageBusStopsScreen());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case AppRoutes.pendingDrivers:
        return MaterialPageRoute(builder: (_) => const PendingDriversScreen());

      case AppRoutes.manageBuses:
        return MaterialPageRoute(builder: (_) => const ManageBusesScreen());

      case AppRoutes.manageAssignments:
        return MaterialPageRoute(builder: (_) => const ManageAssignmentsScreen());

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
