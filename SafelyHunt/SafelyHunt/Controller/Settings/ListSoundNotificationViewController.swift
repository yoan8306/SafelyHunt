//
//  ListSoundNotificationViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 22/10/2022.
//

import UIKit

class ListSoundNotificationViewController: UIViewController {

    let sounds: [String] = ["OrchestralEmergency", "Scanning-alarm"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension ListSoundNotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "soundsCell", for: indexPath)
        
        return cell
    }
    
    
}

extension ListSoundNotificationViewController: UITableViewDelegate {
    
}
