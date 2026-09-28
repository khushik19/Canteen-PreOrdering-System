import '../datasources/report_remote_datasource.dart';
import '../models/report_model.dart';

class ReportRepository {
  final ReportRemoteDatasource _remoteDatasource;

  ReportRepository({ReportRemoteDatasource? remoteDatasource})
      : _remoteDatasource = remoteDatasource ?? ReportRemoteDatasource();

  Future<VendorReportModel> getDailyReport({
    required String vendorId,
    required DateTime date,
  }) =>
      _remoteDatasource.getDailyReport(vendorId: vendorId, date: date);
}
