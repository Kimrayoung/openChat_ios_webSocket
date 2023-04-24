//
//  ViewController.swift
//  OpenChat_webSocket
//
//  Created by 김라영 on 2023/04/24.
//

import UIKit

class ViewController: UIViewController {
    var webSocketTask: URLSessionWebSocketTask? = nil
    
    @IBOutlet weak var nickNameLabel: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //continue버튼을 누르면 채팅화면이 present되고 socket연결
    @objc func nextBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        //이거 누르면 채팅화면으로 변경
    }
    
    fileprivate func connectSocket() {
        //1. session만들어주기
        //2. url만들어주기
        //3. session과 url로 webSocketTask만들어주기
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        guard let url = URL(string: "wss://ws-ap3.pusher.com:443/app/bd0b7360f2c92f6cff54") else { return }
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
    }
    
    //MARK: - socket 구독 설정
    fileprivate func socketPublish() {
        
    }
    
    //MARK: - 소켓 연결 후에 들어오는 메시지들은 전부 여기로 들어와진다
    fileprivate func receiveMsg() {
        webSocketTask?.receive(completionHandler: { [weak self] (result: Result<URLSessionWebSocketTask.Message, Error>) in
            print(#fileID, #function, #line, "- <#comment#>")
            guard let self = self else { return }
            
            switch result {
            case .success(.string(let data)):
                print(#fileID, #function, #line, "- dataString: \(data)")
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

extension ViewController: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print(#fileID, #function, #line, "- success: \(session)")
    }
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print(#fileID, #function, #line, "- 연결 끊김 session: \(session)")
    }
}
