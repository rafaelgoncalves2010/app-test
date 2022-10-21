// ignore_for_file: non_constant_identifier_names

class RequestRelatorioIdwall {
  String matriz;
  Parametros parametros;
  RequestRelatorioIdwall(this.matriz, this.parametros);
  Map toJson() => {'matriz': matriz, 'parametros': parametros};
}

class Parametros {
  String token_sdk;
  Parametros(this.token_sdk);
  Map toJson() => {
    'token_sdk':token_sdk
  };
}
