//
//  RestaurantTableViewCell.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 21/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var typeFoodLabel: UILabel!
    @IBOutlet weak var nameRestaurantLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.shadowColor = UIColor.lightGray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cardView.layer.shadowRadius = 4.0
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.cornerRadius = 5.0
        cardView.layer.masksToBounds = false
        cardView.tintColor = .white
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupRestaurant(_ restaurant: Restaurant) {
        restaurantImageView.loadImage(withURL: restaurant.image)
        typeFoodLabel.text = restaurant.type
        nameRestaurantLabel.text = restaurant.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        restaurantImageView.image = UIImage()
        typeFoodLabel.text = "'"
        nameRestaurantLabel.text = ""
    }
}
