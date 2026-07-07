import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class FxDetailScreen extends StatelessWidget {
  const FxDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sparkPoints = [
      1498.0,
      1512.0,
      1505.0,
      1520.0,
      1530.0,
      1528.0,
      1540.20
    ];
    final minVal = sparkPoints.reduce((a, b) => a < b ? a : b);
    final maxVal = sparkPoints.reduce((a, b) => a > b ? a : b);
    final change = ((fxRate - sparkPoints.first) / sparkPoints.first * 100);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const VBackButton(),
                  const SizedBox(width: 14),
                  const Text('USD / NGN Rate',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Veritas rate',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFFC9C6A6))),
                          const SizedBox(height: 8),
                          Text('₦${fxRate.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1.5)),
                          const Text('per USD',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFFC9C6A6))),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color:
                                        AppColors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(children: [
                                  const Icon(Icons.arrow_upward,
                                      color: AppColors.green, size: 13),
                                  const SizedBox(width: 4),
                                  Text('+${change.toStringAsFixed(2)}% today',
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.green)),
                                ]),
                              ),
                              const SizedBox(width: 12),
                              const Text('Updated just now',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF9C9A7C))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 60,
                            child: CustomPaint(
                              painter: _SparklinePainter(
                                  sparkPoints, minVal, maxVal),
                              size: Size.infinite,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Now'
                            ]
                                .map(
                                  (d) => Text(d,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF9C9A7C))),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('Rate breakdown',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subText2)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        _RateRow('Mid-market rate', '₦1,541.80'),
                        _RateRow('Veritas spread', '– ₦1.60 (0.1%)'),
                        const Divider(height: 20, color: AppColors.border),
                        _RateRow('Your rate', '₦${fxRate.toStringAsFixed(2)}',
                            bold: true),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('How it works',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText)),
                          const SizedBox(height: 12),
                          _Bullet(
                              'Veritas uses the live interbank (mid-market) rate from Reuters.'),
                          _Bullet(
                              'We apply a transparent 0.1% spread — no hidden markups.'),
                          _Bullet(
                              'Your rate is locked at the moment of withdrawal.'),
                          _Bullet(
                              'NGN arrives in your account within 2–4 business hours.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        _RateRow('7-day high', '₦1,542.10'),
                        _RateRow('7-day low', '₦1,498.00'),
                        _RateRow('30-day average', '₦1,521.40'),
                      ]),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _RateRow(String label, String value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                fontSize: 13.5,
                color: bold ? AppColors.darkText : AppColors.subText2,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        Text(value,
            style: TextStyle(
                fontSize: 13.5,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.darkText)),
      ]),
    );

Widget _Bullet(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: CircleAvatar(radius: 3, backgroundColor: AppColors.subText2),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.subText2, height: 1.5))),
      ]),
    );

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final double minVal, maxVal;
  _SparklinePainter(this.points, this.minVal, this.maxVal);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.yellow
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = size.height -
          ((points[i] - minVal) / (maxVal - minVal)) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.fill;
    final lastX = size.width;
    final lastY = size.height -
        ((points.last - minVal) / (maxVal - minVal)) * size.height;
    canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) => false;
}
