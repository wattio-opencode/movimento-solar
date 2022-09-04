import 'dart:math';

import 'package:flutter/material.dart';
import 'package:movimento_solar/assets/ceu.dart';
import 'package:movimento_solar/assets/nuvem.dart';
import 'package:movimento_solar/assets/passaro.dart';
import 'package:movimento_solar/assets/sol.dart';
import 'package:movimento_solar/movimento.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movimento Solar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black12,
        ),
      ),
      home: const PaginaInicial(),
    );
  }
}

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial>
    with TickerProviderStateMixin {
  late final controlador6s = AnimationController(
    duration: const Duration(seconds: 6),
    vsync: this,
  );
  late final controlador12s = AnimationController(
    duration: const Duration(seconds: 12),
    vsync: this,
  );
  late final int nPassaros;
  late final int nNuvens;
  final List<double> passarosOffsetY = [];
  final List<double> passarosOffsetX = [];
  final List<double> nuvensOffsetY = [];
  final List<double> nuvensOffsetX = [];
  bool amanheceu = false;
  @override
  void initState() {
    final rand = Random();
    randomBirdsAndClouds();
    // distribuição de offsets de espaçamento dos pássaros
    for (int i = 0; i < nPassaros; i++) {
      passarosOffsetY.add(0.4 * rand.nextDouble());
      // valor entre 0 e 0.4
      passarosOffsetX.add(0.5 * rand.nextDouble());
      // valor entre 0 e 0.5
    }

    // distribuição de espaços das nuvens
    for (int i = 0; i < nNuvens; i++) {
      nuvensOffsetY.add(0.4 * rand.nextDouble());
      nuvensOffsetX.add(0.8 * rand.nextDouble());
    }

    // fazendo com que o controlador redesenhe a tela sempre
    // e diga se amanheceu ou não, para mostrar ou não os pássaros e nuvens
    controlador6s.addListener(() => setState(() {
          if (controlador6s.value > 0.5) amanheceu = true;
        }));

    // fazendo com que os controladores reiniciem sempre que chegarem ao final
    controlador6s.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controlador6s.reset();
        controlador6s.forward();
      }
    });
    controlador12s.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controlador12s.reset();
        controlador12s.forward();
      }
    });

    // iniciando
    controlador6s.forward();
    controlador12s.forward();
    super.initState();
  }

  @override
  void dispose() {
    controlador6s.dispose();
    controlador12s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Ceu(controlador: controlador6s),
          sol(),
          ...passaros(),
          ...nuvens(),
        ],
      ),
    );
  }

  void randomBirdsAndClouds() {
    final rand = Random();
    nPassaros = (3 + rand.nextInt(17));
    nNuvens = (2 + rand.nextInt(8));
  }

  Widget sol() {
    // sol possui movimento em Y, X é estático
    return Movimento(
      repetir: false,
      controlador: controlador6s,
      posX: (valor) => 0.7,
      posY: (valor) => valor * 0.85,
      child: Sol(controlador: controlador6s),
    );
  }

  List<Widget> passaros() => [
        for (int i = 0; i < nPassaros; i++)
          // passaros se movimentam linearmente em X,
          // com um offset de espaçamento horizontal para cada um
          // passaros tem o Y fixo,
          // cada um com um offset de espaçamento vertical
          Visibility(
            visible: amanheceu,
            child: Movimento(
              posX: (valor) => valor + passarosOffsetX[i],
              // valor é o que vem do controlador, que varia de 0 a 1;
              posY: (valor) => 0.4 + passarosOffsetY[i],
              // espalha os pássaros no eixo Y,
              // com o mais baixo em 40% da altura
              // e cada um com seu offset de altura;
              repetir: true,
              controlador: controlador6s,
              child: const Passaro(),
            ),
          )
      ];
  List<Widget> nuvens() => [
        for (int i = 0; i < nNuvens; i++)
          Visibility(
            visible: amanheceu,
            child: Movimento(
              posX: (valor) => valor + nuvensOffsetX[i],
              posY: (valor) => 0.5 + nuvensOffsetY[i],
              repetir: true,
              controlador: controlador12s,
              child: const Nuvem(),
            ),
          )
      ];
}
