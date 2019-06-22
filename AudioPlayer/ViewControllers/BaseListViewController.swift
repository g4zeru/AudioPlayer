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
import RxSwift

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
    
    private let mediaListAuthStatusSubject = PublishSubject<MPMediaLibraryAuthorizationStatus>()
    private let willEnterForegroundSubject = PublishSubject<NSNotification>()
    private let didEnterBackgroundSubject = PublishSubject<NSNotification>()
    
    var mediaListAuth: Observable<MPMediaLibraryAuthorizationStatus> {
        return mediaListAuthStatusSubject.asObservable()
    }
    var willEnterForeground: Observable<NSNotification> {
        return willEnterForegroundSubject.asObservable()
    }
    var didEnterBackground: Observable<NSNotification> {
        return didEnterBackgroundSubject.asObservable()
    }
    
    let disposeBag = DisposeBag()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let accessView: UIView = {
        let view = UINib(nibName: "RequestMediaAccessView", bundle: nil).instantiate(withOwner: self, options: nil).first as! RequestMediaAccessView
        return view
        
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
        MPMediaLibrary.requestAuthorization { [weak self] (status) in
            self?.mediaListAuthStatusSubject.onNext(status)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectIndex = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectIndex, animated: true)
        }
    }
    
    func showRequestView() {
        self.view.addSubview(accessView)
        accessView.snp.makeConstraints({ (maker) in
            let safeAreaConstraints = self.view.safeAreaLayoutGuide.snp
            maker.top.equalTo(safeAreaConstraints.top)
            maker.leading.equalTo(safeAreaConstraints.leading)
            maker.bottom.equalTo(safeAreaConstraints.bottom)
            maker.trailing.equalTo(safeAreaConstraints.trailing)
        })
        self.view.layoutIfNeeded()
    }
    
    func queryFetch(case queryCase: MediaItemsUseCase.QueryCase ) {
        //デフォでアップルミュージックの接続を制限
        self.fetcher.fetch(cases: queryCase, with: self.queryFilter, isAppleMusic: false)
    }
    
    @objc func willEnterForeground(_ notification: NSNotification) {
        self.willEnterForegroundSubject.onNext(notification)
    }
    @objc func didEnterBackground(_ notification: NSNotification) {
        self.didEnterBackgroundSubject.onNext(notification)
    }
}
extension BaseListViewController: MediaItemsFetchResult {
    func finishedFetchQuery(query: MPMediaQuery?) {
        self.query = query
    }
}
