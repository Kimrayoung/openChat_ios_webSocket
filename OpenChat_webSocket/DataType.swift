//
//  DataType.swift
//  OpenChat_webSocket
//
//  Created by 김라영 on 2023/04/25.
//

import Foundation
import UIKit

// MARK: - message
struct MsgData: Codable {
    let id, username, message, createdAt: String?
}

//MARK: - socket 메시지 응답 형태
struct SocketMsgResponse: Codable {
    let event: String?
    let data: MsgData?
    let channel: String?
}

//MARK: - Socket 구독 응답 형태
struct SocketPublishResponse: Codable {
    let event: String?
    let data: PublishData?
}

struct PublishData: Codable {
    let channel: String?
}
