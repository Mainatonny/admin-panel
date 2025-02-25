// lib/models/report.dart
class Report {
  final String id;
  final String reporterId;
  final String reportType;
  //final String description;
  final String evidence;
  final String status;
  final int reward;

  Report({
    required this.id,
    required this.reporterId,
    required this.reportType,
    //required this.description,
    required this.evidence,
    required this.status,
    required this.reward,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'] ?? '',
      reporterId: json['reporter'] ?? '',
      reportType: json['reportType'] ?? '',
      //description: json['description'] ?? '',
      evidence: json['evidence'] ?? '',
      status: json['status'] ?? 'pending',
      reward: json['reward'] ?? 0,
    );
  }
}
