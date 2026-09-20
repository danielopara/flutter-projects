import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.notes, size: 25, color: Colors.white),
        toolbarHeight: 30,
        elevation: 0,
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.info, size: 25, color: Colors.white),
          ),
        ],
      ),
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(100),
                ),
              ),
              // child: ,
            ),
          ],
        ),
      ),
    );
  }
}
