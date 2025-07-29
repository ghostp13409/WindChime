# GitHub Releases Setup Guide

This guide will help you set up GitHub Releases to host your audio files and reduce your app bundle size.

## Step 1: Prepare Your Audio Files

1. **Rename your audio files** to match the configuration in `lib/config/audio_config.dart`:
   - Remove spaces and special characters
   - Use lowercase with underscores
   - Example: `Body Scan.mp3` → `body_scan_meditation.mp3`

2. **Create a list of files to upload**:
   ```
   body_scan_meditation.mp3
   fifteen_minute_body_scan.mp3
   forty_five_minute_body_scan.mp3
   four_minute_body_scan.mp3
   twenty_minute_body_scan.mp3
   five_minute_breathing.mp3
   six_minute_breath_awareness.mp3
   ten_minute_breathing.mp3
   ten_minute_mindfulness_breathing.mp3
   three_minute_breathing.mp3
   brief_mindfulness_practice.mp3
   breathing_space.mp3
   tension_release_meditation.mp3
   three_minute_mindfulness_sounds.mp3
   three_step_breathing_space.mp3
   mountain_meditation_peter_morgan.mp3
   padraig_mountain.mp3
   five_minutes_bells.mp3
   forty_five_minute_bells_5min.mp3
   forty_five_minute_bells_15min.mp3
   ten_minutes_bells.mp3
   thirty_minute_bells_5min.mp3
   twenty_minute_bells_5min.mp3
   twenty_minutes_bells.mp3
   twenty_five_minute_bells_5min.mp3
   breath_sound_body.mp3
   breath_sounds_body_thoughts_emotions.mp3
   compassionate_breath.mp3
   seated_meditation.mp3
   sitting_meditation.mp3
   ten_minute_wisdom_meditation.mp3
   ```

## Step 2: Create GitHub Release

1. **Go to your GitHub repository** (create one if you don't have it)

2. **Create a new release**:
   - Click "Releases" in your repository
   - Click "Create a new release"
   - Tag: `v1.0.0`
   - Title: `WindChime Audio Files v1.0.0`
   - Description: `Audio files for WindChime meditation app`

3. **Upload all audio files**:
   - Drag and drop all renamed audio files
   - Wait for upload to complete
   - Click "Publish release"

## Step 3: Update Configuration

1. **Update the base URL** in `lib/config/audio_config.dart`:
   ```dart
   static const String baseUrl = 'https://github.com/YOUR_USERNAME/YOUR_REPO/releases/download/v1.0.0/';
   ```
   Replace `YOUR_USERNAME` and `YOUR_REPO` with your actual GitHub username and repository name.

## Step 4: Test the Implementation

1. **Build your app**:
   ```bash
   flutter build apk --release
   ```

2. **Check bundle size**:
   - Your APK should now be much smaller (~30MB instead of 290MB+)
   - The guided meditations will download when users access them

## Step 5: Update Your Repository

1. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Implement dynamic audio downloads via GitHub Releases"
   git push
   ```

## How It Works

### For Users:
1. **App installs quickly** (small bundle size)
2. **User taps a guided meditation** → Download dialog appears
3. **User confirms download** → File downloads with progress indicator
4. **File is cached locally** → Future access is instant
5. **Offline access** → Downloaded files work without internet

### For You:
1. **Easy updates** → Upload new audio files to GitHub releases
2. **No hosting costs** → GitHub provides free hosting
3. **Reliable CDN** → GitHub's infrastructure is fast and reliable
4. **Version control** → Easy to manage different versions

## Troubleshooting

### If downloads fail:
1. **Check internet connection**
2. **Verify GitHub URLs** are correct
3. **Ensure files are uploaded** to the release
4. **Check file permissions** on GitHub

### If app crashes:
1. **Check file paths** in audio_config.dart
2. **Verify file names** match exactly
3. **Test with smaller files** first

## Benefits

✅ **Bundle size reduced** from 290MB to ~30MB  
✅ **Faster app installs** for users  
✅ **Play Store compliance** (under 200MB limit)  
✅ **Free hosting** via GitHub  
✅ **Easy updates** without app store releases  
✅ **Offline access** for downloaded files  

## Next Steps

1. **Test thoroughly** with different devices
2. **Monitor download success rates**
3. **Consider adding a "Download All" option**
4. **Add cache management** for users to clear downloads
5. **Implement download retry logic** for failed downloads

## Support

If you encounter issues:
1. Check the console logs for error messages
2. Verify all file paths and URLs
3. Test with a single file first
4. Ensure your GitHub repository is public (or use GitHub tokens for private repos) 