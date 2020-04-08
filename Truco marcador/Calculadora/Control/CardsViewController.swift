//
//  SceneDelegate.swift
//  Sueca
//
//  Created by Joao Flores on 01/12/19.
//  Copyright © 2019 Joao Flores. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController {

    
    @IBOutlet weak var Gaudério: UIView!
    @IBOutlet weak var paulistaList: UIView!
    @IBOutlet weak var mineiro: UIView!
    
    @IBOutlet weak var segmentRules: UISegmentedControl!
    @IBOutlet weak var label3: UILabel!
    
    @IBAction func close(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rules(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex
        {
        case 0:
//            paulista
            Gaudério.alpha = 0
            paulistaList.alpha = 1
            mineiro.alpha = 0
            
        case 1:
//            mineiro
            Gaudério.alpha = 0
            paulistaList.alpha = 0
            mineiro.alpha = 1
            
        default:
//            gaucho
            Gaudério.alpha = 1
            paulistaList.alpha = 0
            mineiro.alpha = 0
        }
    }
        override func viewDidLoad() {
            segmentRules.selectedSegmentIndex = 0
            Gaudério.alpha = 0
           paulistaList.alpha = 1
           mineiro.alpha = 0
    }
    
override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
}
}
