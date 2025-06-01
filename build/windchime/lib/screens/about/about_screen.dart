import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  final List<DonationMethod> _donationMethods = [
    DonationMethod(
      name: 'PayPal',
      icon: Icons.payment,
      qrImagePath: 'assets/images/about/donatepaypal.png',
      color: const Color(0xFF003087),
      url: 'https://www.paypal.com/qrcodes/p2pqrc/UUTYHV3A526VY',
    ),
    DonationMethod(
      name: 'Bitcoin',
      icon: Icons.currency_bitcoin,
      qrImagePath: 'assets/images/about/donatebtc.png',
      color: const Color(0xFFF7931A),
      url: 'bitcoin:bc1qn3rgkrkv287k5hauymtnpd6uzu67gsmv0kcma5',
    ),
  ];

  final List<SocialLink> _socialLinks = [
    SocialLink(
      icon: FontAwesomeIcons.github,
      label: 'GitHub',
      url: 'https://www.github.com/ghostp13409',
      color: const Color.fromARGB(255, 109, 111, 114),
    ),
    SocialLink(
      icon: FontAwesomeIcons.linkedin,
      label: 'LinkedIn',
      url: 'https://www.linkedin.com/in/parth-gajjar09',
      color: const Color(0xFF0077B5),
    ),
    SocialLink(
      icon: FontAwesomeIcons.instagram,
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
      duration: const Duration(milliseconds: 300),
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
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If the app-specific URL fails, try opening in browser
        if (url.contains('github.com')) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        } else if (url.contains('linkedin.com')) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        } else if (url.contains('instagram.com')) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Cannot launch URL');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(),
            const SizedBox(height: 24),

            // Donation Section
            _buildDonationSection(),
            const SizedBox(height: 24),

            // Social Links Section
            _buildSocialLinksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Profile Image
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
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
        const SizedBox(height: 24),

        // Name
        Text(
          'Parth Gajjar',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),

        // Title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
          child: Text(
            'Developer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinksSection() {
    return Column(
      children: [
        Text(
          'Connect',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _socialLinks.map((link) => _buildSocialLink(link)).toList(),
        ),
      ],
    );
  }

  Widget _buildSocialLink(SocialLink link) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _launchUrl(link.url);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: link.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: link.color.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              link.icon,
              size: 40,
              color: link.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationSection() {
    return Column(
      children: [
        Text(
          'Buy Me a Coffee',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),

        // QR Code Carousel
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _donationMethods.length,
            itemBuilder: (context, index) {
              return _buildDonationCard(_donationMethods[index]);
            },
          ),
        ),
        const SizedBox(height: 24),

        // Method Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _donationMethods.asMap().entries.map((entry) {
            final isActive = _currentPage == entry.key;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  entry.key,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? entry.value.color.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? entry.value.color.withOpacity(0.3)
                              : entry.value.color.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        entry.value.icon,
                        color: isActive
                            ? entry.value.color
                            : entry.value.color.withOpacity(0.5),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.value.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isActive
                                ? entry.value.color
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withOpacity(0.5),
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDonationCard(DonationMethod method) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: method.color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: method.color.withOpacity(0.1),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive QR code size
            final maxQRSize = constraints.maxWidth - 40; // Account for padding
            final qrSize = (maxQRSize > 200) ? 180.0 : maxQRSize - 20;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // QR Code
                Container(
                  width: qrSize,
                  height: qrSize,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    method.qrImagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DonationMethod {
  final String name;
  final IconData icon;
  final String qrImagePath;
  final Color color;
  final String url;

  DonationMethod({
    required this.name,
    required this.icon,
    required this.qrImagePath,
    required this.color,
    required this.url,
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
