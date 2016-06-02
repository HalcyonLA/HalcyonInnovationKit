//
//  HITableViewCell.swift
//  HalcyonInnovationKit
//
//  Created by Vlad Getman on 24.05.16.
//  Copyright © 2016 Vlad Getman. All rights reserved.
//

import Foundation

public class HITableViewCell: UITableViewCell {
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
    }
}