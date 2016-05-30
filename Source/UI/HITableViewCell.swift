//
//  HITableViewCell.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

class HITableViewCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutMargins = UIEdgeInsetsZero
    }
}