import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../l10n/app_localizations.dart'; // Import localization

class NoticePolicyManagementPage extends StatefulWidget {
  const NoticePolicyManagementPage({super.key});

  @override
  _NoticePolicyManagementPageState createState() =>
      _NoticePolicyManagementPageState();
}

class _NoticePolicyManagementPageState extends State<NoticePolicyManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Notices data
  List<dynamic> _notices = [];
  bool _isLoadingNotices = true;
  final TextEditingController _noticeTitleController = TextEditingController();
  final TextEditingController _noticeContentController =
      TextEditingController();

  // Policies data
  String _termsOfUse = '';
  String _privacyPolicy = '';
  bool _isLoadingPolicies = true;
  final TextEditingController _termsController = TextEditingController();
  final TextEditingController _privacyController = TextEditingController();

  // App Updates
  List<dynamic> _appUpdates = [];
  bool _isLoadingUpdates = true;
  final TextEditingController _updateTitleController = TextEditingController();
  final TextEditingController _updateDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchNotices();
    _fetchPolicies();
    _fetchAppUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noticeTitleController.dispose();
    _noticeContentController.dispose();
    _termsController.dispose();
    _privacyController.dispose();
    _updateTitleController.dispose();
    _updateDescriptionController.dispose();
    super.dispose();
  }

  // ---------------------------
  // Notice Management
  // ---------------------------
  Future<void> _fetchNotices() async {
    try {
      final data = await ApiService.get('notices');
      setState(() {
        _notices = data as List;
        _isLoadingNotices = false;
      });
    } catch (error) {
      print('Error fetching notices: $error');
      setState(() {
        _isLoadingNotices = false;
      });
    }
  }

  Future<void> _createNotice() async {
    final title = _noticeTitleController.text.trim();
    final content = _noticeContentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('provide_title_content'))));
      return;
    }

    try {
      final response = await ApiService.post('notices', {
        'title': title,
        'content': content,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ??
              AppLocalizations.of(context).translate('notice_created'))));
      _noticeTitleController.clear();
      _noticeContentController.clear();
      _fetchNotices();
    } catch (error) {
      print('Error creating notice: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('failed_create_notice'))));
    }
  }

  // ---------------------------
  // Policy Management
  // ---------------------------
  Future<void> _fetchPolicies() async {
    try {
      final data = await ApiService.get('policies');
      setState(() {
        _termsOfUse = data['termsOfUse'] ?? '';
        _privacyPolicy = data['privacyPolicy'] ?? '';
        _termsController.text = _termsOfUse;
        _privacyController.text = _privacyPolicy;
        _isLoadingPolicies = false;
      });
    } catch (error) {
      print('Error fetching policies: $error');
      setState(() {
        _isLoadingPolicies = false;
      });
    }
  }

  Future<void> _updatePolicies() async {
    try {
      final response = await ApiService.put('policies', {
        'termsOfUse': _termsController.text.trim(),
        'privacyPolicy': _privacyController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ??
              AppLocalizations.of(context).translate('policies_updated'))));
      _fetchPolicies();
    } catch (error) {
      print('Error updating policies: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('failed_update_policies'))));
    }
  }

  // ---------------------------
  // App Updates Management
  // ---------------------------
  Future<void> _fetchAppUpdates() async {
    try {
      final data = await ApiService.get('updates');
      setState(() {
        _appUpdates = data as List;
        _isLoadingUpdates = false;
      });
    } catch (error) {
      print('Error fetching app updates: $error');
      setState(() {
        _isLoadingUpdates = false;
      });
    }
  }

  Future<void> _createAppUpdate() async {
    final title = _updateTitleController.text.trim();
    final description = _updateDescriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('provide_update_title_description'))));
      return;
    }

    try {
      final response = await ApiService.post('updates', {
        'title': title,
        'description': description,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ??
              AppLocalizations.of(context).translate('app_update_created'))));
      _updateTitleController.clear();
      _updateDescriptionController.clear();
      _fetchAppUpdates();
    } catch (error) {
      print('Error creating app update: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('failed_create_update'))));
    }
  }

  // ---------------------------
  // UI Tabs
  // ---------------------------
  Widget _buildNoticesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).translate('create_notice'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _noticeTitleController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('title'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noticeContentController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('content'),
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _createNotice,
            child: Text(AppLocalizations.of(context).translate('send_notice')),
          ),
          const Divider(height: 32),
          Text(
            AppLocalizations.of(context).translate('existing_notices'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _isLoadingNotices
              ? const Center(child: CircularProgressIndicator())
              : _notices.isEmpty
                  ? Text(AppLocalizations.of(context)
                      .translate('no_notices_available'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _notices.length,
                      itemBuilder: (context, index) {
                        final notice = _notices[index];
                        return ListTile(
                          title: Text(notice['title'] ?? ''),
                          subtitle: Text(notice['content'] ?? ''),
                          trailing: Text(notice['createdAt'] != null
                              ? DateTime.parse(notice['createdAt'])
                                  .toLocal()
                                  .toString()
                                  .split('.')[0]
                              : ''),
                        );
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildPoliciesTab() {
    if (_isLoadingPolicies) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).translate('manage_terms_policies'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _termsController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('terms_of_use'),
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _privacyController,
            decoration: InputDecoration(
              labelText:
                  AppLocalizations.of(context).translate('privacy_policy'),
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _updatePolicies,
            child:
                Text(AppLocalizations.of(context).translate('update_policies')),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            AppLocalizations.of(context).translate('manage_app_updates'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _updateTitleController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('update_title'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _updateDescriptionController,
            decoration: InputDecoration(
              labelText:
                  AppLocalizations.of(context).translate('update_description'),
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _createAppUpdate,
            child: Text(
                AppLocalizations.of(context).translate('create_app_update')),
          ),
          const Divider(height: 32),
          Text(
            AppLocalizations.of(context).translate('past_app_updates'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _isLoadingUpdates
              ? const Center(child: CircularProgressIndicator())
              : _appUpdates.isEmpty
                  ? Text(AppLocalizations.of(context)
                      .translate('no_app_updates_available'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _appUpdates.length,
                      itemBuilder: (context, index) {
                        final update = _appUpdates[index];
                        return ListTile(
                          title: Text(update['title'] ?? ''),
                          subtitle: Text(update['description'] ?? ''),
                          trailing: Text(update['releaseDate'] != null
                              ? DateTime.parse(update['releaseDate'])
                                  .toLocal()
                                  .toString()
                                  .split('.')[0]
                              : ''),
                        );
                      },
                    ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context).translate('notice_policy_management')),
      ),
      drawer: Sidebar(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: AppLocalizations.of(context).translate('notices')),
              Tab(text: AppLocalizations.of(context).translate('policies')),
              Tab(text: AppLocalizations.of(context).translate('app_updates')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNoticesTab(),
                _buildPoliciesTab(),
                _buildUpdatesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
