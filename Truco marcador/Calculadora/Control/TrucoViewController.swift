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

class TrucoViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
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
    var ratingShow = false
    var rateControll = 0
    //    MARK: -  IBOutlet
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBOutlet weak var usTeamName: UILabel!
    @IBOutlet weak var theyTeamName: UILabel!
    
    @IBOutlet weak var backGroundBlack: UIImageView!
    @IBOutlet var LabelsTutorial: [UILabel]!
    @IBOutlet var ImagesTutorial: [UIImageView]!
    @IBOutlet weak var buttonTutorial: UIButton!
    
    @IBOutlet weak var backGoundImg: UIImageView!
    
    //    labels rounds and games
    @IBOutlet weak var roundTeam1: UILabel!
    @IBOutlet weak var roundTeam2: UILabel!
    @IBOutlet weak var gamesTeam1: UILabel!
    @IBOutlet weak var gamesTeam2: UILabel!
    
    //    MARK: - IBAction
    @IBAction func finishTutorial(_ sender: Any) {
        backGroundBlack.alpha = 0
        for x in 0 ... 2 {
            LabelsTutorial[x].alpha = 0
            ImagesTutorial[x].alpha = 0
        }
        
        buttonTutorial.alpha = 0
        inAnimate = false
    }
    
    @IBAction func home(_ sender: Any) {
        showMenu()
    }

    //   MARK: - LIFE CYCLE
    override func viewDidLoad() {
        self.ratingShow = OptionsViewController().checkFirsGame()
        atualizeNamesTeams()
        partida = PointsClass()
        refreshScores()
        refreshRounds()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TrucoViewController.tap(_:)))
        self.view.addGestureRecognizer(tap)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    //   MARK: - GESTURES
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if !(inAnimate) {
            
            if gesture.direction == UISwipeGestureRecognizer.Direction.up {
                if(gesture.location(in: backGoundImg).x < backGoundImg.frame.size.width/2) {
                    partida.round1Sum3()
//                    SpeechThreePoint(points: "Tres pontos", team: usTeamName.text!)
                } else {
                    partida.roundT2 = partida.sum3(round: partida.roundT2)
//                    SpeechThreePoint(points: "Tres pontos", team: usTeamName.text!)
                }
                
                let currentPoint = gesture.location(in: view)
                drawLine(from: lastPoint, to: CGPoint(x: lastPoint.x, y: lastPoint.y - 100))
                
                lastPoint = currentPoint
            }
                
            else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
                if (gesture.location(in: backGoundImg).x < backGoundImg.frame.width/2) {
                    partida.roundT1 = partida.sub1(round: partida.roundT1)
//                    SpeechPoints (points: "Menos um ponto", team: usTeamName.text!)
                } else {
                    partida.roundT2 = partida.sub1(round: partida.roundT2)
//                    SpeechPoints (points: "Menos um ponto", team: theyTeamName.text!)
                }
                
                let currentPoint = gesture.location(in: view)
                drawLine(from: lastPoint, to: CGPoint(x: lastPoint.x, y: lastPoint.y + 100))
                
                lastPoint = currentPoint
            }
            
            if(partida.checkEndGame()) {
                if(partida.finshScoreboard() == 1) {
                    SpeechVictory(team: usTeamName.text!)
                } else {
                    SpeechVictory(team: theyTeamName.text!)
                }
                inAnimate = true
                animate()
                
            } else {
                refreshScores()
            }
        }
    }
    
    @objc func tap (_ gesture:UITapGestureRecognizer) {
        if !(inAnimate) {
            if(gesture.location(in: nil).x < backGoundImg.frame.size.width/2) {
                partida.roundT1 = partida.sum1(round: partida.roundT1)
//                SpeechPoints(points: "Um ponto",team: usTeamName.text!)
            } else {
                partida.roundT2 = partida.sum1(round: partida.roundT2)
//                SpeechPoints(points: "Um ponto",team: theyTeamName.text!)
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
                self.rateApp()
            } else {
                UserDefaults.standard.set (true, forKey: "noFirstUse")
            }
//            self.rateApp()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel pressed")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func showMenu() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let ResetGame = UIAlertAction(title: "Reiniciar partida", style: .destructive, handler: { (action) -> Void in
            
//            if(self.rateControll == 1) {
//                self.rateApp()
//            } else {
//                self.rateControll = self.rateControll + 1
//            }
            
            self.ConfirmationReset()
        })
        
        let GoOrdemDasCartas = UIAlertAction(title: "Ordem das cartas", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "CardsSeg", sender: nil)
        })
        
        let EditAction = UIAlertAction(title: "Opções", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "optionsSeg", sender: nil)
        })
        
