import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

/// Reusable custom text field widget with consistent styling
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;

  const AppTextField({
    super.key,
    required this.label,
    required this.prefixIcon,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.subtle,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }
}

/// Primary button with loading state
class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(text),
      ),
    );
  }
}

/// Decorative blue wave background painter.
/// [progress] drives the vertical slide-in (0.0 = fully hidden above, 1.0 = final position).
class BlueWavePainter extends CustomPainter {
  final double progress;

  const BlueWavePainter({this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Translate upward when progress < 1 so the wave slides in from the top.
    // At progress=0 the wave is shifted up by its full height; at 1 it sits at its final position.
    final slideOffset = (1.0 - progress) * -size.height;
    canvas.save();
    canvas.translate(0, slideOffset);

    final paint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.80)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.95,
        size.width * 0.5,
        size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.75,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Lighter overlay wave
    final paint2 = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.70)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.85,
        size.width * 0.6,
        size.height * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.65,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path2, paint2);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BlueWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Self-contained animated wrapper for [BlueWavePainter].
/// Plays a slide-down + fade-in entrance animation once on mount.
class AnimatedBlueWave extends StatefulWidget {
  const AnimatedBlueWave({super.key});

  @override
  State<AnimatedBlueWave> createState() => _AnimatedBlueWaveState();
}

class _AnimatedBlueWaveState extends State<AnimatedBlueWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Slide: wave travels from fully hidden (0) to its resting position (1)
  late final Animation<double> _slide;

  // Fade: overlaps the tail of the slide for a smooth reveal
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Slide runs first (0% → 80% of total duration) with easeOut
    _slide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
    );

    // Fade overlaps slightly (0% → 65%) with easeIn
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // prevent memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return FadeTransition(
          opacity: _fade,
          child: CustomPaint(
            painter: BlueWavePainter(progress: _slide.value),
          ),
        );
      },
    );
  }
}
