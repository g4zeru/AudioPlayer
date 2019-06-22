//
//  AlbamListViewController.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/02/09.
//  Copyright © 2019 teranyan. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import RxSwift
import RxCocoa

class AlbumListViewController: BaseListViewController {
    let cellHeight: CGFloat = 120
    let headerHeight: CGFloat = 70
    deinit {
        DebugUtil.log("AlbumList is deinit")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "AlbumListTableViewCell", bundle: nil), forCellReuseIdentifier: "List")
        self.tableView.register(UINib(nibName: "HomeHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        bind()
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
                print("request")
                self?.queryFetch(case: .album)
        }.disposed(by: disposeBag)
    }
}
extension AlbumListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albamDetailView = AlbumDetailListViewController()
        albamDetailView.albumTitle = query?.collections?.filter {$0.representativeItem?.albumTitle != ""}[indexPath.item].representativeItem?.albumTitle
        self.navigationController?.show(albamDetailView, sender: nil)
    }
}
extension AlbumListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return query?.collections?.filter {$0.representativeItem?.albumTitle != ""}.count ?? 00
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "List", for: indexPath) as? AlbumListTableViewCell else {
            fatalError()
        }
        cell.updateView(item: query?.collections?.filter {$0.representativeItem?.albumTitle != ""}[indexPath.item].representativeItem)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? HomeHeaderView else {
            fatalError()
        }
        view.updateView(text: "Albums")
        return view
    }
}
