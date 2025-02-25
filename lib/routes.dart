import 'package:flutter/material.dart';
import 'pages/dashboard.dart';
import 'pages/user_management.dart';
import 'pages/report_management.dart';
import 'pages/payment_management.dart';
import 'pages/reward_management.dart';
import 'pages/partner_management.dart';
import 'pages/lottery_management.dart';
import 'pages/notification_management.dart';
import 'pages/system_management.dart';
import 'pages/login.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/dashboard': (context) => DashboardPage(),
  '/login': (context) => LoginScreen(),
  '/users': (context) => UserManagementPage(),
  '/reports': (context) => ReportManagementPage(),
  '/payments': (context) => PaymentManagementPage(),
  '/rewards': (context) => RewardManagementPage(),
  '/partners': (context) => PartnerManagementPage(),
  '/lottery': (context) => LotteryManagementPage(),
  '/notifications': (context) => NotificationManagementPage(),
  '/system': (context) => SystemManagementPage(),
};
