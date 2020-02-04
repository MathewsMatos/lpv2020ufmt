/*
* Corrigir erro que ocorre ao pesquisar um ativo inexistente (OK) e ou com data inválida (dia não útil); OK
* Colocar o nome do ativo buscado, por padrão deixa a consulta do índice Bovespa; ------OK-----
* Colocar datepicker para selecionar o dia no qual a ação será buscada; ----- OK --------
* Colocar menu para alterar a consulta para valor em tempo real (atualizado a cada 5 minutos),
  diário (como está implementado atualmente), semanal ou mensal. ----- OK -----
* Usar a documentação da API em https://www.alphavantage.co/documentation/ para saber como realizar
  as consultas diárias, semanais e mensais.
* Desenvolver protótipo antes de iniciar a implementação.

REAL-TIME: https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=MSFT&interval=5min&apikey=N2Y8BOLSIVL47N4T
DIARIO: https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=^BVSP&apikey=N2Y8BOLSIVL47N4T
SEMANAL: https://www.alphavantage.co/query?function=TIME_SERIES_WEEKLY&symbol=MSFT&apikey=N2Y8BOLSIVL47N4T
MENSAL: https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY&symbol=MSFT&apikey=N2Y8BOLSIVL47N4T

*/
import 'dart:async';

import 'package:cotacao_app/src/resources/stock__api_provider.dart';
import 'package:cotacao_app/src/widgets/widgets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      title: "Stock App",
      home: Home(),
      theme: ThemeData(hintColor: Colors.white)));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _search;
  String _fnUrl;
  String _keyResult;
  String _stockName;
  String _error;
  double _variacao;
  double _abertura;
  double _fechamento;
  double _alta;
  double _baixa;
  String date;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Cota Ação"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: _fnUrl != 'TIME_SERIES_INTRADAY'
                  ? () {
                      _selectDate(context);
                    }
                  : null), // Caso seja tempo real, o calendario é desabilitado
          simplePopup(),
        ],
      ),
      body: Stack(
        children: <Widget>[
          BuildBodyBack(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: 'Pesquise Aqui!',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder()),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  onSubmitted: (text) {
                    setState(() {
                      _search = text;
                    });
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder(
                    future: getStockPrice(stkCod: _search, fnUrl: _fnUrl),
                    builder: (context, AsyncSnapshot<Map> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Container(
                            width: 200.0,
                            height: 200.0,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 5.0,
                            ),
                          );
                        default:
                          _keyResult = getKeyResult(_fnUrl);
                          getValues(snapshot);
                          if (_error == '' || _error == null) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      _stockName,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(_variacao.toStringAsPrecision(3) + "%",
                                        style: TextStyle(
                                            fontSize: 70,
                                            fontWeight: FontWeight.bold,
                                            color: _variacao > 0
                                                ? Colors.green
                                                : Colors.red)),
                                    rowInfo('Data', date,
                                        style: TextStyle(fontSize: 10)),
                                    rowInfo(
                                        'Open', 'R\$${_abertura.toString()}'),
                                    rowInfo('High', 'R\$${_alta.toString()}'),
                                    rowInfo('Low', 'R\$${_baixa.toString()}'),
                                    rowInfo("Close",
                                        'R\$${_fechamento.toStringAsFixed(2)}')
                                  ]),
                            );
                          } else {
                            return Center(
                              child: Text("Erro: $_error"),
                            );
                          }
                      }
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget simplePopup() => PopupMenuButton<String>(
        // Relação de séries temporais disponíveis.
        initialValue: 'TIME_SERIES_DAILY',
        onSelected: (String choice) {
          setState(() {
            _fnUrl = choice;
          });
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'TIME_SERIES_DAILY',
            child: Text("Cotações Diarias"),
          ),
          PopupMenuItem(
            value: 'TIME_SERIES_WEEKLY',
            child: Text("Tempo Semanais"),
          ),
          PopupMenuItem(
            value: 'TIME_SERIES_MONTHLY',
            child: Text("Cotações Mensais"),
          ),
          PopupMenuItem(
            value: 'TIME_SERIES_INTRADAY',
            child: Text("Cotações Tempo Real"),
          ),
        ],
      );

  getValues(AsyncSnapshot<Map> snapshot) {
    // Método para extrair os dados da requisição da Api Alpha Advantage.
    _error = '';
    if (_fnUrl == 'TIME_SERIES_INTRADAY') {
      Timer.periodic(Duration(minutes: 5), (timer) {
        setState(() {
          _fnUrl = _fnUrl;
        });
      });
    }
    if (snapshot.data['Error Message'] == '' ||
        snapshot.data['Error Message'] == null) {
      if (date == null ||
          date == '' ||
          _fnUrl == 'TIME_SERIES_INTRADAY' ||
          ((_fnUrl != 'TIME_SERIES_INTRADAY') && date.length > 10))
        date = snapshot.data[_keyResult].keys.first;
      if (!snapshot.data[_keyResult].keys.contains(date))
        _error = 'Data informada é inválida.';
      else {
        _stockName = snapshot.data['Meta Data']['2. Symbol'];
        if (_stockName.length == 5) {
          _stockName = _stockName.substring(1, 5);
        } else {
          _stockName = _stockName.substring(0, 5);
        }
        _abertura = double.parse(snapshot.data[_keyResult][date]["1. open"]);
        _alta = double.parse(snapshot.data[_keyResult][date]["2. high"]);
        _baixa = double.parse(snapshot.data[_keyResult][date]["3. low"]);
        _fechamento = double.parse(snapshot.data[_keyResult][date]["4. close"]);
        _variacao = _getVariacao(_abertura, _fechamento);
      }
    } else
      _error = snapshot.data['Error Message'];
  }

  String getKeyResult(String _fnUrl) {
    // Método para identificar qual será a key utilizada no
    // Map retornado na requisição da Api Alpha Advantage.
    switch (_fnUrl) {
      case 'TIME_SERIES_INTRADAY':
        return 'Time Series (5min)';
        break;
      case 'TIME_SERIES_WEEKLY':
        return 'Weekly Time Series';
        break;
      case 'TIME_SERIES_MONTHLY':
        return 'Monthly Time Series';
      default:
        return 'Time Series (Daily)';
        break;
    }
  }

  double _getVariacao(double abertura, double fechamento) {
    // Método para calculo da variação do stock.
    return (fechamento / abertura - 1) * 100;
  }

  Future _selectDate(BuildContext context) async {
    // Calendário para escolha da data a ser pesquisada.
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2018),
        lastDate: DateTime(2030));
    if (picked != null) {
      setState(() {
        String month;
        String day;
        if (picked.month < 10)
          month = '0${picked.month}';
        else
          month = '${picked.month}';
        if (picked.day < 10)
          day = '0${picked.day}';
        else
          day = '${picked.day}';
        date = '${picked.year}-$month-$day';
        print(date);
      });
    }
  }
}
