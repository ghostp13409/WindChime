# F-Droid Submission Guide for WindChime

This document provides instructions for submitting WindChime to F-Droid.

## Metadata File

The F-Droid metadata file has been created at [`metadata/com.example.windchime.yml`](metadata/com.example.windchime.yml).

## Pre-Submission Checklist

### 1. Update Package Name

Before submission, you need to update the application ID from the placeholder:

- Current: `com.example.windchime`
- Should be: Your actual domain (e.g., `com.yourname.windchime`)

Update in:

- [`android/app/build.gradle`](android/app/build.gradle) (lines 15, 21, 45)
- [`metadata/com.example.windchime.yml`](metadata/com.example.windchime.yml) (filename and content)

### 2. Repository Setup

Update the repository URLs in the metadata file:

- Replace `https://github.com/yourusername/windchime` with your actual repository
- Ensure the repository is public and contains the complete source code
- Tag the release version (e.g., `v1.0`) that matches the metadata

### 3. License Verification

- Verify all audio files have proper licensing for distribution
- Ensure GPL-3.0 license file is present in repository
- Check that all dependencies are compatible with F-Droid requirements

### 4. Build Requirements

The app requires:

- Flutter SDK (handled by F-Droid build system)
- Android NDK 25.1.8937393
- Java 17
- Minimum SDK 21, Target SDK 34

## Submission Process

### Option 1: Direct Submission

1. Fork the [F-Droid Data repository](https://gitlab.com/fdroid/fdroiddata)
2. Add your metadata file to the `metadata/` directory
3. Submit a merge request

### Option 2: Request for Packaging (RFP)

1. Create an issue in the [F-Droid Data repository](https://gitlab.com/fdroid/fdroiddata/-/issues)
2. Use the "Request for Packaging" template
3. Provide the repository URL and brief description

## Important Notes

### App Size Considerations

- The app contains 60+ meditation audio files
- Total APK size will be significant (~100MB+)
- F-Droid has guidelines about large apps - ensure this is documented

### Privacy Features

- App works completely offline
- No network permissions required for core functionality
- All data stored locally
- No analytics or tracking

### Audio License Compliance

Ensure all meditation audio files are:

- Royalty-free or properly licensed
- Compatible with GPL-3.0 distribution
- Documented with proper attribution if required

## Testing Before Submission

1. **Local Build Test:**

   ```bash
   flutter build apk --release
   ```

2. **Verify APK:**

   - Test on clean device
   - Verify offline functionality
   - Check audio playback works correctly

3. **F-Droid Build Simulation:**
   You can test the F-Droid build process locally using the F-Droid build tools.

## Metadata Validation

Before submitting, validate your metadata file:

```bash
# If you have fdroidserver tools installed
fdroid readmeta metadata/com.example.windchime.yml
```

## Post-Submission

After submission:

1. Monitor the merge request for feedback
2. Address any build issues or policy concerns
3. Update metadata as needed based on F-Droid maintainer feedback

## Contact Information

For F-Droid specific questions:

- F-Droid Forum: https://forum.f-droid.org/
- Matrix: #fdroid:f-droid.org
- Documentation: https://f-droid.org/docs/

## Additional Resources

- [F-Droid Inclusion Policy](https://f-droid.org/docs/Inclusion_Policy/)
- [Build Metadata Reference](https://f-droid.org/docs/Build_Metadata_Reference/)
- [All About Descriptions](https://f-droid.org/docs/All_About_Descriptions_Graphics_and_Screenshots/)
