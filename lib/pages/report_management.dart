import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart'; // Import localization

class ReportManagementPage extends StatefulWidget {
  const ReportManagementPage({super.key});

  @override
  _ReportManagementPageState createState() => _ReportManagementPageState();
}

class _ReportManagementPageState extends State<ReportManagementPage> {
  List<Report> _reports = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Report> _filteredReports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch all reports from the backend
  Future<void> _fetchReports() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final data = await ApiService.get(
        'reports',
        headers: {
          'Authorization': 'Bearer ${auth.token}',
        },
      );
      setState(() {
        _reports = (data as List).map((json) => Report.fromJson(json)).toList();
        _filteredReports = _reports;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching reports: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filter reports by reporter ID or report type
  void _filterReports() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReports = _reports.where((report) {
        return report.reporterId.toLowerCase().contains(query) ||
            report.reportType.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Navigate to detailed view of a report
  void _showReportDetails(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailsPage(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).translate('report_management')),
      ),
      drawer: Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)
                    .translate('search_placeholder'),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            // Reports List
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('report_id'))),
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('reporter'))),
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('type'))),
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('status'))),
                          DataColumn(
                              label: Text(AppLocalizations.of(context)
                                  .translate('actions'))),
                        ],
                        rows: _filteredReports.map((report) {
                          return DataRow(cells: [
                            DataCell(Text(report.id)),
                            DataCell(Text(report.reporterId)),
                            DataCell(Text(report.reportType)),
                            DataCell(Text(report.status)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                tooltip: AppLocalizations.of(context)
                                    .translate('view_details'),
                                onPressed: () => _showReportDetails(report),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Detailed view to manage and update a specific report.
class ReportDetailsPage extends StatefulWidget {
  final Report report;
  const ReportDetailsPage({super.key, required this.report});

  @override
  _ReportDetailsPageState createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  late Report _report;
  bool _isUpdating = false;
  String _status = 'pending';
  bool _compensationPaid = false;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
    _status = _report.status;
  }

  // Update the report status and compensation decision
  Future<void> _updateReport() async {
    setState(() {
      _isUpdating = true;
    });

    final updatedData = {
      'status': _status,
      'compensationPaid': _compensationPaid,
    };

    try {
      await ApiService.put('reports/${_report.id}', updatedData);
      setState(() {
        _report = Report(
          id: _report.id,
          reporterId: _report.reporterId,
          reportType: _report.reportType,
          evidence: _report.evidence,
          status: _status,
          reward: _report.reward,
        );
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('report_updated_successfully')),
        ),
      );
    } catch (error) {
      setState(() {
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('error_updating_report')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)
            .translate('report_details')
            .replaceAll('{id}', _report.id)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              AppLocalizations.of(context)
                  .translate('report_id')
                  .replaceAll('{id}', _report.id),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)
                  .translate('reporter')
                  .replaceAll('{reporter}', _report.reporterId),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)
                  .translate('report_type')
                  .replaceAll('{type}', _report.reportType),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Evidence:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _report.evidence.isNotEmpty
                ? (_report.evidence.endsWith('.mp4') ||
                        _report.evidence.endsWith('.mov')
                    ? const Icon(Icons.videocam, size: 100)
                    : Image.network(
                        'https://safealert.onrender.com/${_report.evidence}',
                        height: 200,
                      ))
                : Text(AppLocalizations.of(context)
                    .translate('no_evidence_provided')),
            const SizedBox(height: 16),
            const Text(
              'Update Status:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _status,
              items: <String>['pending', 'processing', 'complete', 'rejected']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (newStatus) {
                setState(() {
                  _status = newStatus!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).translate('compensation_paid'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _compensationPaid,
                  onChanged: (val) {
                    setState(() {
                      _compensationPaid = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isUpdating
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateReport,
                    child: Text(AppLocalizations.of(context)
                        .translate('update_report')),
                  ),
            const SizedBox(height: 16),
            const Text(
              'Report Statistics:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // Additional statistics widgets can be added here.
          ],
        ),
      ),
    );
  }
}
