//
//  PunchcardView.swift
//  Punchcard
//
//  Created by Sklar, Josh on 10/10/16.
//  Copyright © 2016 StockX. All rights reserved.
//

import UIKit

// Libs
import SnapKit

class PunchcardView: UIView {
    
    struct State {
        var backgroundColor: UIColor
        var punchesRequired: Int
        var punchesReceived: Int
        
        var emptyPunchImage: UIImage?
        var filledPunchImage: UIImage?
        
        var rewardText: String
        
        var punchNumberFont: UIFont
        var punchNumberColor: UIColor
    }
    
    var state: State = State(backgroundColor: UIColor.whiteColor(),
                             punchesRequired: 0,
                             punchesReceived: 0,
                             emptyPunchImage: nil,
                             filledPunchImage: nil,
                             rewardText: "",
                             punchNumberFont: UIFont.systemFontOfSize(UIFont.systemFontSize()),
                             punchNumberColor: UIColor.lightGrayColor()) {
        didSet {
            update(oldValue)
        }
    }
    
    /**
     The content view area for the punches.
     Slightly inset from the edges of the `PunchcardView`, and has a
     border around it.
     */
    private var punchesContentView = UIView()
    
    private var punchViews = [PunchView]()
    private var rewardView = RewardView(frame: CGRectZero)
    private var spacerViews = [UIView]()
    
    // MARK: Init
    
    init(state: State) {
        super.init(frame: CGRect.zero)
        initialize()
        self.state = state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        punchesContentView.backgroundColor = UIColor.clearColor()
        punchesContentView.layer.borderWidth = 1.0
        addSubview(punchesContentView)
        
        punchesContentView.snp_makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

        layoutIfNeeded()
    }
    
    // MARK: View
    
    override func updateConstraints() {
        guard let emptyPunchImage = state.emptyPunchImage else {
            super.updateConstraints()
            return
        }
        
        // Calculate if the PunchcardView has enough size to accommodate all punchViews.
        let punchNumberLabelHeight = NSString(string: "1").sizeWithAttributes([NSFontAttributeName: state.punchNumberFont]).height
        let punchViewSize = CGSize(width: emptyPunchImage.size.width,
                                   height: emptyPunchImage.size.height + punchNumberLabelHeight)
        
        guard punchViewSize.height < punchesContentView.bounds.size.height &&
            ((punchViewSize.width * CGFloat(state.punchesRequired)) + rewardView.state.size.width) < punchesContentView.bounds.size.width else {
                print("Punchcard: PunchcardView is either too short or too tall to support the punchViews given the punch image and number of punches.\nPunchViews will be cut off.")
                super.updateConstraints()
                return
        }
        
        // Make sure there are enough spacer views.
        guard spacerViews.count == punchViews.count + 1 + 1 /* 2 because 1 for the right side, and 1 for the left of the spacer view */ else {
            print("Punchcard: There are not enough spacer views to constrain all punch views and the reward view.")
            super.updateConstraints()
            return
        }
        
        for (index, punchView) in punchViews.enumerate() {
            // If it is the first element, grab the first spacer view and constrain
            // it to the left and the right of the first punch view.
            if index == 0 {
                let firstSpacerView = spacerViews[index]
                firstSpacerView.snp_remakeConstraints { make in
                    make.left.equalToSuperview()
                    make.height.equalTo(0)
                    make.right.equalTo(punchView.snp_left)
                    make.centerY.equalToSuperview()
                }
            }
            
            // If it's somewhere in the middle of the end, anchor the left spacer
            // view to the right of the previous punchView and to the left of the
            // punchView, and equal width/height to the previous spacer.
            if index > 0 && index <= (punchViews.count - 1) {
                let leftSpacerView = spacerViews[index]
                let previousSpacerView = spacerViews[index - 1]
                let previousPunchView = punchViews[index - 1]
                
                leftSpacerView.snp_remakeConstraints { make in
                    make.height.equalTo(previousSpacerView.snp_height)
                    make.width.equalTo(previousSpacerView.snp_width)
                    make.centerY.equalToSuperview()
                    
                    make.left.equalTo(previousPunchView.snp_right)
                    make.right.equalTo(punchView.snp_left)
                }
            }
            
            // If it's the last one, anchor the right spacer view to the right of
            // the superview, and to the current punchView's left.
            if index == punchViews.count - 1 {
                let leftSpacerView = spacerViews[index]
                let rightSpacerView = spacerViews[index + 1]
                
                rightSpacerView.snp_remakeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.width.equalTo(leftSpacerView.snp_width)
                    make.height.equalTo(leftSpacerView.snp_height)
                    
                    make.left.equalTo(punchView.snp_right)
                    make.right.equalTo(rewardView.snp_left)
                }
            }
            
            // snp_make, not snp_remake, since we don't want to blow away its
            // existing constraints.
            punchView.snp_makeConstraints { make in
                make.centerY.equalToSuperview()
            }
            
        }
        
