//
//  CardsViewController.swift
//  Truco Marcador
//
//  Created by Joao Flores on 01/12/19.
//  Copyright © 2019 Joao Flores. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController {

    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var Gaudério: UIView!
    @IBOutlet weak var paulistaList: UIView!
    @IBOutlet weak var mineiro: UIView!
    
    @IBOutlet weak var scrollViewRules: UIScrollView!
    @IBOutlet weak var segmentRules: UISegmentedControl!
    
    @IBAction func close(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rules(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex
        {
        case 0:
//            paulista
            print("paulista")
            let targetRect = CGRect(x: 0, y:0, width: 1, height: 1)
            scrollViewRules.scrollRectToVisible(targetRect, animated: true)
            
        case 1:
//            mineiro
            print("mineiro")
            let targetRect = CGRect(x: backgroundView.frame.width*2, y:0, width: 1, height: 1)
            scrollViewRules.scrollRectToVisible(targetRect, animated: true)
            
        
        default:
//            gaucho
            print("gaucho")
            print(backgroundView.frame.width*3)
            let targetRect = CGRect(x: backgroundView.frame.width*3 - 100, y:0, width: 1, height: 1)
            scrollViewRules.scrollRectToVisible(targetRect, animated: true)
        }
    }
        override func viewDidLoad() {
            segmentRules.selectedSegmentIndex = 0
    }
    
override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
}
}
