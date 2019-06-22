//
//  PlayListViewController.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/02/10.
//  Copyright © 2019 teranyan. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class PlaylistViewCotroller: BaseListViewController {
    let cellHeight: CGFloat = 50
    let headerHeight: CGFloat = 70
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "PlaylistTableViewCell", bundle: nil), forCellReuseIdentifier: "List")
        self.tableView.register(UINib(nibName: "HomeHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        bind()
    }
    
    func bind() {
        rx.sentMessage(#selector(viewWillAppear(_:)))
            .asObservable()
            .map {_ in
                return MPMediaLibrary.authorizationStatus()
            }.filter({ (status) -> Bool in
                return status == MPMediaLibraryAuthorizationStatus.authorized
            })
            .subscribe { [weak self] _ in
                self?.queryFetch(case: .playlists)
            }
            .disposed(by: self.disposeBag)
        
        self.mediaListAuth.subscribe(onNext: { [weak self] (status) in
            if status == MPMediaLibraryAuthorizationStatus.authorized {
                self?.queryFetch(case: .playlists)
            }
        }).disposed(by: disposeBag)
    }
}
extension PlaylistViewCotroller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? HomeHeaderView else {
            fatalError()
        }
        view.updateView(text: "PlayList")
        return view
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playListPropertyName = self.query?.collections?.map{$0.value(forProperty: MPMediaPlaylistPropertyName)}[indexPath.item]
        guard let title: String = playListPropertyName as? String else {
            fatalError()
        }
        let detailView = PlaylistDetailViewController()
        detailView.playlist = title
        self.navigationController?.show(detailView, sender: nil)
    }
}
extension PlaylistViewCotroller: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.query?.collections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "List", for: indexPath) as? PlaylistTableViewCell else {
            fatalError()
        }
        let playListPropertyName = self.query?.collections?.map{$0.value(forProperty: MPMediaPlaylistPropertyName)}[indexPath.item]
        guard let title: String = playListPropertyName as? String else {
            fatalError()
        }
        cell.updateView(text: title)
        return cell
    }
}
