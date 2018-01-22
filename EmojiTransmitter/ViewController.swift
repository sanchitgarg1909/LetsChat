/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Starscream

final class ViewController: UIViewController {

  // MARK: - Properties
  var user: User?
  var group: Group?
  var groupList = [Group]()
  var socket = WebSocket(url: URL(string: "ws://192.168.0.108:8181/chat")!, protocols: ["chat"])

  // MARK: - IBOutlets
  @IBOutlet var emojiLabel: UILabel!
  @IBOutlet var usernameLabel: UILabel!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    socket.delegate = self
    socket.connect()

//    navigationItem.hidesBackButton = true
  }
  @IBAction func addGroup1(_ sender: UIButton) {
    group = Group(name: "group1")
    let jsonString = "{\"event\":\"addgroup\", \"name\": \"\((group?.name)!)\"}"
    socket.write(string: jsonString)
  }
  
  @IBAction func addGroup2(_ sender: UIButton) {
    group = Group(name: "group1")
    let jsonString = "{\"event\":\"addgroup\", \"name\": \"\((group?.name)!)\"}"
    socket.write(string: jsonString)
  }
  @IBAction func joinGroup1(_ sender: UIButton) {
    guard user != nil else {
      print("user is nil")
      return
    }
    var groupid: String = ""
    let alert = UIAlertController(title: "Join group", message: "Enter group id", preferredStyle: .alert)
    alert.addTextField(configurationHandler: { (textField) in
      textField.placeholder = "groupid"
    })
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
      if let field = alert.textFields?[0] {
        // store your data
        groupid = field.text!
        guard groupid != "" else {
          print ("enter something")
          return
        }
        let jsonString = "{\"event\":\"joingroup\", \"groupid\":\"\(groupid)\", \"userid\": \"\((self.user?.id)!)\"}"
        self.socket.write(string: jsonString)
      }
    }))
    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: { _ in
      
    }))
    self.present(alert, animated: true, completion: nil)
  }
  @IBAction func joinGroup2(_ sender: UIButton) {
    guard user != nil else {
      print("group or user is nil")
      return
    }
    
    let jsonString = "{\"event\":\"joingroup\", \"groupid\":\"\((groupList[1].id)!)\", \"userid\": \"\((user?.id)!)\"}"
    socket.write(string: jsonString)
  }
  @IBAction func sendMessage1(_ sender: UIButton) {
    guard user != nil else {
      print("group or user is nil")
      return
    }
    let jsonString = "{\"event\":\"sendmessage\", \"groupid\":\"\((groupList[0].id)!)\", \"userid\": \"\((user?.id)!)\", \"message\": \"hello group 1\"}"
    socket.write(string: jsonString)
  }
  @IBAction func sendMessage2(_ sender: UIButton) {
    guard user != nil else {
      print("group or user is nil")
      return
    }
    let jsonString = "{\"event\":\"sendmessage\", \"groupid\":\"\((groupList[1].id)!)\", \"userid\": \"\((user?.id)!)\", \"message\": \"hello group 2\"}"
    socket.write(string: jsonString)
  }
  
//  deinit {
//    socket.disconnect(forceTimeout: 0)
//    socket.delegate = nil
//  }
}

//// MARK: - IBActions
//extension ViewController {
//
//  @IBAction func selectedEmojiUnwind(unwindSegue: UIStoryboardSegue) {
//    guard let viewController = unwindSegue.source as? CollectionViewController,
//      let emoji = viewController.selectedEmoji() else {
//        return
//    }
//
//    sendMessage(emoji)
//  }
//}
//
//// MARK: - FilePrivate
//extension ViewController {
//
//  fileprivate func sendMessage(_ message: String) {
//    socket.write(string: message)
//  }
//
//  fileprivate func messageReceived(_ message: String, senderName: String) {
//    emojiLabel.text = message
//    usernameLabel.text = senderName
//  }
//}

// MARK: - WebSocketDelegate
extension ViewController : WebSocketDelegate {

  public func websocketDidConnect(_ socket: Starscream.WebSocket) {
    print("socket connected")
    user = User(name: "sanchit", email: "abc@gmail.com")
    let jsonString = "{\"event\": \"adduser\", \"name\": \"\((user?.name)!)\", \"email\": \"\((user?.email)!)\"}"
    socket.write(string: jsonString)
  }

  public func websocketDidDisconnect(_ socket: Starscream.WebSocket, error: NSError?) {
//    performSegue(withIdentifier: "websocketDisconnected", sender: self)
    print(error ?? "disconnected")
  }

  /* Message format:
   * {"type":"message","data":{"time":1472513071731,"text":"😍","author":"iPhone Simulator","color":"orange"}}
   */
  public func websocketDidReceiveMessage(_ socket: Starscream.WebSocket, text: String) {
    print(text)
    guard let data = text.data(using: .utf8),
      let jsonData = try? JSONSerialization.jsonObject(with: data, options: []),
      let jsonDict = jsonData as? [String: Any],
      let type = jsonDict["type"] as? String else {
        print("error in msg ")
        return
    }

    if type == "user" {
      let userId = jsonDict["id"] as? String
      print("userid: ",userId ?? "nil")
      user?.id = userId
    }
    else if type == "group" {
      let groupId = jsonDict["id"] as? String
      print("groupid: ",groupId ?? "nil")
      group?.id = groupId
      groupList.append(group!)
    }
    else if type == "chat" {
      let message = jsonDict["message"] as? String
      print("msg: ",message ?? "message was nil")
      let alert = UIAlertController(title: "New message", message: message ?? "message was nil", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
        
      }))
      self.present(alert, animated: true, completion: nil)
    }
    
  }

  public func websocketDidReceiveData(_ socket: Starscream.WebSocket, data: Data) {
    // Noop - Must implement since it's not optional in the protocol
  }

}
