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
    @IBOutlet weak var switchButton: UISwitch!
    
    @IBAction func close(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
        UserDefaults.standard.set(pickerView.selectedRow(inComponent: 0), forKey: "LanguageVoiceIndex")
        UserDefaults.standard.set(voices[pickerView.selectedRow(inComponent: 0)].language, forKey: "LanguageVoice")
        UserDefaults.standard.set(rateValueSlider.value, forKey: "rateValue")
        UserDefaults.standard.set(pitchValueSlider.value, forKey: "pitchValue")
        
        print(voices[pickerView.selectedRow(inComponent: 0)].language)
    }
    
    // MARK: - Variables
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        rateValueSlider.setValue(UserDefaults.standard.float(forKey: "rateValue"), animated: true)
        pitchValueSlider.setValue(UserDefaults.standard.float(forKey: "pitchValue"), animated: true)
        pickerView.selectRow(UserDefaults.standard.integer(forKey: "LanguageVoiceIndex"), inComponent: 0, animated: true)
        
        
        
        rateValueLabel.text = String(format: "%.2f", UserDefaults.standard.float(forKey: "rateValue"))
        pitchValueLabel.text = String(format: "%.2f", UserDefaults.standard.float(forKey: "pitchValue"))
        
    }
    
    @IBAction func activeSound(_ sender: Any) {
        if(switchButton.isOn) {
            UserDefaults.standard.set (true, forKey: "SomAtivo")
        } else {
            UserDefaults.standard.set (false, forKey: "SomAtivo")
        }
    }
    
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
}

