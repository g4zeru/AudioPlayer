//
//  HomeViewController.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/02/09.
//  Copyright © 2019 teranyan. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class HomeViewController: BaseListViewController {
    var collection: [String] = ["Albums","Artist","Songs","PlayList","Genre"]
    let cellHeight: CGFloat = 50
    let headerHeight: CGFloat = 70
    lazy var miniController: MiniAudioController = {
        let view = MiniAudioController(frame: CGRect(x: 0, y: self.view.frame.origin.y + self.view.frame.height - miniControllerHeight - self.view.safeAreaInsets.bottom, width: self.view.frame.width, height: miniControllerHeight))
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "HomeListTableViewCell", bundle: nil), forCellReuseIdentifier: "List")
        self.tableView.register(UINib(nibName: "HomeHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.view.addSubview(miniController)
        let gesture = UITapGestureRecognizer(target: self.navigationController, action: #selector(AudioPlayListNavigationViewController.openPlayer))
        self.miniController.contentView.addGestureRecognizer(gesture)
    }
}
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            self.navigationController?.show(AlbumListViewController(), sender: nil)
        case 1:
            self.navigationController?.show(ArtistListViewController(), sender: nil)
        case 2:
            self.navigationController?.show(SongsListViewController(), sender: nil)
        case 3:
            self.navigationController?.show(PlaylistViewCotroller(), sender: nil)
        case 4:
            self.navigationController?.show(GenreListViewController(), sender: nil)
        default:
            return
        }
    }
}
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "List", for: indexPath) as? HomeListTableViewCell else {
            fatalError()
        }
        cell.updateView(text: collection[indexPath.item])
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? HomeHeaderView else {
            fatalError()
        }
        view.updateView(text: "Library")
        return view
    }
}
