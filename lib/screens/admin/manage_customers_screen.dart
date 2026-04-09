import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_background.dart';

class ManageCustomersScreen extends StatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  State<ManageCustomersScreen> createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends State<ManageCustomersScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            _buildSearchBar(),
            _buildCustomerList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'MANAGE CUSTOMERS',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w200,
          letterSpacing: 4,
          fontSize: 14,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.textColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 14),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'SEARCH CUSTOMERS BY NAME OR ID...',
              hintStyle: GoogleFonts.outfit(
                color: AppTheme.textColor.withValues(alpha: 0.3),
                fontSize: 12,
                letterSpacing: 2,
              ),
              prefixIcon: Icon(Icons.search, color: AppTheme.textColor.withValues(alpha: 0.3), size: 20),
              suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppTheme.textColor.withValues(alpha: 0.3), size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('users').where('role', isEqualTo: 'user').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
          );
        }

        var docs = snapshot.data?.docs ?? [];
        
        // Filter locally
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            final nId = (data['numericId'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) || email.contains(_searchQuery) || nId.contains(_searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                _searchQuery.isEmpty ? 'NO CUSTOMERS FOUND' : 'NO RESULTS FOR "$_searchQuery"',
                style: GoogleFonts.outfit(
                  color: AppTheme.textColor.withValues(alpha: 0.5),
                  letterSpacing: 2,
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final uid = docs[index].id;
                return _buildCustomerTile(uid, data);
              },
              childCount: docs.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerTile(String uid, Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Unknown User';
    final String email = data['email'] ?? 'No Email';
    final String nId = data['numericId'] ?? 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.02),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          name.toUpperCase(),
          style: GoogleFonts.outfit(
            color: AppTheme.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email,
              style: GoogleFonts.outfit(
                color: AppTheme.textColor.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(
                'ID: $nId',
                style: GoogleFonts.outfit(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
          onPressed: () => _confirmDeleteCustomer(uid, name),
        ),
      ),
    );
  }

  void _confirmDeleteCustomer(String uid, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('DELETE CUSTOMER', style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 16)),
        content: Text(
          'ARE YOU SURE YOU WANT TO REMOVE $name FROM THE SYSTEM?',
          style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.7), fontSize: 12),
        ),
        actions: [
          TextButton(
            child: Text('CANCEL', style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.5))),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onPressed: () async {
              await _db.collection('users').doc(uid).delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
