import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windchime/models/home_screen/menu_item.dart';

class MenuItemsRow extends StatelessWidget {
  final List<MenuItem> menuItems;

  const MenuItemsRow({
    super.key,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: menuItems.map((item) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, item.route);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? item.color.withOpacity(0.2)
                                    : item.color.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item.color,
                              width: 2,
                            ),
                            boxShadow:
                                Theme.of(context).brightness == Brightness.light
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                          ),
                          child: Icon(
                            item.icon,
                            size: 28,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? item.color
                                    : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
