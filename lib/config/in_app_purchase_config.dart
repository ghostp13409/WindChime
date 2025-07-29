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
  // Product IDs for Google Play Store
  static const String smallDonationId = 'windchime_small_donation';
  static const String mediumDonationId = 'windchime_medium_donation';
  static const String largeDonationId = 'windchime_large_donation';

  // Product IDs for Apple App Store (if needed)
  static const String smallDonationIdIOS = 'windchime_small_donation';
  static const String mediumDonationIdIOS = 'windchime_medium_donation';
  static const String largeDonationIdIOS = 'windchime_large_donation';

  // Get all product IDs
  static List<String> get productIds => [
        smallDonationId,
        mediumDonationId,
        largeDonationId,
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
      default:
        return 'Donation';
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
      default:
        return 'card_giftcard';
    }
  }
} 