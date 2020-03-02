//
//  PointsClass.swift
//  Calculadora
//
//  Created by Joao Flores on 01/11/19.
//  Copyright © 2019 Gustavo Lima. All rights reserved.
//

import UIKit

class FunctionsClass {
    
    init() {
        
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    
}
