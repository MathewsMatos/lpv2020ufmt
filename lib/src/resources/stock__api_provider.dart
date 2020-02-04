import 'package:http/http.dart' as http;
import 'dart:convert';

const API_KEY = 'RBCKQHWHEDD5N7C3';

//Função para buscar valor das ações
Future<Map> getStockPrice({String fnUrl, String stkCod}) async {
  // implementar switch case para opções real-time/diario/semanal/mensal
  print("entered");
  String _url;
  

  if (stkCod == '' || stkCod == null) stkCod = '^BVSP';
  else if (stkCod.length > 4)  {
    stkCod = stkCod + ".SAO";
  }


  if (fnUrl == '' || fnUrl == null) {
    fnUrl = 'TIME_SERIES_DAILY';
  }

  if (fnUrl == 'TIME_SERIES_INTRADAY') {
    _url =
        'https://www.alphavantage.co/query?function=$fnUrl&symbol=$stkCod&interval=5min&apikey=$API_KEY';
  } else {
    _url =
        'https://www.alphavantage.co/query?function=$fnUrl&symbol=$stkCod&apikey=$API_KEY';
  }

  final response = await http.get(_url);

  if (response.statusCode == 200) {
    return 
        json.decode(response.body); // Success
  } else
    throw Exception('Failed to load post'); // Fail
}


