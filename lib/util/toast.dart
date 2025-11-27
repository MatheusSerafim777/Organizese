import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

void MensagemErro(BuildContext context, String msg){
  MotionToast.error(
      title:  Text("Erro"),
      description:  Text(msg)
  ).show(context);
}


void MensagemAlerta(BuildContext context, String msg){
  MotionToast.warning(
      title:  Text("Atenção"),
      description:  Text(msg)
  ).show(context);
}

void MensagemSucesso(BuildContext context, String msg){
  MotionToast.success(
      title:  Text("Sucesso"),
      description:  Text(msg)
  ).show(context);
}
