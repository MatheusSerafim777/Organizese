import 'package:flutter/material.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/view/tela_cadastrar.dart';
import 'package:organizese/view/tela_cadastro_contracheque.dart';
import 'package:organizese/view/tela_cadastro_falta.dart';
import 'package:organizese/view/tela_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:organizese/view/tela_login.dart';

class TelaInicial01 extends StatefulWidget {
  final Funcionario usuario;
  TelaInicial01(this.usuario);

  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial01> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_selectedIndex) {
      case 0:
        currentPage = HomePage();
        break;
      case 1:
        currentPage = TelaCadastroFalta();
        break;
      case 2:
        currentPage = TelaCadastroContracheque();
        break;
      case 3:
        currentPage = TelaCadastro();
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
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Telalogin()),
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
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Faltas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Contracheque',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Cadastro',
          ),
        ],
      ),
    );
  }
}