        rewardView.snp_remakeConstraints(closure: { (make) in
            make.centerY.equalToSuperview()
            
            // TODO: Determine the correct height/width. This should be the max of the punchView's images width/height
            make.width.equalTo(100)
            make.height.equalTo(100)
        })
        
        if let lastSpacerView = spacerViews.last, firstSpacerView = spacerViews.first {
            lastSpacerView.snp_remakeConstraints(closure: { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(rewardView.snp_right)
                make.right.equalToSuperview()
                
                make.width.equalTo(firstSpacerView.snp_width)
                make.height.equalTo(firstSpacerView.snp_height)
            })
        }
        
        super.updateConstraints()
    }
    
    // MARK: State
    
    func update(oldState: State) {
        // If the number of punches required has changed, remove the old ones
        // and add the new ones.
        if oldState.punchesRequired != state.punchesRequired {
            // Remove all punch views, spacer views, and reward view.
            punchViews.forEach {
                $0.removeFromSuperview()
            }
            spacerViews.forEach {
                $0.removeFromSuperview()
            }
            rewardView.removeFromSuperview()
            
            punchViews.removeAll()
            spacerViews.removeAll()
            
            for _ in 0..<state.punchesRequired {
                punchViews.append(PunchView(frame: CGRectZero))
                spacerViews.append(UIView(frame: CGRectZero))
            }
            
            // Add one more for the rewardView
            spacerViews.append(UIView(frame: CGRectZero))
            
            // Add one more spacer view for the right side.
            spacerViews.append(UIView(frame: CGRectZero))
            
            punchViews.forEach {
                self.punchesContentView.addSubview($0)
            }
            spacerViews.forEach {
                self.punchesContentView.addSubview($0)
            }
            punchesContentView.addSubview(rewardView)
        }
        
        // Update all the punchViews state's.
        for (index, punchView) in punchViews.enumerate() {
            var punchViewState = punchView.state
            punchViewState.emptyPunchImage = state.emptyPunchImage
            punchViewState.filledPunchImage = state.filledPunchImage
            punchViewState.punchNumber = index + 1
            punchViewState.isFilled = index < state.punchesReceived
            punchViewState.punchNumberFont = state.punchNumberFont
            punchViewState.punchNumberColor = state.punchNumberColor
            
            punchView.state = punchViewState
        }
        
        // Update the rewardView's state.
        var rewardViewState = rewardView.state
        rewardViewState.size = state.emptyPunchImage?.size ?? CGSizeZero
        rewardViewState.achieved = state.punchesReceived == state.punchesRequired
        rewardViewState.unachievedColor = state.punchNumberColor
        rewardViewState.achievedBackgroundColor = UIColor.greenColor() // TODO: Add this to the state
        rewardViewState.achievedTextColor = UIColor.whiteColor() // TODO: Add this to the state
        rewardViewState.text = state.rewardText
        rewardViewState.textFont = state.punchNumberFont
        rewardView.state = rewardViewState
        
        backgroundColor = state.backgroundColor
        punchesContentView.layer.borderColor = state.punchNumberColor.CGColor
        
        setNeedsUpdateConstraints()
    }
}
