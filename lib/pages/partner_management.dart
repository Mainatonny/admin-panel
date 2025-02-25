import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../l10n/app_localizations.dart'; // Import localization

class PartnerManagementPage extends StatefulWidget {
  const PartnerManagementPage({super.key});

  @override
  _PartnerManagementPageState createState() => _PartnerManagementPageState();
}

class _PartnerManagementPageState extends State<PartnerManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1: Partner List
  List<dynamic> _partners = [];
  bool _isLoadingPartners = true;

  // Tab 2: Revenue Management
  Map<String, dynamic> _revenueData = {};
  bool _isLoadingRevenue = true;

  // Tab 3: Tier & Reward Management
  String _selectedTier = 'standard'; // e.g., 'standard', 'premium', etc.
  final TextEditingController _rewardPolicyController = TextEditingController();

  // Tab 4: Campaign Management
  List<dynamic> _campaigns = [];
  bool _isLoadingCampaigns = true;
  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _campaignDescController = TextEditingController();

  // Tab 5: Advertising Revenue Analysis
  Map<String, dynamic> _adRevenueStats = {};
  bool _isLoadingAdRevenue = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchPartnerList();
    _fetchRevenueData();
    _fetchCampaigns();
    _fetchAdRevenueStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rewardPolicyController.dispose();
    _campaignNameController.dispose();
    _campaignDescController.dispose();
    super.dispose();
  }

  // --------------------------
  // Tab 1: Partner List
  // --------------------------
  Future<void> _fetchPartnerList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'partners',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _partners = data as List;
        _isLoadingPartners = false;
      });
    } catch (error) {
      print('Error fetching partners: $error');
      setState(() {
        _isLoadingPartners = false;
      });
    }
  }

  // --------------------------
  // Tab 2: Revenue Management
  // --------------------------
  Future<void> _fetchRevenueData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'partners/dashboard',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _revenueData = data;
        _isLoadingRevenue = false;
      });
    } catch (error) {
      print('Error fetching revenue data: $error');
      setState(() {
        _isLoadingRevenue = false;
      });
    }
  }

  Future<void> _requestPayout() async {
    try {
      final response = await ApiService.post('partners/payout', {
        'method': 'paypal', // or 'bank_transfer'
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ??
              AppLocalizations.of(context).translate('payout_processed')),
        ),
      );
      _fetchRevenueData();
    } catch (error) {
      print('Payout error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('payout_failed')),
        ),
      );
    }
  }

  // --------------------------
  // Tab 3: Tier & Reward Management
  // --------------------------
  Future<void> _updateTierAndReward() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updatedData = {
        'tier': _selectedTier,
        'rewardPolicy': _rewardPolicyController.text,
      };
      await ApiService.put(
        'partners/tier',
        updatedData,
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('tier_reward_updated')),
        ),
      );
    } catch (error) {
      print('Tier update error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('tier_update_failed')),
        ),
      );
    }
  }

  // --------------------------
  // Tab 4: Campaign Management
  // --------------------------
  Future<void> _fetchCampaigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'partners/campaigns',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _campaigns = data as List;
        _isLoadingCampaigns = false;
      });
    } catch (error) {
      print('Error fetching campaigns: $error');
      setState(() {
        _isLoadingCampaigns = false;
      });
    }
  }

  Future<void> _createCampaign() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final campaignData = {
        'name': _campaignNameController.text,
        'description': _campaignDescController.text,
      };
      await ApiService.post(
        'partners/campaigns',
        campaignData,
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('campaign_created_successfully')),
        ),
      );
      _campaignNameController.clear();
      _campaignDescController.clear();
      _fetchCampaigns();
    } catch (error) {
      print('Campaign creation error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('campaign_creation_failed')),
        ),
      );
    }
  }

  // --------------------------
  // Tab 5: Advertising Revenue Analysis
  // --------------------------
  Future<void> _fetchAdRevenueStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'partners/ad-revenue',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _adRevenueStats = data;
        _isLoadingAdRevenue = false;
      });
    } catch (error) {
      print('Error fetching ad revenue stats: $error');
      setState(() {
        _isLoadingAdRevenue = false;
      });
    }
  }

  // --------------------------
  // Build UI
  // --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).translate('partner_management')),
      ),
      drawer: Sidebar(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: AppLocalizations.of(context).translate('partner_list')),
              Tab(
                  text: AppLocalizations.of(context)
                      .translate('revenue_management')),
              Tab(
                  text: AppLocalizations.of(context)
                      .translate('tier_reward_management')),
              Tab(
                  text: AppLocalizations.of(context)
                      .translate('campaign_management')),
              Tab(
                  text: AppLocalizations.of(context)
                      .translate('ad_revenue_analysis')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --------------------------
                // Tab 1: Partner List
                // --------------------------
                _isLoadingPartners
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('partner_id'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('referral_code'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('partner_since'))),
                            DataColumn(
                                label: Text(AppLocalizations.of(context)
                                    .translate('status'))),
                          ],
                          rows: _partners.map((partner) {
                            return DataRow(cells: [
                              DataCell(Text(partner['_id'] ?? '')),
                              DataCell(Text(partner['referralCode'] ?? '')),
                              DataCell(Text(partner['partnerSince'] != null
                                  ? partner['partnerSince']
                                      .toString()
                                      .split('T')[0]
                                  : '')),
                              DataCell(Text(partner['isActive'] == true
                                  ? AppLocalizations.of(context)
                                      .translate('active')
                                  : AppLocalizations.of(context)
                                      .translate('inactive'))),
                            ]);
                          }).toList(),
                        ),
                      ),

                // --------------------------
                // Tab 2: Revenue Management
                // --------------------------
                _isLoadingRevenue
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .translate('promotional_revenue'),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('referral_revenue')
                                  .replaceAll(
                                      '{revenue}',
                                      _revenueData['referralRevenue']
                                              ?.toString() ??
                                          '0'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('earnings')
                                  .replaceAll(
                                      '{earnings}',
                                      _revenueData['earnings']?.toString() ??
                                          '0'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('revenue_share')
                                  .replaceAll(
                                      '{share}',
                                      _revenueData['revenueShare']
                                              ?.toString() ??
                                          '0'),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _requestPayout,
                              child: Text(AppLocalizations.of(context)
                                  .translate('request_payout')),
                            ),
                          ],
                        ),
                      ),

                // --------------------------
                // Tab 3: Tier & Reward Management
                // --------------------------
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .translate('tier_reward_management'),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)
                          .translate('select_tier')),
                      DropdownButton<String>(
                        value: _selectedTier,
                        items:
                            <String>['standard', 'premium', 'vip'].map((tier) {
                          return DropdownMenuItem<String>(
                            value: tier,
                            child: Text(tier.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (newTier) {
                          setState(() {
                            _selectedTier = newTier!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)
                          .translate('reward_policy')),
                      TextField(
                        controller: _rewardPolicyController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: AppLocalizations.of(context)
                              .translate('enter_reward_policy'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updateTierAndReward,
                        child: Text(AppLocalizations.of(context)
                            .translate('update_tier_reward')),
                      ),
                    ],
                  ),
                ),

                // --------------------------
                // Tab 4: Campaign Management
                // --------------------------
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .translate('manage_campaigns'),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _campaignNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate('campaign_name'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _campaignDescController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate('campaign_description'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _createCampaign,
                        child: Text(AppLocalizations.of(context)
                            .translate('create_campaign')),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        AppLocalizations.of(context)
                            .translate('existing_campaigns'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      _isLoadingCampaigns
                          ? Center(child: CircularProgressIndicator())
                          : _campaigns.isEmpty
                              ? Text(AppLocalizations.of(context)
                                  .translate('no_campaigns_available'))
                              : Column(
                                  children: _campaigns.map((campaign) {
                                    return ListTile(
                                      title: Text(campaign['name'] ?? ''),
                                      subtitle:
                                          Text(campaign['description'] ?? ''),
                                      trailing: Text(
                                        campaign['status'] ??
                                            AppLocalizations.of(context)
                                                .translate('open'),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                ),
                    ],
                  ),
                ),

                // --------------------------
                // Tab 5: Advertising Revenue Analysis
                // --------------------------
                _isLoadingAdRevenue
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .translate('ad_revenue_analysis'),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('total_ad_revenue')
                                  .replaceAll(
                                      '{revenue}',
                                      _adRevenueStats['totalRevenue']
                                              ?.toString() ??
                                          '0'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('monthly_revenue')
                                  .replaceAll(
                                      '{revenue}',
                                      _adRevenueStats['monthlyRevenue']
                                              ?.toString() ??
                                          '0'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('campaigns_run')
                                  .replaceAll(
                                      '{count}',
                                      _adRevenueStats['campaignsRun']
                                              ?.toString() ??
                                          '0'),
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
