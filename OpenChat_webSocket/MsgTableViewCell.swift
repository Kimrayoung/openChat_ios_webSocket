//
//  tableViewCell.swift
//  OpenChat_webSocket
//
//  Created by 김라영 on 2023/04/25.
//

import Foundation
import UIKit

class MsgTableViewCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.borderWidth = 1
        backView.layer.cornerRadius = 10
    }
}
