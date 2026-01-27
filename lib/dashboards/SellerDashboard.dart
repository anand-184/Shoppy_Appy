import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SellerDashboardScreen extends StatefulWidget{
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seller Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blue,

      )
    );
  }

}