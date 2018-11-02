//
//  FilterCell.swift
//  CoreImageFilters
//
//  Created by Onur Işık on 2.11.2018.
//  Copyright © 2018 Onur Işık. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected {
                UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve,
                                  animations: {
                                    self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }, completion: nil)
                
            } else {
                UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve,
                                  animations: {
                                    self.transform = CGAffineTransform.identity
                }, completion: nil)
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 3.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
