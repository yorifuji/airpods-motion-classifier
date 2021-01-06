//
//  ViewController.swift
//  airpods-motion-classifier
//
//  Created by yorifuji on 2020/09/30.
//

import UIKit
import CoreMotion
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var labelIcon: UILabel!
    @IBOutlet weak var textView: UITextView!

    let hmm = CMHeadphoneMotionManager()
    let classifier = HeadphoneMotionClassifier()

    override func viewDidLoad() {
        super.viewDidLoad()

        classifier.delegate = self

        if !hmm.isDeviceMotionAvailable {
            print("current device does not supports the headphone motion manager.")
            return
        }

        let queue = OperationQueue()
        hmm.startDeviceMotionUpdates(to: queue) { (motion, error) in
            if let motion = motion {
//                print(motion)
                self.classifier.process(deviceMotion: motion)
                DispatchQueue.main.async {
                self.textView.text = """
                    加速度:
                        x: \(motion.userAcceleration.x)
                        y: \(motion.userAcceleration.y)
                        z: \(motion.userAcceleration.z)
                    """
                }
            }
            if let error = error {
                print(error)
            }
        }
    }
}


extension ViewController : HeadphoneMotionClassifierDelegate {
    func motionDidDetect(results: [(String, Double)]) {
        print(results)
//        if results[0].1 < 0.80 {
//            print("pass")
//            return
//        }
        DispatchQueue.main.async {
            if results[0].0 == "walk" {
                self.labelIcon.text = "🚶"
            }
            else  {
                self.labelIcon.text = "🧍"
            }
            self.label.text = "\(results[0].0)\n\(results[0].1)"
            self.label2.text = results.description
        }
    }
}
