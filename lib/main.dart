import 'package:flutter/material.dart';
import 'dart:math';
import 'package:expressions/expressions.dart';  // Importação do pacote

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo Multiuso',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: const Adivinhacao(title: 'Jogo de adivinhação'),
    );
  }
}

class Adivinhacao extends StatefulWidget {
  const Adivinhacao({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _AdivinhacaoPageState();
}

class _AdivinhacaoPageState extends State<Adivinhacao> {
  final Random random = Random();
  late int numero_secreto;
  int tentativas = 8;
  int numero_tentativa = 0;

  bool isDisabled = false;

  TextEditingController controladorNumero = TextEditingController();
  TextEditingController controladorMensagem = TextEditingController();
  TextEditingController controladorTentativa = TextEditingController();

  List<int> numerosTentativas = [];

  @override
  void initState() {
    super.initState();
    numero_secreto = random.nextInt(100); // Número secreto entre 0 e 99
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Digite um número:'),
              TextField(controller: controladorNumero),
              ElevatedButton(
                onPressed: isDisabled ? null : tentativa,
                child: const Text('Ok'),
              ),
              TextField(
                controller: controladorTentativa,
                style: Theme.of(context).textTheme.headlineSmall,
                readOnly: true,
              ),
              TextField(
                controller: controladorMensagem,
                style: Theme.of(context).textTheme.headlineSmall,
                readOnly: true,
              ),

              // navegar para tentativas
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TentativasPage(
                        numerosTentativas: numerosTentativas,
                      ),
                    ),
                  );
                },
                child: const Text('Ver Tentativas'),
              ),

              // navegar para calculadora
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalculadoraPage(),
                    ),
                  );
                },
                child: const Text('Ir para Calculadora'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void tentativa() {
    int numero;

    if (controladorNumero.text.isNotEmpty) {
      numero = int.tryParse(controladorNumero.text)!;
      numerosTentativas.add(numero); 

      if (numero == numero_secreto) {
        controladorMensagem.text = 'Parabéns, você acertou!';
        setState(() {
          isDisabled = true;
        });
      } else if (numero > numero_secreto) {
        controladorMensagem.text = 'Maior que o número secreto!';
      } else {
        controladorMensagem.text = 'Menor que o número secreto!';
      }

      tentativas--;
      controladorTentativa.text = 'Tentativas: $tentativas';

      if (tentativas == 0) {
        controladorMensagem.text = 'Tentativas esgotadas';
        setState(() {
          isDisabled = true;
        });
        controladorNumero.clear();
      }
    }
  }
}

class TentativasPage extends StatelessWidget {
  final List<int> numerosTentativas;

  const TentativasPage({Key? key, required this.numerosTentativas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Números Tentados'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Números que você tentou:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: numerosTentativas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Tentativa ${index + 1}: ${numerosTentativas[index]}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Volta para a tela principal
              },
              child: const Text('Voltar para o Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  @override
  _CalculadoraPageState createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  String _input = "";
  String _output = "0";

  void _buttonPressed(String text) {
    setState(() {
      if (text == "C") {
        _input = "";
        _output = "0";
      } else if (text == "=") {
        try {
          _output = _calculate(_input);
        } catch (e) {
          _output = "Erro";
        }
      } else {
        _input += text;
      }
    });
  }

  String _calculate(String input) {
    try {
      final expression = Expression.parse(input);
      final evaluator = const ExpressionEvaluator();
      var result = evaluator.eval(expression, {});
      return result.toString();
    } catch (e) {
      return "Erro";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.centerRight,
              child: Text(
                _input,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.centerRight,
              child: Text(
                _output,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildButtonRow("7", "8", "9", "/"),
                _buildButtonRow("4", "5", "6", "*"),
                _buildButtonRow("1", "2", "3", "-"),
                _buildButtonRow("C", "0", "=", "+"),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Volta para a tela principal
            },
            child: const Text('Voltar para o Jogo'),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(String button1, String button2, String button3, String button4) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildButton(button1),
          _buildButton(button2),
          _buildButton(button3),
          _buildButton(button4),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _buttonPressed(text),
        child: Text(text, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
