import 'package:flutter/material.dart';

import '../core/theme.dart';

class VeritasLogo extends StatelessWidget {
  final double size;
  final Color color;

  const VeritasLogo(
      {super.key, this.size = 22, this.color = AppColors.darkText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: size * 1.4,
            height: size,
            child: Image.asset('assets/images/v-icon.png')),
        const SizedBox(width: 8),
        SizedBox(
            width: size * 2,
            height: size,
            child: Image.asset('assets/images/v-text.png')),
      ],
    );
  }

  Widget _circle(double sz) => Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: sz * 0.13),
        ),
      );
}

class VButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? bg;
  final Color? fg;
  final bool small;
  final IconData? icon;

  const VButton({
    super.key,
    required this.label,
    required this.onTap,
    this.bg,
    this.fg,
    this.small = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = bg ?? AppColors.yellow;
    final fgColor = fg ?? AppColors.darkText;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: small ? 12 : 17),
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.lightBg : bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: onTap == null ? AppColors.subText : fgColor, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: small ? 14 : 15.5,
                fontWeight: FontWeight.w800,
                color: onTap == null ? AppColors.subText : fgColor,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final Widget? prefix;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final int? maxLines;

  const VTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.prefix,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.subText2,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: prefix,
          ),
        ),
      ],
    );
  }
}

class VBackButton extends StatelessWidget {
  final Color? bg;
  final Color? fg;

  const VBackButton({super.key, this.bg, this.fg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bg ?? Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          Icons.chevron_left,
          color: fg ?? AppColors.darkText,
          size: 22,
        ),
      ),
    );
  }
}

class VCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const VCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: borderRadius ?? BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }
}

class VSectionLabel extends StatelessWidget {
  final String text;

  const VSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.subText,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class VMenuItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;
  final Color? labelColor;

  const VMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.showDivider = true,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                icon,
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? AppColors.darkText,
                    ),
                  ),
                ),
                trailing ??
                    const Icon(Icons.chevron_right,
                        color: AppColors.mutedText, size: 18),
              ],
            ),
          ),
          if (showDivider)
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1EFD6)),
        ],
      ),
    );
  }
}

class VRoleSwitcher extends StatelessWidget {
  final bool isClient;
  final VoidCallback onFreelancer;
  final VoidCallback onClient;

  const VRoleSwitcher({
    super.key,
    required this.isClient,
    required this.onFreelancer,
    required this.onClient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(13),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Tab('Freelancer', !isClient, onFreelancer),
          _Tab('Client', isClient, onClient),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.dark : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.subText2,
            ),
          ),
        ),
      ),
    );
  }
}

class VStatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const VStatusBadge(
      {super.key, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

void showVToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, color: AppColors.green, size: 18),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3), entry.remove);
}

Future<bool?> showVConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  Color? confirmColor,
}) async {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE0DDC4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CC),
              borderRadius: BorderRadius.circular(18),
            ),
            child:
                const Icon(Icons.lock_outline, color: AppColors.gold, size: 26),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                  letterSpacing: -0.4)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.subText2, height: 1.55)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text('Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText)),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: confirmColor ?? AppColors.yellow,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(confirmLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: confirmColor != null
                                ? Colors.white
                                : AppColors.darkText)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
