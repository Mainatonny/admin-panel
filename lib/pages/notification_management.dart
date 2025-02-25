import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../l10n/app_localizations.dart'; // Import localization

class NotificationManagementPage extends StatefulWidget {
  const NotificationManagementPage({super.key});

  @override
  _NotificationManagementPageState createState() =>
      _NotificationManagementPageState();
}

class _NotificationManagementPageState extends State<NotificationManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for sending notifications
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Templates (managed locally in this example)
  final List<String> _templates = [
    "Your order has been shipped!",
    "Your appointment is confirmed.",
    "Don't miss our latest update!"
  ];
  final TextEditingController _newTemplateController = TextEditingController();

  // Statistics (dummy data, or fetched from an endpoint)
  Map<String, dynamic> _stats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userIdController.dispose();
    _typeController.dispose();
    _messageController.dispose();
    _newTemplateController.dispose();
    super.dispose();
  }

  // Sends a push notification using the backend API.
  Future<void> _sendNotification() async {
    final userId = _userIdController.text.trim();
    final notificationType = _typeController.text.trim();
    final message = _messageController.text.trim();

    if (userId.isEmpty || notificationType.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)
            .translate('fill_all_notification_fields')),
      ));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await ApiService.post(
        'notifications/create',
        {
          'userId': userId,
          'notificationType': notificationType,
          'message': message,
        },
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message'] ??
                AppLocalizations.of(context).translate('notification_sent'))),
      );
      _userIdController.clear();
      _typeController.clear();
      _messageController.clear();
    } catch (error) {
      print('Error sending notification: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('notification_send_failed'))),
      );
    }
  }

  // Fetch notification statistics from the backend.
  Future<void> _fetchStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'notifications/statistics',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _stats = data;
        _isLoadingStats = false;
      });
    } catch (error) {
      print('Error fetching statistics: $error');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  // Add a new notification template.
  void _addTemplate() {
    final newTemplate = _newTemplateController.text.trim();
    if (newTemplate.isNotEmpty) {
      setState(() {
        _templates.add(newTemplate);
        _newTemplateController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).translate('template_added'))),
      );
    }
  }

  // Remove a template.
  void _removeTemplate(int index) {
    setState(() {
      _templates.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('template_removed'))),
    );
  }

  // ---------------------
  // Build UI
  // ---------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)
            .translate('manage_in_app_notifications')),
      ),
      drawer: Sidebar(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  text: AppLocalizations.of(context)
                      .translate('send_notification')),
              Tab(text: AppLocalizations.of(context).translate('templates')),
              Tab(text: AppLocalizations.of(context).translate('statistics')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Send Notification
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      TextField(
                        controller: _userIdController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context).translate('user_id'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _typeController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate('notification_type'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context).translate('message'),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _sendNotification,
                        child: Text(AppLocalizations.of(context)
                            .translate('send_notification')),
                      ),
                    ],
                  ),
                ),
                // Tab 2: Manage Notification Templates
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .translate('notification_templates'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // List of existing templates
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _templates.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_templates[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeTemplate(index),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      TextField(
                        controller: _newTemplateController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate('new_template'),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addTemplate,
                        child: Text(AppLocalizations.of(context)
                            .translate('add_template')),
                      ),
                    ],
                  ),
                ),
                // Tab 3: Notification Delivery Statistics
                _isLoadingStats
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .translate('notification_statistics'),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('total_notifications_sent')
                                  .replaceAll('{total}',
                                      _stats['totalSent']?.toString() ?? '0'),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('total_notifications_read')
                                  .replaceAll('{total}',
                                      _stats['totalRead']?.toString() ?? '0'),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('click_through_rate')
                                  .replaceAll('{rate}',
                                      _stats['clickRate']?.toString() ?? '0'),
                              style: const TextStyle(fontSize: 16),
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
