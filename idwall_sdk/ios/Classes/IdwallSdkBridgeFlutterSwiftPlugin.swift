import Flutter
import UIKit
import IDwallToolkit

public class IdwallSdkBridgeFlutterPluginSwift: NSObject, FlutterPlugin, IDwallEventsHandler {
    static var channelMessage: FlutterBasicMessageChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "idwall_sdk", binaryMessenger: registrar.messenger())
        let instance = IdwallSdkBridgeFlutterPluginSwift()
        registrar.addMethodCallDelegate(instance, channel: channel)
        channelMessage = .init(name: "idwall_sdk_events", binaryMessenger: registrar.messenger(), codec: FlutterJSONMessageCodec.sharedInstance())
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let method = PublicMethods(rawValue: call.method) else { result(FlutterMethodNotImplemented); return }
            let args = call.arguments
            switch method {
            case .initialize:
                guard let authKey = args as? String else { result(FlutterMethodNotImplemented); return; }
                self.initialize(authkey: authKey)
                result(nil)
            case .setupPublicKey:
                guard let publicKeyHash = args as? [String] else { result(FlutterMethodNotImplemented); return; }
                self.setupPublicKey(publicKeysHashs: publicKeyHash)
                result(nil)
            case .initializeWithLoggingLevel:
                guard let casted = args as? [String],
                    let authKey = casted.first,
                    let level = self.asLogginLevel(any: casted.dropFirst().first) else { result(FlutterMethodNotImplemented); return; }
                self.initializeWithLoggingLevel(authkey: authKey, level: level)
                result(nil)
            case .enableLivenessFallback:
                guard let flag = args as? Bool else { result(FlutterMethodNotImplemented); return; }
                self.enableLivenessFallback(flag)
                result(nil)
            case .showTutorialBeforeDocumentCapture:
                guard let flag = args as? Bool else { result(FlutterMethodNotImplemented); return; }
                self.showTutorialBeforeDocumentCapture(flag)
                result(nil)
            case .showTutorialBeforeLiveness:
                guard let flag = args as? Bool else { result(FlutterMethodNotImplemented); return; }
                self.showTutorialBeforeLiveness(flag)
                result(nil)
            case .startDocumentFlow:
                guard let type = self.asDocumentType(any: args as? String) else { result(FlutterMethodNotImplemented); return; }
                self.startDocumentFlow(type: type, result: result)
            case .startLivenessFlow:
                self.startLivenessFlow(result: result)
            case .startCompleteFlow:
                guard let type = self.asDocumentType(any: args as? String) else { result(FlutterMethodNotImplemented); return; }
                self.startCompleteFlow(type: type, result: result)
            case .requestLiveness:
                self.requestLiveness(result: result)
            case .requestDocument:
                guard let casted = args as? [String],
                    let type = self.asDocumentType(any: casted.first),
                    let side = self.asDocumentSide(any: casted.dropFirst().first) else { result(FlutterMethodNotImplemented); return; }
                self.requestDocument(documentType: type, documentSide: side, result: result)
            case .sendLivenessData:
                self.sendLivenessData(result: result)
            case .sendDocumentData:
                guard let type = self.asDocumentType(any: args as? String) else { result(FlutterMethodNotImplemented); return; }
                self.sendDocumentData(documentType: type, result: result)
            case .sendCnhWithLivenessData:
                self.sendCnhWithLivenessData(result: result)
            case .sendRgWithLivenessData:
                self.sendRgWithLivenessData(result: result)
            case .sendCrlvWithLivenessData:
                self.sendCrlvWithLivenessData(result: result)

            }
        }
    }

    func initialize(authkey: String) {
        _ = IDwallToolkitSettings.sharedInstance().initWithAuthKey(authkey)
        IDwallToolkitSettings.sharedInstance().setEventHandler(self)
    }

    func setupPublicKey(publicKeysHashs: [String]) {
        _ = IDwallToolkitSettings.sharedInstance().setupIDWallPublicKey(publicKeysHashs)
    }

    func initializeWithLoggingLevel(authkey: String, level: LoggingLevel) {
        _ = IDwallToolkitSettings.sharedInstance().initWithAuthKey(authkey)
        IDwallToolkitSettings.sharedInstance().setLoggingLevel(level)
        IDwallToolkitSettings.sharedInstance().setEventHandler(self)
    }

    func enableLivenessFallback(_ flag: Bool) {
        IDwallToolkitSettings.sharedInstance().faceFallbackActivated(flag)
    }

    func showTutorialBeforeDocumentCapture(_ flag: Bool) {
        IDwallToolkitSettings.sharedInstance().setDocumentTutorialEnabled(flag)
    }

    func showTutorialBeforeLiveness(_ flag: Bool) {
        IDwallToolkitSettings.sharedInstance().setLivenessTutorialEnabled(flag)
    }

    func startDocumentFlow(type: IDwallDocumentType, result: @escaping FlutterResult) {
        IDwallToolkitFlow.sharedInstance().startDocumentFlow(with: type) { (value, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }

    func startLivenessFlow(result: @escaping FlutterResult) {
        IDwallToolkitFlow.sharedInstance().startFace { (value, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }

    func startCompleteFlow(type: IDwallDocumentType, result: @escaping FlutterResult) {
        IDwallToolkitFlow.sharedInstance().startComplete(with: type) { (value, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }

    func requestDocument(documentType: IDwallDocumentType, documentSide: IDwallDocumentSide, result: @escaping FlutterResult) {
        IDwallDocument.sharedInstance().request(documentType, andDocSide: documentSide) { (val, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
                return }
            result(true)
        }
    }

    func requestLiveness(result: @escaping FlutterResult) {
        IDwallFace.sharedInstance().request { (val, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
                return
            }
            result(true)
        }
    }

    func sendLivenessData(result: @escaping FlutterResult) {
        IDwallFace.sharedInstance().sendData { (value, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }

    func sendDocumentData(documentType: IDwallDocumentType, result: @escaping FlutterResult) {
        if documentType == IDwallDocumentPOA {
            IDwallDocument.sharedInstance().sendPOAData { (value, error) in
                if let error = error as NSError? {
                    result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
                } else if let token = value?["token"] {
                    result(token)
                } else {
                    result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
                }
            }
        } else if documentType == IDwallDocumentTypified {
            IDwallDocument.sharedInstance().sendTypifiedDocumentData { (value, error) in
                if let error = error as NSError? {
                    result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
                } else if let token = value?["token"] {
                    result(token)
                } else {
                    result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
                }
            }

        } else {
            IDwallDocument.sharedInstance().sendData { (value, error) in
                if let error = error as NSError? {
                    result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
                } else if let token = value?["token"] {
                    result(token)
                } else {
                    result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
                }
            }
        }
    }

    func sendRgWithLivenessData(result: @escaping FlutterResult) {
        IDwallToolkitFlow.sharedInstance().sendAllData { (value, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }

    func sendCnhWithLivenessData(result: @escaping FlutterResult) {
        IDwallToolkitFlow.sharedInstance().sendAllData { (value, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }

    func sendCrlvWithLivenessData(result: @escaping FlutterResult) {
        IDwallToolkitFlow.sharedInstance().sendAllData { (value, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }

    public func onEvent(_ event: IDwallEvent) {
        let msg: [String : Any] = ["name": event.name, "properties": event.properties]
        IdwallSdkBridgeFlutterPluginSwift.channelMessage?.sendMessage(msg)
    }

    enum PublicMethods: String {
        case initialize
        case setupPublicKey
        case initializeWithLoggingLevel
        case enableLivenessFallback
        
        case showTutorialBeforeDocumentCapture
        case showTutorialBeforeLiveness
        

        case startDocumentFlow
        case startLivenessFlow
        case startCompleteFlow

        case requestLiveness
        case requestDocument

        case sendLivenessData
        case sendDocumentData
        case sendRgWithLivenessData
        case sendCnhWithLivenessData
        case sendCrlvWithLivenessData
    }

    func asDocumentType(any: String?) -> IDwallDocumentType? {
        switch any {
        case "CHOOSE":
            return IDwallDocumentTypeAny
        case "RG":
            return IDwallDocumentTypeRG
        case "CNH":
            return IDwallDocumentTypeCNH
        case "CRLV":
            return IDwallDocumentTypeCRLV
        case "GENERIC":
            return IDwallDocumentTypeGeneric
        case "GENERIC_FRONT_BACK":
            return IDwallDocumentTypeGenericDoubleSide
        case "TYPIFIED":
            return IDwallDocumentTypified
        case "POA":
            return IDwallDocumentPOA
        default:
            return nil
        }
    }

    func asDocumentSide(any: String?) -> IDwallDocumentSide? {
        switch any {
        case "FRONT":
            return IDwallDocumentSideFront
        case "BACK":
            return IDwallDocumentSideBack
        default:
            return nil
        }
    }

    func asLogginLevel(any: String?) -> LoggingLevel? {
        switch any {
        case "VERBOSE":
            return .Verbose
        case "MINIMAL":
            return .Minimal
        case "REGULAR":
            return .Regular
        default:
            return nil
        }
    }
}
