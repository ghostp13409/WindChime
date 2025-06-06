# Feedback Form Setup Guide

This guide explains how to configure the feedback form in your WindChime app using Formspree, a free form handling service.

## What is Formspree?

Formspree is a free service that handles form submissions and sends them to your email. The free tier includes:

- 50 submissions per month
- Spam filtering
- Email notifications
- No server setup required

## Setup Instructions

### Step 1: Create a Formspree Account

1. Go to [https://formspree.io](https://formspree.io)
2. Click "Sign Up" and create a free account
3. Verify your email address

### Step 2: Create a New Form

1. After logging in, click "New Form"
2. Enter a form name (e.g., "WindChime Feedback")
3. Enter your email address where you want to receive feedback
4. Click "Create Form"

### Step 3: Get Your Form ID

1. After creating the form, you'll see a form endpoint like:
   ```
   https://formspree.io/f/YOUR_FORM_ID
   ```
2. Copy the `YOUR_FORM_ID` part (it looks like `xrbzgqjw` or similar)

### Step 4: Configure the App

1. Open `lib/screens/about/feedback_screen.dart`
2. Find line 33 with:
   ```dart
   static const String _formspreeEndpoint = 'YOUR_FORMSPREE_FORM_ID';
   ```
3. Replace `YOUR_FORMSPREE_FORM_ID` with your actual form ID:
   ```dart
   static const String _formspreeEndpoint = 'xrbzgqjw'; // Your actual form ID
   ```

### Step 5: Test the Integration

1. Run your app: `flutter run`
2. Navigate to About → Feedback (tap the feedback icon in the top right)
3. Fill out the form and submit it
4. Check your email for the feedback submission

## Form Features

The feedback form includes:

### ✅ Basic Information

- **Name**: User's name (required)
- **Email**: User's email for responses (required)
- **Subject**: Brief description of the feedback topic (required)
- **Message**: Detailed feedback message (required, minimum 10 characters)

### ✅ File Attachments

- **Screenshots**: Users can attach images from their device gallery
- **Log Files**: Users can attach text/log files (.txt, .log, .json, .xml)
- **File Size Limit**: Small files (< 50KB) are included in the email content
- **Large Files**: Larger files are noted but not included (Formspree free tier limitation)

### ✅ Device Information (Optional)

- **App Version**: Current app version and build number
- **Platform Info**: Android/iOS version and device details
- **Toggle Control**: Users can disable this if they prefer privacy

### ✅ User Experience

- **Modern UI**: Consistent with your app's design language
- **Form Validation**: Ensures all required fields are filled correctly
- **Loading States**: Shows progress during submission
- **Success/Error Messages**: Clear feedback on submission status
- **Haptic Feedback**: Tactile responses for better UX

## Email Format

When users submit feedback, you'll receive an email containing:

```
From: user@example.com
Subject: WindChime Feedback - [User's Subject]

Name: John Doe
Email: user@example.com
Subject: Bug Report - Audio not playing

Message:
The meditation audio stops playing after 5 minutes on my device. This happens consistently with longer sessions.

--- Device Information ---
App Version: 1.0.0 (1)
App Name: WindChime
Platform: Android 13
Device: Google Pixel 7
SDK: 33

--- Attachments ---
File 1: screenshot.png
Content: [base64 encoded image data for small files]

File 2: error_log.txt
Content: [log file contents for small files]
```

## Advanced Configuration

### Custom Email Templates (Paid Plans)

For more professional email formatting, consider upgrading to Formspree's paid plans which offer:

- Custom email templates
- Auto-responders
- Integration with other services
- Higher submission limits

### Alternative Services

If you need more features, consider these alternatives:

- **EmailJS**: Client-side email sending
- **Netlify Forms**: If hosting on Netlify
- **Google Forms**: Completely free but less customizable
- **Custom Backend**: For full control (requires server setup)

### Security Considerations

- The form endpoint is public but Formspree provides spam protection
- Consider adding rate limiting for production apps
- User emails are handled securely by Formspree
- Device information is optional and can be disabled by users

## Troubleshooting

### Common Issues

1. **"Please configure Formspree endpoint first" error**

   - Make sure you replaced `YOUR_FORMSPREE_FORM_ID` with your actual form ID

2. **"Network error" message**

   - Check internet connection
   - Verify the form ID is correct
   - Check Formspree dashboard for any issues

3. **Emails not received**

   - Check spam/junk folder
   - Verify email address in Formspree dashboard
   - Ensure form is active in Formspree

4. **File attachments not working**
   - Large files (>50KB) are noted but not included in emails
   - Check file permissions on device
   - Ensure file types are supported (.txt, .log, .json, .xml for logs)

### Testing Checklist

- [ ] Form validation works (try submitting empty fields)
- [ ] Email validation works (try invalid email formats)
- [ ] Success message appears after submission
- [ ] Email received in your inbox
- [ ] Device information toggle works
- [ ] File attachments work (both images and text files)
- [ ] Error handling works (try with no internet)

## Support

If you encounter issues:

1. Check the [Formspree documentation](https://help.formspree.io/)
2. Verify your form setup in the Formspree dashboard
3. Test with a simple submission first
4. Check the Flutter console for any error messages

The feedback system is now ready to help you gather valuable user input to improve WindChime! 🎉
