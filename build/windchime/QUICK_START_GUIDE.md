# 🚀 Quick Start: WindChime Feedback Form

Your feedback form is ready! Just follow these simple steps to activate it:

## ⚡ 1-Minute Setup

### Step 1: Create Formspree Account

1. Go to **[formspree.io](https://formspree.io)**
2. Click **"Sign Up"** (it's free!)
3. Verify your email

### Step 2: Create Your Form

1. Click **"New Form"**
2. Name it **"WindChime Feedback"**
3. Enter your email address
4. Click **"Create Form"**

### Step 3: Get Your Form ID

After creating the form, you'll see something like:

```
https://formspree.io/f/xrbzgqjw
```

Copy the part after `/f/` (in this example: `xrbzgqjw`)

### Step 4: Configure WindChime

1. Open `lib/screens/about/feedback_screen.dart`
2. Find line 33 and replace:

   ```dart
   static const String _formspreeEndpoint = 'YOUR_FORMSPREE_FORM_ID';
   ```

   With your actual form ID:

   ```dart
   static const String _formspreeEndpoint = 'xrbzgqjw'; // Replace with your ID
   ```

### Step 5: Test It!

```bash
flutter run
```

Navigate to: **About** → **Feedback** (feedback icon in top-right corner)

## ✨ What Users Can Do

- **📝 Send detailed feedback** with required name, email, and message
- **📸 Attach screenshots** from their device gallery
- **📋 Attach log files** (.txt, .log, .json, .xml files)
- **📱 Include device info** (optional, with toggle control)
- **✅ Get confirmation** when feedback is sent successfully

## 📧 What You'll Receive

Every feedback submission sends you an email with:

```
From: user@example.com
Subject: WindChime Feedback - Bug Report

Name: John Doe
Email: user@example.com
Subject: Audio stops playing

Message:
The meditation audio stops after 5 minutes. This happens
consistently with longer breathing sessions.

--- Device Information ---
App Version: 1.0.0 (1)
Platform: Android 13
Device: Google Pixel 7

--- Attachments ---
File 1: screenshot.png
File 2: error_log.txt
Content: [file contents for small files]
```

## 🔧 Need Help?

**Common Issues:**

❌ **"Please configure Formspree endpoint first"**  
✅ Make sure you replaced `YOUR_FORMSPREE_FORM_ID` with your actual form ID

❌ **"Network error"**  
✅ Check internet connection and verify your form ID is correct

❌ **No emails received**  
✅ Check spam folder and verify email in Formspree dashboard

## 🎯 Free Tier Limits

- **50 submissions/month** (perfect for beta testing)
- **Spam protection** included
- **Unlimited forms**
- **Email notifications**

Need more? Upgrade to paid plans for higher limits and advanced features.

## 🚀 You're Done!

Your WindChime app now has a professional feedback system that will help you:

- **📊 Gather user insights** to improve meditation features
- **🐛 Catch bugs** with device info and screenshots
- **💡 Get feature requests** from your community
- **❤️ Build relationships** with your users

The feedback form seamlessly integrates with your app's beautiful design and provides a smooth user experience. Happy coding! 🧘‍♀️✨
