//
//  RewardView.swift
//  Punchcard
//
//  Created by Sklar, Josh on 10/11/16.
//  Copyright © 2016 StockX. All rights reserved.
//

import UIKit

// Libs
import SnapKit

/**
 Represents the last item on the Punchcard.
 
 Contains a circular label with text in it for the reward of filling
 every punch in the punchcard.
 */
class RewardView: UIView {
    
    private var label = UILabel()
    
    /// Used to draw the circular border around the `label`.
    private let circularBorderView = UIView()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(circularBorderView)
        circularBorderView.snp_makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        circularBorderView.addSubview(label)
        label.snp_makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        
        // Add aspect ration constraint
        addConstraint(NSLayoutConstraint(item: label,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: label,
            attribute: .Width,
            multiplier: 1.0,
            constant: 0.0))
        
        label.numberOfLines = 0
        label.text = "FREE\nSHIPPING"
        label.textAlignment = .Center
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented. Please use init(frame:)")
    }
    
    // MARK: View
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circularBorderView.layer.cornerRadius = circularBorderView.bounds.size.height / 2
    }
    
    // MARK: State
    
    func update() {
        circularBorderView.layer.borderColor = UIColor.blackColor().CGColor
        circularBorderView.layer.borderWidth = 1
    }
}
