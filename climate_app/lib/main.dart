import 'package:flutter/material.dart';



void main() {

  runApp(const MyApp());

}



class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Flutter Dart pro',

      theme: ThemeData(

        primarySwatch: Colors.blue,

        useMaterial3: true,

      ),

      home: const MyHomePage(),

    );

  }

}



class MyHomePage extends StatelessWidget {

  const MyHomePage({Key? key}) : super(key: key);



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('App de clima final (pruebas)'),

        centerTitle: true,

      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(

              '29°C',

              style: TextStyle(

                fontSize: 72,

                fontWeight: FontWeight.bold,

                color: Colors.red,

              ),

            ),

            const SizedBox(height: 16),

            const Text(

              'Querétaro',

              style: TextStyle(

                fontSize: 24,

                color: Colors.grey,

              ),

            ),

            const SizedBox(height: 32),

            const Icon(

              Icons.sunny,

              size: 120,

              color: Colors.blue,

            ),

          ],

        ),

      ),

    );

  }

}