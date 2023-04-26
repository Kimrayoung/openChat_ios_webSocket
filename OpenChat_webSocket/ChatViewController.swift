//
//  ChatViewController.swift
//  OpenChat_webSocket
//
//  Created by 김라영 on 2023/04/25.
//

import Foundation
import UIKit
import SwiftyJSON

class ChatViewController: UIViewController {
    var webSocketTask: URLSessionWebSocketTask? = nil
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var nickNameChangeBtn: UIButton!
    
    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var msgInputTextView: UITextView!
    @IBOutlet weak var sendMsgBtn: UIButton!
    
    var formatter = DateFormatter()
    
    var tableViewData : [MsgData] = []
    //diffableDataSource가 어떤 데이터 형태인지 표시
    var diffableDataSource: UITableViewDiffableDataSource<Int, MsgData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewSetting()
        sendMsgBtn.addTarget(self, action: #selector(sendMsgBtnClicked(_:)), for: .touchUpInside)
        connectSocket()
        messageTableView.register(MsgTableViewCell.uiNib, forCellReuseIdentifier: MsgTableViewCell.reuseIdentifier)
        
        //데이터 소스의 테이블 뷰랑 cellProvide를 세팅해주기 -> 즉, 어떤 테이블 뷰에 데이터를 넣어줄 것인지, 그리고 어떤 cell을 넣어줄 것인지
        diffableDataSource = UITableViewDiffableDataSource<Int, MsgData>(tableView: messageTableView, cellProvider: { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MsgTableViewCell.reuseIdentifier, for: indexPath) as? MsgTableViewCell else { return UITableViewCell() }

            cell.msgLabel.text = self.tableViewData[indexPath.row].message
            cell.timeLabel.text = self.tableViewData[indexPath.row].createdAt
            
            guard let nickName = self.nickName.text else { return UITableViewCell() }
            if self.tableViewData[indexPath.row].username == nickName {
                cell.backgroundColor = .blue
            }

            return cell
        })
        
    }
    
    func textViewSetting() {
        msgInputTextView.layer.borderWidth = 1
        msgInputTextView.layer.borderColor = UIColor.black.cgColor
        msgInputTextView.layer.cornerRadius = 10
        
        sendMsgBtn.layer.borderWidth = 1
        sendMsgBtn.layer.borderColor = UIColor.black.cgColor
        sendMsgBtn.layer.cornerRadius = 10
    }
    
    //MARK: - 채팅 보내기
    @objc func sendMsgBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- <#comment#>")
        
        let urlString = "https://phplaravel-574671-3402493.cloudwaysapps.com/api/new-message"
        
        guard let url = URL(string: urlString),
              let msg = msgInputTextView.text,
              let nickname = nickName.text else { return }
        
        let sendMsg : [String : Any] = [
            "username" : nickname,
            "message"  : msg
        ]
        
        do {
            guard let msgSendData = try? JSONSerialization.data(withJSONObject: sendMsg, options: .prettyPrinted) else { return }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = msgSendData
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, res, err in
                print(#fileID, #function, #line, "- err: \(String(describing: err))")
            }
            task.resume()
        }
        
        
    }
    
    //MARK: - 소켓 연결 설정
    fileprivate func connectSocket() {
        print(#fileID, #function, #line, "- connectSocket")
        //1. session만들어주기
        //2. url만들어주기
        //3. session과 url로 webSocketTask만들어주기
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        guard let url = URL(string: "wss://ws-ap3.pusher.com:443/app/bd0b7360f2c92f6cff54") else { return }
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        socketPublish()

        receiveMsg()
    }
    
    //MARK: - socket 구독 설정
    fileprivate func socketPublish() {
        let json: JSON = ["data" : ["channel": "public.room"], "event": "pusher:subscribe"]
        guard let jsonString = json.rawString() else { return }
        print(#fileID, #function, #line, "- jsonString: \(jsonString)")
        let socketPublishMsg = URLSessionWebSocketTask.Message.string(jsonString)
        
        self.webSocketTask?.send(socketPublishMsg, completionHandler: { err in
            print(#fileID, #function, #line, "- err: \(err)")
        })
    }
    
    //MARK: - 소켓 연결 후에 들어오는 메시지들은 전부 여기로 들어와진다
    fileprivate func receiveMsg() {
        print(#fileID, #function, #line, "- receiveMsg")
        webSocketTask?.receive(completionHandler: { [weak self] (result: Result<URLSessionWebSocketTask.Message, Error>) in
            print(#fileID, #function, #line, "- <#comment#>")
            guard let self = self else { return }
            
            switch result {
            case .success(.string(let data)):
                print(#fileID, #function, #line, "- dataString: \(data)")
                //딕셔너리 형태로 데이터 만들기
                var convertMsg : Dictionary<String, Any> = [String : Any]()
                do {
                    //딕셔너리에 데이터 저장
                    convertMsg = try JSONSerialization.jsonObject(with: Data(data.utf8)) as! [String : Any]
                    print(#fileID, #function, #line, "- convertMsg: \(convertMsg)")
                    //딕셔너리에 저장된 데이터 중에 event가 message.new일때
                    if convertMsg["event"] as? String ?? "" == "message.new" {
                        let chatData = convertMsg["data"] as? String ?? ""
                        print(#fileID, #function, #line, "- chatData: \(chatData)")
                        //메시지 데이터를 Json을 String으로 변경
                        guard let tempMsg = chatData.data(using: .utf8) else { return }
                        //메시지가 내가 보낸 메시지인지 아닌지 확인
                        
                        guard let newMsg = try? JSONDecoder().decode(MsgData.self, from: tempMsg) else { return }
                        
                        DispatchQueue.main.async {
                            print(#fileID, #function, #line, "- username: \(convertMsg["username"] as? String ?? ""), nickName: \(self.nickName.text!)")
                            guard let nickName = self.nickName.text else { return }
                            if convertMsg["username"] as? String ?? "" == nickName {
                                print(#fileID, #function, #line, "- 내가 보낸 메시지")
                                return
                            }
                            
                            //테이블 뷰의 데이터에 append
                            self.tableViewData.append(newMsg)
                            print(#fileID, #function, #line, "- ⭐️data checking: \(self.tableViewData)")

                            // Create a snapshot.
                            var snapshot = NSDiffableDataSourceSnapshot<Int, MsgData>()

                            // Populate the snapshot.
                            snapshot.appendSections([0])
                            snapshot.appendItems(self.tableViewData)

                            // Apply the snapshot.
                            self.diffableDataSource.apply(snapshot, animatingDifferences: true)
                            self.receiveMsg()
                        }
                        
                    }
                } catch {
                    print(#fileID, #function, #line, "- err: \(error.localizedDescription)")
                }
                self.receiveMsg()
            case .success(.data(let data)):
                print(#fileID, #function, #line, "- data: \(data)")
            case .success(_):
                print(#fileID, #function, #line, "- just success")
            case .failure(let err):
                print(#fileID, #function, #line, "- err: \(err)")
            }
        })
    }
}



extension ChatViewController: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print(#fileID, #function, #line, "- success: \(session)")
    }
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print(#fileID, #function, #line, "- 연결 끊김 session: \(session)")
    }
}
