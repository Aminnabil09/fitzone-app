import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';

class CarouselBanner extends StatefulWidget {
  const CarouselBanner({super.key});

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  int _currentIndex = 0;

  // Default banners (used if Firestore has none)
  static const List<Map<String, String>> _defaultBanners = [
    {'title': 'New Arrivals', 'subtitle': 'SPRING 2026 COLLECTION'},
    {'title': 'Special Offers', 'subtitle': 'UP TO 40% OFF'},
    {'title': 'Best Sellers', 'subtitle': 'TOP RATED GEAR'},
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('banners')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        // Use Firestore banners if available, otherwise fallback
        final List<Map<String, String>> banners;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          banners = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'title': (data['title'] ?? '').toString(),
              'subtitle': (data['subtitle'] ?? '').toString(),
            };
          }).toList();
        } else {
          banners = _defaultBanners;
        }

        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 150,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: banners.map((banner) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        border: Border.all(
                            color: AppTheme.textColor.withValues(alpha: 0.05),
                            width: 0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner['title']!.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w200,
                              letterSpacing: 6,
                              color: AppTheme.textColor,
                            ),
                          ),
                          if (banner['subtitle']!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              banner['subtitle']!,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 3,
                                color: AppTheme.primaryColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == entry.key ? 20.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == entry.key
                        ? AppTheme.primaryColor
                        : AppTheme.textColor.withValues(alpha: 0.15),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
