//
//  TrucoViewController.swift
//  Truco Marcador
//
//  Created by Joao Flores on 01/12/19.
//  Copyright © 2019 Joao Flores. All rights reserved.
//

import UIKit
import StoreKit
import AVFoundation
import QuartzCore
import GoogleMobileAds

class TrucoViewController: UIViewController, AVSpeechSynthesizerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    
    var bannerView: GADBannerView!
    
    let synth = AVSpeechSynthesizer()
    
    var lastPoint = CGPoint.zero
    var color = UIColor.white
    var brushWidth: CGFloat = 15.0
    var opacity: CGFloat = 0.5
    var swiped = false
    
    var partida: PointsClass!
    var defaults = UserDefaults.standard
    var timerAnimate: Timer!
    var increasing = true
    
    var winner: UILabel!
    var sizeFont = 60
    var maxFont = 65
    var regularFont = 60
    var inAnimate = true
    var rateControll = 0
    
    var firstReset = 0
    //    ADS
    var interstitial: GADInterstitial!
    
    func createAndLoadInterstitial() -> GADInterstitial {
      var interstitial = GADInterstitial(adUnitID: "ca-app-pub-8858389345934911/1816921732")
      interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      interstitial = createAndLoadInterstitial()
    }
    
    //    MARK: -  IBOutlet
    @IBOutlet weak var buttonsPointsTeam1: UIView!
    @IBOutlet weak var buttonsPointsTeam2: UIView!
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var whiteButtonsSpeach: UIImageView!
    @IBOutlet weak var blackButtonSpeach: UIImageView!
    @IBOutlet weak var backGroundBlack: UIImageView!
    @IBOutlet weak var backGoundImg: UIImageView!
    @IBOutlet var ImagesTutorial: [UIImageView]!
    
    @IBOutlet weak var usTeamName: UILabel!
    @IBOutlet weak var theyTeamName: UILabel!
    @IBOutlet var LabelsTutorial: [UILabel]!
    
    @IBOutlet weak var buttonTutorial: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    //    labels rounds and games
    @IBOutlet weak var roundTeam1: UILabel!
    @IBOutlet weak var roundTeam2: UILabel!
    @IBOutlet weak var gamesTeam1: UILabel!
    @IBOutlet weak var gamesTeam2: UILabel!
    
    @IBOutlet weak var bannerVIewPlaceHolder: UIView!
    
    //    MARK: - IBAction
    @IBAction func addTeam1(_ sender: Any) {
        if !(inAnimate) {
            partida.roundT1 = partida.sum1(round: partida.roundT1)
            
            if(partida.checkEndGame()) {
                inAnimate = true
                animate()
                
            } else {
                refreshScores()
            }
        }
    }
    
    @IBAction func lessTeam1(_ sender: Any) {
        if !(inAnimate) {
            partida.roundT1 = partida.sub1(round: partida.roundT1)
            
                if(partida.checkEndGame()) {
                    inAnimate = true
                    animate()
                    
                } else {
                    refreshScores()
                }
        }
    }
    
    @IBAction func addTeam2(_ sender: Any) {
        if !(inAnimate) {
            partida.roundT2 = partida.sum1(round: partida.roundT2)
            
            if(partida.checkEndGame()) {
                inAnimate = true
                animate()
                
            } else {
                refreshScores()
            }
        }
    }
    
    @IBAction func lessTeam2(_ sender: Any) {
        if !(inAnimate) {
            partida.roundT2 = partida.sub1(round: partida.roundT2)
            
            if(partida.checkEndGame()) {
                inAnimate = true
                animate()
                
            } else {
                refreshScores()
            }
        }
    }
    
    
    @IBAction func speachAction(_ sender: Any) {
        speechAction()
    }
    
    @IBAction func finishTutorial(_ sender: Any) {
        finishTutorialFunc()
    }
    
    @IBAction func home(_ sender: Any) {
        showMenu()
    }
    
    //   MARK: - LIFE CYCLE
    override func viewDidLoad() {

        UserDefaults.standard.set(true, forKey:"FirtsUse")
        
        //        ADS
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-8858389345934911/1816921732")
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
        interstitial = createAndLoadInterstitial()
        
        
        cropBounds(viewlayer: bannerVIewPlaceHolder.layer, cornerRadius: 20)
        
        if(!OptionsViewController().checkFirsGame()) {
            self.finishTutorialFunc()
        }
        
        atualizeNamesTeams()
        partida = PointsClass()
        refreshScores()
        refreshRounds()
        setupGestures()
        cropButtonImg()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if(defaults.bool(forKey: "ShowButtons")) {
            buttonsPointsTeam1.alpha = 1
            buttonsPointsTeam2.alpha = 1
        }
        else {
            buttonsPointsTeam1.alpha = 0
            buttonsPointsTeam2.alpha = 0
        }
        
        atualizeNamesTeams()
        setupAds()
    }
    
    //   MARK: - GESTURES
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(TrucoViewController.tap(_:)))
        self.view.addGestureRecognizer(tap)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if !(inAnimate || defaults.bool(forKey: "ShowButtons")) {
            
            if gesture.direction == UISwipeGestureRecognizer.Direction.up {
                if(gesture.location(in: backGoundImg).x < backGoundImg.frame.size.width/2) {
                    partida.round1Sum3()
                } else {
                    partida.roundT2 = partida.sum3(round: partida.roundT2)
                }
                
                let currentPoint = gesture.location(in: view)
                drawLine(from: lastPoint, to: CGPoint(x: lastPoint.x, y: lastPoint.y - 100))
                
                lastPoint = currentPoint
            }
                
            else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
                if (gesture.location(in: backGoundImg).x < backGoundImg.frame.width/2) {
                    partida.roundT1 = partida.sub1(round: partida.roundT1)
                } else {
                    partida.roundT2 = partida.sub1(round: partida.roundT2)
                }
                
                let currentPoint = gesture.location(in: view)
                drawLine(from: lastPoint, to: CGPoint(x: lastPoint.x, y: lastPoint.y + 100))
                
                lastPoint = currentPoint
            }
            
            if(partida.checkEndGame()) {
                inAnimate = true
                animate()
            } else {
                refreshScores()
            }
        }
    }
    
    @objc func tap (_ gesture:UITapGestureRecognizer) {
        if !(inAnimate || defaults.bool(forKey: "ShowButtons")) {
            if(gesture.location(in: nil).x < backGoundImg.frame.size.width/2) {
                partida.roundT1 = partida.sum1(round: partida.roundT1)
            } else {
                partida.roundT2 = partida.sum1(round: partida.roundT2)
            }
            
            if(partida.checkEndGame()) {
                inAnimate = true
                animate()
                
            } else {
                refreshScores()
            }
        }
        
        let currentPoint = gesture.location(in: view)
        drawLine(from: lastPoint, to: currentPoint)
        
        lastPoint = currentPoint
    }
    
    //    MARK: - ANIMATIONS
    func animate() {
        winner = roundTeam2
        increasing = true
        
        if(partida.finshScoreboard() == 1) {
            winner = roundTeam1
        }
        
        refreshScores()
        
        self.timerAnimate = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.sizeAnimate), userInfo: nil, repeats: true)
    }
    
    @objc func sizeAnimate() {
        if (increasing) { sizeFont += 1 }
        else { sizeFont -= 1 }
        
        winner.font = winner.font.withSize(CGFloat(sizeFont))
        
        if(increasing && sizeFont >= maxFont) {increasing = false}
        
        if(sizeFont <= regularFont && !(increasing)) {
            sizeFont = regularFont
            partida.resetRound()
            
            timerAnimate.invalidate()
            
            FunctionsClass().delayWithSeconds(TimeInterval(0.2)) {
                self.refreshScores()
            }
            
            FunctionsClass().delayWithSeconds(TimeInterval(0.5)) {
                if(self.winner == self.roundTeam1) {
                    self.winner = self.gamesTeam1
                    self.partida.gameT1 += 1
                }
                else {
                    self.winner = self.gamesTeam2
                    self.partida.gameT2 += 1
                }
                
                self.refreshRounds()
                
                self.increasing = true
            }
            
            FunctionsClass().delayWithSeconds(TimeInterval(0.7)) {
                self.timerAnimate = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.sizeAnimate2), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func sizeAnimate2() {
        if (increasing) { sizeFont += 1 }
        else { sizeFont -= 1 }
        
        winner.font = winner.font.withSize(CGFloat(sizeFont))
        
        if(increasing && sizeFont >= maxFont) {increasing = false}
        
        if(sizeFont <= regularFont && !(increasing)) {
            sizeFont = regularFont
            partida.resetRound()
            
            timerAnimate.invalidate()
            inAnimate = false
        }
    }
    
    //    MARK: - POINTS MANAGER
    func refreshScores() {
        roundTeam1.text = String(partida.roundT1)
        roundTeam2.text = String(self.partida.roundT2)
    }
    
    func refreshRounds() {
        gamesTeam1.text = String(partida.gameT1)
        gamesTeam2.text = String(partida.gameT2)
    }
    
    func refreshAll() {
        refreshRounds()
        refreshScores()
    }
    
    //    MARK: - ALERTS
    func ConfirmationReset() {
        let refreshAlert = UIAlertController(title: "Deseja reiniciar a partida?", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.modalPresentationStyle = .popover
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.partida.resetRoundAndGame()
            self.refreshAll()
            
            if(UserDefaults.standard.bool(forKey: "noFirstUse")) {
                
                if(RazeFaceProducts.store.isProductPurchased("NoAds") || (UserDefaults.standard.object(forKey: "NoAds") != nil)) {
                    print("comprado")
                }
                else if(self.firstReset == 2) {
                    if self.interstitial.isReady {
                        self.interstitial.present(fromRootViewController: self)
                    }
                }
                else if (self.firstReset == 0){
                    self.rateApp()
                }
                
                self.firstReset += 1
            } else {
                UserDefaults.standard.set (true, forKey: "noFirstUse")
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel pressed")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func showMenu() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let ResetGame = UIAlertAction(title: "Reiniciar partida", style: .destructive, handler: { (action) -> Void in
            self.ConfirmationReset()
        })
        
        let GoOrdemDasCartas = UIAlertAction(title: "Ordem das cartas", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "CardsSeg", sender: nil)
        })
        
        let EditAction = UIAlertAction(title: "Opções", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "optionsSeg", sender: nil)
        })
        
        let TutorialShow = UIAlertAction(title: "Tutorial", style: .default, handler: { (action) -> Void in
            self.showTutorial()
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        
        optionMenu.addAction(ResetGame)
        optionMenu.addAction(GoOrdemDasCartas)
        optionMenu.addAction(EditAction)
        optionMenu.addAction(TutorialShow)
        optionMenu.addAction(cancelAction)
        
        optionMenu.modalPresentationStyle = .popover
        optionMenu.popoverPresentationController?.sourceView = self.view
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.2, width: 1.0, height: 1.0)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
//    MARK: - Tutorial
    func finishTutorialFunc() {
        backGroundBlack.alpha = 0
        for x in 0 ... 2 {
            LabelsTutorial[x].alpha = 0
            ImagesTutorial[x].alpha = 0
        }
        
        buttonTutorial.alpha = 0
        inAnimate = false
    }
    
    func showTutorial() {
        backGroundBlack.alpha = 0.8
        for x in 0 ... 2 {
            LabelsTutorial[x].alpha = 1
            ImagesTutorial[x].alpha = 1
        }
        
        buttonTutorial.alpha = 1
        inAnimate = true
    }
    
    // MARK: - Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func cropBounds(viewlayer: CALayer, cornerRadius: Float) {
        
        let imageLayer = viewlayer
        imageLayer.cornerRadius = CGFloat(cornerRadius)
        imageLayer.masksToBounds = true
    }
    
    func cropButtonImg() {
        var imageLayer: CALayer? = whiteButtonsSpeach.layer
        imageLayer?.cornerRadius = 29
        imageLayer?.masksToBounds = true
        
        imageLayer = blackButtonSpeach.layer
        imageLayer?.cornerRadius = 27
        imageLayer?.masksToBounds = true
    }
    // MARK: - FUNCTIONS
    func atualizeNamesTeams() {
        usTeamName.text = defaults.string(forKey: "usTeamName") ?? "Nós"
        theyTeamName.text = defaults.string(forKey: "theyTeamName") ?? "Eles"
    }
    
    func rateApp() {
        if #available(iOS 10.3, *) {

            SKStoreReviewController.requestReview()
        }
    }
    
    // MARK: - Speech
    func speechAction() {
        AudioServicesPlaySystemSound(SystemSoundID(1002))
        
        var myUtterance = AVSpeechUtterance(string: "Truuuco Marreco")
        
        delayWithSeconds(0.5) {
            let rand =  Int.random(in: 0...3)
            switch rand {
            case 0:
                myUtterance = AVSpeechUtterance(string: "Trururururururuco, Muito fácil com freguêis, quem vai pedir seis??")
                
                myUtterance.voice = AVSpeechSynthesisVoice(language: self.defaults.string(forKey: "LanguageVoice") ?? "pt-BR")
                myUtterance.rate = self.defaults.float(forKey: "rateValue")
                myUtterance.pitchMultiplier = 0.5
                myUtterance.volume = 10
                myUtterance.postUtteranceDelay =  0
                
                self.synth.speak(myUtterance)
                
            case 1:
                myUtterance = AVSpeechUtterance(string: "Trururururururuco Marreco!!!")
                
                myUtterance.voice = AVSpeechSynthesisVoice(language: self.defaults.string(forKey: "LanguageVoice") ?? "pt-BR")
                myUtterance.rate = self.defaults.float(forKey: "rateValue")
                myUtterance.pitchMultiplier = 0.5
                myUtterance.volume = 10
                myUtterance.postUtteranceDelay =  0
                
                self.synth.speak(myUtterance)
                
            case 2:
                myUtterance = AVSpeechUtterance(string: "Trururururururuco")
                
                myUtterance.voice = AVSpeechSynthesisVoice(language: self.defaults.string(forKey: "LanguageVoice") ?? "pt-BR")
                myUtterance.rate = self.defaults.float(forKey: "rateValue")
                myUtterance.pitchMultiplier = 0.5
                myUtterance.volume = 10
                myUtterance.postUtteranceDelay =  0
                
                self.synth.speak(myUtterance)
            default:
                myUtterance = AVSpeechUtterance(string: "Minhoca não tem osso, banana não tem caroço, TRUCO seu moço")
                
                myUtterance.voice = AVSpeechSynthesisVoice(language: self.defaults.string(forKey: "LanguageVoice") ?? "pt-BR")
                myUtterance.rate = self.defaults.float(forKey: "rateValue")
                myUtterance.pitchMultiplier = 0.5
                myUtterance.volume = 10
                myUtterance.postUtteranceDelay =  0
                
                self.synth.speak(myUtterance)
            }
        }
    }
    
    // MARK: - Draw
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      swiped = false
      lastPoint = touch.location(in: view)
        
        delayWithSeconds(0.3) {
          self.tempImageView.image = nil
          self.mainImageView.image = nil
        }
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        
      UIGraphicsBeginImageContext(view.frame.size)
      guard let context = UIGraphicsGetCurrentContext() else {
        return
      }
        
      tempImageView.image?.draw(in: view.bounds)
        
      context.move(to: fromPoint)
      context.addLine(to: toPoint)
      
      context.setLineCap(.round)
      context.setBlendMode(.normal)
      context.setLineWidth(brushWidth)
      context.setStrokeColor(color.cgColor)
      
      context.strokePath()
      
      tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = 0.5
      
      UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
        
      let currentPoint = touch.location(in: view)
      drawLine(from: lastPoint, to: currentPoint)
      
      lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      drawLine(from: lastPoint, to: lastPoint)
      // Merge tempImageView into mainImageView
      UIGraphicsBeginImageContext(mainImageView.frame.size)
      mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 0.5)
      tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: 0.5)
      
      mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        mainImageView.image = nil
        
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
//    MARK: - ADs
    
    func setupAds() {
        if(RazeFaceProducts.store.isProductPurchased("NoAds") || (UserDefaults.standard.object(forKey: "NoAds") != nil)) {
            if let banner = bannerView {
                banner.removeFromSuperview()
            }
            
            if let mktPlace = bannerVIewPlaceHolder {
                mktPlace.removeFromSuperview()
            }
            
            let margins = view.layoutMarginsGuide
            homeButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -10).isActive = true
        }
        else {
            bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
            addBannerViewToView(bannerView)
            
            bannerView.adUnitID = "ca-app-pub-8858389345934911/5265350806"
            bannerView.rootViewController = self
            
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
        ])
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}
