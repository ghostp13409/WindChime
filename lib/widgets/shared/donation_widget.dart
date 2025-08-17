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

class DonationWidget extends StatefulWidget {
  const DonationWidget({super.key});

  @override
  State<DonationWidget> createState() => _DonationWidgetState();
}

class _DonationWidgetState extends State<DonationWidget>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _purchaseInProgress = false;
  List<ProductDetails> _products = [];
  int? _selectedIndex;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeInAppPurchases();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeInAppPurchases() async {
    // Set up callbacks
    InAppPurchaseService.onProductsLoaded = () {
      setState(() {
        _products = InAppPurchaseService.getProducts();
        _isLoading = false;
      });
    };

    InAppPurchaseService.onPurchaseSuccess = (String donationType) {
      setState(() {
        _purchaseInProgress = false;
        _selectedIndex = null;
      });
      _scaleController.reset();
      _showSuccessDialog(donationType);
    };

    InAppPurchaseService.onPurchaseError = (String error) {
      setState(() {
        _purchaseInProgress = false;
        _selectedIndex = null;
      });
      _scaleController.reset();
      _showErrorDialog(error);
    };

    // Initialize the service
    await InAppPurchaseService.initialize();

    // If products are already loaded, update state
    if (InAppPurchaseService.getProducts().isNotEmpty) {
      setState(() {
        _products = InAppPurchaseService.getProducts();
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
            padding: const EdgeInsets.all(28),
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
                // Success Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4CAF50).withOpacity(0.2),
                        const Color(0xFF4CAF50).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF4CAF50),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Thank You! 🙏',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
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
                const SizedBox(height: 24),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(28),
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
                // Error Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF5252).withOpacity(0.2),
                        const Color(0xFFFF5252).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFFF5252),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Purchase Failed',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
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
                const SizedBox(height: 24),

                // Close Button
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
                        borderRadius: BorderRadius.circular(16),
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

  Future<void> _purchaseProduct(String productId, int index) async {
    setState(() {
      _purchaseInProgress = true;
      _selectedIndex = index;
    });

    _scaleController.forward();
    HapticFeedback.lightImpact();
    await InAppPurchaseService.purchaseProduct(productId);
  }

  Widget _buildModernDonationCard(ProductDetails product, int index) {
    final String title = InAppPurchaseService.getProductTitle(product.id);
    final String description =
        InAppPurchaseService.getProductDescription(product.id);
    final Color color = _getProductColor(product.id);
    final bool isSelected = _selectedIndex == index && _purchaseInProgress;
    final bool isRecommended = index == 1; // Middle option is recommended

    return AnimatedBuilder(
      animation: isSelected ? _scaleAnimation : _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected
              ? _scaleAnimation.value
              : (isRecommended ? _pulseAnimation.value : 1.0),
          child: GestureDetector(
            onTap: _purchaseInProgress
                ? null
                : () => _purchaseProduct(product.id, index),
            child: Container(
              margin: EdgeInsets.only(
                top: isRecommended ? 0 : 12,
                bottom: isRecommended ? 0 : 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.08),
                    color.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? color.withOpacity(0.4)
                      : color.withOpacity(isRecommended ? 0.3 : 0.2),
                  width: isSelected ? 2 : (isRecommended ? 1.5 : 1),
                ),
                boxShadow: [
                  if (isRecommended || isSelected)
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: isSelected ? 16 : 12,
                      offset: const Offset(0, 4),
                      spreadRadius: isSelected ? 2 : 0,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Recommended Badge
                  if (isRecommended && !isSelected)
                    Positioned(
                      top: -1,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Main Content
                  Padding(
                    padding: EdgeInsets.all(isRecommended ? 20 : 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with loading state
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isSelected
                              ? SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        color.withOpacity(0.2),
                                        color.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    _getProductIcon(product.id),
                                    color: color,
                                    size: isRecommended ? 28 : 24,
                                  ),
                                ),
                        ),

                        SizedBox(height: isSelected ? 12 : 16),

                        // Title
                        Text(
                          title,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: isRecommended ? 18 : 16,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Price with enhanced styling
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            product.price,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: isRecommended ? 20 : 18,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          description,
                          style: TextStyle(
                            color: color.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (isSelected) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getProductColor(String productId) {
    return Color(InAppPurchaseConfig.getProductColor(productId));
  }

  IconData _getProductIcon(String productId) {
    switch (InAppPurchaseConfig.getProductIcon(productId)) {
      case 'favorite_border':
        return Icons.favorite_border_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  (iconColor ?? Colors.grey).withOpacity(0.2),
                  (iconColor ?? Colors.grey).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor ?? Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading donation options...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.withOpacity(0.8),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (!InAppPurchaseService.isAvailable) {
      return _buildEmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Donations Unavailable',
        description: 'In-app purchases are not available on this device.',
        iconColor: Colors.orange,
      );
    }

    if (_products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.hourglass_empty_rounded,
        title: 'No Options Available',
        description:
            'Donation products are not available at the moment. Please try again later.',
        iconColor: Colors.blue,
      );
    }

    return Column(
      children: [
        // Header with subtle animation
        if (_products.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choose Your Support Level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
              ],
            ),
          ),

        // Modern donation cards in a staggered layout
        if (_products.isNotEmpty)
          Column(
            children: _products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _products.length - 1 ? 16 : 0,
                ),
                child: _buildModernDonationCard(product, index),
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    InAppPurchaseService.dispose();
    super.dispose();
  }
}
