import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pastel Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9981BD)),
        scaffoldBackgroundColor: const Color(0xFFF8F4EF),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  double? _first;
  String? _operator;
  bool _newEntry = true;
  bool _error = false;

  void _clear() {
    _display = '0';
    _expression = '';
    _first = null;
    _operator = null;
    _newEntry = true;
    _error = false;
  }

  String _format(double value) {
    if (value == 0) return '0';
    return double.parse(value.toStringAsPrecision(12))
        .toString()
        .replaceFirst(RegExp(r'\.0$'), '');
  }

  bool _calculate() {
    final second = double.parse(_display);
    if (_operator == '÷' && second == 0) {
      _display = 'Cannot divide by zero';
      _error = true;
      _first = null;
      _operator = null;
      _newEntry = true;
      return false;
    }
    final result = switch (_operator) {
      '+' => _first! + second,
      '−' => _first! - second,
      '×' => _first! * second,
      '÷' => _first! / second,
      _ => second,
    };
    if (!result.isFinite) {
      _display = 'Result is too large';
      _error = true;
      _first = null;
      _operator = null;
      _newEntry = true;
      return false;
    }
    _display = _format(result);
    return true;
  }

  void _press(String key) {
    setState(() {
      if (key == 'AC') {
        _clear();
        return;
      }
      if (_error) _clear();
      if ('0123456789.'.contains(key)) {
        if (_newEntry) {
          _display = key == '.' ? '0.' : key;
          _newEntry = false;
          if (_operator == null) _expression = '';
        } else if (key == '.') {
          if (!_display.contains('.')) _display += '.';
        } else if (_display.replaceAll(RegExp(r'[-.]'), '').length < 12) {
          _display = _display == '0' ? key : _display + key;
        }
      } else if (key == '±') {
        if (_newEntry && _operator != null) {
          _display = '-0';
          _newEntry = false;
        } else {
          _display = _display.startsWith('-')
              ? _display.substring(1)
              : '-$_display';
        }
      } else if (key == '⌫') {
        if (!_newEntry) {
          _display = _display.length > 1
              ? _display.substring(0, _display.length - 1)
              : '0';
          if (_display == '-') _display = '0';
        }
      } else if (key == '=') {
        if (_operator == null || _newEntry) return;
        _expression = '${_format(_first!)} $_operator $_display =';
        if (!_calculate()) return;
        _operator = null;
        _first = null;
        _newEntry = true;
      } else {
        if (_operator != null && !_newEntry && !_calculate()) return;
        _first = double.parse(_display);
        _operator = key;
        _expression = '$_display $key';
        _newEntry = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF494353);
    const rows = [
      ['AC', '±', '⌫', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Calculator',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: ink,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A simple little calculator :p',
                    style: TextStyle(color: Color(0xFF787180)),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EDDF),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _expression.isEmpty ? ' ' : _expression,
                          style: const TextStyle(
                            color: Color(0xFF66725F),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          liveRegion: true,
                          label: 'Result',
                          child: SizedBox(
                            height: 62,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _display,
                                key: const Key('result'),
                                style: TextStyle(
                                  fontSize: _error ? 25 : 52,
                                  fontWeight: FontWeight.w500,
                                  color: ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final row in rows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          for (var i = 0; i < row.length; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(
                              flex: row[i] == '0' ? 2 : 1,
                              child: _button(row[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _button(String label) {
    final isOperator = ['÷', '×', '−', '+'].contains(label);
    final isUtility = ['AC', '±', '⌫'].contains(label);
    final color = label == '='
        ? const Color(0xFFCEC0E8)
        : isOperator
        ? const Color(0xFFE6DDF3)
        : isUtility
        ? const Color(0xFFF4DDD2)
        : const Color(0xFFFFFCF8);
    const names = {
      'AC': 'Clear all',
      '±': 'Change sign',
      '⌫': 'Delete last digit',
      '÷': 'Divide',
      '×': 'Multiply',
      '−': 'Subtract',
      '+': 'Add',
      '=': 'Equals',
      '.': 'Decimal point',
    };
    return SizedBox(
      height: 64,
      child: FilledButton(
        key: ValueKey('key_$label'),
        onPressed: () => _press(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color(0xFF494353),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isOperator && _operator == label
                ? const BorderSide(color: Color(0xFF9981BD), width: 2)
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          semanticsLabel: names[label] ?? label,
          style: TextStyle(fontSize: label == 'AC' ? 18 : 26),
        ),
      ),
    );
  }
}
