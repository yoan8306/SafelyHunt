//
//  AreaCellTableViewCell.swift
//  SafelyHunt
//
//  Created by Yoan on 28/07/2022.
//

import UIKit

class AreaCellTableViewCell: UITableViewCell {

    @IBOutlet weak var areaNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureCell(infoArea: Area, cellIsSelected: Bool) {
        areaNameLabel.text = infoArea.name
        cityLabel.text = infoArea.city

        guard let double = Double(infoArea.date ?? "0") else {
                return
            }

            let myDate = Date(timeIntervalSince1970: TimeInterval(double))
            let numbersDays = numberDayBetween(from: myDate, to: Date())

            if numbersDays < 20 {
                dateLabel.text = myDate.relativeDate(relativeTo: Date())
            } else {
                dateLabel.text = DateFormatter.localizedString(from: myDate, dateStyle: .medium, timeStyle: .medium)
            }
        setLabel(cellSelected: cellIsSelected, numbersDaysIsCreated: numbersDays)
    }

    private func numberDayBetween(from start: Date, to end: Date) -> Int {
        let cal = Calendar.current
        let numbersDays = cal.dateComponents([.day], from: start, to: end)
        guard let numbersDays = numbersDays.day else {
            return 0
        }
        return numbersDays
    }

    private func setLabel(cellSelected: Bool, numbersDaysIsCreated: Int) {
        accessoryType = (cellSelected) ? .checkmark : .detailButton
    
        if numbersDaysIsCreated < 2 {
            let green = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            tintColor = green
            dateLabel.textColor = green
            areaNameLabel.textColor = green
            cityLabel.textColor = green
            dateLabel.textColor = green
        } else {
            tintColor = .label
            dateLabel.textColor = .gray
            areaNameLabel.textColor = .label
            cityLabel.textColor = .label
            dateLabel.textColor = .gray
        }
        areaNameLabel.font = .boldSystemFont(ofSize: 12)
        cityLabel.font = .boldSystemFont(ofSize: 12)
        dateLabel.font = .italicSystemFont(ofSize: 10)
    }
}
