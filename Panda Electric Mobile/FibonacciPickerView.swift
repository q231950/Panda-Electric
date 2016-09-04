//
//  SequenceView.swift
//  Panda Electric Mobile
//
//  Created by Martin Kim Dung-Pham on 03/09/16.
//  Copyright © 2016 elbedev.com. All rights reserved.
//

import UIKit

class FibonacciPickerView: UIView, UIScrollViewDelegate {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let backgroundImageView = UIImageView(image: UIImage(named: "Background")!)
    let myMaskView = UIView()
    let spacing:CGFloat = 10
    let sequence: FibonacciSequence
    var stackView:UIStackView!
    
    init (sequence: FibonacciSequence) {
        self.sequence = sequence
        super.init(frame: CGRectZero)
        setupNumberButtonsForSequence(sequence)
        setupScrollView()
        setupScrollContentView()
        setupMaskView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// MARK: Setup
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        addSubview(scrollView)
        NSLayoutConstraint.activateConstraints([
            scrollView.topAnchor.constraintEqualToAnchor(stackView.topAnchor),
            scrollView.leftAnchor.constraintEqualToAnchor(stackView.leftAnchor),
            scrollView.bottomAnchor.constraintEqualToAnchor(stackView.bottomAnchor),
            scrollView.rightAnchor.constraintEqualToAnchor(stackView.rightAnchor)])
    }
    
    private func setupScrollContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activateConstraints([
            contentView.heightAnchor.constraintEqualToAnchor(stackView.arrangedSubviews[0].heightAnchor, multiplier: 2*CGFloat(sequence.numbers.count)-1, constant: 2*spacing*CGFloat(sequence.numbers.count-1)),
            contentView.topAnchor.constraintEqualToAnchor(scrollView.topAnchor),
            contentView.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor),
            contentView.leadingAnchor.constraintEqualToAnchor(scrollView.leadingAnchor),
            contentView.trailingAnchor.constraintEqualToAnchor(scrollView.trailingAnchor),
            contentView.widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor),])
    }
    
    private func setupBackgroundImageView() {
        addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            backgroundImageView.centerYAnchor.constraintEqualToAnchor(centerYAnchor, constant: 30),
            backgroundImageView.centerXAnchor.constraintEqualToAnchor(centerXAnchor),])
    }
    
    private func setupMaskView() {
        myMaskView.userInteractionEnabled = false
        myMaskView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        myMaskView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(myMaskView)
        NSLayoutConstraint.activateConstraints([
            myMaskView.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            myMaskView.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: 0),
            myMaskView.widthAnchor.constraintEqualToAnchor(contentView.widthAnchor),
            myMaskView.heightAnchor.constraintEqualToAnchor(stackView.arrangedSubviews[0].heightAnchor, constant: spacing),])

    }
    
    private func setupNumberButtonsForSequence(sequence: FibonacciSequence) {
        var buttons = [UIView]()
        sequence.numbers.forEach { (number: FibonacciNumber) in
            buttons.append(FibonacciNumberButton(fibonacciNumber: number))
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.alignment = .Center
        stackView.axis = .Vertical
        stackView.distribution = .FillEqually
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activateConstraints([
            stackView.topAnchor.constraintEqualToAnchor(topAnchor, constant: 40),
            stackView.leftAnchor.constraintEqualToAnchor(leftAnchor),
            stackView.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -40),
            stackView.rightAnchor.constraintEqualToAnchor(rightAnchor)])
        self.stackView = stackView
    }
    
    /// MARK: Snapping
    
    private func closestTargetContentOffsetForOffset(offset: CGPoint) -> CGFloat {
        let elementHeight = stackView.arrangedSubviews[0].frame.size.height + spacing
        
        let newOffset:CGFloat
        if (offset.y % elementHeight) > elementHeight/2 {
            newOffset = offset.y + (elementHeight - (offset.y % elementHeight))
        } else {
            newOffset = offset.y - (offset.y % elementHeight)
        }
        
        return newOffset
    }
    
    /// MARK: UIScrollViewDelegate
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.memory.y = closestTargetContentOffsetForOffset(targetContentOffset.memory)
    }
}