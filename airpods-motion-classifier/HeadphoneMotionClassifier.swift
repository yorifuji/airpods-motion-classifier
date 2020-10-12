//
//  HeadphoneMotionClassifier.swift
//  airpods-motion-classifier
//
//  Created by yorifuji on 2020/09/30.
//

import Foundation
import CoreML
import CoreMotion

protocol HeadphoneMotionClassifierDelegate: class {
    func motionDidDetect(results: [(String, Double)])
}

class HeadphoneMotionClassifier {

    weak var delegate: HeadphoneMotionClassifierDelegate?

    static let configuration = MLModelConfiguration()
    let model = try! HumanActivityClassifier_30(configuration: configuration)

    static let predictionWindowSize = 100
    let acceleration_x = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let acceleration_y = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let acceleration_z = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
//    let attitude_pitch = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let attitude_roll = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let attitude_yaw = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let gravity_x = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let gravity_y = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let gravity_z = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let quaternion_x = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let quaternion_y = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let quaternion_z = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let quaternion_w = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let rotation_x = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let rotation_y = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let rotation_z = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)

    private var predictionWindowIndex = 0

    func process(deviceMotion: CMDeviceMotion) {

        if predictionWindowIndex == HeadphoneMotionClassifier.predictionWindowSize {
            return
        }

        acceleration_x[[predictionWindowIndex] as [NSNumber]] = deviceMotion.userAcceleration.x as NSNumber
        acceleration_y[[predictionWindowIndex] as [NSNumber]] = deviceMotion.userAcceleration.y as NSNumber
        acceleration_z[[predictionWindowIndex] as [NSNumber]] = deviceMotion.userAcceleration.z as NSNumber
//        attitude_pitch[[predictionWindowIndex] as [NSNumber]] = deviceMotion.attitude.pitch as NSNumber
//        attitude_roll[[predictionWindowIndex] as [NSNumber]] = deviceMotion.attitude.roll as NSNumber
//        attitude_yaw[[predictionWindowIndex] as [NSNumber]] = deviceMotion.attitude.yaw as NSNumber
//        gravity_x[[predictionWindowIndex] as [NSNumber]] = deviceMotion.gravity.x as NSNumber
//        gravity_y[[predictionWindowIndex] as [NSNumber]] = deviceMotion.gravity.y as NSNumber
//        gravity_z[[predictionWindowIndex] as [NSNumber]] = deviceMotion.gravity.z as NSNumber
//        quaternion_x[[predictionWindowIndex] as [NSNumber]] = deviceMotion.attitude.quaternion.x as NSNumber
//        quaternion_y[[predictionWindowIndex] as [NSNumber]] = deviceMotion.attitude.quaternion.y as NSNumber
//        quaternion_z[[predictionWindowIndex] as [NSNumber]] = deviceMotion.attitude.quaternion.z as NSNumber
//        quaternion_w[[predictionWindowIndex] as [NSNumber]] = deviceMotion.attitude.quaternion.w as NSNumber
//        rotation_x[[predictionWindowIndex] as [NSNumber]] = deviceMotion.rotationRate.x as NSNumber
//        rotation_y[[predictionWindowIndex] as [NSNumber]] = deviceMotion.rotationRate.y as NSNumber
//        rotation_z[[predictionWindowIndex] as [NSNumber]] = deviceMotion.rotationRate.z as NSNumber

        predictionWindowIndex += 1

        if predictionWindowIndex == HeadphoneMotionClassifier.predictionWindowSize {
            DispatchQueue.global().async {
                self.predict()
                DispatchQueue.main.async {
                    self.predictionWindowIndex = 0
                }
            }
        }
    }

    var stateOut: MLMultiArray? = nil

    private func predict() {

        let input = HumanActivityClassifier_30Input(
            acceleration_x: acceleration_x,
            acceleration_y: acceleration_y,
            acceleration_z: acceleration_z)

//            acceleration_x: acceleration_x,
//            acceleration_y: acceleration_y,
//            acceleration_z: acceleration_z,
//            attitude_pitch: attitude_pitch,
//            attitude_roll: attitude_roll,
//            attitude_yaw: attitude_yaw,
//            gravity_x: gravity_x,
//            gravity_y: gravity_y,
//            gravity_z: gravity_z,
//            quaternion_w: quaternion_w,
//            quaternion_x: quaternion_x,
//            quaternion_y: quaternion_y,
//            quaternion_z: quaternion_z,
//            rotation_x: rotation_x,
//            rotation_y: rotation_y,
//            rotation_z: rotation_z,
//            stateIn: self.stateOut

        guard let result = try? model.prediction(input: input) else { return }

        let sorted = result.labelProbability.sorted {
            return $0.value > $1.value
        }
        delegate?.motionDidDetect(results: sorted)

        self.stateOut = result.stateOut
    }
}
