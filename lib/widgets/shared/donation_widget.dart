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

class _DonationWidgetState extends State<DonationWidget> {
  bool _isLoading = true;
  bool _purchaseInProgress = false;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _initializeInAppPurchases();
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
      });
      _showSuccessDialog(donationType);
    };

    InAppPurchaseService.onPurchaseError = (String error) {
      setState(() {
        _purchaseInProgress = false;
      });
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
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Thank You!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Your $donationType has been processed successfully. '
            'Your support helps keep WindChime free and open source!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Purchase Failed',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Sorry, the purchase could not be completed: $error',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _purchaseProduct(String productId) async {
    setState(() {
      _purchaseInProgress = true;
    });

    HapticFeedback.lightImpact();
    await InAppPurchaseService.purchaseProduct(productId);
  }

  Widget _buildDonationCard(ProductDetails product) {
    final String title = InAppPurchaseService.getProductTitle(product.id);
    final String description = InAppPurchaseService.getProductDescription(product.id);
    final Color color = _getProductColor(product.id);

    return GestureDetector(
      onTap: _purchaseInProgress ? null : () => _purchaseProduct(product.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.08),
              color.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getProductIcon(product.id),
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              product.price,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getProductColor(String productId) {
    return Color(InAppPurchaseConfig.getProductColor(productId));
  }

  IconData _getProductIcon(String productId) {
    switch (InAppPurchaseConfig.getProductIcon(productId)) {
      case 'favorite_border':
        return Icons.favorite_border;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.card_giftcard;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!InAppPurchaseService.isAvailable) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'In-App Purchases Not Available',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'In-app purchases are not available on this device.',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No Donation Options Available',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Donation products are not available at the moment.',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_purchaseInProgress)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Processing purchase...',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            return _buildDonationCard(_products[index]);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    InAppPurchaseService.dispose();
    super.dispose();
  }
} 