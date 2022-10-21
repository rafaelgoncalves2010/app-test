// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api, avoid_print, depend_on_referenced_packages, unused_local_variable
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:idwall_sdk/idwall_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'constants.dart';
import 'model/request_relatorio_idwall.dart';

void main() {
  runApp(WebViewSRM());
}

class WebViewSRM extends StatefulWidget {
  @override
  _WebViewSRMState createState() => _WebViewSRMState();
}

class _WebViewSRMState extends State<WebViewSRM> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    IdwallSdk.initialize("2312a3608d921ae389448f111cea262d");
    IdwallSdk.setupPublic([
      "AHYMQP+2/KIo32qYcfqnmSn+N/K3IdSZWlqa2Zan9eY=",
      "tDilFQ4366PMdAmN/kyNiBQy24YHjuDs6Qsa6Oc/4c8="
    ]);
  }

  Future<Map<String, dynamic>> gerarRelatorio(
      String tokenID, String matriz) async {
    var urlIDWall = 'https://api-v2.idwall.co/relatorios';
    //var body = json.encode({'matriz': matriz, 'parametros': tokenID});

    var parametros = Parametros(tokenID);
    var request = RequestRelatorioIdwall(matriz, parametros);

    var body = json.encode(request);

    print('Body: $body');

    var response = await http.post(
      Uri.parse(urlIDWall),
      headers: {
        'Content-Type': 'application/json',
        //'Authorization': '8948bf01-2c08-4140-b06e-71817372d459' // RICARDO
        //'Authorization': 'a15c83c9-a24b-4208-9a87-c783b46b65a' // MARCELO
        'Authorization': 'a15c83c9-a24b-4208-9a87-c783b46b65a1'
      },
      body: body,
    );
    String retorno = jsonDecode(response.body).toString();
    print('Json Request IDWALL:  $retorno');
    return jsonDecode(response.body);
  }

  void fluxoLivenessFlow() {
    IdwallSdk.startLivenessFlow().then((token) => {
          _controller.runJavascriptReturningResult(
              'mensagemFlutter("TOKEN ID GERADO COM SUCESSO($token), ENVIANDO PARA RELATÓRIO.")'),
          print(gerarRelatorio(token.toString(), 'wefin_ocr_fm_doc_bgc_pf'))
        });
  }

  void fluxoLivenessCNH() {
    IdwallSdk.startCompleteFlow(IdwallDocumentType.CNH).then((token) => {
          _controller.runJavascriptReturningResult(
              'mensagemFlutter("TOKEN ID GERADO COM SUCESSO($token), ENVIANDO PARA RELATÓRIO.")'),
          print(gerarRelatorio(token.toString(), 'sdk_wefin_ocr_fm_doc_bgc_pf'))
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Scaffold(
        appBar: null,
        body: WebView(
          initialUrl: 'about:blank',
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>{
            JavascriptChannel(
              name: 'messageHandler',
              onMessageReceived: (JavascriptMessage message) {
                if (int.parse(message.message) == 1) {
                  fluxoLivenessCNH();
                } else if (int.parse(message.message) == 2) {
                  fluxoLivenessFlow();
                } else if(int.parse(message.message) == 3) {
                  _loadSRMApp();
                } else {
                  print('Nenhum fluxo selecionado');
                }
              },
            ),
          },
          onWebViewCreated: (WebViewController webviewController) {
            _controller = webviewController;
            _loadSRMApp();
          },
          onWebResourceError: (WebResourceError webviewerrr) {
            _loadSRMError();
            //Navigator.pushNamed(context, ErrorScreen.routeName,);
          },
        ),
      )),
    );
  }

  _loadSRMError() async {
    print('ERRO HTTP');
    String fileHtmlContents =
        await rootBundle.loadString('assets/html/error.html');
    _controller.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  _loadSRMApp() async {
    _controller.loadUrl(
        'https://srm-operacoes-financeiras-cliente-homologacao.srmasset.com/');
  }
}