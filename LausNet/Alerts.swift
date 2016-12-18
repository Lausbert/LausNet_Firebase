//
//  Alerts.swift
//  LausNet
//
//  Created by Stephan Lerner on 18.12.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation
import UIKit

func showErrorAlert(title: String, msg: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
    alert.addAction(action)
    return alert
}
