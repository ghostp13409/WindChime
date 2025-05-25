import 'package:flutter/material.dart';
import 'package:prog2435_final_project_app/models/meditation/meditation_category.dart';

class CategoryCard extends StatelessWidget {
  final MeditationCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: isSelected
                ? category.color.withOpacity(0.3)
                : category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border:
                isSelected ? Border.all(color: category.color, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
