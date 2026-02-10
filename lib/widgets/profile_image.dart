import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const ProfileImage({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color defaultBg =
        backgroundColor ??
        (isDarkMode ? const Color(0xff1e293b) : const Color(0xfff1f5f9));
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black45;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        color: defaultBg,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      fallbackIcon,
                      size: size * 0.6,
                      color: iconColor,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.5,
                      height: size * 0.5,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              )
            : Icon(fallbackIcon, size: size * 0.6, color: iconColor),
      ),
    );
  }
}
