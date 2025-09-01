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

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:windchime/config/in_app_purchase_config.dart';

class InAppPurchaseService {
  static final List<String> _productIds = InAppPurchaseConfig.productIds;

  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static List<ProductDetails> _products = [];
  static bool _isAvailable = false;
  static bool _purchasePending = false;

  // Callbacks
  static Function(String)? onPurchaseSuccess;
  static Function(String)? onPurchaseError;
  static Function()? onProductsLoaded;

  static Future<void> initialize() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final bool available = await _inAppPurchase.isAvailable();
      _isAvailable = available;

      if (available) {
        await _loadProducts();
        await _initializePurchaseStream();
      }
    }
  }

  static Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds.toSet());

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      onProductsLoaded?.call();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  static Future<void> _initializePurchaseStream() async {
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );
  }

  static void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
      } else {
        _purchasePending = false;
        if (purchaseDetails.status == PurchaseStatus.error) {
          onPurchaseError
              ?.call(purchaseDetails.error?.message ?? 'Purchase failed');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _handleSuccessfulPurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  static void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    String donationType = '';
    switch (purchaseDetails.productID) {
      case InAppPurchaseConfig.smallDonationId:
        donationType = 'Small Donation';
        break;
      case InAppPurchaseConfig.mediumDonationId:
        donationType = 'Medium Donation';
        break;
      case InAppPurchaseConfig.largeDonationId:
        donationType = 'Large Donation';
        break;
    }
    onPurchaseSuccess?.call(donationType);
  }

  static Future<bool> purchaseProduct(String productId) async {
    if (!_isAvailable) {
      onPurchaseError?.call('In-app purchases not available');
      return false;
    }

    final ProductDetails product = _products.firstWhere(
      (element) => element.id == productId,
      orElse: () => throw Exception('Product not found'),
    );

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      if (product.id == InAppPurchaseConfig.smallDonationId ||
          product.id == InAppPurchaseConfig.mediumDonationId ||
          product.id == InAppPurchaseConfig.largeDonationId) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
      return true;
    } catch (e) {
      onPurchaseError?.call('Purchase failed: $e');
      return false;
    }
    return false;
  }

  static List<ProductDetails> getProducts() {
    return _products;
  }

  static bool get isAvailable => _isAvailable;
  static bool get purchasePending => _purchasePending;

  static String getProductTitle(String productId) {
    return InAppPurchaseConfig.getProductTitle(productId);
  }

  static String getProductDescription(String productId) {
    return InAppPurchaseConfig.getProductDescription(productId);
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
