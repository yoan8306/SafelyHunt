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
            updateView()
        }
    }

    @IBAction func forwardButtonAction() {
        if index >= getImages().count - 1 {
            return
        } else {
            index += 1
            backwardButton.isHidden = false
            forwardButton.isHidden = index + 1 > getImages().count - 1
            updateView()
        }
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
        updateView()
    }

    /// Update imageView and description
    private func updateView() {
        imageTuto.image = getImages()[index]
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
        let image3 = UIImage(named: "GiveNameArea")
        let image4 = UIImage(named: "AreaList")
        let image5 = UIImage(named: "SetYourRadius")
        guard let image0, let image1, let image2, let image3, let image4, let image5 else {return [] }

        collectionImages.append(image0)
        collectionImages.append(image1)
        collectionImages.append(image2)
        collectionImages.append(image3)
        collectionImages.append(image4)
        collectionImages.append(image5)
        return collectionImages
    }

    /// get description for label
    /// - Parameter page: page tutorial
    /// - Returns: return description image
    private func getDescription(page: Int) -> String {
        switch page {
        case 0:
            return "Hello, for start click on select your area for create an area or select an area created"
        case 1:
            return "For create a new area click on \"+\". "
        case 2:
            return "Position your map where you want create area and click on button in corner right for draw your area with your finger"
        case 3:
            return "Give a new name at your area"
        case 4:
            return "Select your area"
        case 5:
            return "If another user is near of you, you are alerted"
        default:
            return "Welcome"
        }
    }
}
