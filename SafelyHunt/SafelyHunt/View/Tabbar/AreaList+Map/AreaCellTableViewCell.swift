//
//  AreaCellTableViewCell.swift
//  SafelyHunt
//
//  Created by Yoan on 28/07/2022.
//

import UIKit

class AreaCellTableViewCell: UITableViewCell {

    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var areaNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// insert accessory type
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = .detailButton
    }

    /// configure cell
    /// - Parameters:
    ///   - area: area at index
    ///   - cellIsSelected: cell selected by user
    func configureCell(area: Area, cellIsSelected: Bool) {
        areaNameLabel.text = area.name
        cityLabel.text = area.city

        guard let timeStampe = Double(area.date ?? "0") else {
                return
            }

            let myDate = Date(timeIntervalSince1970: TimeInterval(timeStampe))
            let numbersDays = numberDayBetween(from: myDate, to: Date())

            if numbersDays < 20 {
                dateLabel.text = myDate.relativeDate(relativeTo: Date())
            } else {
                dateLabel.text = DateFormatter.localizedString(from: myDate, dateStyle: .medium, timeStyle: .medium)
            }
        setCell(cellSelected: cellIsSelected)
    }

    /// set date to display it's date relative if date create is < to 20 day
    /// - Parameters:
    ///   - start: date created area
    ///   - end: date now
    /// - Returns: number days
    private func numberDayBetween(from start: Date, to end: Date) -> Int {
        let cal = Calendar.current
        let numbersDays = cal.dateComponents([.day], from: start, to: end)
        guard let numbersDays = numbersDays.day else {
            return 0
        }
        return numbersDays
    }

    /// set cell
    /// - Parameter cellSelected: it's area selected 
    private func setCell(cellSelected: Bool) {
        let checkmarck = UIImage(systemName: "checkmark.circle.fill")
        let circle = UIImage(systemName: "circle")

        checkmarkImage.image = (cellSelected) ? checkmarck : circle

        tintColor = .label
        dateLabel.textColor = .gray
        areaNameLabel.textColor = .label
        cityLabel.textColor = .label
        dateLabel.textColor = .gray

        areaNameLabel.font = .boldSystemFont(ofSize: 12)
        cityLabel.font = .boldSystemFont(ofSize: 12)
        dateLabel.font = .italicSystemFont(ofSize: 10)
    }
}
