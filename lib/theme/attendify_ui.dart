import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:attendify/index.dart';
import 'package:attendify/theme/attendify_theme.dart';

class AttendifyScreen extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool scrollable;
  final bool expandChild;
  final EdgeInsetsGeometry padding;

  const AttendifyScreen({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.scrollable = true,
    this.expandChild = false,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 24),
  });

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null ||
              leading != null ||
              (actions?.isNotEmpty ?? false))
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          if (title != null ||
              leading != null ||
              (actions?.isNotEmpty ?? false))
            const SizedBox(height: 20),
          if (expandChild && !scrollable)
            Expanded(child: child)
          else
            child,
        ],
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AttendifyPalette.background,
            Color(0xFFEAF1F8),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AttendifyPalette.tertiary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(140),
                ),
                child: const SizedBox(width: 220, height: 220),
              ),
            ),
            Positioned(
              left: -50,
              bottom: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AttendifyPalette.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(120),
                ),
                child: const SizedBox(width: 180, height: 180),
              ),
            ),
            if (scrollable) SingleChildScrollView(child: body) else body,
          ],
        ),
      ),
    );
  }
}

class AttendifySurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AttendifySurface({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? AttendifyPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AttendifyPalette.outline),
        boxShadow: [
          BoxShadow(
            color: AttendifyPalette.primary.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AttendifyPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const AttendifyPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else ...[
              Text(label),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 18),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class AttendifySectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;

  const AttendifySectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AttendifyPalette.secondary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AttendifyPalette.mutedText,
                ),
          ),
        ],
      ],
    );
  }
}

class AttendifyMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? helper;
  final IconData? icon;
  final Color? accentColor;
  final bool emphasized;

  const AttendifyMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.helper,
    this.icon,
    this.accentColor,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final highlightColor = accentColor ?? AttendifyPalette.secondary;
    final backgroundColor =
        emphasized ? AttendifyPalette.primary : AttendifyPalette.surface;
    final foregroundColor = emphasized ? Colors.white : AttendifyPalette.text;
    final mutedColor = emphasized
        ? Colors.white.withValues(alpha: 0.78)
        : AttendifyPalette.mutedText;

    return AttendifySurface(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: mutedColor,
                      ),
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: emphasized ? Colors.white70 : highlightColor,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: foregroundColor,
                ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 8),
            Text(
              helper!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class AttendifyStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const AttendifyStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
            ),
      ),
    );
  }
}

class AttendifyUserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const AttendifyUserAvatar({
    super.key,
    required this.imageUrl,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AttendifyPalette.surface,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: AttendifyPalette.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Image(
            image: AppImages.defaultProfile,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class AttendifyEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final Widget? action;

  const AttendifyEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AttendifySurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 42,
            color: AttendifyPalette.secondary,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AttendifyPalette.mutedText,
                ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

InputDecoration attendifyInputDecoration({
  required String hintText,
  String? labelText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    labelText: labelText,
    suffixIcon: suffixIcon,
    labelStyle: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AttendifyPalette.mutedText,
    ),
  );
}
