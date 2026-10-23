import 'package:flutter/material.dart';
import '../widgets/calculator_button.dart';

const Color lightPurple = Color(0xFFB99AE8);
const Color palePurple = Color(0xFFF0E7FF);
const Color pink = Color(0xFFFFB8D2);
const Color darkText = Color(0xFF655477);

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstController = TextEditingController();
  final TextEditingController secondController = TextEditingController();

  // ----- Cursor blink controller -----
  late AnimationController _cursorController;

  // ----- Calculator state -----
  String display = '0';
  String expression = '';
  String? previewResult;
  double? storedValue;
  String? selectedOperator;
  bool waitingForOperand = false;
  bool justCalculated = false;

  double? lastOperand;
  String? lastOperator;

  String? formOperator;
  final List<String> operators = ['+', '−', '×', '÷'];

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    firstController.dispose();
    secondController.dispose();
    super.dispose();
  }

  bool get hasError =>
      display == 'Error' || display == 'Cannot divide by zero';

  void resetAll() {
    display = '0';
    expression = '';
    previewResult = null;
    storedValue = null;
    selectedOperator = null;
    waitingForOperand = false;
    justCalculated = false;
    lastOperand = null;
    lastOperator = null;
  }

  String formatResult(double value) {
    if (!value.isFinite) return 'Error';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsPrecision(10)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double? performCalculation(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '−':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return null;
        return a / b;
      default:
        return null;
    }
  }

  void pressButton(String value) {
    setState(() {
      if (value == 'C') {
        resetAll();
        firstController.clear();
        secondController.clear();
        formOperator = null;
      } else if (value == '⌫') {
        _onBackspace();
      } else if (value == '=') {
        _onEquals();
      } else if (operators.contains(value)) {
        _onOperator(value);
      } else if (value == '.') {
        _onDecimal();
      } else if (RegExp(r'^\d$').hasMatch(value)) {
        _onDigit(value);
      }
    });
  }

  void _onDigit(String digit) {
    if (hasError) {
      resetAll();
      display = digit;
      return;
    }

    if (justCalculated) {
      resetAll();
      display = digit;
      return;
    }

    if (waitingForOperand) {
      display = digit;
      waitingForOperand = false;
    } else if (display == '0') {
      display = digit;
    } else {
      display += digit;
    }

    _refreshExpression();
  }

  void _onDecimal() {
    if (hasError) {
      resetAll();
      display = '0.';
      return;
    }

    if (justCalculated) {
      resetAll();
      display = '0.';
      return;
    }

    if (waitingForOperand) {
      display = '0.';
      waitingForOperand = false;
    } else if (!display.contains('.')) {
      display += '.';
    }

    _refreshExpression();
  }

  void _onOperator(String op) {
    if (hasError) return;

    final current = double.tryParse(display);
    if (current == null) return;

    if (justCalculated) {
      storedValue = current;
      selectedOperator = op;
      expression = '${formatResult(current)} $op';
      previewResult = null;
      waitingForOperand = true;
      justCalculated = false;
      lastOperand = null;
      lastOperator = null;
      return;
    }

    if (selectedOperator != null &&
        !waitingForOperand &&
        storedValue != null) {
      final result = performCalculation(
          storedValue!, current, selectedOperator!);
      if (result == null || !result.isFinite) {
        _showError();
        return;
      }
      display = formatResult(result);
      storedValue = result;
    } else if (selectedOperator == null) {
      storedValue = current;
    }

    selectedOperator = op;
    expression = '${formatResult(storedValue!)} $op';
    previewResult = null;
    waitingForOperand = true;
    justCalculated = false;
    lastOperand = null;
    lastOperator = null;
  }

  // ===== SMART BACKSPACE (cursor ki tarah, ek digit) =====
  void _onBackspace() {
    if (hasError) {
      resetAll();
      return;
    }

    // "=" ke baad backspace → poora reset
    if (justCalculated) {
      resetAll();
      return;
    }

    // Operator ke baad, naya number type hone se pehle
    if (waitingForOperand) {
      if (storedValue != null) {
        display = formatResult(storedValue!);
      }
      selectedOperator = null;
      expression = '';
      previewResult = null;
      waitingForOperand = false;
      storedValue = null;
      return;
    }

    // Display mein multiple characters hain → ek character delete
    if (display.length > 1) {
      display = display.substring(0, display.length - 1);
      if (display == '-' || display.isEmpty) display = '0';
      _refreshExpression();
      return;
    }

    // Display mein sirf 1 character ya '0' hai
    if (storedValue != null && selectedOperator != null) {
      display = formatResult(storedValue!);
      selectedOperator = null;
      expression = '';
      previewResult = null;
      storedValue = null;
      return;
    }

    display = '0';
    expression = '';
    previewResult = null;
  }

  void _onEquals() {
    if (hasError) return;

    if (selectedOperator == null) {
      if (justCalculated && lastOperator != null && lastOperand != null) {
        final current = double.tryParse(display);
        if (current == null) return;

        final result =
            performCalculation(current, lastOperand!, lastOperator!);
        if (result == null || !result.isFinite) {
          _showError();
          return;
        }

        display = formatResult(result);
        expression = '';
        previewResult = null;
        justCalculated = true;
      }
      return;
    }

    if (storedValue == null) return;

    final second =
        waitingForOperand ? storedValue! : double.tryParse(display);
    if (second == null) {
      _showError();
      return;
    }

    final first = storedValue!;
    final op = selectedOperator!;

    if (op == '÷' && second == 0) {
      display = 'Cannot divide by zero';
      expression = '';
      previewResult = null;
      storedValue = null;
      selectedOperator = null;
      waitingForOperand = false;
      justCalculated = true;
      lastOperator = null;
      lastOperand = null;
      return;
    }

    final result = performCalculation(first, second, op);
    if (result == null || !result.isFinite) {
      _showError();
      return;
    }

    display = formatResult(result);
    expression = '';
    previewResult = null;

    lastOperator = op;
    lastOperand = second;
    storedValue = null;
    selectedOperator = null;
    waitingForOperand = false;
    justCalculated = true;
  }

  void _refreshExpression() {
    previewResult = null;

    if (selectedOperator == null || storedValue == null) {
      expression = '';
      return;
    }

    if (waitingForOperand) {
      expression = '${formatResult(storedValue!)} $selectedOperator';
      return;
    }

    expression = '${formatResult(storedValue!)} $selectedOperator $display';

    final current = double.tryParse(display);
    if (current == null) return;
    if (selectedOperator == '÷' && current == 0) return;

    final result =
        performCalculation(storedValue!, current, selectedOperator!);
    if (result != null && result.isFinite) {
      previewResult = formatResult(result);
    }
  }

  void _showError() {
    display = 'Error';
    expression = '';
    previewResult = null;
    storedValue = null;
    selectedOperator = null;
    waitingForOperand = false;
    justCalculated = true;
    lastOperator = null;
    lastOperand = null;
  }

  void calculateFromForm() {
    if (!formKey.currentState!.validate()) return;

    if (formOperator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an operation first.')),
      );
      return;
    }

    final first = double.tryParse(firstController.text.trim());
    final second = double.tryParse(secondController.text.trim());
    if (first == null || second == null) return;

    if (formOperator == '÷' && second == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot divide by zero.')),
      );
      return;
    }

    final result = performCalculation(first, second, formOperator!);
    if (result == null || !result.isFinite) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to calculate this result.')),
      );
      return;
    }

    setState(() {
      resetAll();
      display = formatResult(result);
      justCalculated = true;
    });
  }

  Widget numberField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter a number',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a number';
        }
        if (double.tryParse(value.trim()) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  // ===== Cursor blinking =====
  Widget _cursor() {
    return FadeTransition(
      opacity: _cursorController,
      child: Container(
        width: 2,
        height: 38,
        color: lightPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Answer ke saath cursor
    final String answerText =
        justCalculated ? display : (previewResult ?? display);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Calculator',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clear',
            onPressed: () => pressButton('C'),
            icon: const Icon(Icons.refresh_rounded, color: darkText),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: lightPurple.withAlpha(35),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'YOUR CALCULATION',
                      style: TextStyle(
                        color: lightPurple,
                        fontSize: 12,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (!justCalculated && expression.isNotEmpty) ...[
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          expression,
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // ===== Answer + cursor =====
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              answerText,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: lightPurple,
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            _cursor(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  CalculatorButton(
                    label: 'C',
                    background: const Color(0xFFFFE4EF),
                    foreground: const Color(0xFFC65F8D),
                    onPressed: () => pressButton('C'),
                  ),
                  CalculatorButton(
                    label: '⌫',
                    background: palePurple,
                    foreground: lightPurple,
                    onPressed: () => pressButton('⌫'),
                  ),
                  CalculatorButton(
                    label: '÷',
                    background: palePurple,
                    foreground: lightPurple,
                    onPressed: () => pressButton('÷'),
                  ),
                  CalculatorButton(
                    label: '×',
                    background: palePurple,
                    foreground: lightPurple,
                    onPressed: () => pressButton('×'),
                  ),
                ],
              ),
              Row(
                children: [
                  for (final digit in ['7', '8', '9'])
                    CalculatorButton(
                      label: digit,
                      onPressed: () => pressButton(digit),
                    ),
                  CalculatorButton(
                    label: '−',
                    background: palePurple,
                    foreground: lightPurple,
                    onPressed: () => pressButton('−'),
                  ),
                ],
              ),
              Row(
                children: [
                  for (final digit in ['4', '5', '6'])
                    CalculatorButton(
                      label: digit,
                      onPressed: () => pressButton(digit),
                    ),
                  CalculatorButton(
                    label: '+',
                    background: palePurple,
                    foreground: lightPurple,
                    onPressed: () => pressButton('+'),
                  ),
                ],
              ),
              Row(
                children: [
                  for (final digit in ['1', '2', '3'])
                    CalculatorButton(
                      label: digit,
                      onPressed: () => pressButton(digit),
                    ),
                  CalculatorButton(
                    label: '=',
                    background: pink,
                    foreground: Colors.white,
                    onPressed: () => pressButton('='),
                  ),
                ],
              ),
              Row(
                children: [
                  CalculatorButton(
                    label: '0',
                    flex: 2,
                    onPressed: () => pressButton('0'),
                  ),
                  CalculatorButton(
                    label: '.',
                    onPressed: () => pressButton('.'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Quick Calculation Form',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter two numbers and select an operation.',
                style: TextStyle(color: Color(0xFF9586A5), fontSize: 13),
              ),
              const SizedBox(height: 16),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    numberField('First Number', firstController),
                    const SizedBox(height: 14),
                    numberField('Second Number', secondController),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        for (final op in operators)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() => formOperator = op);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: formOperator == op
                                      ? lightPurple
                                      : Colors.white,
                                  foregroundColor: formOperator == op
                                      ? Colors.white
                                      : lightPurple,
                                  side: const BorderSide(color: palePurple),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  op,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: calculateFromForm,
                        icon: const Icon(Icons.calculate_rounded),
                        label: const Text(
                          'Calculate Result',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}