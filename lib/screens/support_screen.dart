import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_background.dart';
import '../services/support_service.dart';
import '../models/support_report.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'App';
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _types = ['App', 'Product', 'Order', 'Other'];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await SupportService().submitReport(
        type: _selectedType,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );
      
      if (mounted) {
        _subjectController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FEEDBACK SUBMITTED SUCCESSFULLY', style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 2)),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ERROR SUBMITTING FEEDBACK')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildFeedbackForm(),
            _buildHistoryHeader(),
            _buildFeedbackHistory(),
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
        'SUPPORT & FEEDBACK',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w200,
          letterSpacing: 4,
          fontSize: 14,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEW REPORT',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildTextField('SUBJECT', _subjectController, 'e.g., App Lag or Sizing Issue'),
              const SizedBox(height: 16),
              _buildTextField('MESSAGE', _messageController, 'Describe your issue in detail...', maxLines: 5),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  child: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text('SUBMIT REPORT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ISSUE CATEGORY',
          style: GoogleFonts.outfit(fontSize: 9, letterSpacing: 2, color: AppTheme.textColor.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.textColor.withValues(alpha: 0.02),
            border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.1), width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedType,
              dropdownColor: AppTheme.surfaceColor,
              isExpanded: true,
              style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 13),
              items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 9, letterSpacing: 2, color: AppTheme.textColor.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.textColor.withValues(alpha: 0.02),
            border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.1), width: 0.5),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 13),
            validator: (v) => v!.isEmpty ? 'FIELD REQUIRED' : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: AppTheme.textColor.withValues(alpha: 0.2), fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
        child: Text(
          'YOUR SUPPORT HISTORY',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
            color: AppTheme.textColor.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackHistory() {
    return StreamBuilder<List<SupportReport>>(
      stream: SupportService().streamUserReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'NO REPORTS FOUND',
                  style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.2), fontSize: 12),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildReportTile(reports[index]),
              childCount: reports.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportTile(SupportReport report) {
    bool isReplied = report.status == 'replied';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.01),
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
              report.type.toUpperCase(),
              style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontSize: 9, letterSpacing: 1),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isReplied ? Colors.green.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
              ),
              child: Text(
                report.status.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: isReplied ? Colors.green : Colors.amber,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR MESSAGE:',
                style: GoogleFonts.outfit(fontSize: 9, color: AppTheme.textColor.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 8),
              Text(
                report.message,
                style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 12),
              ),
              if (report.adminReply != null) ...[
                const SizedBox(height: 24),
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
                        'ADMIN REPLY:',
                        style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.adminReply!,
                        style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 12),
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
}
