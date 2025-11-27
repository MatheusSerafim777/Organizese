import 'package:flutter/material.dart';

class CampoInput extends StatelessWidget {
  String texto_label;
  String texto_placehoader;
  bool  passaword;
  TextEditingController? controlador;
  FormFieldValidator<String>? validador;
  TextInputType teclado;

  CampoInput(
      this.texto_label,
      {super.key, this.texto_placehoader = "",
        this.passaword = false,
        this.controlador,
        this.validador,
        this.teclado = TextInputType.text
      }){
    validador ??= (String? text){
        if(text!.isEmpty) {
          return "O campo '$texto_label' está vazio e necessita ser preenchido";
        }
        return null;
      };
  }


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validador,
      obscureText: passaword,
      controller: controlador,
      keyboardType: teclado,
      textInputAction: TextInputAction.next,
      // Estilo da fonte
      style: TextStyle(
        fontSize: 25,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        labelText: texto_label,
        // Estilo de labelText
        labelStyle: TextStyle(
          fontSize: 25,
          color: Colors.grey,
        ),
        hintText: texto_placehoader,
        // Estilo do hintText
        hintStyle: TextStyle(
          fontSize: 10,
          color: Colors.black,
        ),
      ),
    );
  }


}
