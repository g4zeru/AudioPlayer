//
//  AlbamDetailViewController.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/02/07.
//  Copyright © 2019 teranyan. All rights reserved.
//

import UIKit
import MediaPlayer
import SnapKit

class BaseListViewController: UIViewController {
    
    let miniControllerHeight: CGFloat = 60
    var queryFilter: Set<MPMediaPropertyPredicate> = []
    
    private let backgroundView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        return view
    }()
    private(set) var query: MPMediaQuery? {
        didSet {
            self.tableView.reloadData()
        }
    }
    private lazy var fetcher: MediaQueryFetcher = {
        let fetcher = MediaQueryFetcher()
        fetcher.output = self
        return fetcher
    }()
    let queueController: MediaPlayerInputQueueProtocol = AudioPlayer.shared
    let queue: MediaPlayerOutputQueueProtocol = AudioPlayer.shared
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    override func loadView() {
        super.loadView()
        self.view = backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        self.tableView.snp.makeConstraints { (maker) in
            let safeAreaConstraints = self.view.safeAreaLayoutGuide.snp
            maker.top.equalTo(safeAreaConstraints.top)
            maker.leading.equalTo(safeAreaConstraints.leading)
            maker.trailing.equalTo(safeAreaConstraints.trailing)
            maker.bottom.equalTo(safeAreaConstraints.bottom).inset(60)
        }
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectIndex = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectIndex, animated: true)
        }
    }
    func queryFetch(case queryCase: MediaItemsUseCase.QueryCase ) {
        //デフォでアップルミュージックの接続を制限
        self.fetcher.fetch(cases: queryCase, with: self.queryFilter, isAppleMusic: false)
    }
}
extension BaseListViewController: MediaItemsFetchResult {
    func finishedFetchQuery(query: MPMediaQuery?) {
        self.query = query
    }
}
