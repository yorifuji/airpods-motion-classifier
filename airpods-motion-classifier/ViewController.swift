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

    let hmm = CMHeadphoneMotionManager()
    let classifier = HeadphoneMotionClassifier()

    override func viewDidLoad() {
        super.viewDidLoad()

        classifier.delegate = self

        if !hmm.isDeviceMotionAvailable {
            print("current device does not supports the headphone motion manager.")
            return
        }

        hmm.startDeviceMotionUpdates(to: .main) { (motion, error) in
            if let motion = motion {
//                print(motion)
                self.classifier.process(deviceMotion: motion)
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
        DispatchQueue.main.async {
            self.label.text = "\(results[0].0)\n\(results[0].1)"
        }
    }
}
