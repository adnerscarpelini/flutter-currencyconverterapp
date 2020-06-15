import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

//URL da API que busca as cotações de Dólar, Euro...
const request = "https://api.hgbrasil.com/finance?format=jsson&key=80df7608";

void main() async {
  runApp(MaterialApp(
    home: Home(),

    //ADNER: Criação de um tema customizado
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

//ADNER: Future porque é assíncrono
//Map é arquivo Json mapeado
Future<Map> getData() async {
  //Consulta a API de forma assíncrona
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //ADNER: Os controladores serve para pegar os valores dos campos da tela
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  //ADNER: Eventos dos campos de texto
  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text =
        (real / dolar).toStringAsFixed(2); //Mostra só duas casas"
    euroController.text =
        (real / euro).toStringAsFixed(2); //Mostra só duas casas"
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text =
        (dolar * this.dolar).toStringAsFixed(2); //Mostra só duas casas"
    euroController.text =
        (dolar * this.dolar / euro).toStringAsFixed(2); //Mostra só duas casas"
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text =
        (euro * this.euro).toStringAsFixed(2); //Mostra só duas casas"
    dolarController.text =
        (euro * this.euro / dolar).toStringAsFixed(2); //Mostra só duas casas"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      //ADNER: FutureBuilder permite adicionar um 'loading' na página
      body: FutureBuilder<Map>(
          future: getData(), //ADNER: Chama a função que conecta na API
          builder: (context, snapshot) {
            //ADNER: Caso a tela esteja tentando conectar ou aguardando resposta da API
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  'Carregando Dados...',
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    'Erro ao Carregar Dados :(',
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  //ADNER: Navega nas estruturas do JSON pra pegar os valores
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      //ADNER: Estica o ícone para pegar a linha toda e centralizar
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        buildTextField(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField(
                            "Dólares", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "€", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

//ADNER: Função para criar os campos na tela de forma dinâmica
Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function funcao) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: funcao,
    keyboardType: TextInputType.numberWithOptions(
        decimal: true), //ADNER: Todos campos são number
  );
}
