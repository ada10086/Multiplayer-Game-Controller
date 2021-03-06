
import UIKit
import Starscream    // Socket library
import JoystickView  //JoystickView library


// Create an enumeration for direction commands.

// An enumeration defines a common type for a group of related values and enables you to work with those values in a type-safe way within your code.

// In this example we also map the enumeration values to the number exact codes we need send to the server for each direction.

// In this case it not only
enum DirectionCode: String {
    case up = "0"
    case right = "1"
    case down = "2"
    case left = "3"
}

let playerIdKey = "PLAYER_ID";


class ViewController: UIViewController, WebSocketDelegate, UITextFieldDelegate, JoystickViewDelegate {
    
    @IBOutlet weak var myJoystick: JoystickView!
    @IBOutlet weak var messageLabel: UILabel!
    

    // User UserDefaults for simple storage.
    var defaults: UserDefaults!
    
    // Object for managing the web socket.
    var socket: WebSocket?

    
    // Input text field.
    @IBOutlet weak var playerIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = "Ready?"

        
        //Assign JoystickView delegate to self
        myJoystick.form = .around
        myJoystick.delegate = self
        
        // URL of the websocket server.
        let urlString = "wss://gameserver.mobilelabclass.com"
    
        // Create a WebSocket.
        socket = WebSocket(url: URL(string: urlString)!)
        
        
        // Assign WebSocket delegate to self
        socket?.delegate = self
        
        // Connect.
        socket?.connect()
        
        // Assigning notifications to handle when the app becomes active or inactive.
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    
        // Set delegate for text field to conform to protocol.
        playerIdTextField.delegate = self


        // Init user defaults object for storage.
        defaults = UserDefaults.standard

        // Get USER DEFAULTS data. ////////////
        // If there is a player id saved, set text field.
        if let playerId = defaults.string(forKey: playerIdKey) {
            playerIdTextField.text = playerId
        }
        //////////////////////////////////////
    }


    // Textfield delegate method.
    // Update player id in user defaults when "Done" is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)

        // Check text field is not empty, otherwise save to user defaults.
        if (textField.text?.isEmpty)! {
            presentAlertMessage(message: "Enter Valid Player Id")
            textField.text = defaults.string(forKey: playerIdKey)!
        } else {

            // Set USER DEFAULTS data. ////////////
            defaults.set(textField.text!, forKey: playerIdKey)
            presentAlertMessage(message: "Player Id Saved!")
            //////////////////////////////////////
        }
        
        return false
    }
    

    // Helper method for displaying a alert view.
    func presentAlertMessage(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

    // WebSocket delegate methods
    func websocketDidConnect(socket: WebSocketClient) {
        print("✅ Connected")
        messageLabel.text = "Go!!!!!"
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("🛑 Disconnected:", error ?? "No message")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        // print("⬇️ websocket did receive message:", text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // print("<<< Received data:", data)
    }

    func sendDirectionMessage(_ code: DirectionCode) {
        // Get the raw string value from the DirectionCode enum
        // that we created at the top of this program.
        sendMessage(code.rawValue)
    }

    func sendMessage(_ message: String) {
        // Check if there is a valid player id set.
        guard let playerId = defaults.string(forKey: playerIdKey) else {
            presentAlertMessage(message: "Enter Player Id")
            return
        }

        // Construct server message and write to socket. ///////////
        let message = "\(playerId), \(message)"
        socket?.write(string: message) {
            // This is a completion block.
            // We can write custom code here that will run once the message is sent.
            print("⬆️ sent message to server: ", message)
        }
        ///////////////////////////////////////////////////////////
    }
    
    @objc func willResignActive() {
        print("💡 Application will resign active. Disconnecting socket.")
        socket?.disconnect()
    }
    
    @objc func didBecomeActive() {
        print("💡 Application did become active. Connecting socket.")
        socket?.connect()
    }
    
    //functions come with JoystickViewDelegate
    func joystickView(_ joystickView: JoystickView, didMoveto x: Float, y: Float, direction: JoystickMoveDriection) {
//        print("myJoystick move to x:\(x) y:\(y) direction:\(direction.rawValue)")
        if direction.rawValue == 1 {
            sendDirectionMessage(.up)
        } else if direction.rawValue == 2 {
            sendDirectionMessage(.down)
        } else if direction.rawValue == 3 {
            sendDirectionMessage(.left)
        } else {
            sendDirectionMessage(.right)
        }

    }
    
    func joystickViewDidEndMoving(_ joystickView: JoystickView) {
        print("myJoystick did end moving")
    }
}
