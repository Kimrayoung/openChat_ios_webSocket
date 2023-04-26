//
//  DataType.swift
//  OpenChat_webSocket
//
//  Created by 김라영 on 2023/04/25.
//

import Foundation
import UIKit

// MARK: - message
struct MsgData: Hashable & Codable {
    let id, username, profileImage, message, createdAt: String?
}

//MARK: - Socket 구독 응답 형태
struct SocketPublishResponse: Codable {
    let event: String?
    let data: PublishData?
}

struct PublishData: Codable {
    let channel: String?
}
