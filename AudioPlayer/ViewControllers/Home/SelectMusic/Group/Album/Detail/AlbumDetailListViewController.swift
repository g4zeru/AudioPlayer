//
//  AlbamDetailListViewController.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/02/07.
//  Copyright © 2019 teranyan. All rights reserved.
//

import UIKit
import MediaPlayer
import RxCocoa
import RxSwift

class AlbumDetailListViewController: BaseListViewController {

    private let albumViewHeight: CGFloat = 150
    private let listViewHeight: CGFloat = 50
    
    var albumTitle: String? = nil
    
    deinit {
        DebugUtil.log("AlbumDetailList is deinit")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "AlbumDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "Albam")
        self.tableView.register(UINib(nibName: "AlbumPlayListTableViewCell", bundle: nil), forCellReuseIdentifier: "List")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.queryFilter = [MPMediaPropertyPredicate(value: albumTitle, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: .equalTo)]
        self.bind()
    }
    
    func bind() {
        Observable.of(
            rx.sentMessage(#selector(viewWillAppear(_:))).map {_ in},
            willEnterForeground.asObservable().map {_ in},
            mediaListAuth.asObservable().map {_ in}
            )
            .merge()
            .map { _ in
                return MPMediaLibrary.authorizationStatus()
            }.filter ({ (status) -> Bool in
                return status == MPMediaLibraryAuthorizationStatus.authorized
            })
            .subscribe { [weak self] _ in
                self?.queryFetch(case: .album)
            }.disposed(by: disposeBag)
    }
}
extension AlbumDetailListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return self.query?.items?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Albam", for: indexPath) as? AlbumDetailTableViewCell else {
                fatalError()
            }
            let item = self.query?.collections?[0].representativeItem
            cell.updateView(item: item)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "List", for: indexPath) as? AlbumPlayListTableViewCell else {
                fatalError()
            }
            cell.updateCell(index: indexPath.item, title: self.query?.items?[indexPath.item].title ?? "", duration: self.query?.items?[indexPath.item].playbackDuration)
            return cell
        }
    }
}
extension AlbumDetailListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        default:
            return true
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return self.albumViewHeight
        default:
            return self.listViewHeight
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let query = query else {
            return
        }
        guard queue.nowPlayingItem?.persistentID != query.items?[indexPath.item].persistentID else {
            return
        }
        self.queueController.setQueue(query: query, playingItem: query.items?[indexPath.item], isPlay: true)
    }
}
