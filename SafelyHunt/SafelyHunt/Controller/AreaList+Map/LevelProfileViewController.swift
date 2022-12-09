//
//  LevelProfileViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 08/12/2022.
//

import UIKit

class LevelProfileViewController: UIViewController {
    var person = Person()
    var levelData = CalculationsPoints()
    var timer: Timer?
    var pointsTotalWin = 0
    var pointsStart = 0

    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var currentPointsLabel: UILabel!
    @IBOutlet weak var nextLevelPointsLabel: UILabel!
    @IBOutlet weak var progressLevelView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getProfile()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(animateLabelCount), userInfo: nil, repeats: true)
        progressLevelView.setProgress(Float(levelData.currentProgressValue), animated: true)
    }

    func getProfile() {
        UserServices.shared.getProfileUser { [weak self] result in
            switch result {
            case .success(let person):
                self?.person = person
                self?.levelData.calculationPointsAndLevel(points: person.totalPoints)
                self?.pointsTotalWin = Int(round(person.totalPoints ?? 0))
                self?.initLabel()
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
            }
        }
    }

    func initLabel() {
        levelLabel.text = "You are at level \(levelData.actualLevel)"
        currentPointsLabel.text = "You have \(pointsStart) points"
        nextLevelPointsLabel.text = "\(Int(round(levelData.numbersPointsForNextLevel)))"
        progressLevelView.progress = 0
    }

  @objc func animateLabelCount() {
      pointsStart += 1/pointsTotalWin
        if pointsStart < pointsTotalWin {
            currentPointsLabel.text = "You have \(pointsStart) points"
        } else {
            currentPointsLabel.text = "You have \(pointsTotalWin) points"
            timer?.invalidate()
        }
    }
}
