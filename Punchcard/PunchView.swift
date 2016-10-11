//
//  PunchView.swift
//  Punchcard
//
//  Created by Sklar, Josh on 10/10/16.
//  Copyright © 2016 StockX. All rights reserved.
//

import UIKit

// Libs
import SnapKit

class PunchView: UIView {
    
    struct State {
        var emptyPunchImage: UIImage?
        var filledPunchImage: UIImage?
        
        var punchNumber: Int
        
        var isFilled: Bool
        
        var punchNumberFont: UIFont?
        var punchNumberColor: UIColor?
    }
    
    private let emptyPunchImageView = UIImageView()
    private let filledPunchImageView = UIImageView()
    private let punchNumberLabel = UILabel()
    
    /**
     View to contain all of the subviews and center them within the Punch View.
     */
    private let contentView = UIView()
    
    var state: State = State(emptyPunchImage: nil, filledPunchImage: nil, punchNumber: 0, isFilled: false, punchNumberFont: nil, punchNumberColor: nil) {
        didSet {
            update()
        }
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentView)
        
        contentView.addSubview(emptyPunchImageView)
        contentView.addSubview(filledPunchImageView)
        contentView.addSubview(punchNumberLabel)
        
        emptyPunchImageView.snp_makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        punchNumberLabel.textAlignment = .Center
        
        punchNumberLabel.snp_makeConstraints { make in
            make.top.equalTo(emptyPunchImageView.snp_bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        filledPunchImageView.snp_makeConstraints { make in
            make.edges.equalTo(self.emptyPunchImageView)
        }
        
        contentView.snp_makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented. Please use init(frame:)")
    }
    
    // MARK: State
    
    func update() {
        emptyPunchImageView.image = state.emptyPunchImage
        filledPunchImageView.image = state.filledPunchImage
        filledPunchImageView.hidden = !state.isFilled
        punchNumberLabel.text = "\(state.punchNumber)"
    }
}
