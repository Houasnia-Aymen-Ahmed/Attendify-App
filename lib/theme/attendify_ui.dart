import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:attendify/index.dart';
import 'package:attendify/theme/attendify_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// All sizing, color, and style decisions in this file reference the centralized
// tokens in attendify_theme.dart:
//   • Colors  → AttendifyPalette
//   • Spacing → AttendifySpacing
//   • Radii   → AttendifyRadius
//   • Text    → AttendifyTextStyle / Theme.of(context).textTheme
// ─────────────────────────────────────────────────────────────────────────────

// ── Page scaffold ─────────────────────────────────────────────────────────────

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
    this.padding = const EdgeInsets.fromLTRB(
      AttendifySpacing.xl,
      AttendifySpacing.md + AttendifySpacing.sm, // 20
      AttendifySpacing.xl,
      AttendifySpacing.xxl,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final hasHeader =
        title != null || leading != null || (actions?.isNotEmpty ?? false);

    final body = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeader)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(
                      width: AttendifySpacing.md + AttendifySpacing.xs),
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
                        const SizedBox(height: AttendifySpacing.xs),
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
          if (hasHeader) const SizedBox(height: AttendifySpacing.xl),
          if (expandChild && !scrollable) Expanded(child: child) else child,
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
        child: Stack(
          children: [
            // Decorative blobs — purely visual
            Positioned(
              top: -80,
              right: -60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AttendifyPalette.tertiary.withValues(alpha: 0.10),
                  borderRadius: AttendifyRadius.lgAll * (140 / 24),
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
                  borderRadius: AttendifyRadius.lgAll * (120 / 24),
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

// ── Surface card ──────────────────────────────────────────────────────────────

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
      padding: padding ?? const EdgeInsets.all(AttendifySpacing.xl),
      decoration: BoxDecoration(
        color: color ?? AttendifyPalette.surface,
        borderRadius: AttendifyRadius.lgAll,
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

// ── Primary button ────────────────────────────────────────────────────────────

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
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  if (icon != null) ...[
                    const SizedBox(width: AttendifySpacing.sm),
                    Icon(icon, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

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
        const SizedBox(height: AttendifySpacing.sm),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (subtitle != null) ...[
          const SizedBox(height: AttendifySpacing.sm),
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

// ── Metric card ───────────────────────────────────────────────────────────────

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
    final bg = emphasized ? AttendifyPalette.primary : AttendifyPalette.surface;
    final fg = emphasized ? Colors.white : AttendifyPalette.text;
    final muted = emphasized
        ? Colors.white.withValues(alpha: 0.78)
        : AttendifyPalette.mutedText;

    return AttendifySurface(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: muted,
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
          const SizedBox(height: AttendifySpacing.lg),
          Text(
            value,
            style:
                Theme.of(context).textTheme.headlineMedium?.copyWith(color: fg),
          ),
          if (helper != null) ...[
            const SizedBox(height: AttendifySpacing.sm),
            Text(
              helper!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: muted,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(
        horizontal: AttendifySpacing.md,
        vertical: AttendifySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AttendifyRadius.smAll,
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

// ── User avatar ───────────────────────────────────────────────────────────────

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

// ── Empty state ───────────────────────────────────────────────────────────────

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
          const SizedBox(height: AttendifySpacing.md + AttendifySpacing.xs),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AttendifySpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AttendifyPalette.mutedText,
                ),
          ),
          if (action != null) ...[
            const SizedBox(height: AttendifySpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}

// ── Input decoration helper ───────────────────────────────────────────────────
// Prefer using the global inputDecorationTheme from AttendifyTheme.
// Use this only when you need a custom override on a specific field.

InputDecoration attendifyInputDecoration({
  required String hintText,
  String? labelText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    labelText: labelText,
    suffixIcon: suffixIcon,
    labelStyle: AttendifyTextStyle.caption(color: AttendifyPalette.mutedText)
        .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
  );
}
