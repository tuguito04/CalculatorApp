import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ScientificCalculator());
}

class ScientificCalculator extends StatelessWidget {
  const ScientificCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora Científica',
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _output = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _input = '';
        _output = '';
      } else if (value == '=') {
        try {
          _output = _evaluateExpression(_input);
        } catch (e) {
          _output = 'Error';
        }
      } else {
        _input += value;
      }
    });
  }

  String _evaluateExpression(String expression) {
    try {
      expression = expression.replaceAll('×', '*').replaceAll('÷', '/');

      if (expression.contains('sin')) {
        return sin(_parseExpression(expression, 'sin') * (pi / 180)).toString();
      } else if (expression.contains('cos')) {
        return cos(_parseExpression(expression, 'cos') * (pi / 180)).toString();
      } else if (expression.contains('tan')) {
        return tan(_parseExpression(expression, 'tan') * (pi / 180)).toString();
      } else if (expression.contains('log')) {
        return log(_parseExpression(expression, 'log')).toString();
      } else if (expression.contains('√')) {
        return sqrt(_parseExpression(expression, '√')).toString();
      } else if (expression.contains('^')) {
        List<String> parts = expression.split('^');
        return pow(double.parse(parts[0]), double.parse(parts[1])).toString();
      }

      return _calculateBasic(expression).toString();
    } catch (e) {
      return 'Error';
    }
  }

  double _parseExpression(String expression, String function) {
    String number = expression.replaceAll(function, '');
    return double.tryParse(number) ?? 0;
  }

  double _calculateBasic(String expression) {
    try {
      return _evaluateMathExpression(expression);
    } catch (e) {
      return double.nan;
    }
  }

  double _evaluateMathExpression(String expr) {
    expr = expr.replaceAll(' ', '');

    RegExp regex = RegExp(r'(\d+\.?\d*)|([+\-*/])');
    List<String> tokens = regex.allMatches(expr).map((e) => e.group(0)!).toList();

    if (tokens.isEmpty) return double.nan;

    List<double> numbers = [];
    List<String> operators = [];

    for (var token in tokens) {
      if (double.tryParse(token) != null) {
        numbers.add(double.parse(token));
      } else {
        while (operators.isNotEmpty && _precedence(operators.last) >= _precedence(token)) {
          _applyOperator(numbers, operators.removeLast());
        }
        operators.add(token);
      }
    }

    while (operators.isNotEmpty) {
      _applyOperator(numbers, operators.removeLast());
    }

    return numbers.isNotEmpty ? numbers.first : double.nan;
  }

  int _precedence(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  void _applyOperator(List<double> numbers, String op) {
    if (numbers.length < 2) return;
    double b = numbers.removeLast();
    double a = numbers.removeLast();
    switch (op) {
      case '+':
        numbers.add(a + b);
        break;
      case '-':
        numbers.add(a - b);
        break;
      case '*':
        numbers.add(a * b);
        break;
      case '/':
        numbers.add(b != 0 ? a / b : double.nan);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora Científica')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_input, style: const TextStyle(fontSize: 24)),
                  Text(_output, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
            ),
            itemCount: buttons.length,
            itemBuilder: (context, index) {
              return CalculatorButton(
                text: buttons[index],
                onPressed: () => _onButtonPressed(buttons[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CalculatorButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(20),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}

final List<String> buttons = [
  'C', '√', '^', '÷',
  '7', '8', '9', '×',
  '4', '5', '6', '-',
  '1', '2', '3', '+',
  '0', '.', '=', 'sin',
  'cos', 'tan', 'log'
];
