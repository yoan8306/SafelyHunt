//
//  LevelProfileViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 08/12/2022.
//
import GoogleMobileAds
import UIKit

class LevelProfileViewController: UIViewController {
    // MARK: - Properties
    var person = Person()
    var levelData = CalculationsPoints()
    var timer: Timer?
    var pointsTotalWin: Float = 0.0
    var pointsStart: Float = 0.0
    var rewardViewed = false
    var timerLoadReward: Timer?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var rewardedAd: GADRewardedAd?

    // MARK: - IBOutlet
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var currentPointsLabel: UILabel!
    @IBOutlet weak var nextLevelPointsLabel: UILabel!
    @IBOutlet weak var progressLevelView: UIProgressView!
    @IBOutlet weak var showVideoButton: UIButton!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getProfile()
        initButtonVideo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if rewardViewed {
            rewardViewed = false
            getProfile()
        }
        animateProgressView()
        loadRewardedAd()
    }

    // MARK: - Actions
    @IBAction func showVideoAction() {
        showAward()
    }

    @objc func animateLabelCount() {
          if pointsStart < pointsTotalWin {
              currentPointsLabel.text = "You have".localized(tableName: "Localizable") + " " + String(format: "%.2f", pointsTotalWin) + " points"
              switch pointsTotalWin > 50 {
              case true:
                  pointsStart += 1 + pointsStart
              case false:
                  pointsStart += 1
              }

          } else {
              currentPointsLabel.text = "You have".localized(tableName: "Localizable") + " " + String(format: "%.2f", pointsTotalWin) + " points"
              timer?.invalidate()
          }
      }

    // MARK: - functions
    func getProfile() {
        UserServices.shared.getProfileUser { [weak self] result in
            switch result {
            case .success(let person):
                self?.person = person
                self?.levelData.calculationPointsAndLevel(points: person.totalPoints)
                self?.pointsTotalWin = Float(person.totalPoints ?? 0)
                self?.initLabel()
                self?.animateProgressView()
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
            }
        }
    }

    private func animateProgressView() {
        pointsStart = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(animateLabelCount), userInfo: nil, repeats: true)
        progressLevelView.setProgress(Float(levelData.currentProgressValue), animated: true)
    }

  private func initLabel() {
      levelLabel.text = "Your actual level:".localized(tableName: "Localizable") + " \(levelData.actualLevel)"
      currentPointsLabel.text = "You have".localized(tableName: "Localizable") + " \(pointsStart) points"
        nextLevelPointsLabel.text = "/ " + String(format: "%.2f", Float((levelData.numbersPointsForNextLevel)))
        progressLevelView.progress = 0
    }

    private func initButtonVideo() {
        activityIndicator.layer.cornerRadius = 8
        activityIndicator.isHidden = false
        showVideoButton.isEnabled = false
        showVideoButton.setTitleColor(.black, for: .normal)
        showVideoButton.backgroundColor = #colorLiteral(red: 0.6659289002, green: 0.5453534722, blue: 0.3376245499, alpha: 1)
        showVideoButton.layer.cornerRadius = 8
    }

 @objc func loadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: AdMobIdentifier().videoAwardLevelId(),
                           request: request,
                           completionHandler: { [weak self] adReward, error in
            guard error == nil else {
                self?.timerLoadReward = Timer.scheduledTimer(timeInterval: 5, target: self!, selector: #selector(self?.loadRewardedAd), userInfo: nil, repeats: false)
                return
            }
            if let adReward = adReward {
                self?.activityIndicator.isHidden = true
                self?.showVideoButton.isEnabled = true
                self?.rewardedAd = adReward
                self?.timerLoadReward?.invalidate()
            }
        }
        )
    }

    func showAward() {
        pointsStart = 0
        if let adReward = rewardedAd {
            adReward.present(fromRootViewController: self) {
                let reward = adReward.adReward
                UserServices.shared.insertPoints(reward: Double(truncating: reward.amount))
                self.presentNativeAlertSuccess(alertMessage: "You win \(reward.amount)")
                self.rewardViewed = true
            }
        } else {
            self.presentAlertError(alertMessage: "No video available".localized(tableName: "Localizable"))        }
    }
}
