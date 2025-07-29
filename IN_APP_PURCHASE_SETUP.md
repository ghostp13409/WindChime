# Google Play In-App Purchase Setup Guide

This guide explains how to set up Google Play In-App Purchases for the WindChime app.

## Overview

The app has been updated to use Google Play In-App Purchases instead of PayPal and Bitcoin donations. This ensures compliance with Google Play Store policies and provides a better user experience.

## Product Configuration

### Product IDs
The following product IDs are configured in the app:

- `windchime_small_donation` - Small donation tier
- `windchime_medium_donation` - Medium donation tier  
- `windchime_large_donation` - Large donation tier

### Configuration Files
- `lib/config/in_app_purchase_config.dart` - Contains product IDs and UI configuration
- `lib/services/in_app_purchase_service.dart` - Handles purchase logic
- `lib/widgets/shared/donation_widget.dart` - UI component for donations

## Google Play Console Setup

### 1. Create In-App Products
1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Navigate to **Monetization** > **Products** > **In-app products**
4. Create three non-consumable products:
   - **Product ID**: `windchime_small_donation`
   - **Product ID**: `windchime_medium_donation`
   - **Product ID**: `windchime_large_donation`

### 2. Configure Product Details
For each product, set:
- **Title**: "Small/Medium/Large Donation"
- **Description**: "Support WindChime development"
- **Price**: Set appropriate prices for your region
- **Product type**: Non-consumable

### 3. Testing
1. Upload your app to internal testing
2. Add test accounts in Google Play Console
3. Test purchases using test accounts

## Implementation Details

### Dependencies Added
```yaml
in_app_purchase: ^3.1.13
```

### Permissions Added
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### Key Features
- **Non-consumable products**: Users can purchase once
- **Error handling**: Graceful fallback if purchases unavailable
- **Loading states**: Visual feedback during purchase process
- **Success/error dialogs**: User-friendly feedback
- **Platform detection**: Works on Android and iOS

## Code Structure

### Service Layer
- `InAppPurchaseService` handles all purchase logic
- Callbacks for success/error states
- Product loading and validation

### UI Layer
- `DonationWidget` provides the donation interface
- Grid layout with product cards
- Loading and error states
- Purchase progress indicators

### Configuration
- `InAppPurchaseConfig` centralizes product configuration
- Easy to modify product IDs and descriptions
- Platform-specific configurations

## Testing Checklist

- [ ] Products load correctly in test environment
- [ ] Purchase flow works with test accounts
- [ ] Error handling works when purchases unavailable
- [ ] Success/error dialogs display correctly
- [ ] UI adapts to different screen sizes
- [ ] Loading states work properly

## Deployment Notes

1. **Before publishing**: Ensure all products are approved in Google Play Console
2. **Testing**: Use internal testing track before production
3. **Monitoring**: Use Google Play Console analytics to track purchase performance
4. **Support**: Be prepared to handle purchase-related support requests

## Troubleshooting

### Common Issues
1. **Products not loading**: Check product IDs match exactly
2. **Purchase fails**: Verify test account setup
3. **App crashes**: Check billing permission is added
4. **UI issues**: Verify widget integration in about screen

### Debug Information
- Check logs for purchase stream errors
- Verify product availability with `InAppPurchaseService.isAvailable`
- Test with different device configurations

## Migration from PayPal/Bitcoin

The following changes were made:
- Removed PayPal and Bitcoin donation methods
- Removed donation QR code images
- Removed PayPal URL schemes from iOS
- Added Google Play Billing permission
- Implemented in-app purchase service
- Updated about screen to use new donation widget

## Support

For issues with in-app purchases:
1. Check Google Play Console for product status
2. Verify test account configuration
3. Review purchase logs in Google Play Console
4. Test with different device configurations 