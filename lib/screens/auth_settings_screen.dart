import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../widgets/animated_background.dart';

class AuthSettingsScreen extends StatefulWidget {
  const AuthSettingsScreen({super.key});

  @override
  State<AuthSettingsScreen> createState() => _AuthSettingsScreenState();
}

class _AuthSettingsScreenState extends State<AuthSettingsScreen> {
  bool _biometricEnabled = true;
  bool _pushNotifications = true;
  bool _marketingEmails = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleService(), ThemeService()]),
      builder: (context, child) {
        return Scaffold(
          body: AnimatedBackground(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                _buildSettingsList(context),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        LocaleService().translate('AUTH SETTINGS'),
        style: LocaleService().getTextStyle(
          baseStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w200, letterSpacing: 8, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Logged in as banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SIGNED IN AS',
                        style: GoogleFonts.outfit(
                            color: AppTheme.textColor.withValues(alpha: 0.4),
                            fontSize: 8,
                            letterSpacing: 2)),
                    const SizedBox(height: 2),
                    Text(email,
                        style: GoogleFonts.outfit(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            letterSpacing: 1)),
                  ],
                ),
              ],
            ),
          ),

          // Toggle settings
          _buildSectionLabel('PREFERENCES'),
          const SizedBox(height: 12),
          _buildToggleItem(Icons.fingerprint, 'BIOMETRIC AUTHENTICATION',
              _biometricEnabled,
              (v) => setState(() => _biometricEnabled = v)),
          _buildToggleItem(Icons.notifications_active_outlined,
              'PUSH NOTIFICATIONS', _pushNotifications,
              (v) => setState(() => _pushNotifications = v)),
          _buildToggleItem(Icons.email_outlined, 'MARKETING COMMUNICATIONS',
              _marketingEmails,
              (v) => setState(() => _marketingEmails = v)),

          const SizedBox(height: 32),
          _buildSectionLabel('ACCOUNT MANAGEMENT'),
          const SizedBox(height: 12),

          // Change Password
          _buildActionButton(
            icon: Icons.lock_reset_outlined,
            label: 'CHANGE PASSWORD',
            onTap: () => _showChangePasswordSheet(context),
          ),

          // Sign Out from all devices
          _buildActionButton(
            icon: Icons.logout_outlined,
            label: 'SIGN OUT',
            onTap: () => _signOut(context),
          ),

          const SizedBox(height: 16),
          _buildSectionLabel('DANGER ZONE'),
          const SizedBox(height: 12),

          // Delete Account
          _buildActionButton(
            icon: Icons.delete_forever_outlined,
            label: 'DELETE ACCOUNT',
            onTap: () => _showDeleteDialog(context),
            isDestructive: true,
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: GoogleFonts.outfit(
            color: AppTheme.textColor.withValues(alpha: 0.3),
            fontSize: 9,
            letterSpacing: 4,
            fontWeight: FontWeight.w600));
  }

  Widget _buildToggleItem(
      IconData icon, String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.01),
        border:
            Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textColor.withValues(alpha: 0.5), size: 18),
        title: Text(title,
            style: GoogleFonts.outfit(
                color: AppTheme.textColor,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w300)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryColor,
          activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          inactiveThumbColor: AppTheme.textColor.withValues(alpha: 0.5),
          inactiveTrackColor: AppTheme.textColor.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : onTap,
        icon: Icon(icon,
            size: 16,
            color: isDestructive
                ? Colors.redAccent.withValues(alpha: 0.7)
                : AppTheme.textColor.withValues(alpha: 0.54)),
        label: Text(label,
            style: GoogleFonts.outfit(
              color: isDestructive
                  ? Colors.redAccent.withValues(alpha: 0.7)
                  : AppTheme.textColor.withValues(alpha: 0.54),
              fontSize: 10,
              letterSpacing: 2,
            )),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          side: BorderSide(
            color: isDestructive
                ? Colors.redAccent.withValues(alpha: 0.15)
                : AppTheme.textColor.withValues(alpha: 0.06),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  // ─── CHANGE PASSWORD SHEET ────────────────────────────────────────────────
  void _showChangePasswordSheet(BuildContext context) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    bool showCurrent = false;
    bool showNew = false;
    bool showConfirm = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 40),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CHANGE PASSWORD',
                    style: GoogleFonts.outfit(
                        color: AppTheme.textColor,
                        fontSize: 14,
                        letterSpacing: 6,
                        fontWeight: FontWeight.w200)),
                const SizedBox(height: 8),
                Text('YOU WILL STAY SIGNED IN AFTER CHANGING',
                    style: GoogleFonts.outfit(
                        color: AppTheme.textColor.withValues(alpha: 0.3),
                        fontSize: 9,
                        letterSpacing: 2)),
                const SizedBox(height: 32),
                // Current password
                _passwordField(
                  'CURRENT PASSWORD', currentPassCtrl,
                  show: showCurrent,
                  onToggle: () => setModal(() => showCurrent = !showCurrent),
                  validator: (v) => (v == null || v.isEmpty) ? 'REQUIRED' : null,
                ),
                const SizedBox(height: 16),
                _passwordField(
                  'NEW PASSWORD', newPassCtrl,
                  show: showNew,
                  onToggle: () => setModal(() => showNew = !showNew),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'MIN 6 CHARACTERS';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _passwordField(
                  'CONFIRM NEW PASSWORD', confirmPassCtrl,
                  show: showConfirm,
                  onToggle: () => setModal(() => showConfirm = !showConfirm),
                  validator: (v) {
                    if (v != newPassCtrl.text) return 'PASSWORDS DO NOT MATCH';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModal(() => saving = true);
                            try {
                              final user = FirebaseAuth.instance.currentUser!;
                              final cred = EmailAuthProvider.credential(
                                email: user.email!,
                                password: currentPassCtrl.text,
                              );
                              await user.reauthenticateWithCredential(cred);
                              await user.updatePassword(newPassCtrl.text);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                _showSnack(context,
                                    'PASSWORD UPDATED SUCCESSFULLY',
                                    isError: false);
                              }
                            } on FirebaseAuthException catch (e) {
                              setModal(() => saving = false);
                              if (ctx.mounted) {
                                _showSnack(context,
                                    e.code == 'wrong-password'
                                        ? 'CURRENT PASSWORD IS INCORRECT'
                                        : (e.message ?? 'ERROR'),
                                    isError: true);
                              }
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2))
                        : Text('UPDATE PASSWORD',
                            style: GoogleFonts.outfit(
                                color: Colors.black,
                                letterSpacing: 4,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController ctrl, {
    required bool show,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                color: AppTheme.textColor.withValues(alpha: 0.4),
                fontSize: 9,
                letterSpacing: 3)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: !show,
          style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.textColor.withValues(alpha: 0.03),
            suffixIcon: IconButton(
              icon: Icon(
                  show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: AppTheme.textColor.withValues(alpha: 0.3)),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                    color: AppTheme.textColor.withValues(alpha: 0.08), width: 0.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                    color: AppTheme.textColor.withValues(alpha: 0.08), width: 0.5)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide:
                    BorderSide(color: AppTheme.primaryColor, width: 0.5)),
            errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Colors.redAccent, width: 0.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // ─── SIGN OUT ──────────────────────────────────────────────────────────────
  Future<void> _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    await AuthService().logout();
    if (mounted) {
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // ─── DELETE ACCOUNT ────────────────────────────────────────────────────────
  void _showDeleteDialog(BuildContext context) {
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('DELETE ACCOUNT',
            style: GoogleFonts.outfit(
                color: Colors.redAccent,
                fontSize: 14,
                letterSpacing: 4,
                fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THIS IS IRREVERSIBLE. ALL YOUR DATA (ORDERS, CART, WISHLIST, ADDRESSES) WILL BE PERMANENTLY DELETED.',
              style: GoogleFonts.outfit(
                  color: AppTheme.textColor.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w200,
                  height: 1.6),
            ),
            const SizedBox(height: 20),
            Text('CONFIRM YOUR PASSWORD',
                style: GoogleFonts.outfit(
                    color: AppTheme.textColor.withValues(alpha: 0.4),
                    fontSize: 9,
                    letterSpacing: 3)),
            const SizedBox(height: 8),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              style: GoogleFonts.outfit(color: AppTheme.textColor),
              decoration: InputDecoration(
                hintText: 'Your password',
                hintStyle: GoogleFonts.outfit(
                    color: AppTheme.textColor.withValues(alpha: 0.2)),
                filled: true,
                fillColor: AppTheme.textColor.withValues(alpha: 0.03),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.3), width: 0.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.3), width: 0.5)),
                focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: Colors.redAccent, width: 0.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL',
                  style: GoogleFonts.outfit(
                      color: AppTheme.textColor.withValues(alpha: 0.4)))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteAccount(context, passwordCtrl.text);
            },
            child: Text('DELETE FOREVER',
                style: GoogleFonts.outfit(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, String password) async {
    setState(() => _isLoading = true);
    final navigator = Navigator.of(context); // capture before await gap

    try {
      final user = FirebaseAuth.instance.currentUser!;
      // Re-authenticate first
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);

      // Delete all user Firestore data
      final uid = user.uid;
      final db = FirebaseFirestore.instance;
      final collections = ['cart', 'wishlist', 'orders', 'addresses',
          'payment_methods', 'chat_history'];
      for (final col in collections) {
        final docs = await db.collection('users').doc(uid).collection(col).get();
        for (final doc in docs.docs) {
          await doc.reference.delete();
        }
      }
      await db.collection('users').doc(uid).delete();

      // Delete Firebase Auth account
      await user.delete();
      await AuthService().logout();

      if (mounted) {
        navigator.pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      _showSnack(context,
          e.code == 'wrong-password'
              ? 'INCORRECT PASSWORD'
              : (e.message ?? 'ERROR'),
          isError: true);
    }
  }

  void _showSnack(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.outfit(
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: isError ? Colors.white : Colors.black)),
      backgroundColor: isError ? Colors.redAccent : AppTheme.primaryColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ));
  }
}
