import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AppSlidableAction {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const AppSlidableAction({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

class AppSlidable extends StatelessWidget {
  final Widget child;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final IconData bookmarkIcon;

  final List<AppSlidableAction> additionalActions;

  const AppSlidable({
    super.key,
    required this.child,
    required this.onBookmark,
    required this.onShare,
    required this.onDelete,
    required this.bookmarkIcon,
    this.additionalActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Slidable(
      key: key,

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: (3 + additionalActions.length) * 0.15,
        children: [
          ...additionalActions.map(
            (action) => SlidableAction(
              onPressed: (_) => action.onPressed(),
              backgroundColor: action.backgroundColor,
              foregroundColor: action.foregroundColor,
              icon: action.icon,
            ),
          ),

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