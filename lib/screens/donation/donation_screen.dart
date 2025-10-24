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
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:windchime/services/in_app_purchase_service.dart';
import 'package:windchime/config/in_app_purchase_config.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // (existing build method content goes here)
    // If missing, restore the build method from previous working version.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.2),
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
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                ?.withOpacity(0.8),
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
                              'Support WindChime',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.5,
                                    fontSize: 28,
                                  ),
                            ),
                            Text(
                              'Choose your contribution',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
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
                            _showRoadmapDialog(context);
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
                ),

                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : !InAppPurchaseService.isAvailable
                          ? _buildEmptyState(
                              icon: Icons.shopping_cart_outlined,
                              title: 'Donations Unavailable',
                              description:
                                  'In-app purchases are not available on this device.',
                            )
                          : (_consumableProducts.isEmpty &&
                                  _subscriptionProducts.isEmpty)
                              ? _buildEmptyState(
                                  icon: Icons.hourglass_empty,
                                  title: 'No Options Available',
                                  description:
                                      'Support products are not available at the moment.',
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Description
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.info_outline,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'About Donations',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'If WindChime brings you peace, please consider helping me reach more people! '
                                              'I\'m a solo developer with limited resources to publish widely or add bigger features. '
                                              'So, your donations helps a lot! Rest assured, WindChime is and will always be free and open source. '
                                              'If you are as broke as me, just sharing it helps too!',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.grey
                                                        .withOpacity(0.8),
                                                    height: 1.5,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      // One-time Donations Section
                                      if (_consumableProducts.isNotEmpty) ...[
                                        Text(
                                          'One-Time Support',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.3,
                                              ),
                                        ),
                                        const SizedBox(height: 16),
                                        ..._consumableProducts.map((product) =>
                                            _buildDonationOption(product)),
                                        const SizedBox(height: 40),
                                      ],
                                      // Subscriptions Section
                                      if (_subscriptionProducts.isNotEmpty) ...[
                                        Text(
                                          'Monthly Support',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.3,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Help maintain cloud features like backup/restore, leaderboards, and personalized insights',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey
                                                    .withOpacity(0.7),
                                                height: 1.4,
                                              ),
                                        ),
                                        const SizedBox(height: 16),
                                        ..._subscriptionProducts.map(
                                            (product) =>
                                                _buildDonationOption(product)),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Subscriptions automatically renew monthly. You can cancel anytime through your app store account settings.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey
                                                    .withOpacity(0.6),
                                                height: 1.4,
                                                fontSize: 12,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isLoading = true;
  bool _purchaseInProgress = false;
  List<ProductDetails> _consumableProducts = [];
  List<ProductDetails> _subscriptionProducts = [];
  String? _selectedProductId;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeInAppPurchases();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _initializeInAppPurchases() async {
    InAppPurchaseService.onProductsLoaded = () {
      setState(() {
        _consumableProducts = InAppPurchaseService.getConsumableProducts();
        _subscriptionProducts = InAppPurchaseService.getSubscriptionProducts();
        _isLoading = false;
      });
    };

    InAppPurchaseService.onPurchaseSuccess = (String donationType) {
      setState(() {
        _purchaseInProgress = false;
        _selectedProductId = null;
      });
      _showSuccessDialog(donationType);
    };

    InAppPurchaseService.onPurchaseError = (String error) {
      setState(() {
        _purchaseInProgress = false;
        _selectedProductId = null;
      });
      _showErrorDialog(error);
    };

    await InAppPurchaseService.initialize();

    if (InAppPurchaseService.getProducts().isNotEmpty) {
      setState(() {
        _consumableProducts = InAppPurchaseService.getConsumableProducts();
        _subscriptionProducts = InAppPurchaseService.getSubscriptionProducts();
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String donationType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Thank You! 🙏',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your $donationType has been processed successfully.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.withOpacity(0.8),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your support helps keep WindChime free and open source!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFF5252),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Purchase Failed',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sorry, the purchase could not be completed:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.withOpacity(0.8),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFFF5252),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      foregroundColor:
                          Theme.of(context).textTheme.bodyLarge?.color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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

  Future<void> _purchaseProduct(String productId) async {
    setState(() {
      _purchaseInProgress = true;
      _selectedProductId = productId;
    });

    HapticFeedback.lightImpact();
    await InAppPurchaseService.purchaseProduct(productId);
  }

  Widget _buildDonationOption(ProductDetails product) {
    final String title = InAppPurchaseService.getProductTitle(product.id);
    final String description =
        InAppPurchaseService.getProductDescription(product.id);
    final Color color = Color(InAppPurchaseConfig.getProductColor(product.id));
    final bool isSelected = _selectedProductId == product.id;
    final bool isProcessing = _purchaseInProgress && isSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              _purchaseInProgress ? null : () => _purchaseProduct(product.id),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.05)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color.withOpacity(0.3)
                    : Theme.of(context).dividerColor.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isProcessing
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      : Icon(
                          _getProductIcon(product.id),
                          color: color,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.price,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getProductIcon(String productId) {
    switch (InAppPurchaseConfig.getProductIcon(productId)) {
      case 'favorite_border':
        return Icons.favorite_border;
      case 'favorite':
        return Icons.favorite;
      case 'repeat':
        return Icons.repeat;
      default:
        return Icons.card_giftcard;
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.grey.withOpacity(0.6),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withOpacity(0.8),
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showRoadmapDialog(BuildContext context) {
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Text(
                          'Your support helps reach these milestones',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                        ),
                        const SizedBox(height: 20),
                        ..._buildRoadmapMilestones(context),
                        const SizedBox(height: 24),
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

  List<Widget> _buildRoadmapMilestones(BuildContext context) {
    final milestones = [
      RoadmapMilestone(
        title: 'Play Store Release',
        description: 'Publish WindChime on Google Play Store',
        fundingGoal: '\$35',
        isCompleted: true,
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
        .map((milestone) => _buildMilestoneItem(context, milestone))
        .toList();
  }

  Widget _buildMilestoneItem(BuildContext context, RoadmapMilestone milestone) {
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    InAppPurchaseService.dispose();
    super.dispose();
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
