//
//  LevelProfileViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 08/12/2022.
//
import GoogleMobileAds
import UIKit

class LevelProfileViewController: UIViewController {
    var person = Person()
    var levelData = CalculationsPoints()
    var timer: Timer?
    var pointsTotalWin = 0
    var pointsStart = 0
    var rewardViewed = false
    private var rewardedAd: GADRewardedAd?

    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var currentPointsLabel: UILabel!
    @IBOutlet weak var nextLevelPointsLabel: UILabel!
    @IBOutlet weak var progressLevelView: UIProgressView!

    @IBOutlet weak var showVideoButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        getProfile()
        showVideoButton.layer.cornerRadius = 8
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

    @IBAction func showVideoAction() {
        showAward()
    }

    func getProfile() {
        UserServices.shared.getProfileUser { [weak self] result in
            switch result {
            case .success(let person):
                self?.person = person
                self?.levelData.calculationPointsAndLevel(points: person.totalPoints)
                self?.pointsTotalWin = Int(round(person.totalPoints ?? 0))
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
        nextLevelPointsLabel.text = "/\(Int(round(levelData.numbersPointsForNextLevel)))"
        progressLevelView.progress = 0
    }

  @objc func animateLabelCount() {
        if pointsStart < pointsTotalWin {
            currentPointsLabel.text = "You have".localized(tableName: "Localizable") + " \(pointsStart) points"
            switch pointsTotalWin > 50 {
            case true:
                pointsStart += 1 + pointsStart
            case false:
                pointsStart += 1
            }

        } else {
            currentPointsLabel.text = "You have".localized(tableName: "Localizable") + " \(pointsTotalWin) points"
            timer?.invalidate()
        }
    }

    func loadRewardedAd() {
        let bannerIDProd = "ca-app-pub-3063172456794459/3470661557"
        let bannerIDTest = "ca-app-pub-3940256099942544/1712485313"
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: bannerIDProd,
                           request: request,
                           completionHandler: { [weak self] adReward, error in
            if error != nil {
                self?.showVideoButton.backgroundColor = #colorLiteral(red: 0.2238582075, green: 0.3176955879, blue: 0.2683802545, alpha: 1)
                self?.showVideoButton.setTitleColor(.white, for: .disabled)
                self?.showVideoButton.isEnabled = false
                return
            }
            self?.rewardedAd = adReward
            self?.showVideoButton.isEnabled = true
            self?.showVideoButton.setTitleColor(.black, for: .normal)
            self?.showVideoButton.backgroundColor = #colorLiteral(red: 0.6659289002, green: 0.5453534722, blue: 0.3376245499, alpha: 1)
        }
        )
    }

    func showAward() {
        pointsStart = 0
        if let adReward = rewardedAd {
            adReward.present(fromRootViewController: self) {
                let reward = adReward.adReward
                UserServices.shared.insertPoints(reward: Int(truncating: reward.amount))
                self.presentNativeAlertSuccess(alertMessage: "You win \(reward.amount)")
                self.rewardViewed = true
            }
        }
    }
}
