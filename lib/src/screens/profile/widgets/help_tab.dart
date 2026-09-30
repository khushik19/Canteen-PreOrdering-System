import 'package:flutter/material.dart';

class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  static const _faqs = [
    (
      'How do I cancel an order?',
      'Go to Orders tab, tap the live order, and select Cancel. Orders can only be cancelled before the vendor marks them as "Preparing".',
    ),
    (
      'What happens if I miss my pickup time?',
      'If your order isn\'t picked up and the vendor can\'t reach you within their set time window, it may be sold to another student at a discount through Flash Sale.',
    ),
    (
      'How does the cooking-time based pickup slot work?',
      'Each item has a minimum cooking time set by the vendor. You can only select a pickup time that\'s at least that long from when you place the order.',
    ),
    (
      'How do I get a refund?',
      'Refunds for cancelled or rejected orders are processed automatically to your original payment method within 3-5 business days.',
    ),
    (
      'I have another issue.',
      'Reach out to your campus canteen directly, or contact support at support@canteencrave.app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _faqs.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final (question, answer) = _faqs[index];
        return ExpansionTile(
          title: Text(question,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          childrenPadding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
          children: [
            Text(answer, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ],
        );
      },
    );
  }
}