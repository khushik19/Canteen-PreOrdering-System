import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

// ---------------------------------------------------------------------------
// CenteredContent — Restricts child to a max width of 1200px and centers it.
//
// Prevents lines of text from stretching unnaturally across wide desktop
// monitors (RULES.md Section 5.2).
// ---------------------------------------------------------------------------

class CenteredContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredContent({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
