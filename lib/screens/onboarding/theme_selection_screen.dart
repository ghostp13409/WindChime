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
import 'package:provider/provider.dart';
import 'package:windchime/providers/theme_provider.dart';
import 'package:windchime/services/utils/sound_utils.dart';

class ThemeSelectionScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const ThemeSelectionScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectTheme(ThemeModeOption themeMode) {
    HapticFeedback.lightImpact();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Header
                Text(
                  'Choose Your Theme',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.5,
                        fontSize: 32,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Customize your visual experience',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Theme animation icon
                SizedBox(
                  height: 160,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFCF86).withOpacity(0.6),
                                  const Color(0xFFFFCF86).withOpacity(0.2),
                                  const Color(0xFFFFCF86).withOpacity(0.05),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFFCF86).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.palette_outlined,
                              size: 48,
                              color: const Color(0xFFFFCF86),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Theme options container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Available themes:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFFCF86),
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _buildThemeFeatureItem(
                        icon: Icons.light_mode,
                        title: 'Light Theme',
                        description: 'Clean and bright interface',
                        color: const Color(0xFFFFCF86),
                        isSelected:
                            themeProvider.themeMode == ThemeModeOption.light,
                        onTap: () => _selectTheme(ThemeModeOption.light),
                      ),
                      const SizedBox(height: 12),
                      _buildThemeFeatureItem(
                        icon: Icons.dark_mode,
                        title: 'Dark Theme',
                        description: 'Easy on the eyes, saves battery',
                        color: const Color(0xFF7B65E4),
                        isSelected:
                            themeProvider.themeMode == ThemeModeOption.dark,
                        onTap: () => _selectTheme(ThemeModeOption.dark),
                      ),
                      const SizedBox(height: 12),
                      _buildThemeFeatureItem(
                        icon: Icons.settings_brightness,
                        title: 'Follow System',
                        description: 'Automatically match your device',
                        color: const Color(0xFFF6815B),
                        isSelected:
                            themeProvider.themeMode == ThemeModeOption.system,
                        onTap: () => _selectTheme(ThemeModeOption.system),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Complete button - "Start Exploring" since this is the last page
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7B65E4),
                        const Color(0xFF7B65E4).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B65E4).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      playSound('sounds/startup/completetask.mp3');
                      widget.onNext();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start Exploring',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.explore,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info note - styled consistently with other screens
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: const Color(0xFFFFCF86),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can change your theme anytime in the About screen by tapping the theme toggle button.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.withOpacity(0.8),
                                    height: 1.4,
                                    letterSpacing: 0.1,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(isSelected ? 0.3 : 0.2),
                    color.withOpacity(isSelected ? 0.2 : 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(
                        color: color.withOpacity(0.5),
                        width: 2,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: isSelected ? color : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withOpacity(0.8),
                          height: 1.3,
                          letterSpacing: 0.1,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: color,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
