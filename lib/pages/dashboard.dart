import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../routes.dart';
import '../l10n/app_localizations.dart'; // Import localization

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Build the list of dashboard cards at runtime so we can localize titles.
    final List<_DashboardCardData> cards = [
      _DashboardCardData(
        title: AppLocalizations.of(context).translate('user_management'),
        icon: Icons.people,
        route: '/users',
      ),
      _DashboardCardData(
        title: AppLocalizations.of(context).translate('report_management'),
        icon: Icons.report,
        route: '/reports',
      ),
      _DashboardCardData(
        title: AppLocalizations.of(context).translate('payment_subscription'),
        icon: Icons.payment,
        route: '/payments',
      ),
      _DashboardCardData(
        title: AppLocalizations.of(context).translate('promotion_partners'),
        icon: Icons.group,
        route: '/partners',
      ),
      _DashboardCardData(
        title: AppLocalizations.of(context).translate('lottery_management'),
        icon: Icons.casino,
        route: '/lottery',
      ),
      _DashboardCardData(
        title: AppLocalizations.of(context).translate('notifications'),
        icon: Icons.notifications,
        route: '/notifications',
      ),
      _DashboardCardData(
        title: AppLocalizations.of(context).translate('system_management'),
        icon: Icons.settings,
        route: '/system',
      ),
      _DashboardCardData(
        title: AppLocalizations.of(context).translate('statistics_reporting'),
        icon: Icons.analytics,
        route: '/statistics',
      ),
      _DashboardCardData(
        title: AppLocalizations.of(context).translate('notice_policy'),
        icon: Icons.announcement,
        route: '/notice',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).translate('dashboard_overview')),
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, card.route);
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        card.icon,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardCardData {
  final String title;
  final IconData icon;
  final String route;

  _DashboardCardData({
    required this.title,
    required this.icon,
    required this.route,
  });
}
