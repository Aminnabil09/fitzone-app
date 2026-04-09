import '../services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../services/locale_service.dart';
import '../widgets/animated_background.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  CollectionReference get _payRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('payment_methods');

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
                _buildCardsList(context),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
          bottomNavigationBar: _buildAddButton(context),
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
        LocaleService().translate('PAYMENT METHODS'),
        style: LocaleService().getTextStyle(
          baseStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w200, letterSpacing: 8, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildCardsList(BuildContext context) {
    if (_uid.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: StreamBuilder<QuerySnapshot>(
        stream: _payRef.orderBy('createdAt', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(64),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card_off_outlined,
                          size: 48, color: AppTheme.textColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text('NO CARDS SAVED',
                          style: GoogleFonts.outfit(
                              color: AppTheme.textColor.withValues(alpha: 0.3),
                              letterSpacing: 4,
                              fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('TAP + TO ADD YOUR FIRST CARD',
                          style: GoogleFonts.outfit(
                              color: AppTheme.textColor.withValues(alpha: 0.2),
                              letterSpacing: 2,
                              fontSize: 10)),
                    ],
                  ),
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildPaymentCard(ctx, docs[i]),
              childCount: docs.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isDefault = data['isDefault'] == true;
    final last4 = data['last4'] ?? '****';
    final label = (data['label'] ?? 'CARD').toString().toUpperCase();
    final expiry = data['expiry'] ?? 'MM/YY';
    final cardType = data['cardType'] ?? 'VISA';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDefault
                ? AppTheme.primaryColor.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.02),
            Colors.white.withValues(alpha: 0.01),
          ],
        ),
        border: Border.all(
          color: isDefault
              ? AppTheme.primaryColor.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.outfit(
                      color: AppTheme.textColor.withValues(alpha: 0.54),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2)),
              Row(
                children: [
                  Text(cardType,
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor.withValues(alpha: 0.3),
                          fontSize: 10,
                          letterSpacing: 1)),
                  const SizedBox(width: 8),
                  Icon(Icons.credit_card,
                      color: isDefault
                          ? AppTheme.primaryColor
                          : AppTheme.textColor.withValues(alpha: 0.24),
                      size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Card number (masked)
          Text(
            '**** **** **** $last4',
            style: GoogleFonts.inter(
                color: AppTheme.textColor,
                fontSize: 18,
                letterSpacing: 4,
                fontWeight: FontWeight.w200),
          ),
          const SizedBox(height: 28),
          // Expiry + Default badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXPIRY',
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor.withValues(alpha: 0.24),
                          fontSize: 8,
                          letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text(expiry,
                      style: GoogleFonts.inter(
                          color: AppTheme.textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w300)),
                ],
              ),
              if (isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.5),
                        width: 0.5),
                  ),
                  child: Text('PRIMARY',
                      style: GoogleFonts.outfit(
                          color: AppTheme.primaryColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Actions
          Row(
            children: [
              if (!isDefault)
                GestureDetector(
                  onTap: () => _setDefault(doc.id),
                  child: Text('SET PRIMARY',
                      style: GoogleFonts.outfit(
                          color: AppTheme.primaryColor.withValues(alpha: 0.7),
                          fontSize: 10,
                          letterSpacing: 2)),
                ),
              if (!isDefault) const SizedBox(width: 24),
              GestureDetector(
                onTap: () => _deleteCard(context, doc.id, label),
                child: Text('REMOVE',
                    style: GoogleFonts.outfit(
                        color: Colors.redAccent.withValues(alpha: 0.6),
                        fontSize: 10,
                        letterSpacing: 2)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setDefault(String docId) async {
    final batch = FirebaseFirestore.instance.batch();
    final all = await _payRef.get();
    for (final d in all.docs) {
      batch.update(d.reference, {'isDefault': d.id == docId});
    }
    await batch.commit();
  }

  Future<void> _deleteCard(
      BuildContext context, String docId, String label) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('REMOVE CARD',
            style: GoogleFonts.outfit(
                color: AppTheme.textColor, letterSpacing: 2, fontSize: 14)),
        content: Text('$label will be permanently removed.',
            style: GoogleFonts.outfit(
                color: AppTheme.textColor.withValues(alpha: 0.5), fontSize: 12)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('CANCEL',
                  style: GoogleFonts.outfit(
                      color: AppTheme.textColor.withValues(alpha: 0.4)))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('REMOVE',
                  style: GoogleFonts.outfit(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) await _payRef.doc(docId).delete();
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      color: Colors.transparent,
      child: ElevatedButton.icon(
        onPressed: () => _showAddCardSheet(context),
        icon: const Icon(Icons.add, size: 18, color: Colors.black),
        label: Text('ADD NEW CARD',
            style: GoogleFonts.outfit(
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20)),
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    final labelCtrl = TextEditingController();
    final last4Ctrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    String selectedType = 'VISA';
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 40),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ADD PAYMENT METHOD',
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor,
                          fontSize: 14,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w200)),
                  const SizedBox(height: 8),
                  Text(
                    'WE ONLY STORE THE LAST 4 DIGITS FOR SECURITY',
                    style: GoogleFonts.outfit(
                        color: AppTheme.textColor.withValues(alpha: 0.3),
                        fontSize: 9,
                        letterSpacing: 2),
                  ),
                  const SizedBox(height: 32),
                  // Card type selector
                  Text('CARD TYPE',
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor.withValues(alpha: 0.4),
                          fontSize: 9,
                          letterSpacing: 3)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['VISA', 'MASTERCARD', 'AMEX'].map((type) {
                      final selected = selectedType == type;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedType = type),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textColor.withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                            color: selected
                                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                          ),
                          child: Text(type,
                              style: GoogleFonts.outfit(
                                  color: selected
                                      ? AppTheme.primaryColor
                                      : AppTheme.textColor.withValues(alpha: 0.4),
                                  fontSize: 10,
                                  letterSpacing: 1)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _field('CARD LABEL', labelCtrl, hint: 'Personal, Business…'),
                  // Last 4 digits
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LAST 4 DIGITS',
                            style: GoogleFonts.outfit(
                                color: AppTheme.textColor.withValues(alpha: 0.4),
                                fontSize: 9,
                                letterSpacing: 3)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: last4Ctrl,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: GoogleFonts.outfit(
                              color: AppTheme.textColor,
                              fontSize: 20,
                              letterSpacing: 8),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '0000',
                            hintStyle: GoogleFonts.outfit(
                                color: AppTheme.textColor.withValues(alpha: 0.2),
                                fontSize: 20,
                                letterSpacing: 8),
                            filled: true,
                            fillColor: AppTheme.textColor.withValues(alpha: 0.03),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide(
                                    color:
                                        AppTheme.textColor.withValues(alpha: 0.08),
                                    width: 0.5)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide(
                                    color:
                                        AppTheme.textColor.withValues(alpha: 0.08),
                                    width: 0.5)),
                            focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide(
                                    color: AppTheme.primaryColor, width: 0.5)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          validator: (v) {
                            if (v == null || v.length != 4) {
                              return 'ENTER EXACTLY 4 DIGITS';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  _field('EXPIRY DATE', expiryCtrl,
                      hint: 'MM/YY', required: true),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => saving = true);
                              final count = (await _payRef.get()).docs.length;
                              await _payRef.add({
                                'label': labelCtrl.text.trim().toUpperCase().isEmpty
                                    ? selectedType
                                    : labelCtrl.text.trim().toUpperCase(),
                                'last4': last4Ctrl.text.trim(),
                                'expiry': expiryCtrl.text.trim(),
                                'cardType': selectedType,
                                'isDefault': count == 0,
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2))
                          : Text('SAVE CARD',
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
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String hint = '', bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
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
            style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                  color: AppTheme.textColor.withValues(alpha: 0.2), fontSize: 13),
              filled: true,
              fillColor: AppTheme.textColor.withValues(alpha: 0.03),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: required
                ? (v) => (v == null || v.isEmpty) ? 'REQUIRED' : null
                : null,
          ),
        ],
      ),
    );
  }
}
