import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart'; // Import localization

class PaymentManagementPage extends StatefulWidget {
  const PaymentManagementPage({super.key});

  @override
  _PaymentManagementPageState createState() => _PaymentManagementPageState();
}

class _PaymentManagementPageState extends State<PaymentManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Payment history
  List<Payment> _payments = [];
  bool _isLoadingPayments = true;

  // Subscription details
  Map<String, dynamic> _subscription = {};
  bool _isLoadingSubscription = true;

  // Wallet / Recharge history
  List<dynamic> _walletTransactions = [];
  bool _isLoadingWallet = true;

  // Compensation management
  Map<String, dynamic> _compensation = {};
  bool _isLoadingCompensation = true;
  final TextEditingController _policyController = TextEditingController();
  final TextEditingController _paidServiceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Now we have 4 tabs
    _tabController = TabController(length: 4, vsync: this);
    _fetchPayments();
    _fetchSubscription();
    _fetchWalletTransactions();
    _fetchCompensationDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _policyController.dispose();
    _paidServiceController.dispose();
    super.dispose();
  }

  // ------------------------
  // Payment History
  // ------------------------
  Future<void> _fetchPayments() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final data = await ApiService.get(
        'payments',
        headers: {
          'Authorization': 'Bearer ${auth.token}',
        },
      );
      setState(() {
        _payments =
            (data as List).map((json) => Payment.fromJson(json)).toList();
        _isLoadingPayments = false;
      });
    } catch (error) {
      print('Error fetching payments: $error');
      setState(() {
        _isLoadingPayments = false;
      });
    }
  }

  Future<void> _processRefund(String paymentId) async {
    // Placeholder for refund processing logic.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('refund_processed')
              .replaceAll('{id}', paymentId))),
    );
  }

  // ------------------------
  // Subscription Management
  // ------------------------
  Future<void> _fetchSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'subscriptions',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _subscription = data['subscription'] ?? {};
        _isLoadingSubscription = false;
      });
    } catch (error) {
      print('Error fetching subscription: $error');
      setState(() {
        _isLoadingSubscription = false;
      });
    }
  }

  Future<void> _upgradeSubscription(String tier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.put(
        'subscriptions/upgrade',
        {
          'tier': tier,
        },
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _subscription['subscriptionType'] = data['tier'];
        _subscription['endDate'] = data['expiry'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('subscription_upgraded')
              .replaceAll('{tier}', tier)),
        ),
      );
    } catch (error) {
      print('Upgrade error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('subscription_upgrade_failed'))),
      );
    }
  }

  Future<void> _extendSubscription(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.put(
        'subscriptions/extend',
        {
          'pointsToUse': points,
        },
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _subscription['endDate'] = data['newEndDate'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('subscription_extended'))),
      );
    } catch (error) {
      print('Extend error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('subscription_extension_failed'))),
      );
    }
  }

  // ------------------------
  // Recharge History / Wallet Transactions
  // ------------------------
  Future<void> _fetchWalletTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'payments',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _walletTransactions = data['transactionHistory'] ?? [];
        _isLoadingWallet = false;
      });
    } catch (error) {
      print('Error fetching wallet transactions: $error');
      setState(() {
        _isLoadingWallet = false;
      });
    }
  }

  // ------------------------
  // Compensation Management
  // ------------------------
  Future<void> _fetchCompensationDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'compensation',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _compensation = data['compensation'] ?? {};
        _isLoadingCompensation = false;
        _policyController.text = _compensation['policy'] ?? '';
        _paidServiceController.text = _compensation['paidService'] ?? '';
      });
    } catch (error) {
      print('Error fetching compensation details: $error');
      setState(() {
        _isLoadingCompensation = false;
      });
    }
  }

  Future<void> _updateCompensationDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedData = {
      'policy': _policyController.text,
      'paidService': _paidServiceController.text,
    };

    try {
      await ApiService.put(
        'compensation',
        updatedData,
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('compensation_updated_successfully')),
        ),
      );
      _fetchCompensationDetails();
    } catch (error) {
      print('Error updating compensation details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('compensation_update_failed')),
        ),
      );
    }
  }

  // ------------------------
  // Build UI
  // ------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)
            .translate('payment_subscription_management')),
      ),
      drawer: Sidebar(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(
                  text: AppLocalizations.of(context)
                      .translate('payment_history')),
              Tab(text: AppLocalizations.of(context).translate('subscription')),
              Tab(
                  text: AppLocalizations.of(context)
                      .translate('recharge_history')),
              Tab(text: AppLocalizations.of(context).translate('compensation')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Payment History
                _isLoadingPayments
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('payment_id'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('user_id'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('amount'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('date'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('status'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('actions'))),
                          ],
                          rows: _payments.map((payment) {
                            return DataRow(
                              cells: [
                                DataCell(Text(payment.id)),
                                DataCell(Text(payment.userId)),
                                DataCell(
                                    Text(payment.amount.toStringAsFixed(2))),
                                DataCell(Text(payment.date
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0])),
                                DataCell(Text(payment.status)),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () => _processRefund(payment.id),
                                    child: Text(AppLocalizations.of(context)
                                        .translate('refund')),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                // Tab 2: Subscription Management
                _isLoadingSubscription
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .translate('subscription_details'),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('subscription_type')
                                  .replaceAll(
                                      '{type}',
                                      _subscription['subscriptionType'] ??
                                          'Free'),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('expiry_date')
                                  .replaceAll('{date}',
                                      _subscription['endDate'] ?? 'N/A'),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('manage_subscription'),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _upgradeSubscription('premium'),
                              child: Text(AppLocalizations.of(context)
                                  .translate('upgrade_to_premium')),
                            ),
                            ElevatedButton(
                              onPressed: () => _upgradeSubscription('vip'),
                              child: Text(AppLocalizations.of(context)
                                  .translate('upgrade_to_vip')),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _extendSubscription(100),
                              child: Text(AppLocalizations.of(context)
                                  .translate('extend_subscription')),
                            ),
                          ],
                        ),
                      ),
                // Tab 3: Recharge History / Wallet Transactions
                _isLoadingWallet
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('date'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('type'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('amount'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('method'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('description'))),
                          ],
                          rows: _walletTransactions.map((tx) {
                            return DataRow(
                              cells: [
                                DataCell(Text(tx['date'] ?? '')),
                                DataCell(Text(tx['type'] ?? '')),
                                DataCell(Text(
                                    (tx['amount'] as num).toStringAsFixed(2))),
                                DataCell(Text(tx['method'] ?? '')),
                                DataCell(Text(tx['description'] ?? '')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                // Tab 4: Compensation Management
                _isLoadingCompensation
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .translate('compensation_details'),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('compensation_policy'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TextField(
                              controller: _policyController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: AppLocalizations.of(context)
                                    .translate('enter_compensation_policy'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('paid_services_provided'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TextField(
                              controller: _paidServiceController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: AppLocalizations.of(context)
                                    .translate('enter_paid_services'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _updateCompensationDetails,
                              child: Text(AppLocalizations.of(context)
                                  .translate('update_compensation_details')),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('additional_options'),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
