import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Tax_commission extends StatefulWidget{
  const Tax_commission({super.key});

  @override
  State<Tax_commission> createState() => _Tax_commission();

}

class _Tax_commission extends State<Tax_commission>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tax and Commission"),
        centerTitle: true,
      )

    );
  }
}