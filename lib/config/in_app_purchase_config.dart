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

class InAppPurchaseConfig {
  // Product IDs for Google Play Store - Consumables (One-time donations)
  static const String smallDonationId = 'small_tip';
  static const String mediumDonationId = 'medium_tip';
  static const String largeDonationId = 'large_tip';

  // Product IDs for Google Play Store - Subscriptions
  static const String smallPledgeId = 'small_pledge';
  static const String mediumPledgeId = 'medium_pledge';

  // Product IDs for Apple App Store (if needed) - Consumables
  static const String smallDonationIdIOS = 'windchime_small_donation';
  static const String mediumDonationIdIOS = 'windchime_medium_donation';
  static const String largeDonationIdIOS = 'windchime_large_donation';

  // Product IDs for Apple App Store (if needed) - Subscriptions
  static const String smallPledgeIdIOS = 'windchime_small_pledge';
  static const String mediumPledgeIdIOS = 'windchime_medium_pledge';

  // Get all product IDs
  static List<String> get productIds => [
        ...consumableProductIds,
        ...subscriptionProductIds,
      ];

  // Get consumable product IDs (one-time donations)
  static List<String> get consumableProductIds => [
        smallDonationId,
        mediumDonationId,
        largeDonationId,
      ];

  // Get subscription product IDs
  static List<String> get subscriptionProductIds => [
        smallPledgeId,
        mediumPledgeId,
      ];

  // Product titles
  static String getProductTitle(String productId) {
    switch (productId) {
      case smallDonationId:
        return 'Small Donation';
      case mediumDonationId:
        return 'Medium Donation';
      case largeDonationId:
        return 'Large Donation';
      case smallPledgeId:
        return 'Small Monthly Pledge';
      case mediumPledgeId:
        return 'Medium Monthly Pledge';
      default:
        return 'Support';
    }
  }

  // Product descriptions
  static String getProductDescription(String productId) {
    switch (productId) {
      case smallDonationId:
        return 'Support WindChime with a small donation';
      case mediumDonationId:
        return 'Support WindChime with a medium donation';
      case largeDonationId:
        return 'Support WindChime with a large donation';
      case smallPledgeId:
        return 'Monthly support to help maintain cloud features like backup/restore';
      case mediumPledgeId:
        return 'Monthly support to help maintain advanced features like leaderboards';
      default:
        return 'Support WindChime development';
    }
  }

  // Product colors for UI
  static int getProductColor(String productId) {
    switch (productId) {
      case smallDonationId:
        return 0xFF4CAF50; // Green
      case mediumDonationId:
        return 0xFFFF9800; // Orange
      case largeDonationId:
        return 0xFFE91E63; // Pink
      case smallPledgeId:
        return 0xFF2196F3; // Blue
      case mediumPledgeId:
        return 0xFF9C27B0; // Purple
      default:
        return 0xFF2196F3; // Blue
    }
  }

  // Product icons
  static String getProductIcon(String productId) {
    switch (productId) {
      case smallDonationId:
        return 'favorite_border';
      case mediumDonationId:
        return 'favorite';
      case largeDonationId:
        return 'favorite';
      case smallPledgeId:
        return 'repeat';
      case mediumPledgeId:
        return 'repeat';
      default:
        return 'card_giftcard';
    }
  }

  // Check if product is a subscription
  static bool isSubscription(String productId) {
    return subscriptionProductIds.contains(productId);
  }
}
