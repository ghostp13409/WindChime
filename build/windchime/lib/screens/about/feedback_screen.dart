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
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'dart:io';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  final List<File> _attachedFiles = [];
  bool _isSubmitting = false;
  bool _includeDeviceInfo = true;

  // Replace with your Formspree form ID
  static const String _formspreeEndpoint = 'mblylbow';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _attachedFiles.add(File(image.path));
        });
        _showSnackBar('Screenshot attached successfully', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Failed to attach screenshot', Colors.red);
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'log', 'json', 'xml'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _attachedFiles.addAll(
            result.paths
                .where((path) => path != null)
                .map((path) => File(path!)),
          );
        });
        _showSnackBar('Log files attached successfully', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Failed to attach log files', Colors.red);
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
    HapticFeedback.lightImpact();
  }

  Future<String> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceDetails = '';
      deviceDetails +=
          'App Version: ${packageInfo.version} (${packageInfo.buildNumber})\n';
      deviceDetails += 'App Name: ${packageInfo.appName}\n';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceDetails += 'Platform: Android ${androidInfo.version.release}\n';
        deviceDetails +=
            'Device: ${androidInfo.manufacturer} ${androidInfo.model}\n';
        deviceDetails += 'SDK: ${androidInfo.version.sdkInt}\n';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceDetails += 'Platform: iOS ${iosInfo.systemVersion}\n';
        deviceDetails += 'Device: ${iosInfo.model}\n';
        deviceDetails += 'Name: ${iosInfo.name}\n';
      }

      return deviceDetails;
    } catch (e) {
      return 'Device info unavailable';
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_formspreeEndpoint == 'YOUR_FORMSPREE_FORM_ID') {
      _showSnackBar('Please configure Formspree endpoint first', Colors.orange);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String message = _messageController.text;

      if (_includeDeviceInfo) {
        final deviceInfo = await _getDeviceInfo();
        message += '\n\n--- Device Information ---\n$deviceInfo';
      }

      // For files, we'll encode them as base64 and include in the message
      // Note: Formspree free tier has limitations on file uploads
      if (_attachedFiles.isNotEmpty) {
        message += '\n\n--- Attachments ---\n';
        for (int i = 0; i < _attachedFiles.length; i++) {
          final file = _attachedFiles[i];
          final fileName = file.path.split('/').last;
          message += 'File ${i + 1}: $fileName\n';

          // For small files, include content
          try {
            final fileSize = await file.length();
            if (fileSize < 50000) {
              // Less than 50KB
              final content = await file.readAsString();
              message += 'Content:\n$content\n\n';
            } else {
              message += 'File too large to include in feedback\n\n';
            }
          } catch (e) {
            message += 'Could not read file content\n\n';
          }
        }
      }

      final response = await http.post(
        Uri.parse('https://formspree.io/f/$_formspreeEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text,
          'email': _emailController.text,
          'subject': _subjectController.text,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Feedback submitted successfully!', Colors.green);
        _clearForm();
      } else {
        _showSnackBar(
            'Failed to submit feedback. Please try again.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Network error. Please check your connection.', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
    setState(() {
      _attachedFiles.clear();
      _includeDeviceInfo = true;
    });
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == Colors.green ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildIntroSection(),
                        const SizedBox(height: 32),
                        _buildContactFields(),
                        const SizedBox(height: 24),
                        _buildMessageField(),
                        const SizedBox(height: 24),
                        _buildAttachmentsSection(),
                        const SizedBox(height: 24),
                        _buildDeviceInfoToggle(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
              ),
              iconSize: 20,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feedback',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.5,
                        fontSize: 32,
                      ),
                ),
                Text(
                  'Help improve WindChime',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.2),
                      Theme.of(context).primaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.feedback_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Share Your Experience',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your feedback helps me improve WindChime. Whether you found a bug, have a feature request, or just want to share your meditation journey, I\'d love to hear from you!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.withOpacity(0.8),
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _subjectController,
          label: 'Subject',
          icon: Icons.subject_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a subject';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildMessageField() {
    return _buildTextField(
      controller: _messageController,
      label: 'Your Message',
      icon: Icons.message_outlined,
      maxLines: 6,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your message';
        }
        if (value.trim().length < 10) {
          return 'Please provide more details (at least 10 characters)';
        }
        return null;
      },
    );
  }

  Widget _buildAttachmentsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Attachments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Attach screenshots or log files to help describe the issue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAttachmentButton(
                  onTap: _pickImage,
                  icon: Icons.image_outlined,
                  label: 'Add Screenshot',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttachmentButton(
                  onTap: _pickFile,
                  icon: Icons.description_outlined,
                  label: 'Add Log File',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          if (_attachedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...List.generate(_attachedFiles.length, (index) {
              final file = _attachedFiles[index];
              final fileName = file.path.split('/').last;
              return _buildAttachmentItem(fileName, index);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(String fileName, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            fileName.toLowerCase().contains('.png') ||
                    fileName.toLowerCase().contains('.jpg')
                ? Icons.image
                : Icons.description,
            size: 20,
            color: Colors.grey.withOpacity(0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _removeAttachment(index),
            icon: Icon(
              Icons.close,
              size: 18,
              color: Colors.grey.withOpacity(0.8),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone_android,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Include Device Information',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Helps with debugging issues',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: _includeDeviceInfo,
            onChanged: (value) {
              setState(() {
                _includeDeviceInfo = value;
              });
              HapticFeedback.lightImpact();
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Submitting...',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Send Feedback',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
