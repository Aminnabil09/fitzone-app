import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../services/storage_service.dart';
import '../widgets/animated_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleService(), ThemeService(), AuthService()]),
      builder: (context, child) {
        return Scaffold(
          body: AnimatedBackground(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                _buildProfileHeader(context),
                _buildActionGrid(context),
                _buildLogOutButton(context),
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
        LocaleService().translate('PROFILE'),
        style: LocaleService().getTextStyle(
          baseStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w200,
            letterSpacing: 8,
            fontSize: 18,
          ),
        ),
      ),
      actions: const [
        SizedBox(width: 48),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => _showEditProfileSheet(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.textColor.withValues(alpha: 0.02),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          image: AuthService().userImage.isNotEmpty
                              ? DecorationImage(
                                  image: AuthService().userImage.startsWith('http')
                                      ? NetworkImage(AuthService().userImage)
                                      : MemoryImage(base64Decode(AuthService().userImage)) as ImageProvider,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: AuthService().userImage.isEmpty
                            ? Icon(Icons.person_outline, size: 48, color: AppTheme.textColor.withValues(alpha: 0.2))
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 0.5),
                      ),
                      child: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleService().translate(AuthService().userName.isEmpty ? 'NEW MEMBER' : AuthService().userName.toUpperCase()),
                    style: LocaleService().getTextStyle(
                      baseStyle: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, size: 14, color: AppTheme.textColor.withValues(alpha: 0.3)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AuthService().userEmail,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  color: AppTheme.primaryColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildMenuSection(LocaleService().translate('MANAGEMENT'), [
              _buildMenuItem(context, Icons.shopping_bag_outlined, LocaleService().translate('ORDER HISTORY'), '/order_history'),
              _buildMenuItem(context, Icons.favorite_border_rounded, LocaleService().translate('MY ARCHIVE'), '/wishlist'),
              _buildMenuItem(context, Icons.location_on_outlined, LocaleService().translate('DELIVERY ADDRESS'), '/address'),
            ]),
            const SizedBox(height: 32),
            _buildMenuSection(LocaleService().translate('SECURITY'), [
              _buildMenuItem(context, Icons.credit_card_outlined, LocaleService().translate('PAYMENT METHODS'), '/payment'),
              _buildMenuItem(context, Icons.security_outlined, LocaleService().translate('AUTH SETTINGS'), '/auth_settings'),
            ]),
            const SizedBox(height: 32),
            _buildMenuSection(LocaleService().translate('HELP'), [
              _buildMenuItem(context, Icons.help_outline_rounded, LocaleService().translate('SUPPORT & FEEDBACK'), '/support'),
            ]),
            const SizedBox(height: 32),
            _buildMenuSection(LocaleService().translate('PREFERENCES'), [
              _buildLanguageSelector(),
              const SizedBox(height: 16),
              _buildThemeToggle(),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
            color: AppTheme.textColor.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.01),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textColor.withValues(alpha: 0.5), size: 18),
        title: Text(
          title,
          style: LocaleService().getTextStyle(
            baseStyle: GoogleFonts.outfit(
              color: AppTheme.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 2,
            ),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.textColor.withValues(alpha: 0.3), size: 10),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
  Widget _buildLanguageSelector() {
    return Column(
      children: [
        _buildLanguageItem('English', const Locale('en')),
        _buildLanguageItem('Kurdish (Sorani)', const Locale('ku')),
        _buildLanguageItem('Arabic', const Locale('ar')),
      ],
    );
  }

  Widget _buildLanguageItem(String name, Locale locale) {
    final isSelected = LocaleService().currentLocale == locale;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : AppTheme.textColor.withValues(alpha: 0.01),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.3) : AppTheme.textColor.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: ListTile(
        title: Text(
          name,
          style: LocaleService().getTextStyle(
            baseStyle: GoogleFonts.outfit(
              color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: 2,
            ),
          ),
        ),
        trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor, size: 16) : null,
        onTap: () => LocaleService().setLocale(locale),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final isDark = ThemeService().isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.01),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: ListTile(
        leading: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: AppTheme.textColor.withValues(alpha: 0.5), size: 18),
        title: Text(
          LocaleService().translate('APPEARANCE (DARK / LIGHT)'),
          style: LocaleService().getTextStyle(
            baseStyle: GoogleFonts.outfit(
              color: AppTheme.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 2,
            ),
          ),
        ),
        trailing: Switch(
          value: isDark,
          onChanged: (_) => ThemeService().toggleTheme(),
          activeThumbColor: AppTheme.primaryColor,
          activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          inactiveThumbColor: AppTheme.textColor.withValues(alpha: 0.5),
          inactiveTrackColor: AppTheme.textColor.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildLogOutButton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GestureDetector(
          onTap: () async {
            await AuthService().logout();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.1), width: 0.5),
            ),
            child: Center(
              child: Text(
                LocaleService().translate('END SESSION'),
                style: LocaleService().getTextStyle(
                  baseStyle: GoogleFonts.outfit(
                    color: Colors.redAccent.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 4,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final nameController = TextEditingController(text: AuthService().userName);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              border: Border(top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleService().translate('EDIT PROFILE'),
                  style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    letterSpacing: 4, color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField('DISPLAY NAME', nameController),
                const SizedBox(height: 16),
                // Upload photo button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.textColor.withValues(alpha: 0.1)),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    icon: Icon(Icons.photo_camera_outlined,
                        size: 16, color: AppTheme.textColor.withValues(alpha: 0.5)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 50);
                      if (image != null) {
                        setModal(() => saving = true);
                        final bytes = await image.readAsBytes();
                        
                        final String path = 'profiles/${AuthService().currentNumericId ?? DateTime.now().millisecondsSinceEpoch}.jpg';
                        final String? imageUrl = await StorageService().uploadImage(bytes, path);
                        
                        if (imageUrl != null) {
                          await AuthService().updateUserProfile(
                              nameController.text.trim(), imageUrl);
                        } else {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('IMAGE UPLOAD FAILED. CHECK STORAGE RULES.')),
                            );
                            setModal(() => saving = false);
                          }
                          return;
                        }

                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('PROFILE PHOTO UPDATED',
                                style: GoogleFonts.outfit(
                                    fontSize: 10, letterSpacing: 2,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                            backgroundColor: AppTheme.primaryColor,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(24),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                          ));
                        }
                      }
                    },
                    label: Text(
                      LocaleService().translate('CHANGE PROFILE PHOTO'),
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                          fontSize: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Save name button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.backgroundColor,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty) return;
                            setModal(() => saving = true);
                            await AuthService().updateUserProfile(
                                nameController.text.trim(),
                                AuthService().userImage);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('PROFILE UPDATED',
                                    style: GoogleFonts.outfit(
                                        fontSize: 10, letterSpacing: 2,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black)),
                                backgroundColor: AppTheme.primaryColor,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(24),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                              ));
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2))
                        : Text(
                            LocaleService().translate('SAVE CHANGES'),
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleService().translate(label),
          style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 2, color: AppTheme.textColor.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.textColor.withValues(alpha: 0.02),
            border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.1), width: 0.5),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

