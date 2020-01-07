//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Антон Потапчик on 1/6/20.
//  Copyright © 2020 TonyPo Production. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    // MARK: - Properties
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: UInt = 5 {
        didSet {
            setupButtons()
        }
    }
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    // MARK: - Initialization
    //    Code realization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    //    storyboard realization
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: - Button actions
    @objc func ratingButtontapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        // Calculate rating of selected buton
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    private func setupButtons() {
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Load button image
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        
        
        for _ in 0..<starCount{
        //    create button
        let button = UIButton()
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
        //    add constraints
        button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
        
        //    add action
        button.addTarget(self, action: #selector(ratingButtontapped(button:)), for: .touchUpInside)
        
        //    add button in stack
        addArrangedSubview(button)
            
        // add new button to the rating button array
            ratingButtons.append(button)
        }
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
