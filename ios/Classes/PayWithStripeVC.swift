//
//  PayStripeVC.swift
//  SimplePayments
//
//  Created by Pascoal Bernardo on 10/27/19.
//  Copyright © 2019 Pascoal. All rights reserved.
//

import UIKit
import Stripe
import Material
import Flutter

class PayStripeVC: UIViewController {
    
    var map: [String : Any]?
    var result: FlutterResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setUpNavigation()

        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        super.loadView()
        self.setupViews()
    }
    
    func setupViews() {
        self.view.addSubview(self.txtFCardPay)
        self.view.addSubview(self.stripePay)
        
        if #available(iOS 11.0, *) {
            self.txtFCardPay.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            self.txtFCardPay.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            self.txtFCardPay.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 10.0).isActive = true
            self.txtFCardPay.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -10.0).isActive = true
            
            self.stripePay.topAnchor.constraint(equalTo: self.txtFCardPay.bottomAnchor, constant: 25.0).isActive = true
            self.stripePay.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 10.0).isActive = true
            self.stripePay.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -10.0).isActive = true
            let gestureStripe = UITapGestureRecognizer(target: self, action: #selector(goPayStripe))
            stripePay.addGestureRecognizer(gestureStripe)
        }
        
    }
    
    func setUpNavigation() {
        navigationItem.title = "Pay Easy"
        // label.font = UIFont(name: "AmericanTypewriter-Bold", size: 29.0)
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:_ColorLiteralType(red: 0, green: 0, blue: 0, alpha: 1), NSAttributedString.Key.font: UIFont(name: "AmericanTypewriter-Bold", size: 16)!]
    }
    
    @objc func goPayStripe() {
        self.stripePay.isEnabled = false
        self.stripePay.isUserInteractionEnabled = false

        // UIApplication.shared.keyWindow?.rootViewController?.navigationController
        DispatchQueue.main.async {
            self.getCardInfo()
        }
    }
    
    func getCardInfo() {
        let cardParams = STPCardParams()
        cardParams.number = txtFCardPay.cardNumber
        cardParams.expMonth = txtFCardPay.expirationMonth
        cardParams.expYear = txtFCardPay.expirationYear
        cardParams.cvc = txtFCardPay.cvc
    
        STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
            guard let token = token else {
                // Handle the error
                self.dialogMsg(msg: "Couldn't generate the token", title: "Error", message: "Oops. Something happened, try again later!")
                return
            }
            // Use the token in the next step
            // tell the Server-side ip to charge the card
            // print(token.tokenId)
            if let trMap = self.map {
                self.requestPayment(url: trMap["url"] as! String, token: token.tokenId, body: trMap["body"] as! [String : Any])
            }
        }
    }
    
    func requestPayment(url: String, token: String, body: [String : Any]) {
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid

        var parameters: [String : Any] = [:]
        parameters["tokenStripe"] = token
        for (key, value) in body {
            parameters[key] = value
        }

        //create the url with URL
        let url = URL(string: url)! //change the url

        //create the session object
        let session = URLSession.shared

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch _ {
            // print(errorHttp.localizedDescription)
            self.dialogMsg(msg: "HTTP Error", title: "Error", message: "Oops. Something happened, try again later!")

        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                self.dialogMsg(msg: "Error: Unable to establish connection to server", title: "Error", message: "Oops. Something happened, try again later!")
                return
            }

            guard let data = data else {
                self.dialogMsg(msg: "Error: To get data from the server", title: "Error", message: "Oops. Something happened, try again later!")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode >= 400 {
                            self.dialogMsg(msg: "Error: \(jsonString)", title: "Error", message: "Oops. Something happened, try again later!")
                        } else {
                            self.dialogMsg(msg: jsonString, title: "Payment", message: "Success")
                        }
                    } else {
                        self.dialogMsg(msg: "Error: \(jsonString)", title: "Error", message: "Oops. Something happened, try again later!")
                    }
                    
                }
              // self.dialogMsg()
            } else {
                self.dialogMsg(msg: "Unable to parse JSON", title: "Error", message: "Oops. Something happened, try again later!")
            }
        })
        task.resume()
    }
    
    func dialogMsg(msg: String, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert in self.exitPay(msg: msg) }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc func exitPay(msg: String) {
        if let res = result {
            self.dismiss(animated: true) {
                res(msg)
            }
        }
    }
    
    let txtFCardPay: STPPaymentCardTextField = {
        let txtFCard = STPPaymentCardTextField()
        txtFCard.translatesAutoresizingMaskIntoConstraints = false
        return txtFCard
    }()
    
    let stripePay: Button = {
        let button = Button()
        button.title = "Pay"
        button.backgroundColor = UIColor.black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleColor = UIColor.white
        
        return button
    }()
}

