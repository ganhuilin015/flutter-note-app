import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AppSlidable extends StatelessWidget {
  final Widget child;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final IconData bookmarkIcon;

  const AppSlidable({
    super.key,
    required this.child,
    required this.onBookmark,
    required this.onShare,
    required this.onDelete,
    required this.bookmarkIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Slidable(
      key: key,

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) => onBookmark(),
            backgroundColor: Colors.yellow,
            foregroundColor: colors.onPrimary,
            icon: bookmarkIcon,
          ),

          SlidableAction(
            onPressed: (_) => onShare(),
            backgroundColor: Colors.orange,
            foregroundColor: colors.onPrimary,
            icon: Icons.share,
          ),

          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: colors.onPrimary,
            icon: Icons.delete,
          ),
        ],
      ),

      child: child,
    );
  }
}