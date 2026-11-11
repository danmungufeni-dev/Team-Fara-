import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/notification_item.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';
import '../../shared/widgets/dignity_chip.dart';

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  final MockBackendStore _store = MockBackendStore();
  NotificationCategory _selectedCat = NotificationCategory.all;

  void _markAllRead() {
    setState(() {
      _store.notifications =
          _store.notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var list = _store.notifications;
    if (_selectedCat != NotificationCategory.all) {
      list = list.where((n) => n.category == _selectedCat).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications & Alerts', style: AppTypography.headlineSM()),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark All Read',
            onPressed: _markAllRead,
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              // Category filter pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      DignityChip(
                        label: 'All (${_store.notifications.length})',
                        isSelected: _selectedCat == NotificationCategory.all,
                        onTap: () =>
                            setState(() => _selectedCat = NotificationCategory.all),
                      ),
                      const SizedBox(width: 8),
                      DignityChip(
                        label: 'Reservations & Codes',
                        leading: const Icon(Icons.qr_code_2, size: 16),
                        isSelected:
                            _selectedCat == NotificationCategory.reservations,
                        onTap: () => setState(() =>
                            _selectedCat = NotificationCategory.reservations),
                      ),
                      const SizedBox(width: 8),
                      DignityChip(
                        label: 'Stock Restocks',
                        leading: const Icon(Icons.inventory, size: 16),
                        isSelected: _selectedCat == NotificationCategory.stock,
                        onTap: () => setState(
                            () => _selectedCat = NotificationCategory.stock),
                      ),
                      const SizedBox(width: 8),
                      DignityChip(
                        label: 'Community & Safety',
                        leading: const Icon(Icons.verified_user, size: 16),
                        isSelected:
                            _selectedCat == NotificationCategory.community,
                        onTap: () => setState(
                            () => _selectedCat = NotificationCategory.community),
                      ),
                    ],
                  ),
                ),
              ),

              // Notifications list
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_off_outlined,
                                size: 56, color: AppColors.neutralMuted),
                            const SizedBox(height: 12),
                            Text('No notifications found',
                                style: AppTypography.labelLG()),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return DignityCard(
                            backgroundColor: item.isRead
                                ? AppColors.surfaceContainerLowest
                                : AppColors.surfaceContainerLow,
                            border: Border.all(
                              color: item.isRead
                                  ? AppColors.borderSubtle
                                  : AppColors.primaryFixedDim,
                              width: item.isRead ? 1.0 : 1.5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildCategoryIcon(item.category),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.title,
                                              style: AppTypography.labelMD(
                                                  color: AppColors.neutralDark)),
                                          Text(
                                            AppFormatters.timeAgo(
                                                item.timestamp),
                                            style: AppTypography.labelSM(
                                                color: AppColors.neutralMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (item.timeLeft != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorContainer,
                                          borderRadius: AppRadius.fullBorder,
                                        ),
                                        child: Text(
                                          item.timeLeft!,
                                          style: AppTypography.labelSM(
                                              color: AppColors.error),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(item.body, style: AppTypography.bodyMD()),
                                if (item.voucherCode != null) ...[
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DignityButton(
                                          text:
                                              'View Code (${item.voucherCode})',
                                          height: 38,
                                          icon: const Icon(Icons.lock_open,
                                              size: 16, color: Colors.white),
                                          onPressed: () =>
                                              context.push('/requests'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      DignityButton(
                                        text: 'Directions',
                                        height: 38,
                                        style: DignityButtonStyle.secondary,
                                        icon: const Icon(Icons.directions,
                                            size: 16,
                                            color: AppColors.primaryContainer),
                                        onPressed: () => context.push('/map'),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(NotificationCategory cat) {
    IconData icon;
    Color color;
    switch (cat) {
      case NotificationCategory.reservations:
        icon = Icons.qr_code_2;
        color = AppColors.primaryContainer;
        break;
      case NotificationCategory.stock:
        icon = Icons.inventory;
        color = AppColors.success;
        break;
      case NotificationCategory.community:
      default:
        icon = Icons.verified_user;
        color = AppColors.coralPink;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
