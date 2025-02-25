import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../l10n/app_localizations.dart'; // Import localization
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart'; // Import LocaleProvider for language settings

class SystemManagementPage extends StatefulWidget {
  const SystemManagementPage({super.key});

  @override
  _SystemManagementPageState createState() => _SystemManagementPageState();
}

class _SystemManagementPageState extends State<SystemManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Log Management
  List<dynamic> _logs = [];
  bool _isLoadingLogs = true;

  // Security Management
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isUpdatingPassword = false;

  // Server Monitoring
  Map<String, dynamic> _serverStatus = {};
  bool _isLoadingStatus = true;

  // Backup and Restore
  bool _isProcessingBackup = false;
  bool _isProcessingRestore = false;
  String _backupMessage = '';
  String _restoreMessage = '';

  @override
  void initState() {
    super.initState();
    // Now we have 5 tabs: Logs, Security, Monitoring, Backup/Restore, and Settings
    _tabController = TabController(length: 5, vsync: this);
    _fetchLogs();
    _fetchServerStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // ---------------------------
  // Log Management
  // ---------------------------
  Future<void> _fetchLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'system/logs',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _logs = data as List;
        _isLoadingLogs = false;
      });
    } catch (error) {
      print('Error fetching logs: $error');
      setState(() {
        _isLoadingLogs = false;
      });
    }
  }

  // ---------------------------
  // Security Management
  // ---------------------------
  Future<void> _updatePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('fill_password_fields')),
        ),
      );
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await ApiService.put(
        'system/security/changePassword',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ??
              AppLocalizations.of(context)
                  .translate('password_updated_successfully')),
        ),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } catch (error) {
      print('Password update error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('password_update_failed')),
        ),
      );
    } finally {
      setState(() {
        _isUpdatingPassword = false;
      });
    }
  }

  // ---------------------------
  // Server Monitoring
  // ---------------------------
  Future<void> _fetchServerStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.get(
        'system/server/status',
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _serverStatus = data;
        _isLoadingStatus = false;
      });
    } catch (error) {
      print('Error fetching server status: $error');
      setState(() {
        _isLoadingStatus = false;
      });
    }
  }

  // ---------------------------
  // Backup and Restore Functions
  // ---------------------------
  Future<void> _triggerBackup() async {
    setState(() {
      _isProcessingBackup = true;
      _backupMessage = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.post(
        'system/backup',
        {},
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _backupMessage = data['message'] ??
            AppLocalizations.of(context)
                .translate('backup_completed_successfully');
      });
    } catch (error) {
      print('Backup error: $error');
      setState(() {
        _backupMessage =
            AppLocalizations.of(context).translate('backup_failed');
      });
    } finally {
      setState(() {
        _isProcessingBackup = false;
      });
    }
  }

  Future<void> _triggerRestore() async {
    setState(() {
      _isProcessingRestore = true;
      _restoreMessage = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ApiService.post(
        'system/restore',
        {},
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _restoreMessage = data['message'] ??
            AppLocalizations.of(context)
                .translate('restore_completed_successfully');
      });
    } catch (error) {
      print('Restore error: $error');
      setState(() {
        _restoreMessage =
            AppLocalizations.of(context).translate('restore_failed');
      });
    } finally {
      setState(() {
        _isProcessingRestore = false;
      });
    }
  }

  // ---------------------------
  // Settings Tab: Language Selection
  // ---------------------------
  Widget _buildSettingsTab() {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('choose_language'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          RadioListTile<Locale>(
            title: const Text('English'),
            value: const Locale('en', 'US'),
            groupValue: localeProvider.locale,
            onChanged: (Locale? locale) {
              if (locale != null) {
                localeProvider.setLocale(locale);
              }
            },
          ),
          RadioListTile<Locale>(
            title: const Text('한국어'),
            value: const Locale('ko', 'KR'),
            groupValue: localeProvider.locale,
            onChanged: (Locale? locale) {
              if (locale != null) {
                localeProvider.setLocale(locale);
              }
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Build UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).translate('system_management')),
      ),
      drawer: Sidebar(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: AppLocalizations.of(context).translate('logs')),
              Tab(text: AppLocalizations.of(context).translate('security')),
              Tab(text: AppLocalizations.of(context).translate('monitoring')),
              Tab(
                  text:
                      AppLocalizations.of(context).translate('backup_restore')),
              Tab(text: AppLocalizations.of(context).translate('settings')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Log Management
                _isLoadingLogs
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _fetchLogs,
                        child: ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return ListTile(
                              title: Text(log['message'] ??
                                  AppLocalizations.of(context)
                                      .translate('no_message')),
                              subtitle:
                                  Text(log['timestamp']?.toString() ?? ''),
                            );
                          },
                        ),
                      ),
                // Tab 2: Security Management
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .translate('change_password'),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _currentPasswordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate('current_password'),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate('new_password'),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      _isUpdatingPassword
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _updatePassword,
                              child: Text(AppLocalizations.of(context)
                                  .translate('update_password')),
                            ),
                      const SizedBox(height: 32),
                      Text(
                        AppLocalizations.of(context)
                            .translate('two_factor_auth'),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)
                          .translate('two_factor_auth_info')),
                    ],
                  ),
                ),
                // Tab 3: Server Monitoring
                _isLoadingStatus
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .translate('server_status'),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(AppLocalizations.of(context)
                                .translate('uptime')
                                .replaceAll(
                                    '{uptime}',
                                    _serverStatus['uptime']?.toString() ??
                                        'N/A')),
                            const SizedBox(height: 8),
                            Text(AppLocalizations.of(context)
                                .translate('cpu_usage')
                                .replaceAll(
                                    '{usage}',
                                    _serverStatus['cpuUsage']?.toString() ??
                                        'N/A')),
                            const SizedBox(height: 8),
                            Text(AppLocalizations.of(context)
                                .translate('memory_usage')
                                .replaceAll(
                                    '{usage}',
                                    _serverStatus['memoryUsage']?.toString() ??
                                        'N/A')),
                            const SizedBox(height: 8),
                            Text(AppLocalizations.of(context)
                                .translate('active_connections')
                                .replaceAll(
                                    '{count}',
                                    _serverStatus['activeConnections']
                                            ?.toString() ??
                                        'N/A')),
                          ],
                        ),
                      ),
                // Tab 4: Backup and Restore Function
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .translate('backup_restore'),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _isProcessingBackup
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _triggerBackup,
                              child: Text(AppLocalizations.of(context)
                                  .translate('run_backup')),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        _backupMessage,
                        style: const TextStyle(color: Colors.green),
                      ),
                      const Divider(height: 32),
                      _isProcessingRestore
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _triggerRestore,
                              child: Text(AppLocalizations.of(context)
                                  .translate('run_restore')),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        _restoreMessage,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
                // Tab 5: Settings (Language Selection)
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
