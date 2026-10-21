
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

class _CalculatorScreenState extends State<CalculatorScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstController = TextEditingController();
  final TextEditingController secondController = TextEditingController();

  String display = '0';
  String expression = '';
  String? selectedOperator;
  String? previewResult;
  bool secondOperandStarted = false;

  @override
  void dispose() {
    firstController.dispose();
    secondController.dispose();
    super.dispose();
  }

  void pressButton(String value) {
    setState(() {
      if (value == 'C') {
        display = '0';
        expression = '';
        selectedOperator = null;
        previewResult = null;
        secondOperandStarted = false;
        firstController.clear();
        secondController.clear();
      } else if (value == '⌫') {
        if (display == 'Error' ||
            display == 'Cannot divide by zero') {
          display = '0';
        } else if (display.length > 1) {
          display = display.substring(0, display.length - 1);
        } else {
          display = '0';
        }

        if (selectedOperator != null) {
          secondOperandStarted = display != '0';
        }
      } else if (value == '=') {
        calculateFromKeypad();
      } else if (['+', '−', '×', '÷'].contains(value)) {
        if (display == 'Error' ||
            display == 'Cannot divide by zero') {
          return;
        }

        // Use the current number as the first operand.
        expression = '$display $value';
        selectedOperator = value;
        display = '0';
        previewResult = null;
        secondOperandStarted = false;
      } else if (value == '.') {
        if (!display.contains('.')) {
          display += '.';
          if (selectedOperator != null) {
            secondOperandStarted = true;
          }
        }
      } else {
        if (display == '0' ||
            display == 'Error' ||
            display == 'Cannot divide by zero') {
          display = value;
        } else {
          display += value;
        }

        if (selectedOperator != null) {
          secondOperandStarted = true;
        }
      }

      // Update the answer before the user presses equals.
      if (value != '=' && selectedOperator != null) {
        updateLivePreview();
      }
    });
  }

  void updateLivePreview() {
    previewResult = null;

    if (!secondOperandStarted ||
        selectedOperator == null ||
        expression.isEmpty) {
      return;
    }

    final parts = expression.split(' ');
    if (parts.isEmpty) return;

    final first = double.tryParse(parts.first);
    final second = double.tryParse(display);

    if (first == null || second == null) return;

    double result;

    switch (selectedOperator) {
      case '+':
        result = first + second;
        break;
      case '−':
        result = first - second;
        break;
      case '×':
        result = first * second;
        break;
      case '÷':
        if (second == 0) {
          expression =
              '${formatResult(first)} $selectedOperator $display';
          return;
        }
        result = first / second;
        break;
      default:
        return;
    }

    expression =
        '${formatResult(first)} $selectedOperator $display';
    previewResult = formatResult(result);
  }

  void calculateFromKeypad() {
    if (selectedOperator == null || expression.isEmpty) return;

    final parts = expression.split(' ');
    final first = double.tryParse(parts.first);
    final second = double.tryParse(display);

    if (first == null || second == null) {
      display = 'Error';
      previewResult = null;
      return;
    }

    double result;

    switch (selectedOperator) {
      case '+':
        result = first + second;
        break;
      case '−':
        result = first - second;
        break;
      case '×':
        result = first * second;
        break;
      case '÷':
        if (second == 0) {
          display = 'Cannot divide by zero';
          expression = '';
          selectedOperator = null;
          previewResult = null;
          secondOperandStarted = false;
          return;
        }
        result = first / second;
        break;
      default:
        return;
    }

    expression =
        '${formatResult(first)} $selectedOperator ${formatResult(second)} =';

    display = formatResult(result);
    selectedOperator = null;
    previewResult = null;
    secondOperandStarted = false;
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

  void calculateFromForm() {
    if (!formKey.currentState!.validate()) return;

    if (selectedOperator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an operation first.'),
        ),
      );
      return;
    }

    final first = double.parse(firstController.text.trim());
    final second = double.parse(secondController.text.trim());

    if (selectedOperator == '÷' && second == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot divide by zero.'),
        ),
      );
      return;
    }

    double result;

    switch (selectedOperator) {
      case '+':
        result = first + second;
        break;
      case '−':
        result = first - second;
        break;
      case '×':
        result = first * second;
        break;
      case '÷':
        result = first / second;
        break;
      default:
        return;
    }

    setState(() {
      expression =
          '${firstController.text.trim()} $selectedOperator ${secondController.text.trim()} =';
      display = formatResult(result);
      previewResult = null;
    });
  }

  Widget numberField(
    String label,
    TextEditingController controller,
  ) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Calculator',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clear',
            onPressed: () => pressButton('C'),
            icon: const Icon(
              Icons.refresh_rounded,
              color: darkText,
            ),
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
                    Text(
                      expression.isEmpty
                          ? 'Ready to calculate'
                          : expression,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        previewResult ?? display,
                        style: const TextStyle(
                          color: lightPurple,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
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
                style: TextStyle(
                  color: Color(0xFF9586A5),
                  fontSize: 13,
                ),
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
                        for (final op in ['+', '−', '×', '÷'])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedOperator = op;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      selectedOperator == op
                                          ? lightPurple
                                          : Colors.white,
                                  foregroundColor:
                                      selectedOperator == op
                                          ? Colors.white
                                          : lightPurple,
                                  side: const BorderSide(
                                    color: palePurple,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
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
