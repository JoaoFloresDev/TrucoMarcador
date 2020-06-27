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

class OptionsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var defaults = UserDefaults.standard
    
    //MARK: - OUTLETS
    @IBOutlet weak var usTeamTextBox: UITextField!
    @IBOutlet weak var theyTeamTextBox: UITextField!
    @IBOutlet weak var maxPointsTextBox: UITextField!
    @IBOutlet weak var switchButtonsShow: UISwitch!
    
    @IBOutlet weak var upgradeButton: UIButton!
    //MARK: - Actions
    @IBAction func dismissView(_ sender: Any) {
        self.atualizeNames()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSwitch(_ sender: Any) {
        if(switchButtonsShow.isOn){
            defaults.set(true, forKey: "ShowButtons")
        }
        else {
            defaults.set(false, forKey: "ShowButtons")
        }
    }
    
    
    
    // Credredits
    @IBAction func iconCredit(_ sender: Any) {
        let urlStr = "https://www.freepik.com/free-photos-vectors"
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            
        } else {
            UIApplication.shared.openURL(URL(string: urlStr)!)
        }
    }
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if(checkFirsGame()) {
            populateDefault()
        }
        
        upgradeButton.layer.cornerRadius = 10
        
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
        switchButtonsShow.setOn(defaults.bool(forKey: "ShowButtons"), animated: true)
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
    
//    MARK: - Style
    func cropBounds(viewlayer: CALayer, cornerRadius: Float) {
        
        let imageLayer = viewlayer
        imageLayer.cornerRadius = CGFloat(cornerRadius)
        imageLayer.masksToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
