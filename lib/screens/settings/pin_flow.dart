import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class PinFlowScreen extends StatefulWidget {
  final bool isChange;
  const PinFlowScreen({super.key, this.isChange = false});

  @override
  State<PinFlowScreen> createState() => _PinFlowScreenState();
}

class _PinFlowScreenState extends State<PinFlowScreen> {
  int _step = 0; // 0: enter current (if change), 1: new pin, 2: confirm pin
  String _pin = '';
  String _newPin = '';
  bool _done = false;
  String? _error;

  int get _totalSteps => widget.isChange ? 3 : 2;

  String get _title {
    if (_done) return 'PIN set!';
    if (!widget.isChange) return _step == 0 ? 'Create PIN' : 'Confirm PIN';
    switch (_step) {
      case 0: return 'Current PIN';
      case 1: return 'New PIN';
      default: return 'Confirm new PIN';
    }
  }

  String get _subtitle {
    if (_done) return 'Your transaction PIN has been updated.';
    if (!widget.isChange) return _step == 0 ? 'Choose a 4-digit PIN for transactions' : 'Re-enter your PIN to confirm';
    switch (_step) {
      case 0: return 'Enter your current transaction PIN';
      case 1: return 'Choose a new 4-digit PIN';
      default: return 'Re-enter your new PIN';
    }
  }

  void _tap(String digit) {
    if (_pin.length >= 4) return;
    setState(() { _pin += digit; _error = null; });
    if (_pin.length == 4) _next();
  }

  void _del() => setState(() {
    if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
    _error = null;
  });

  void _next() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    if (!widget.isChange) {
      if (_step == 0) {
        _newPin = _pin;
        setState(() { _pin = ''; _step = 1; });
      } else {
        if (_pin == _newPin) {
          setState(() => _done = true);
        } else {
          setState(() { _pin = ''; _error = 'PINs don\'t match — try again'; });
        }
      }
    } else {
      if (_step == 0) {
        if (_pin != '1234') {
          setState(() { _pin = ''; _error = 'Incorrect PIN'; });
          return;
        }
        setState(() { _pin = ''; _step = 1; });
      } else if (_step == 1) {
        _newPin = _pin;
        setState(() { _pin = ''; _step = 2; });
      } else {
        if (_pin == _newPin) {
          setState(() => _done = true);
        } else {
          setState(() { _pin = ''; _error = 'PINs don\'t match — try again'; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (!_done) const VBackButton(),
                  const SizedBox(width: 14),
                  Text(widget.isChange ? 'Change PIN' : 'Create PIN', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            if (!_done) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(_totalSteps, (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _step ? AppColors.dark : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )),
                ),
              ),
            ],
            Expanded(
              child: _done
                  ? _SuccessBody(isChange: widget.isChange, onDone: () => Navigator.of(context).pop())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        Text(_subtitle, style: const TextStyle(fontSize: 14, color: AppColors.subText2)),
                        const SizedBox(height: 32),
                        _PinDots(filled: _pin.length, hasError: _error != null),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.redDark, fontWeight: FontWeight.w600)),
                        ],
                        const SizedBox(height: 40),
                        _Numpad(onTap: _tap, onDel: _del),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int filled;
  final bool hasError;
  const _PinDots({required this.filled, required this.hasError});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(4, (i) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 18, height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i < filled ? (hasError ? AppColors.redDark : AppColors.dark) : Colors.transparent,
          border: Border.all(color: hasError ? AppColors.redDark : i < filled ? AppColors.dark : AppColors.border, width: 2),
        ),
      ),
    )),
  );
}

class _Numpad extends StatelessWidget {
  final void Function(String) onTap;
  final VoidCallback onDel;
  const _Numpad({required this.onTap, required this.onDel});

  @override
  Widget build(BuildContext context) {
    final keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6,
        children: keys.map((k) {
          if (k.isEmpty) return const SizedBox.shrink();
          return GestureDetector(
            onTap: k == '⌫' ? onDel : () => onTap(k),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: k == '⌫' ? AppColors.lightBg : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(k, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  final bool isChange;
  final VoidCallback onDone;
  const _SuccessBody({required this.isChange, required this.onDone});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.lock_outline, color: AppColors.greenDark, size: 40),
        ),
        const SizedBox(height: 24),
        Text(isChange ? 'PIN changed!' : 'PIN created!', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
        const SizedBox(height: 12),
        const Text('Your transaction PIN is set. You\'ll use it to authorise payments and withdrawals.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5, color: AppColors.subText2, height: 1.6)),
        const SizedBox(height: 40),
        VButton(label: 'Done', onTap: onDone),
      ],
    ),
  );
}
