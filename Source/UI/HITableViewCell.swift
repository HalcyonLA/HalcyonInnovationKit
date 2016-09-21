//
//  HITableViewCell.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

open class HITableViewCell: UITableViewCell {
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }
}
