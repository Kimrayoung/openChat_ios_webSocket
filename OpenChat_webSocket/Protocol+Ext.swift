//
//  Protocol+Ext.swift
//  OpenChat_webSocket
//
//  Created by 김라영 on 2023/04/25.
//

import Foundation
import UIKit

//Nib파일 가져오기
protocol Nibbed {
    static var uiNib: UINib { get }
}

extension Nibbed {
    static var uiNib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableViewCell: Nibbed {}

//Nib파일 이름 가져오기
protocol ReuseIdentifier {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifier {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifier {}

protocol Storyboarded {
    static func getInstance(_ storyboardName: String?) -> Self?
}

extension Storyboarded {
    static func getInstance(_ storyboardName: String? = nil) -> Self? {
        let name = storyboardName ?? String(describing: self)
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? Self
    }
}

extension UIViewController: Storyboarded {}

extension UIImageView {
    func loadImg(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
