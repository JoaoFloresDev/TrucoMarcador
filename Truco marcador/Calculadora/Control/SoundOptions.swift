//
//  ViewController.swift
//  SayItForMe
//
//  Created by Ryan Morrison on 25/08/2017.
//  Copyright © 2017 egoDev. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - SettingsDelegate declaration
protocol SettingsDelegate {
    func updateValues(volume: Float, pitch: Float, rate: Float, voice: AVSpeechSynthesisVoice?)
}

class Settings: UIViewController {
    
    // MARK: IBoutlets
    @IBOutlet weak var rateValueLabel: UILabel!
    @IBOutlet weak var pitchValueLabel: UILabel!
    @IBOutlet weak var rateValueSlider: UISlider!
    @IBOutlet weak var pitchValueSlider: UISlider!
    @IBOutlet weak var voiceSelected: UIPickerView!
    @IBOutlet weak var pickerView: UIPickerView!

    @IBAction func close(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Variables
    let voices = AVSpeechSynthesisVoice.speechVoices()
    var pickerValues: [String] = [String]()
    var delegate: SettingsDelegate?
    var settingsStartingValues:(volume: Float, pitch:  Float, rate: Float, voice: AVSpeechSynthesisVoice)?
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pickerView setuo
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        var i = 0
        var row = 0
        for voice in voices {
            pickerValues.append(voice.language)
            if  voice == settingsStartingValues?.voice {
                row = i
            }
            i += 1
        }
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        
        // sliders setup
        rateValueSlider.minimumValue = AVSpeechUtteranceMinimumSpeechRate
        rateValueSlider.maximumValue = AVSpeechUtteranceMaximumSpeechRate
        
        pitchValueSlider.minimumValue = 0.5
        pitchValueSlider.maximumValue = 2.0
        
        rateValueSlider.value = settingsStartingValues?.rate ?? rateValueSlider.minimumValue
        rateValueLabel.text = String(format: "%.2f", settingsStartingValues?.rate ?? rateValueSlider.minimumValue)
        pitchValueSlider.value = settingsStartingValues?.pitch ?? pitchValueSlider.minimumValue
        pitchValueLabel.text = String(format: "%.2f", settingsStartingValues?.pitch ?? pitchValueSlider.minimumValue)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        let voice = AVSpeechSynthesisVoice(identifier: voices[pickerView.selectedRow(inComponent: 0)].identifier)
//        delegate?.updateValues(pitch:pitchValueSlider.value , rate: rateValueSlider.value, voice: voice)
//    }
    
    // MARK: - IBAction methods
    @IBAction func sliderRateUpdatingValue(_ sender: UISlider) {
        rateValueLabel.text = String(format: "%.2f", rateValueSlider.value)
    }
    
    @IBAction func sliderPitchUpdatingValue(_ sender: UISlider) {
        pitchValueLabel.text = String(format: "%.2f", pitchValueSlider.value)
    }
}

// MARK: - Extensions
extension Settings: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
}

extension Settings: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row]
    }
    
//    defaults.set (newUsTeamName, forKey: "usTeamName")
}

