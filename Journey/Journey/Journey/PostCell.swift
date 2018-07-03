//
//  PostCell.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-24.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postPhoto: UIImageView!
    @IBOutlet weak var postText: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
