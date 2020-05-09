//
//  OptionsViewController.swift
//  Truco Marcador
//
//  Created by Joao Flores on 01/12/19.
//  Copyright © 2019 Joao Flores. All rights reserved.
//


import UIKit
import Foundation
import GoogleMobileAds

class OptionsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, GADRewardBasedVideoAdDelegate {
    
    //MARK: - Variables
    var defaults = UserDefaults.standard
    var buyButtonHandler: ((_ product: SKProduct) -> Void)?
    var products: [SKProduct] = []
    var showAds = false
    
    //MARK: - OUTLETS
    @IBOutlet weak var usTeamTextBox: UITextField!
    @IBOutlet weak var theyTeamTextBox: UITextField!
    @IBOutlet weak var maxPointsTextBox: UITextField!
    @IBOutlet weak var labelRemoveAds: UILabel!
    
    //MARK: - IBAction
    
    @IBAction func suecaMKT(_ sender: Any) {
        suecaLink()
    }
    
    @IBAction func dispensadoMKT(_ sender: Any) {
        dispensadoLink()
    }
    
    @IBAction func savaUpdatesAndCancel(_ sender: Any) {
        self.atualizeNames()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showAds(_ sender: Any) {
        alertBeginAds()
    }
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkFirstGame()
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
        
        setupAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showAds = false
    }
    
    //MARK: - Defaults
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
    
    func populateInitialDefault() {
        setUsersDefault(newUsTeamName: "Nós", newTheyTeamName: "Eles", newMaxPoints: "12")
    }
    
    func checkFirstGame(){
        if(!defaults.bool(forKey: "NoFirsGame")) {
            defaults.set(true, forKey: "NoFirsGame")
            defaults.set(12, forKey: "maxPoints")
            setUsersDefault(newUsTeamName: "Nós", newTheyTeamName: "Eles", newMaxPoints: "12")
        }
    }
   
    //    MARK: - Alerts
    fileprivate func alertBeginAds() {
        let alert = UIAlertController(title: "Assista até o final", message: "Assista o vídeo até o final para receber recompensa", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.ConfirmationReset()
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //    MARK: - Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //    MARK: - Marketing other apps
    fileprivate func suecaLink() {
        let urlStr = "itms-apps://itunes.apple.com/app/apple-store/id1491372792?mt=8&uo=4"
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            
        } else {
            UIApplication.shared.openURL(URL(string: urlStr)!)
        }
    }
    
    fileprivate func dispensadoLink() {
        let urlStr = "itms-apps://itunes.apple.com/app/apple-store/id1508371263"
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            
        } else {
            UIApplication.shared.openURL(URL(string: urlStr)!)
        }
    }
    
    //    MARK: - ADS
    func setupAds() {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["bc9b21ec199465e69782ace1e97f5b79"]
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: "ca-app-pub-8858389345934911/5418678877")
        GADRewardBasedVideoAd.sharedInstance().delegate = self
    }
    
    func ConfirmationReset() {
        showAds = true
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        } else {
            print("------------------------------------aqui")
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
        print("------------------------------------")
//        if(showAds) {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
//        }
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("A equipe Truco Marcador agradece pela ajuda! bom jogo!")
        print("------------------------------------")
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from: date)
        print(result)
        showAds = false
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Você fechou o vídeo, é preciso ver até o fim")
        print("------------------------------------")
        showAds = false
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Falha ao carregar, tente novamente")
        print("------------------------------------")
        showAds = false
    }
    
    //MARK: - KEYBOARD
    fileprivate func delegateDefine() {
        usTeamTextBox.delegate = self
        theyTeamTextBox.delegate = self
    }
    
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 20
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
