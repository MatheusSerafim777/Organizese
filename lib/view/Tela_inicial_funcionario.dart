import 'package:flutter/material.dart';
import 'package:organizese/domain/Funcionario.dart';
import 'package:organizese/view/TelaCadastroContracheque.dart';
import 'package:organizese/view/TelaCadastroFalta.dart';
import 'package:organizese/view/TelaContrachequesFuncionario.dart';
import 'package:organizese/view/TelaFaltasFuncionario.dart';
import 'package:organizese/view/TelaFuncionario.dart';
import 'package:organizese/view/Tela_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaInicialFuncionario extends StatefulWidget {
  final Funcionario usuario;
  TelaInicialFuncionario(this.usuario);

  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicialFuncionario> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    switch (_selectedIndex) {
      case 0:
        currentPage = TelaFuncionario(usuario: widget.usuario);
        break;
      case 1:
        currentPage = TelaFaltasFuncionario(funcionario: widget.usuario);
        break;
      case 2:
        currentPage = TelaContrachequesFuncionario(funcionario: widget.usuario);
        break;
      default:
        currentPage = HomePage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Organize-se'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green[700],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), label: 'Minhas Falta'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Contracheque'),
        ],
      ),
    );
  }
}