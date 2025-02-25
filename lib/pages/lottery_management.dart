import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart'; // Import localization

class LotteryManagementPage extends StatefulWidget {
  const LotteryManagementPage({super.key});

  @override
  _LotteryManagementPageState createState() => _LotteryManagementPageState();
}

class _LotteryManagementPageState extends State<LotteryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Scratch Card History Data
  List<dynamic> _scratchCards = [];
  bool _isLoadingScratchCards = true;

  // Lottery Product Data
  List<dynamic> _lotteryProducts = [];
  bool _isLoadingProducts = true;

  // Lottery Statistics Data
  Map<String, dynamic> _lotteryStats = {};
  bool _isLoadingStats = true;

  // Assuming you have the current user's ID stored somewhere (replace with your auth/user management solution)
  final String _userId = "currentUserId"; // Replace with the actual user id

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchScratchCards();
    _fetchLotteryProducts();
    _fetchLotteryStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch scratch card history for the current user
  Future<void> _fetchScratchCards() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final data = await ApiService.get(
        'scratchcards',
        headers: {
          // Include the token if required
          'Authorization': 'Bearer ${auth.token}',
        },
      );
      setState(() {
        _scratchCards = data as List;
        _isLoadingScratchCards = false;
      });
    } catch (error) {
      print('Error fetching scratch cards: $error');
      setState(() {
        _isLoadingScratchCards = false;
      });
    }
  }

  // Fetch lottery products/inventory
  Future<void> _fetchLotteryProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'lottery/products',
        headers: {
          // Include the token if required
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _lotteryProducts = data as List;
        _isLoadingProducts = false;
      });
    } catch (error) {
      print('Error fetching lottery products: $error');
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  // Fetch lottery winning statistics
  Future<void> _fetchLotteryStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'lottery/statistics',
        headers: {
          // Include the token if required
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _lotteryStats = data;
        _isLoadingStats = false;
      });
    } catch (error) {
      print('Error fetching lottery statistics: $error');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  // UI for the Scratch Card History tab
  Widget _buildScratchCardHistory() {
    if (_isLoadingScratchCards) {
      return Center(child: CircularProgressIndicator());
    }
    if (_scratchCards.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_scratch_cards_found'),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
              label: Text(AppLocalizations.of(context).translate('card_id'))),
          DataColumn(
              label:
                  Text(AppLocalizations.of(context).translate('reward_type'))),
          DataColumn(
              label:
                  Text(AppLocalizations.of(context).translate('reward_value'))),
          DataColumn(
              label: Text(AppLocalizations.of(context).translate('redeemed'))),
        ],
        rows: _scratchCards.map((card) {
          return DataRow(cells: [
            DataCell(Text(card['_id'] ?? '')),
            DataCell(Text(card['rewardType'] ?? '')),
            DataCell(Text(card['rewardValue'].toString())),
            DataCell(Text(card['isScratched'] == true
                ? AppLocalizations.of(context).translate('yes')
                : AppLocalizations.of(context).translate('no'))),
          ]);
        }).toList(),
      ),
    );
  }

  // UI for the Lottery Product Management tab
  Widget _buildLotteryProducts() {
    if (_isLoadingProducts) {
      return Center(child: CircularProgressIndicator());
    }
    if (_lotteryProducts.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_lottery_products'),
        ),
      );
    }
    return ListView.builder(
      itemCount: _lotteryProducts.length,
      itemBuilder: (context, index) {
        final product = _lotteryProducts[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(product['name'] ??
                AppLocalizations.of(context).translate('unnamed_product')),
            subtitle: Text(AppLocalizations.of(context)
                .translate('inventory')
                .replaceAll(
                    '{inventory}', product['inventory']?.toString() ?? '0')),
            trailing: Text(AppLocalizations.of(context)
                .translate('price')
                .replaceAll('{price}', product['price']?.toString() ?? 'N/A')),
          ),
        );
      },
    );
  }

  // UI for the Lottery Winning Statistics tab
  Widget _buildLotteryStatistics() {
    if (_isLoadingStats) {
      return Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).translate('lottery_statistics'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context)
              .translate('winning_percentage')
              .replaceAll('{percentage}',
                  _lotteryStats['winningPercentage']?.toString() ?? 'N/A')),
          SizedBox(height: 8),
          Text(AppLocalizations.of(context).translate('total_cards').replaceAll(
              '{total}', _lotteryStats['totalCards']?.toString() ?? 'N/A')),
          SizedBox(height: 8),
          Text(AppLocalizations.of(context).translate('total_wins').replaceAll(
              '{wins}', _lotteryStats['totalWins']?.toString() ?? 'N/A')),
          SizedBox(height: 8),
          Text(AppLocalizations.of(context)
              .translate('common_prize')
              .replaceAll('{prize}',
                  _lotteryStats['commonPrize']?.toString() ?? 'N/A')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).translate('lottery_management')),
      ),
      drawer: Sidebar(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  text: AppLocalizations.of(context)
                      .translate('scratch_history')),
              Tab(text: AppLocalizations.of(context).translate('products')),
              Tab(text: AppLocalizations.of(context).translate('statistics')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScratchCardHistory(),
                _buildLotteryProducts(),
                _buildLotteryStatistics(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
