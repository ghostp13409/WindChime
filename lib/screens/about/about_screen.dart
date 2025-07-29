/*
 * Copyright (C) 2025 Parth Gajjar
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'feedback_screen.dart';
import 'package:windchime/widgets/shared/donation_widget.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;



  final List<SocialLink> _socialLinks = [
    SocialLink(
      icon: Icons.code,
      label: 'GitHub',
      url: 'https://www.github.com/ghostp13409',
      color: const Color.fromARGB(255, 109, 111, 114),
    ),
    SocialLink(
      icon: Icons.work,
      label: 'LinkedIn',
      url: 'https://www.linkedin.com/in/parth-gajjar09',
      color: const Color(0xFF0077B5),
    ),
    SocialLink(
      icon: Icons.photo_camera,
      label: 'Instagram',
      url:
          'https://www.instagram.com/p_13_4/profilecard/?igsh=MTBrbThrNHc1aWR3NA==',
      color: const Color(0xFFE1306C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    HapticFeedback.lightImpact();

    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Always try to launch the URL with external application mode first
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // If external application fails, try platform default mode
      try {
        final Uri uri = Uri.parse(url);
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      } catch (e2) {
        // If all attempts fail, show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Modern Header
              _buildModernHeader(),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // App Info Section (first)
                      _buildAppInfoSection(),

                      // Made by Section (includes connect and support)
                      _buildMadeBySection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
              ),
              iconSize: 20,
              padding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(width: 16),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.5,
                        fontSize: 32,
                      ),
                ),
                Text(
                  'WindChime meditation app',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),

          // Feedback Button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.feedback_outlined,
                color: Theme.of(context).primaryColor,
              ),
              iconSize: 20,
              padding: const EdgeInsets.all(12),
              tooltip: 'Send Feedback',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMadeBySection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon (consistent with app info section)
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.2),
                      Theme.of(context).primaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Made by',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                    ),
                    Text(
                      'Developer and creator',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Profile section with consistent layout
          Row(
            children: [
              // Profile Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/about/profile.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name and title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parth Gajjar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.1),
                            Theme.of(context).primaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        'Developer',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'I like building cool stuff. I see a problem, I code a solution.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.withOpacity(0.8),
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 24),

          // Social links with consistent header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.2),
                      Theme.of(context).primaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.connect_without_contact,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect With Me',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                    ),
                    Text(
                      'Follow my work or just get in touch',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                _socialLinks.map((link) => _buildSocialLink(link)).toList(),
          ),
          const SizedBox(height: 32),

          // Support Development section (integrated)
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFCF86).withOpacity(0.2),
                      const Color(0xFFFFCF86).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFFFFCF86),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support Development',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                    ),
                    Text(
                      'Help me bring WindChime to more people or to buy a coffee',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
              // Roadmap info button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showRoadmapDialog();
                  },
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.grey.withOpacity(0.8),
                    size: 20,
                  ),
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'If WindChime brings you peace, please consider helping me reach more people! '
            'I\'m a solo developer with limited resources to publish widely or add bigger features. '
            'So, your donations helps a lot! Rest assured, WindChime is and will always be free and open source. '
            'If you are as broke as me, just sharing it helps too!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.withOpacity(0.8),
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 20),

          // In-App Purchase Donation Widget
          const DonationWidget(),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WindChime',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                    ),
                    Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'About WindChime',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'WindChime is a comprehensive meditation app designed to help you find inner peace through guided meditations and scientific breathing techniques. It combines modern design with evidence-based wellness practices.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.withOpacity(0.8),
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLink(SocialLink link) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _launchUrl(link.url);
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              link.color.withOpacity(0.1),
              link.color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: link.color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: link.color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              link.icon,
              size: 28,
              color: link.color,
            ),
            const SizedBox(height: 4),
            Text(
              link.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: link.color,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }





  void _showRoadmapDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFCF86).withOpacity(0.2),
                            const Color(0xFFFFCF86).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.route,
                        color: Color(0xFFFFCF86),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Development Roadmap',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Roadmap content
                        Text(
                          'Your support helps reach these milestones',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                        ),
                        const SizedBox(height: 20),

                        // Milestones
                        ..._buildRoadmapMilestones(),

                        const SizedBox(height: 24),

                        // Call to action
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFFCF86).withOpacity(0.1),
                                const Color(0xFFFFCF86).withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFCF86).withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            'All contributions, big or small, goes 100% to development! well except for the ones that goes into coffee.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFFFFCF86),
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildRoadmapMilestones() {
    final milestones = [
      RoadmapMilestone(
        title: 'Play Store Release',
        description: 'Publish WindChime on Google Play Store',
        fundingGoal: '\$35',
        isCompleted: false,
        icon: Icons.android_outlined,
        color: const Color(0xFF4CAF50),
      ),
      RoadmapMilestone(
        title: 'App Store Release',
        description: 'Launch on Apple App Store',
        fundingGoal: '\$135/yr',
        isCompleted: false,
        icon: Icons.apple_outlined,
        color: const Color(0xFF2196F3),
      ),
      RoadmapMilestone(
        title: 'Smaller App Size',
        description: 'Optimize app for faster downloads',
        fundingGoal: '\$35 - \$50/mo',
        isCompleted: false,
        icon: Icons.compress,
        color: const Color(0xFFFF9800),
      ),
      RoadmapMilestone(
        title: 'Account & Backup',
        description: 'User accounts with cloud backup',
        fundingGoal: '\$10/mo',
        isCompleted: false,
        icon: Icons.cloud_sync,
        color: const Color(0xFF9C27B0),
      ),
    ];

    return milestones
        .map((milestone) => _buildMilestoneItem(milestone))
        .toList();
  }

  Widget _buildMilestoneItem(RoadmapMilestone milestone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: milestone.isCompleted
              ? milestone.color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  milestone.color
                      .withOpacity(milestone.isCompleted ? 0.2 : 0.1),
                  milestone.color
                      .withOpacity(milestone.isCompleted ? 0.1 : 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              milestone.isCompleted ? Icons.check_circle : milestone.icon,
              color: milestone.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: milestone.isCompleted
                                  ? milestone.color
                                  : null,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: milestone.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        milestone.fundingGoal,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: milestone.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.withOpacity(0.8),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class RoadmapMilestone {
  final String title;
  final String description;
  final String fundingGoal;
  final bool isCompleted;
  final IconData icon;
  final Color color;

  RoadmapMilestone({
    required this.title,
    required this.description,
    required this.fundingGoal,
    required this.isCompleted,
    required this.icon,
    required this.color,
  });
}

class SocialLink {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  SocialLink({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });
}
