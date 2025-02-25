import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../l10n/app_localizations.dart'; // Import localization

class RewardManagementPage extends StatefulWidget {
  const RewardManagementPage({super.key});

  @override
  _RewardManagementPageState createState() => _RewardManagementPageState();
}

class _RewardManagementPageState extends State<RewardManagementPage> {
  bool _isLoading = true;
  List<dynamic> _pendingRewards = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingRewards();
  }

  Future<void> _fetchPendingRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'rewards/pending',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _pendingRewards = data as List;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching pending rewards: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveReward(String rewardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.post(
        'rewards/approve/$rewardId',
        {},
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ??
                AppLocalizations.of(context).translate('reward_approved'),
          ),
        ),
      );
      _fetchPendingRewards();
    } catch (error) {
      print('Error approving reward: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('error_approving_reward')),
        ),
      );
    }
  }

  Future<void> _rejectReward(String rewardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.post(
        'rewards/reject/$rewardId',
        {},
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ??
                AppLocalizations.of(context).translate('reward_rejected'),
          ),
        ),
      );
      _fetchPendingRewards();
    } catch (error) {
      print('Error rejecting reward: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('error_rejecting_reward')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).translate('reward_management')),
      ),
      drawer: Sidebar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pendingRewards.isEmpty
              ? Center(
                  child: Text(AppLocalizations.of(context)
                      .translate('no_pending_rewards')),
                )
              : ListView.builder(
                  itemCount: _pendingRewards.length,
                  itemBuilder: (context, index) {
                    final reward = _pendingRewards[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          AppLocalizations.of(context)
                              .translate('reward_points')
                              .replaceAll(
                                  '{points}', reward['amount'].toString()),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context)
                                  .translate('reward_description') +
                              ': ${reward['description'] ?? ''}\n' +
                              AppLocalizations.of(context)
                                  .translate('reward_user') +
                              ': ${reward['userId'] is Map ? reward['userId']['name'] : reward['userId']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              tooltip: AppLocalizations.of(context)
                                  .translate('approve_reward'),
                              onPressed: () => _approveReward(reward['_id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              tooltip: AppLocalizations.of(context)
                                  .translate('reject_reward'),
                              onPressed: () => _rejectReward(reward['_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
