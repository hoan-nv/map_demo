//
//  ResultCell.swift
//  wemap
//
//  Created by Nguyen Hoan on 27/05/2021.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDistrict: UILabel!
    @IBOutlet weak var lblDistant: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
