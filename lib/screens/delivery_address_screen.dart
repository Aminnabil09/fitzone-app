import '../services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../services/locale_service.dart';
import '../widgets/animated_background.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  CollectionReference get _addressRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('addresses');

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
                _buildAddressList(context),
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
        LocaleService().translate('DELIVERY ADDRESS'),
        style: LocaleService().getTextStyle(
          baseStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w200, letterSpacing: 8, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildAddressList(BuildContext context) {
    if (_uid.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: StreamBuilder<QuerySnapshot>(
        stream: _addressRef.orderBy('createdAt', descending: false).snapshots(),
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
                      Icon(Icons.location_off_outlined,
                          size: 48, color: AppTheme.textColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text('NO ADDRESSES SAVED',
                          style: GoogleFonts.outfit(
                              color: AppTheme.textColor.withValues(alpha: 0.3),
                              letterSpacing: 4,
                              fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('TAP + TO ADD YOUR FIRST ADDRESS',
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
              (ctx, i) => _buildAddressCard(ctx, docs[i]),
              childCount: docs.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isDefault = data['isDefault'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.01),
        border: Border.all(
          color: isDefault
              ? AppTheme.primaryColor.withValues(alpha: 0.4)
              : AppTheme.textColor.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (data['label'] ?? 'ADDRESS').toString().toUpperCase(),
                style: GoogleFonts.outfit(
                    color: isDefault
                        ? AppTheme.primaryColor
                        : AppTheme.textColor.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2),
              ),
              if (isDefault)
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppTheme.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Text('DEFAULT',
                        style: GoogleFonts.outfit(
                            color: AppTheme.primaryColor,
                            fontSize: 8,
                            letterSpacing: 2)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(data['fullName'] ?? '',
              style: GoogleFonts.outfit(
                  color: AppTheme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
          const SizedBox(height: 4),
          Text(
            '${data['street'] ?? ''}\n${data['city'] ?? ''}, ${data['country'] ?? ''}',
            style: GoogleFonts.inter(
                color: AppTheme.textColor.withValues(alpha: 0.6),
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w300),
          ),
          if ((data['phone'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(data['phone'],
                style: GoogleFonts.outfit(
                    color: AppTheme.textColor.withValues(alpha: 0.4),
                    fontSize: 11,
                    letterSpacing: 1)),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              if (!isDefault)
                GestureDetector(
                  onTap: () => _setDefault(doc.id),
                  child: Text('SET DEFAULT',
                      style: GoogleFonts.outfit(
                          color: AppTheme.primaryColor.withValues(alpha: 0.7),
                          fontSize: 10,
                          letterSpacing: 2)),
                ),
              if (!isDefault) const SizedBox(width: 24),
              GestureDetector(
                onTap: () => _showAddressSheet(context, existing: doc),
                child: Text('EDIT',
                    style: GoogleFonts.outfit(
                        color: AppTheme.textColor.withValues(alpha: 0.54),
                        fontSize: 10,
                        letterSpacing: 2)),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => _deleteAddress(context, doc.id),
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
    final all = await _addressRef.get();
    for (final d in all.docs) {
      batch.update(d.reference, {'isDefault': d.id == docId});
    }
    await batch.commit();
  }

  Future<void> _deleteAddress(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('REMOVE ADDRESS',
            style: GoogleFonts.outfit(
                color: AppTheme.textColor, letterSpacing: 2, fontSize: 14)),
        content: Text('This address will be permanently removed.',
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
    if (confirm == true) await _addressRef.doc(docId).delete();
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      color: Colors.transparent,
      child: ElevatedButton.icon(
        onPressed: () => _showAddressSheet(context),
        icon: const Icon(Icons.add, size: 18, color: Colors.black),
        label: Text('ADD NEW ADDRESS',
            style: GoogleFonts.outfit(
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20)),
      ),
    );
  }

  void _showAddressSheet(BuildContext context,
      {QueryDocumentSnapshot? existing}) {
    final data =
        existing != null ? existing.data() as Map<String, dynamic> : null;
    final labelCtrl =
        TextEditingController(text: data?['label'] ?? '');
    final nameCtrl =
        TextEditingController(text: data?['fullName'] ?? '');
    final streetCtrl =
        TextEditingController(text: data?['street'] ?? '');
    final cityCtrl =
        TextEditingController(text: data?['city'] ?? '');
    final countryCtrl =
        TextEditingController(text: data?['country'] ?? '');
    final phoneCtrl =
        TextEditingController(text: data?['phone'] ?? '');
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
                  Text(
                    existing != null ? 'EDIT ADDRESS' : 'NEW ADDRESS',
                    style: GoogleFonts.outfit(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        letterSpacing: 6,
                        fontWeight: FontWeight.w200),
                  ),
                  const SizedBox(height: 32),
                  _field('LABEL (e.g. HOME)', labelCtrl,
                      hint: 'Home, Office…'),
                  _field('FULL NAME', nameCtrl,
                      hint: 'Recipient name', required: true),
                  _field('STREET ADDRESS', streetCtrl,
                      hint: '123 Main St', required: true),
                  _field('CITY', cityCtrl, hint: 'City', required: true),
                  _field('COUNTRY', countryCtrl,
                      hint: 'Country', required: true),
                  _field('PHONE (optional)', phoneCtrl, hint: '+1 000 000 0000'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => saving = true);
                              final payload = {
                                'label': labelCtrl.text.trim().toUpperCase(),
                                'fullName': nameCtrl.text.trim(),
                                'street': streetCtrl.text.trim(),
                                'city': cityCtrl.text.trim(),
                                'country': countryCtrl.text.trim(),
                                'phone': phoneCtrl.text.trim(),
                                'isDefault': data?['isDefault'] ?? false,
                                'createdAt': FieldValue.serverTimestamp(),
                              };
                              if (existing != null) {
                                await _addressRef
                                    .doc(existing.id)
                                    .update(payload);
                              } else {
                                // If first address, set as default
                                final count =
                                    (await _addressRef.get()).docs.length;
                                if (count == 0) payload['isDefault'] = true;
                                await _addressRef.add(payload);
                              }
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2))
                          : Text(
                              existing != null ? 'SAVE CHANGES' : 'SAVE ADDRESS',
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
