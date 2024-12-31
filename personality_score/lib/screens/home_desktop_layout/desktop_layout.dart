// lib/screens/desktop_layout/desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:personality_score/screens/home_desktop_layout/desktop_header_section.dart';
import 'package:personality_score/screens/home_desktop_layout/desktop_video_section2.dart';
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

  // Erstelle einen GlobalKey für die VideoSection2
  final GlobalKey _videoSection2Key = GlobalKey();
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
            child:           // Schnelleres Laden: Nur 1 großes Bild am Anfang
            Image.asset('assets/ps_background_ai.jpg', height: MediaQuery.of(context).size.height/2),

          ),
          SliverToBoxAdapter(
            child: DesktopHeaderSection(videoSection2Key: _videoSection2Key),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 300),
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

          // 4) Video Section2 mit Key
          SliverToBoxAdapter(
            key: _videoSection2Key,
            child: DesktopVideoSection2(),
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
