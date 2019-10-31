import Flutter
import UIKit
import Stripe

public class SwiftSimplePaymentsPlugin: NSObject, FlutterPlugin {
    var window: UIWindow?
    
    var uiVC : UIViewController
    
    init(uiViewController: UIViewController) {
        self.uiVC = uiViewController
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "simple_payments", binaryMessenger: registrar.messenger())
    let viewController: UIViewController =
    (UIApplication.shared.delegate?.window??.rootViewController)!
    let instance = SwiftSimplePaymentsPlugin(uiViewController: viewController)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "payWithStripe") {
        DispatchQueue.main.async {
            
            let dictRequest = call.arguments as? [String: Any]
            if let dR = dictRequest {
                print(dR);
                let payStripeVC = PayStripeVC()
                payStripeVC.map = dR
                payStripeVC.result = result
                if let dict = payStripeVC.map {
                    guard let key = dict["stripePub"] as? String else {
                        return
                    }
                    Stripe.setDefaultPublishableKey(key)
                    self.uiVC.present(payStripeVC, animated: true, completion: nil)
                }
            }
        }
    }
  }
}
