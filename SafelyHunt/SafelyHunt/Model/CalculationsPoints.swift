//
//  CalculationsPoints.swift
//  SafelyHunt
//
//  Created by Yoan on 09/12/2022.
//

import Foundation

class CalculationsPoints {
    var actualLevel = 0
    var numbersPointsForNextLevel = 10.0
    var currentProgressValue = 0.0

    func calculationPointsAndLevel(points: Double?) {
        if let points = points {
            calculationActualLevel(points: points)
            calculationNumberPointsForNextLevel()
            calculationCurrentProgress(points: points)
        }
    }

    private func calculationActualLevel(points: Double) {
        actualLevel = Int(pow((points)/10, 1/1.5))
    }

    private func calculationNumberPointsForNextLevel() {
        let nextLevel = actualLevel + 1
        numbersPointsForNextLevel = pow(Double(nextLevel), 1.5) * 10
    }

    private func calculationCurrentProgress(points: Double) {
        let beforeValueOfLevel = pow(Double(actualLevel), 1.5) * 10
        currentProgressValue = (points - beforeValueOfLevel)/(numbersPointsForNextLevel - beforeValueOfLevel)
    }

}
