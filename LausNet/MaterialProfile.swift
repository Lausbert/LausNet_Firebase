//
//  MaterialProfile.swift
//  LausNet
//
//  Created by Stephan Lerner on 28.11.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit

class MaterialProfile: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
}
