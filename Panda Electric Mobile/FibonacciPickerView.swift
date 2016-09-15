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
    let margin: CGFloat = 40
    let sequence: FibonacciSequence
    var stackView:UIStackView!
    
    init (sequence: FibonacciSequence) {
        self.sequence = sequence
        super.init(frame: CGRect.zero)
        setupNumberButtonsForSequence(sequence)
        setupScrollView()
        setupScrollContentView()
        setupMaskView()
        stackView.arrangedSubviews.forEach { (v: UIView) in
            bringSubview(toFront: v)
        }
//        bringSubviewToFront(stackView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// MARK: Setup
    
    fileprivate func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stackView.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: stackView.rightAnchor)])
    }
    
    fileprivate func setupScrollContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalTo: stackView.arrangedSubviews[0].heightAnchor, multiplier: 2 * CGFloat(sequence.numbers.count)-1, constant: 2 * spacing * CGFloat(sequence.numbers.count-1)),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),])
    }
    
    fileprivate func setupBackgroundImageView() {
        addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 30),
            backgroundImageView.centerXAnchor.constraint(equalTo: centerXAnchor),])
    }
    
    fileprivate func setupMaskView() {
        myMaskView.isUserInteractionEnabled = false
        myMaskView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        myMaskView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(myMaskView)
        NSLayoutConstraint.activate([
            myMaskView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            myMaskView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            myMaskView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            myMaskView.heightAnchor.constraint(equalTo: stackView.arrangedSubviews[0].heightAnchor, constant: spacing),])

    }
    
    fileprivate func setupNumberButtonsForSequence(_ sequence: FibonacciSequence) {
        var buttons = [UIView]()
        sequence.numbers.forEach { (number: FibonacciNumber) in
            let button = FibonacciNumberButton(fibonacciNumber: number)
            button.addTarget(self, action: #selector(FibonacciPickerView.selectFibonacciNumber), for: .touchUpInside)
            buttons.append(button)
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.backgroundColor = UIColor.orange.withAlphaComponent(0.3)
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
            stackView.rightAnchor.constraint(equalTo: rightAnchor)])
        self.stackView = stackView
    }
    
    /// MARK: Actions
    
    func selectFibonacciNumber(_ button: FibonacciNumberButton) {
        print("pressed \(button.fibonacciNumber.value)")
    }
    
    /// MARK: Snapping
    
    fileprivate func closestTargetContentOffsetForOffset(_ offset: CGPoint) -> CGFloat {
        let elementHeight = stackView.arrangedSubviews[0].frame.size.height + spacing
        
        let newOffset:CGFloat
        if (offset.y.truncatingRemainder(dividingBy: elementHeight)) > elementHeight/2 {
            newOffset = offset.y + (elementHeight - (offset.y.truncatingRemainder(dividingBy: elementHeight)))
        } else {
            newOffset = offset.y - (offset.y.truncatingRemainder(dividingBy: elementHeight))
        }
        
        return newOffset
    }
    
    /// MARK: UIScrollViewDelegate
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee.y = closestTargetContentOffsetForOffset(targetContentOffset.pointee)
    }
}
