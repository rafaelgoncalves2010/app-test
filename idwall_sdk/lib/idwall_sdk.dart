import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum IdwallDocumentType {
  CHOOSE,
  CNH,
  CRLV,
  RG,
  POA,
  TYPIFIED,
  GENERIC,
  GENERIC_FRONT_BACK
}
enum IdwallDocumentSide { FRONT, BACK }
enum IdwallLoggingLevel { VERBOSE, MINIMAL, REGULAR }

class IdwallSdk {
  static const MethodChannel _channel = const MethodChannel('idwall_sdk');

  static const BasicMessageChannel _eventChannel =
      const BasicMessageChannel<dynamic>(
          "idwall_sdk_events", JSONMessageCodec());

  static void initialize(String authKey) {
    _channel.invokeMethod<dynamic>('initialize', authKey);
  }

  static void setupPublic(List<String> publicKeyHash) {
    _channel.invokeMethod<dynamic>('setupPublicKey', publicKeyHash);
  }

  static void setIdwallEventsHandler(
      Future<dynamic> Function(dynamic)? eventHandler) {
    _eventChannel.setMessageHandler(eventHandler);
  }

  static void initializeWithLoggingLevel(
      String authKey, IdwallLoggingLevel loggingLevel) {
    _channel.invokeMethod<dynamic>(
      'initializeWithLoggingLevel',
      [authKey, describeEnum(loggingLevel)],
    );
  }

  static void enableLivenessFallback(bool enabled) {
    _channel.invokeMethod<dynamic>('enableLivenessFallback', enabled);
  }

  static void showTutorialBeforeDocumentCapture(bool showTutorial) {
    _channel.invokeMethod<dynamic>(
      'showTutorialBeforeDocumentCapture',
      showTutorial,
    );
  }

  static void showTutorialBeforeLiveness(bool showTutorial) {
    _channel.invokeMethod<dynamic>('showTutorialBeforeLiveness', showTutorial);
  }

  static Future<String?> startDocumentFlow(
      IdwallDocumentType documentType) async {
    return await _channel.invokeMethod<String?>(
      'startDocumentFlow',
      describeEnum(documentType),
    );
  }

  static Future<String?> startLivenessFlow() async {
    return await _channel.invokeMethod<String?>('startLivenessFlow');
  }

  static Future<String?> startCompleteFlow(
      IdwallDocumentType documentType) async {
    return await _channel.invokeMethod<String?>(
      'startCompleteFlow',
      describeEnum(documentType),
    );
  }

  static Future<bool?> requestLiveness() async {
    return await _channel.invokeMethod<bool?>('requestLiveness');
  }

  static Future<bool?> requestDocument(
      IdwallDocumentType documentType, IdwallDocumentSide documentSide) async {
    return await _channel.invokeMethod<bool?>(
      'requestDocument',
      [describeEnum(documentType), describeEnum(documentSide)],
    );
  }

  static Future<String?> sendLivenessData() async {
    return await _channel.invokeMethod<String?>('sendLivenessData');
  }

  static Future<String?> sendDocumentData(
      IdwallDocumentType documentType) async {
    return await _channel.invokeMethod<String?>(
      'sendDocumentData',
      describeEnum(documentType),
    );
  }

  static Future<String?> sendCnhWithLivenessData() async {
    return await _channel.invokeMethod<String?>('sendCnhWithLivenessData');
  }

  static Future<String?> sendRgWithLivenessData() async {
    return await _channel.invokeMethod<String?>('sendRgWithLivenessData');
  }

  static Future<String?> sendCrlvWithLivenessData() async {
    return await _channel.invokeMethod<String?>('sendCrlvWithLivenessData');
  }
}
