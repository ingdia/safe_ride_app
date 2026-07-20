import 'package:flutter/material.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final Map<String, bool> _prefs = {
    'Bus Approaching': true,
    'Student Check-in': true,
    'Route Delays': true,
    'Route Changes': true,
    'Emergency Alerts': true,
    'Daily Summary': false,
    'Weekly Report': false,
  };

  final Map<String, String> _subtitles = const {
    'Bus Approaching': 'Get notified when bus is 5 minutes away',
    'Student Check-in': 'Alert when student boards/exits bus',
    'Route Delays': 'Notifications about schedule changes',
    'Route Changes': 'Updates about route modifications',
    'Emergency Alerts': 'Critical safety notifications',
    'Daily Summary': 'Daily recap of bus activities',
    'Weekly Report': 'Weekly performance summary',
  };

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: HeaderTitleBlock(
                  title: 'Notifications',
                  subtitle: 'Manage your alert preferences',
                  backLabel: 'Back to Profile',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (final key in _prefs.keys) ...[
                    _ToggleTile(
                      title: key,
                      subtitle: _subtitles[key]!,
                      value: _prefs[key]!,
                      onChanged: (v) => setState(() => _prefs[key] = v),
                    ),
                    const SizedBox(height: AdminUiSpacing.sm),
                  ],
                  const SizedBox(height: AdminUiSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminUiColors.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AdminUiRadii.button,
                          ),
                        ),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: AdminUiSpacing.lg),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AdminUiColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AdminUiSpacing.sm),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AdminUiColors.primaryOrange,
          ),
        ],
      ),
    );
  }
}
