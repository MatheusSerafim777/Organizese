import 'package:flutter/material.dart';
import 'package:organizese/util/widgets/campo_botao.dart';
import 'package:organizese/util/widgets/campo_input.dart';
import 'package:organizese/view/controle_interacao/controle_tela_cadastrar.dart';
import 'package:organizese/domain/cargo.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  late ControladorTelaCadastro _controle;

  @override
  void initState() {
    super.initState();
    _controle = ControladorTelaCadastro();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar")),
      body: _body(),
    );
  }

  Widget _body() {
    return FutureBuilder<List<Cargo>>(
      future: _controle.cargosDisponiveis,
      builder: (context, snapshot) {
        // Mostra loading enquanto carrega os cargos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Se houve erro, mostra mensagem
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar cargos: ${snapshot.error}'),
          );
        }

        // Lista de cargos carregada com sucesso
        final cargos = snapshot.data ?? [];

        return Form(
      key: _controle.formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            CampoInput(
              "Nome",
              texto_placehoader: "Como quer ser chamado?",
              controlador: _controle.controladorNome,
            ),
            const SizedBox(height: 20),
            CampoInput(
              "Email",
              texto_placehoader: "seuemail@exemplo.com",
              controlador: _controle.controladorEmail,
              // formatação de e-mail fica a cargo do seu EmailValidator
              validador: (v) {
                if (v == null || v.trim().isEmpty) return "Informe o email";
                return null;
              },
            ),
            const SizedBox(height: 20),
            CampoInput(
              "Senha",
              passaword: true,
              controlador: _controle.controladorSenha,
              validador: (v) {
                if (v == null || v.length < 6) return "Mínimo de 6 caracteres";
                return null;
              },
            ),
            const SizedBox(height: 20),
            CampoInput(
              "Confirmar senha",
              passaword: true,
              controlador: _controle.controladorConfirmarSenha,
              validador: (v) {
                if (v == null || v.isEmpty) return "Confirme a senha";
                if (v != _controle.controladorSenha.text) {
                  return "As senhas não coincidem";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            // Dropdown para seleção de cargo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Cargo",
                  border: InputBorder.none,
                ),
                initialValue: _controle.cargoSelecionado?.id,
                items: cargos.map((cargo) {
                  return DropdownMenuItem<String>(
                    value: cargo.id,
                    child: Text(cargo.nome),
                  );
                }).toList(),
                onChanged: (String? cargoId) {
                  if (cargoId != null) {
                    final cargo = cargos.firstWhere((c) => c.id == cargoId);
                    setState(() {
                      _controle.selecionarCargo(cargo);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Selecione um cargo";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            CampoInput(
              "Idade",
              texto_placehoader: "Ex.: 28",
              controlador: _controle.controladorIdade,
            ),
            const SizedBox(height: 20),
            CampoInput(
              "CPF",
              texto_placehoader: "Somente números (11 dígitos)",
              controlador: _controle.controladorCpf,
            ),

            const SizedBox(height: 20),
            Botao(
              texto: "Cadastrar",
              cor: Colors.black,
              aoClicar: () => _controle.cadastrar(context),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
