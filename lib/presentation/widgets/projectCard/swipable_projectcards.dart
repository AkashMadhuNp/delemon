import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/presentation/widgets/projectCard/components/dialogs/archive_confirmation_dialog.dart';
import 'package:delemon/presentation/widgets/projectCard/components/project_card_actions.dart';
import 'package:delemon/presentation/widgets/projectCard/components/project_card_content.dart';
import 'package:flutter/material.dart';

class SwipeableProjectCard extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final VoidCallback? onTap;

  const SwipeableProjectCard({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
    this.onTap,
  });

  @override
  State<SwipeableProjectCard> createState() => _SwipeableProjectCardState();
}

class _SwipeableProjectCardState extends State<SwipeableProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isRevealed = false;
  static const double _actionWidth = 140.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-_actionWidth / 300, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleReveal() {
    setState(() => _isRevealed = !_isRevealed);
    _isRevealed ? _controller.forward() : _controller.reverse();
  }

  Future<void> _handleAction(VoidCallback action) async {
    await _controller.reverse();
    setState(() => _isRevealed = false);
    action();
  }

  Future<void> _showArchiveDialog() async {
    final result = await ArchiveConfirmationDialog.show(
      context: context,
      project: widget.project,
    );
    
    if (result == true) {
      widget.onArchive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isRevealed ? _toggleReveal : widget.onTap,
      onHorizontalDragEnd: _handleDragEnd,
      onHorizontalDragUpdate: _handleDragUpdate,
      child: Container(
        decoration: _cardDecoration(context),
        child: Stack(
          children: [
            ProjectCardActions(
              fadeAnimation: _fadeAnimation,
              onEdit: () => _handleAction(widget.onEdit),
              onDelete: () => _handleAction(widget.onDelete),
            ),
            SlideTransition(
              position: _slideAnimation,
              child: ProjectCardContent(
                project: widget.project,
                onTap: _isRevealed ? _toggleReveal : widget.onTap,
                onArchive: _showArchiveDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! < -500 && !_isRevealed) {
      _toggleReveal();
    } else if (details.primaryVelocity! > 500 && _isRevealed) {
      _toggleReveal();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx < -5 && !_isRevealed) {
      _toggleReveal();
    } else if (details.delta.dx > 5 && _isRevealed) {
      _toggleReveal();
    }
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
