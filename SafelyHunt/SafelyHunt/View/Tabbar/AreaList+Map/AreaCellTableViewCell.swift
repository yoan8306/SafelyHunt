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
        accessoryType = .detailButton
    }

    func configureCell(infoArea: Area, cellSelected: Bool) {
        areaNameLabel.text = infoArea.name
        cityLabel.text = infoArea.city

        guard let double = Double(infoArea.date ?? "0") else {
                return
            }

            let myDate = Date(timeIntervalSince1970: TimeInterval(double))
            let numbersDays = numberDayBetween(from: myDate, to: Date())

            if numbersDays < 20 {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .full
                dateLabel.text = formatter.localizedString(for: myDate, relativeTo: Date())
            } else {
                dateLabel.text = DateFormatter.localizedString(from: myDate, dateStyle: .medium, timeStyle: .medium)
            }
        setLabel(cellSelected: cellSelected)
    }

    private func numberDayBetween(from: Date, to: Date) -> Int {
        let cal = Calendar.current
        let numbersDays = cal.dateComponents([.day], from: from, to: to)
        guard let numbersDays = numbersDays.day else {
            return 0
        }
        return numbersDays
    }

    private func setLabel(cellSelected: Bool) {
        areaNameLabel.font = .boldSystemFont(ofSize: 12)
        cityLabel.font = .boldSystemFont(ofSize: 12)
        dateLabel.font = .italicSystemFont(ofSize: 10)
        dateLabel.textColor = .gray
        if cellSelected {
            areaNameLabel.textColor = .red
            dateLabel.textColor = .red
            cityLabel.textColor  = .red
        } else {
            areaNameLabel.textColor = .label
            cityLabel.textColor = .label
            dateLabel.textColor = .gray

        }
    }
}