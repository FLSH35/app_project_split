// lib/screens/desktop_layout/desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:personality_score/screens/home_desktop_layout/desktop_header_section.dart';
import 'package:personality_score/screens/home_desktop_layout/desktop_videos_section.dart';
import 'package:personality_score/screens/home_desktop_layout/desktop_personality_types_section.dart';
import 'package:personality_score/screens/home_desktop_layout/desktop_tutorial_section.dart';
import '../home_screen/custom_footer.dart';
import '../custom_app_bar.dart';
import 'desktop_testimonial_section.dart';

class DesktopLayout extends StatefulWidget {
  const DesktopLayout({Key? key}) : super(key: key);

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8DB),
      appBar: CustomAppBar(title: 'Personality Score'),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 1) Header Section
          SliverToBoxAdapter(
            child: SizedBox(
              height: 350,
              child: Container(), // Leerraum, um Scroll zu demonstrieren
            ),
          ),
          SliverToBoxAdapter(
            child: DesktopHeaderSection(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 350),
          ),

          // 2) Video Section (lazy)
          SliverToBoxAdapter(
            child: DesktopVideosSection(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 350),
          ),

          // 3) PersonalityTypesSection
          SliverToBoxAdapter(
            child: DesktopPersonalityTypesSection(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 350),
          ),

          // 4) Tutorial Section
          SliverToBoxAdapter(
            child: DesktopTutorialSection(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 350),
          ),

          // 5) Testimonials
          SliverToBoxAdapter(
            child: DesktopTestimonialSection(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),

          // 6) Footer
          SliverToBoxAdapter(
            child: CustomFooter(),
          ),
        ],
      ),
    );
  }
}