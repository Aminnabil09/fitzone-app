import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/support_service.dart';
import '../../models/support_report.dart';
import '../../widgets/animated_background.dart';

class AdminManageReportsScreen extends StatefulWidget {
  const AdminManageReportsScreen({super.key});

  @override
  State<AdminManageReportsScreen> createState() => _AdminManageReportsScreenState();
}

class _AdminManageReportsScreenState extends State<AdminManageReportsScreen> {
  String _filter = 'pending'; // 'all', 'pending', 'replied'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildFilterTabs(),
            _buildReportsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'MANAGE REPORTS',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w200,
          letterSpacing: 4,
          fontSize: 14,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Row(
          children: [
            _filterChip('PENDING', 'pending'),
            const SizedBox(width: 12),
            _filterChip('REPLIED', 'replied'),
            const SizedBox(width: 12),
            _filterChip('ALL', 'all'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    bool isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor.withValues(alpha: 0.02),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.textColor.withValues(alpha: 0.1), width: 0.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : AppTheme.textColor.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return StreamBuilder<List<SupportReport>>(
      stream: SupportService().streamAllReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        }

        final allReports = snapshot.data ?? [];
        final reports = allReports.where((r) {
          if (_filter == 'all') return true;
          return r.status == _filter;
        }).toList();

        if (reports.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.mark_email_read_outlined, size: 48, color: AppTheme.textColor.withValues(alpha: 0.1)),
                    const SizedBox(height: 16),
                    Text(
                      'NO REPORTS FOUND',
                      style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.2), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildAdminReportTile(reports[index]),
              childCount: reports.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminReportTile(SupportReport report) {
    bool isPending = report.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.02),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: ExpansionTile(
        title: Text(
          report.subject.toUpperCase(),
          style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(
              'BY: ${report.userName} (ID: ${report.userNumericId})',
              style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.5), fontSize: 9),
            ),
            const Spacer(),
            Text(
              report.type.toUpperCase(),
              style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontSize: 9),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CUSTOMER MESSAGE:',
                style: GoogleFonts.outfit(fontSize: 9, color: AppTheme.textColor.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 8),
              Text(
                report.message,
                style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              if (isPending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showReplyDialog(report),
                    child: Text('ANSWER REPORT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    border: const Border(left: BorderSide(color: AppTheme.primaryColor, width: 2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR REPLY:',
                        style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.adminReply ?? '',
                        style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(SupportReport report) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'REPLY TO ${report.userName.toUpperCase()}',
          style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 14, letterSpacing: 2),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            hintStyle: GoogleFonts.inter(color: AppTheme.textColor.withValues(alpha: 0.2)),
            filled: true,
            fillColor: AppTheme.textColor.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.textColor.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await SupportService().replyToReport(report.id, controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text('SEND REPLY', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
