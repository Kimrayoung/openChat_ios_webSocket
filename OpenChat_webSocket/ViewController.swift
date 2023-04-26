//
//  ViewController.swift
//  OpenChat_webSocket
//
//  Created by 김라영 on 2023/04/24.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var nickNameLabel: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nextBtn.addTarget(self, action: #selector(nextBtnClicked(_:)), for: .touchUpInside)
    }

    @objc func nextBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        //이거 누르면 채팅화면으로 변경
        guard let chatVC = ChatViewController.getInstance() else { return }
        chatVC.modalPresentationStyle = .overCurrentContext
        chatVC.modalTransitionStyle = .crossDissolve
        self.present(chatVC, animated: true)

        chatVC.nickName.text = nickNameLabel.text
    }

}