//        let SoundAction = UIAlertAction(title: "Som", style: .default, handler: { (action) -> Void in
//            self.performSegue(withIdentifier: "soundSeg", sender: nil)
//        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        
        optionMenu.addAction(ResetGame)
        optionMenu.addAction(GoOrdemDasCartas)
        optionMenu.addAction(EditAction)
//        optionMenu.addAction(SoundAction)
        optionMenu.addAction(cancelAction)
        
        optionMenu.modalPresentationStyle = .popover
        optionMenu.popoverPresentationController?.sourceView = self.view
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 1.2, width: 1.0, height: 1.0)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: - FUNCTIONS
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func atualizeNamesTeams() {
        usTeamName.text = defaults.string(forKey: "usTeamName") ?? "Nós"
        theyTeamName.text = defaults.string(forKey: "theyTeamName") ?? "Eles"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        atualizeNamesTeams()
    }
    
    func rateApp() {
        if #available(iOS 10.3, *) {

            SKStoreReviewController.requestReview()
        }
        ratingShow = false
    }

    // MARK: - Speech
    
    func SpeechPoints (points: String, team: String) {
        
        if !synth.isSpeaking && defaults.bool(forKey: "SomAtivo") {
        
            let myUtterance = AVSpeechUtterance(string: "\(points) PARA \(team)")
            myUtterance.voice = AVSpeechSynthesisVoice(language: defaults.string(forKey: "LanguageVoice") ?? "pt-BR")
            myUtterance.rate = defaults.float(forKey: "rateValue")
            myUtterance.pitchMultiplier = defaults.float(forKey: "pitchValue")
            myUtterance.volume = 1
            myUtterance.postUtteranceDelay =  0
            
            synth.speak(myUtterance)
        }
    }
    
    func SpeechThreePoint (points: String, team: String) {
        
        if !synth.isSpeaking && defaults.bool(forKey: "SomAtivo") {
        
            var myUtterance = AVSpeechUtterance(string: "\(points) PARA \(team)")
            
            let rand = Int.random(in: 1..<5)
            if(rand == 4) {
                myUtterance = AVSpeechUtterance(string: "\(points) PARA \(team), minha mão tá coçando pra colar o zap na testa")
            }
            
            myUtterance.voice = AVSpeechSynthesisVoice(language: defaults.string(forKey: "LanguageVoice") ?? "pt-BR")
            myUtterance.rate = defaults.float(forKey: "rateValue")
            myUtterance.pitchMultiplier = defaults.float(forKey: "pitchValue")
            myUtterance.volume = 1
            myUtterance.postUtteranceDelay =  0
            
            synth.speak(myUtterance)
        }
    }
    
    func SpeechVictory (team: String) {
        print("ganhador \(team)")
//        if defaults.bool(forKey: "SomAtivo") {
//
//            let myUtterance = AVSpeechUtterance(string: "Fim de jogo, time \(team) é o vencedor, ha ha ha os caras eram uns pa tão")
//            myUtterance.voice = AVSpeechSynthesisVoice(language: defaults.string(forKey: "LanguageVoice") ?? "pt-BR")
//            myUtterance.rate = defaults.float(forKey: "rateValue")
//            myUtterance.pitchMultiplier = defaults.float(forKey: "pitchValue")
//            myUtterance.volume = 1
//            myUtterance.postUtteranceDelay =  0
//
//            synth.speak(myUtterance)
//        }
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
    
    @IBAction func openMktLink(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "https://www.whdecks.com.br/")! as URL)
    }
    
}
