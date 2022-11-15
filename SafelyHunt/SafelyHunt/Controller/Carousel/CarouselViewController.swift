//
//  CarouselViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 11/10/2022.
//

import UIKit

class CarouselViewController: UIViewController {
// MARK: - IBOutlet
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pagesControl: UIPageControl!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var uiIViewSwipe: UIView!
    @IBOutlet weak var imageTuto: UIImageView!

// MARK: - Properties
    var index = 0

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        setUIView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.Keys.tutorialHasBeenSeen)
    }

// MARK: - IBAction
    @IBAction func backwardButtonAction() {
        if index <= 0 {
            return
        } else {
            index -= 1
            forwardButton.isHidden = false
            backwardButton.isHidden = index - 1 < 0
            updateView(animation: .transitionFlipFromLeft)
        }
    }

    @IBAction func forwardButtonAction() {
        if index >= getImages().count - 1 {
            return
        } else {
            index += 1
            backwardButton.isHidden = false
            forwardButton.isHidden = index + 1 > getImages().count - 1
            updateView(animation: .transitionFlipFromRight)
        }
    }

    @IBAction func closeButtonAction() {
        dismiss(animated: true)
    }

    @objc private func swipeImage(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            forwardButtonAction()
        case .right:
            backwardButtonAction()
        default:
            break
        }
    }

// MARK: - Privates functions

    /// insert swipe gesture to UIView
    private func addSwipeGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeImage(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeImage(_:)))
        swipeLeft.direction = .left
        swipeRight.direction = .right
        uiIViewSwipe.addGestureRecognizer(swipeLeft)
        uiIViewSwipe.addGestureRecognizer(swipeRight)
    }

    /// initUIView
    private func setUIView() {
        pagesControl.numberOfPages = getImages().count
        pagesControl.currentPage = 0
        backwardButton.isHidden = true
        updateView(animation: .transitionCrossDissolve)
    }

    /// Update imageView and description
    private func updateView(animation: UIView.AnimationOptions) {
        UIView.transition(with: imageTuto, duration: 0.7, options: animation) {
            self.imageTuto.image = self.getImages()[self.index]
        }

        descriptionLabel.text = getDescription(page: index)
        pagesControl.currentPage = index
    }

    /// get images for tutorial
    /// - Returns: images for tutoriel
    private func getImages() -> [UIImage] {
        var collectionImages: [UIImage] = []
        let image0 = UIImage(named: "page1")
        let image1 = UIImage(named: "page2")
        let image2 = UIImage(named: "page3")
        let image3 = UIImage(named: "page4")
        let image4 = UIImage(named: "page5")
        let image5 = UIImage(named: "page6")
        let image6 = UIImage(named: "page7")
        let image7 = UIImage(named: "page8")
        let image8 = UIImage(named: "page9")

        guard let image0,
              let image1,
              let image2,
              let image3,
              let image4,
              let image5,
              let image6,
              let image7,
              let image8
        else {return []}

        collectionImages.append(image0)
        collectionImages.append(image1)
        collectionImages.append(image2)
        collectionImages.append(image3)
        collectionImages.append(image4)
        collectionImages.append(image5)
        collectionImages.append(image6)
        collectionImages.append(image7)
        collectionImages.append(image8)
        return collectionImages
    }

    /// get description for label
    /// - Parameter page: page tutorial
    /// - Returns: return description image
    private func getDescription(page: Int) -> String {
        switch page {
        case 0:
            return "Hello, \nFor start click on \"Select your hunting area\" for create an area or select.".localized(tableName: "LocalizableCarousel")

        case 1:
            return "For create a new area click on \"+\".".localized(tableName: "LocalizableCarousel")

        case 2:
            return "Position your map and click on button for draw your area with your finger.".localized(tableName: "LocalizableCarousel")

        case 3:
            return "Give a new name at your area".localized(tableName: "LocalizableCarousel")

        case 4:
            return "Go back and select your area.".localized(tableName: "LocalizableCarousel")

        case 5:
            return "You can be alerted if someone is near you. To do this, set the distance where you want to receive the alert by clicking on \"Set your radius alert\".".localized(tableName: "LocalizableCarousel")
        case 6:
            return "Set the distance with slider.".localized(tableName: "LocalizableCarousel")

        case 7:
            return "Your are ready! \nYou can click \"Start Monitoring\".".localized(tableName: "LocalizableCarousel")

        case 8:
            return "You can reduce application. You will receive an alert if you exit your area or if another user is near you. \nYou can show again this tutorial in your setting. Enjoy !".localized(tableName: "LocalizableCarousel")

        default:
            return ""
        }
    }
}
