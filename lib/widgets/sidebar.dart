import 'package:flutter/material.dart';
import '../routes.dart';
import '../l10n/app_localizations.dart'; // Import localization

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              AppLocalizations.of(context).translate('admin_panel'),
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _createDrawerItem(context, Icons.dashboard,
              AppLocalizations.of(context).translate('dashboard'), '/'),
          _createDrawerItem(
              context,
              Icons.people,
              AppLocalizations.of(context).translate('user_management'),
              '/users'),
          _createDrawerItem(
              context,
              Icons.report,
              AppLocalizations.of(context).translate('report_management'),
              '/reports'),
          _createDrawerItem(
              context,
              Icons.payment,
              AppLocalizations.of(context).translate('payment_management'),
              '/payments'),
          _createDrawerItem(
              context,
              Icons.card_giftcard,
              AppLocalizations.of(context).translate('reward_management'),
              '/rewards'),
          _createDrawerItem(
              context,
              Icons.group,
              AppLocalizations.of(context).translate('partner_management'),
              '/partners'),
          _createDrawerItem(
              context,
              Icons.casino,
              AppLocalizations.of(context).translate('lottery_management'),
              '/lottery'),
          _createDrawerItem(
              context,
              Icons.notifications,
              AppLocalizations.of(context).translate('notification_management'),
              '/notifications'),
          _createDrawerItem(
              context,
              Icons.settings,
              AppLocalizations.of(context).translate('system_management'),
              '/system'),
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
