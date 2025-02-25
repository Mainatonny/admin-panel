import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../l10n/app_localizations.dart'; // Import localization

class StatisticsReportingPage extends StatefulWidget {
  const StatisticsReportingPage({super.key});

  @override
  _StatisticsReportingPageState createState() =>
      _StatisticsReportingPageState();
}

class _StatisticsReportingPageState extends State<StatisticsReportingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data holders for statistics
  Map<String, dynamic> _usageStats = {};
  Map<String, dynamic> _reportStats = {};
  Map<String, dynamic> _revenueStats = {};
  Map<String, dynamic> _behaviorStats = {};

  bool _isLoadingUsage = true;
  bool _isLoadingReport = true;
  bool _isLoadingRevenue = true;
  bool _isLoadingBehavior = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchUsageStats();
    _fetchReportStats();
    _fetchRevenueStats();
    _fetchBehaviorStats();
  }

  Future<void> _fetchUsageStats() async {
    try {
      final data = await ApiService.get('statistics/usage');
      setState(() {
        _usageStats = data;
        _isLoadingUsage = false;
      });
    } catch (error) {
      print('Error fetching usage stats: $error');
      setState(() {
        _isLoadingUsage = false;
      });
    }
  }

  Future<void> _fetchReportStats() async {
    try {
      final data = await ApiService.get('statistics/reports');
      setState(() {
        _reportStats = data;
        _isLoadingReport = false;
      });
    } catch (error) {
      print('Error fetching report stats: $error');
      setState(() {
        _isLoadingReport = false;
      });
    }
  }

  Future<void> _fetchRevenueStats() async {
    try {
      final data = await ApiService.get('statistics/revenue');
      setState(() {
        _revenueStats = data;
        _isLoadingRevenue = false;
      });
    } catch (error) {
      print('Error fetching revenue stats: $error');
      setState(() {
        _isLoadingRevenue = false;
      });
    }
  }

  Future<void> _fetchBehaviorStats() async {
    try {
      final data = await ApiService.get('statistics/behavior');
      setState(() {
        _behaviorStats = data;
        _isLoadingBehavior = false;
      });
    } catch (error) {
      print('Error fetching behavior stats: $error');
      setState(() {
        _isLoadingBehavior = false;
      });
    }
  }

  Widget _buildUsageStats() {
    if (_isLoadingUsage) return Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).translate('app_usage_statistics'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)
              .translate('total_logins')
              .replaceAll(
                  '{count}', _usageStats['totalLogins']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('active_users')
              .replaceAll(
                  '{count}', _usageStats['activeUsers']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('feature_usage')
              .replaceAll(
                  '{usage}', _usageStats['featureUsage']?.toString() ?? 'N/A')),
          // Add additional details or charts as needed
        ],
      ),
    );
  }

  Widget _buildReportStats() {
    if (_isLoadingReport) return Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).translate('report_statistics'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)
              .translate('total_reports')
              .replaceAll('{count}',
                  _reportStats['totalReports']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('pending_reports')
              .replaceAll(
                  '{count}', _reportStats['pending']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('processed_reports')
              .replaceAll(
                  '{count}', _reportStats['processed']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('avg_processing_time')
              .replaceAll('{time}',
                  _reportStats['avgProcessingTime']?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  Widget _buildRevenueStats() {
    if (_isLoadingRevenue) return Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).translate('revenue_statistics'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)
              .translate('total_payment_revenue')
              .replaceAll('{amount}',
                  _revenueStats['totalPayments']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('advertising_revenue')
              .replaceAll(
                  '{amount}', _revenueStats['adRevenue']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('promotional_revenue')
              .replaceAll('{amount}',
                  _revenueStats['promoRevenue']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('rewards_compensation')
              .replaceAll(
                  '{amount}', _revenueStats['rewards']?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  Widget _buildBehaviorStats() {
    if (_isLoadingBehavior) return Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).translate('user_behavior_analysis'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)
              .translate('avg_session_duration')
              .replaceAll('{duration}',
                  _behaviorStats['avgSession']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('most_used_features')
              .replaceAll('{features}',
                  _behaviorStats['topFeatures']?.toString() ?? 'N/A')),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).translate('churn_rate').replaceAll(
              '{rate}', _behaviorStats['churnRate']?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context).translate('statistics_reporting')),
      ),
      drawer: Sidebar(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: AppLocalizations.of(context).translate('usage')),
              Tab(text: AppLocalizations.of(context).translate('reports')),
              Tab(text: AppLocalizations.of(context).translate('revenue')),
              Tab(text: AppLocalizations.of(context).translate('behavior')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsageStats(),
                _buildReportStats(),
                _buildRevenueStats(),
                _buildBehaviorStats(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
