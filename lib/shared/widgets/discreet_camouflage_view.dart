import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Discreet Camouflage calculator screen.
/// Instantly converts the app into an innocent calculator to protect seeker dignity in public.
class DiscreetCamouflageView extends StatefulWidget {
  final VoidCallback onExitCamouflage;

  const DiscreetCamouflageView({
    super.key,
    required this.onExitCamouflage,
  });

  @override
  State<DiscreetCamouflageView> createState() => _DiscreetCamouflageViewState();
}

class _DiscreetCamouflageViewState extends State<DiscreetCamouflageView> {
  String _display = '0';
  double _firstNum = 0;
  String _op = '';
  bool _shouldClear = false;

  void _onKey(String key) {
    setState(() {
      if (key == 'C') {
        _display = '0';
        _firstNum = 0;
        _op = '';
        _shouldClear = false;
      } else if (key == '+' || key == '-' || key == '×' || key == '÷') {
        _firstNum = double.tryParse(_display) ?? 0;
        _op = key;
        _shouldClear = true;
      } else if (key == '=') {
        final secondNum = double.tryParse(_display) ?? 0;
        double result = 0;
        switch (_op) {
          case '+':
            result = _firstNum + secondNum;
            break;
          case '-':
            result = _firstNum - secondNum;
            break;
          case '×':
            result = _firstNum * secondNum;
            break;
          case '÷':
            result = secondNum != 0 ? _firstNum / secondNum : 0;
            break;
          default:
            result = secondNum;
        }
        _display = result.toString().endsWith('.0')
            ? result.toInt().toString()
            : result.toStringAsFixed(2);
        _op = '';
        _shouldClear = true;
      } else {
        if (_display == '0' || _shouldClear) {
          _display = key;
          _shouldClear = false;
        } else {
          _display += key;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['C', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '=', '🔓'],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1C1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1A20),
        elevation: 0,
        title: const Text('Calculator', style: TextStyle(color: Colors.white70, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            tooltip: 'Return to PadCare',
            onPressed: widget.onExitCamouflage,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Text(
                  _display,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 54,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white12),
            for (final row in keys)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final k in row)
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: Material(
                          color: k == '🔓'
                              ? AppColors.primaryContainer
                              : (k == '÷' || k == '×' || k == '-' || k == '+' || k == '=')
                                  ? const Color(0xFFE87596)
                                  : const Color(0xFF2C2834),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              if (k == '🔓') {
                                widget.onExitCamouflage();
                              } else {
                                _onKey(k);
                              }
                            },
                            child: Center(
                              child: Text(
                                k,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
