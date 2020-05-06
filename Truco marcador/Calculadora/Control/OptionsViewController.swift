//
//  OptionsViewController.swift
//  Truco Marcador
//
//  Created by Joao Flores on 01/12/19.
//  Copyright © 2019 Joao Flores. All rights reserved.
//


import UIKit
import Foundation
import StoreKit
import InAppPurchase
import SwiftyStoreKit

class OptionsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var defaults = UserDefaults.standard
    var buyButtonHandler: ((_ product: SKProduct) -> Void)?
    var products: [SKProduct] = []
    
    //MARK: - OUTLETS
    @IBOutlet weak var MktView: UIView!
    
    @IBOutlet weak var usTeamTextBox: UITextField!
    @IBOutlet weak var theyTeamTextBox: UITextField!
    @IBOutlet weak var maxPointsTextBox: UITextField!
    
    @IBOutlet weak var labelRemoveAds: UILabel!
    
    //MARK: - IBAction
    @IBAction func suecaMKT(_ sender: Any) {
        let urlStr = "itms-apps://itunes.apple.com/app/apple-store/id1491372792?mt=8&uo=4"
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            
        } else {
            UIApplication.shared.openURL(URL(string: urlStr)!)
        }
    }
    
    @IBAction func dispensadoMKT(_ sender: Any) {
        let urlStr = "itms-apps://itunes.apple.com/app/apple-store/id1508371263"
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            
        } else {
            UIApplication.shared.openURL(URL(string: urlStr)!)
        }
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.atualizeNames()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pursheInApp(_ sender: Any) {
        reload()
    }
    
    @objc func reload() {
      products = []
      
      
      RazeFaceProducts.store.requestProducts{ [weak self] success, products in
        guard let self = self else { return }
        if success {
          self.products = products!
        let isProductPurchased = RazeFaceProducts.store.isProductPurchased(self.products[0].productIdentifier)
            if(!isProductPurchased) {
                RazeFaceProducts.store.buyProduct(self.products[0])
            } else {
                print("já adquirido")
                self.MktView.removeFromSuperview()
            }
        }
      }
    }
    
     func ConfirmationReset() {
        let refreshAlert = UIAlertController(title: "Deseja reiniciar a partida?", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.modalPresentationStyle = .popover
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Cancel pressed")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel pressed")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if(checkFirsGame()) {
            populateDefault()
        }
        usTeamTextBox.placeholder = defaults.string(forKey: "usTeamName") ?? "Nós"
        theyTeamTextBox.placeholder = defaults.string(forKey: "theyTeamName") ?? "Eles"
        maxPointsTextBox.placeholder = String(defaults.integer(forKey: "maxPoints"))
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        maxPointsTextBox.keyboardType = UIKeyboardType.phonePad
        delegateDefine()
        
        self.usTeamTextBox.delegate = self
        self.theyTeamTextBox.delegate = self
        self.maxPointsTextBox.delegate = self
        
        if(defaults.bool(forKey: "Purchased")) {
            MktView.removeFromSuperview()
        }
    }
    
    //MARK: - METHODS
    fileprivate func delegateDefine() {
        usTeamTextBox.delegate = self
        theyTeamTextBox.delegate = self
    }
    
    func populateDefault() {
        setUsersDefault(newUsTeamName: "Nós", newTheyTeamName: "Eles", newMaxPoints: "12")
    }
    
    func showAlert(msg: String, field:UITextField) {
        let alertController = UIAlertController(title: "Preenchimento incorreto", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (act) in
            field.becomeFirstResponder()
        }
        alertController.addAction(okAction)
        present(alertController,animated: true)
    }
    
    //MARK: - KEYBOARD
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            
        case usTeamTextBox:
            self.theyTeamTextBox.becomeFirstResponder()
            
        case theyTeamTextBox:
            self.maxPointsTextBox.becomeFirstResponder()
            
        case maxPointsTextBox:
            textField.resignFirstResponder()
            
        default:
            textField.resignFirstResponder()
        }
        
        atualizeNames()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func atualizeNames() {
        setUsersDefault(newUsTeamName: usTeamTextBox.text ?? "", newTheyTeamName: theyTeamTextBox.text ?? "", newMaxPoints: maxPointsTextBox.text ?? "12")
    }
    
    func setUsersDefault(newUsTeamName: String, newTheyTeamName: String, newMaxPoints: String) {
        if(newUsTeamName != "") {
            defaults.set (newUsTeamName, forKey: "usTeamName")
        }
        
        if(newTheyTeamName != "") {
            defaults.set (newTheyTeamName, forKey: "theyTeamName")
        }
        
        let maxPoints = Int(newMaxPoints) ?? 12
        if(maxPoints > 0 && maxPoints <= 99) {
            defaults.set(maxPoints, forKey: "maxPoints")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 20
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func populateInitialDefault() {
        setUsersDefault(newUsTeamName: "Nós", newTheyTeamName: "Eles", newMaxPoints: "12")
    }
    
    func checkFirsGame() -> Bool{
        var ratingColdShow = false
        
        if(!defaults.bool(forKey: "NoFirsGame")) {
            defaults.set(true, forKey: "NoFirsGame")
            defaults.set(12, forKey: "maxPoints")
            UserDefaults.standard.set(40, forKey: "LanguageVoiceIndex")
            UserDefaults.standard.set("pt-BR", forKey: "LanguageVoice")
            UserDefaults.standard.set(1, forKey: "pitchValue")
            UserDefaults.standard.set(0.5, forKey: "rateValue")
            ratingColdShow = true
        }
        return ratingColdShow
    }
    
    func cropBounds(viewlayer: CALayer, cornerRadius: Float) {
        
        let imageLayer = viewlayer
        imageLayer.cornerRadius = CGFloat(cornerRadius)
        imageLayer.masksToBounds = true
    }
}
