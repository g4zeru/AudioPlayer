//
//  SongsListViewController.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/02/10.
//  Copyright © 2019 teranyan. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import RxCocoa
import RxSwift

class SongsListViewController: BaseListViewController {
    let cellHeight: CGFloat = 60
    let headerHeight: CGFloat = 20
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SongsListTableViewCell", bundle: nil), forCellReuseIdentifier: "List")
        self.tableView.register(UINib(nibName: "ItemSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.bind()
    }
    private func itemIndex(path: IndexPath) -> Int? {
        guard let location = self.query?.itemSections?[path.section].range.location else {
            return nil
        }
        return location + path.item
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
            }
            .subscribe { [weak self] status in
                guard let status = status.element else {
                    return
                }
                if status == MPMediaLibraryAuthorizationStatus.authorized {
                    self?.queryFetch(case: .songs)
                    self?.accessView.removeFromSuperview()
                } else {
                    self?.showRequestView()
                }
            }.disposed(by: disposeBag)
    }
}
extension SongsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let query = query else {
            return
        }
        guard queue.nowPlayingItem?.persistentID != query.items?[itemIndex(path: indexPath) ?? 0].persistentID else {
            return
        }
        
        self.queueController.setQueue(query: query, playingItem: query.items?[itemIndex(path: indexPath) ?? 0], isPlay: true)
    }
}
extension SongsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.query?.itemSections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.query?.itemSections?[section].range.length ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "List", for: indexPath) as? SongsListTableViewCell else {
            fatalError()
        }
        
        cell.updateView(item: self.query?.items?[itemIndex(path: indexPath) ?? 0], index: itemIndex(path: indexPath) ?? 0)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ItemSectionHeader else {
            fatalError()
        }
        view.updateTitle(text: self.query?.itemSections?[section].title ?? "")
        return view
    }
}
