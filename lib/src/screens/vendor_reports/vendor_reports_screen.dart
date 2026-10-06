import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../repositories/report_repository.dart';
import 'widgets/metric_kpi_card.dart';
import 'widgets/top_selling_items_list.dart';

class VendorReportsScreen extends StatefulWidget {
  final String vendorId;

  const VendorReportsScreen({super.key, required this.vendorId});

  @override
  State<VendorReportsScreen> createState() => _VendorReportsScreenState();
}

class _VendorReportsScreenState extends State<VendorReportsScreen> {
  final _reportRepository = ReportRepository();
  DateTime _selectedDate = DateTime.now();
  VendorReportModel? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      final rep = await _reportRepository.getDailyReport(
        vendorId: widget.vendorId,
        date: _selectedDate,
      );
      if (mounted) setState(() => _report = rep);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B00),
              onPrimary: Colors.white,
              surface: Color(0xFF1E222A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(_selectedDate);
    final totalRev = _report?.totalRevenue ?? 0.0;
    final onlineAmount = _report?.onlinePaymentsAmount ?? 0.0;
    final cashAmount = _report?.cashPaymentsAmount ?? 0.0;
    final totalPayments = (onlineAmount + cashAmount) > 0 ? (onlineAmount + cashAmount) : 1.0;
    final onlinePercent = (onlineAmount / totalPayments * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E222A),
        elevation: 0,
        title: const Text(
          'Analytics & Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month, color: Color(0xFFFF6B00), size: 18),
            label: Text(
              formattedDate,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : RefreshIndicator(
              onRefresh: _fetchReport,
              color: const Color(0xFFFF6B00),
              backgroundColor: const Color(0xFF1E222A),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 4 Core KPI Cards Grid
                    Row(
                      children: [
                        Expanded(
                          child: MetricKpiCard(
                            title: 'Total Revenue',
                            value: '₹${totalRev.toStringAsFixed(0)}',
                            subtitle: 'Gross sales turnover',
                            icon: Icons.currency_rupee,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricKpiCard(
                            title: 'Completed Orders',
                            value: '${_report?.completedOrdersCount ?? 0}',
                            subtitle: 'Handed to students',
                            icon: Icons.done_all,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MetricKpiCard(
                            title: 'Avg Kitchen Time',
                            value: '${_report?.averagePrepTimeMinutes.toStringAsFixed(0) ?? "12"}m',
                            subtitle: 'Prep velocity target: <15m',
                            icon: Icons.timer_outlined,
                            color: const Color(0xFFFFB300),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricKpiCard(
                            title: 'Digital Payments',
                            value: '₹${onlineAmount.toStringAsFixed(0)}',
                            subtitle: 'Razorpay UPI & Cards',
                            icon: Icons.payment,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Payment Breakdown (Razorpay vs Cash Counter)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E222A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2C3240)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Methods Breakdown',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Icon(Icons.pie_chart_outline, color: Color(0xFFFF6B00), size: 18),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: onlinePercent > 0 ? onlinePercent : 50,
                                  child: Container(height: 12, color: const Color(0xFF8B5CF6)),
                                ),
                                Expanded(
                                  flex: (100 - onlinePercent) > 0 ? (100 - onlinePercent) : 50,
                                  child: Container(height: 12, color: const Color(0xFF10B981)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(radius: 4, backgroundColor: const Color(0xFF8B5CF6)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Razorpay Online: ₹${onlineAmount.toStringAsFixed(0)} ($onlinePercent%)',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  CircleAvatar(radius: 4, backgroundColor: const Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Cash: ₹${cashAmount.toStringAsFixed(0)} (${100 - onlinePercent}%)',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Top Sellers List
                    TopSellingItemsList(items: _report?.topSellingItems ?? []),
                    const SizedBox(height: 18),

                    // Campus Rush Periods Insight Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E222A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2C3240)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: Color(0xFFFFB300), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Peak Campus Rush Hours',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _RushHourRow(period: 'Breakfast Rush (8:30 - 10:30 AM)', loadText: 'High Demand', color: Color(0xFFFF9800)),
                          Divider(color: Color(0xFF2C3240), height: 16),
                          _RushHourRow(period: 'Lunch Rush (12:30 - 2:30 PM)', loadText: 'Peak Traffic ⚡', color: Color(0xFFEF4444)),
                          Divider(color: Color(0xFF2C3240), height: 16),
                          _RushHourRow(period: 'Evening Snacks (4:30 - 6:30 PM)', loadText: 'Moderate', color: Color(0xFF3B82F6)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RushHourRow extends StatelessWidget {
  final String period;
  final String loadText;
  final Color color;

  const _RushHourRow({required this.period, required this.loadText, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(period, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            loadText,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
