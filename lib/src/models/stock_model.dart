class StockModel {
  MetaData metaData;
  Map<String, Stock> result;
  String error;

  StockModel({
    this.metaData,
    this.result,
    this.error
  });

  factory StockModel.fromJson(Map<String, dynamic> json, String keyResults) =>
      StockModel(
        metaData: MetaData.fromJson(json["Meta Data"]),
        error: json["Error Message"],
        result: Map.from(json[keyResults])
            .map((k, v) => MapEntry<String, Stock>(k, Stock.fromJson(v))),
      );
}

class MetaData {
  String information;
  String symbol;
  DateTime lastRefresh;
  String error;

  MetaData({
    this.information,
    this.symbol,
    this.lastRefresh,
    this.error
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
      return MetaData(
        information: json["1. Information"],
        symbol: json["2. Symbol"],
        lastRefresh: DateTime.parse(json["3. Last Refreshed"]),
      );
}}

class Stock {
  double open;
  double high;
  double low;
  double close;
  int volume;

  Stock({
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        open: double.parse(json["1. open"]),
        high: double.parse(json["2. high"]),
        low: double.parse(json["3. low"]),
        close: double.parse(json["4. close"]),
        volume: int.parse(json["5. volume"]),
      );
}
