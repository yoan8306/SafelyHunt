//
//  CarouselViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 11/10/2022.
//

import UIKit

class CarouselViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pagesControl: UIPageControl!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var uiIViewSwipe: UIView!
    @IBOutlet weak var imageTuto: UIImageView!

    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        setUIView()
    }

    @IBAction func backwardButtonAction() {
        if index <= 0 {
            return
        } else {
            index -= 1
            forwardButton.isHidden = true
            backwardButton.isHidden = index + 1 <= 0
            updateView()
        }
    }

    @IBAction func forwardButtonAction() {
        if index >= getImages().count - 1 {
            return
        } else {
            index += 1
            backwardButton.isHidden = false
            forwardButton.isHidden = index + 1 >= getImages().count - 1
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

    private func addSwipeGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeImage(_:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeImage(_:)))
        swipeLeft.direction = .left
        swipeRight.direction = .right
        uiIViewSwipe.addGestureRecognizer(swipeLeft)
        uiIViewSwipe.addGestureRecognizer(swipeRight)
    }

    private func setUIView() {
        pagesControl.numberOfPages = getImages().count
        pagesControl.currentPage = 0
        backwardButton.isHidden = true
        updateView()
    }

    private func updateView() {
        imageTuto.image = getImages()[index]
        descriptionLabel.text = getDescription(page: index)
        pagesControl.currentPage = index
    }

    private func getImages() -> [UIImage] {
        var collectionImages: [UIImage] = []
        let image1 = UIImage(named: "page1")
        let image2 = UIImage(named: "AreaList")
        let image3 = UIImage(named: "PositionMap")
        let image4 = UIImage(named: "GiveNameArea")
        let image5 = UIImage(named: "SetYourRadius")
        guard let image4, let image5, let image3, let image2, let image1 else {return [] }

        collectionImages.append(image1)
        collectionImages.append(image2)
        collectionImages.append(image3)
        collectionImages.append(image4)
        collectionImages.append(image5)
        return collectionImages
    }

    private func getDescription(page: Int) -> String {
        switch page {
        case 0:
            return "Hello, for start click on select your area for create an area or select an area created"
        case 1:
            return "here you can record the areas and see area on map after click info button. \nFor create a new area click on \"+\". "
        case 2:
            return "Position your map where you want create area and click on button in corner right for draw your area with your finger"
        case 3:
            return "Give a new name at your area"
        case 4:
            return "If another user is near of you, you are alerted"
        default:
            return "Welcome"
        }
    }

}

