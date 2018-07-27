//
//  ViewController.swift
//  QYNetDataTableView
//
//  Created by liuming on 2018/7/26.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    public var tableView: NetTableView<TestModel>?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView = NetTableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView!)
        
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.stateDelegate = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView?.tableFooterView = UIView()

        tableView?.registerHearRefresh({
            self.loadFirstPage()
        })

        tableView?.registerFooterRefresh({
            self.loadNextPage()
        })
        self.tableView?.startHeaderRefresh();
    }

    private func loadFirstPage() {
        guard let tableView = self.tableView else {
            return ;
        }
        let array: Array<TestModel> = [TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel()]

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            tableView.updateCurrentState(NetTableState.populated(array, isAppend: false))
        }
    }

    private func loadNextPage() {
        
        guard let tableView = self.tableView else {
            return ;
        }
        if tableView.pageIndex <= 2 {
            let array: Array<TestModel> = [TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel(), TestModel()]

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                tableView.updateCurrentState(NetTableState.populated(array, isAppend: true))
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                tableView.updateCurrentState(NetTableState.populated([], isAppend: true))
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, NetTableViewStateDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let array = self.tableView?.dataArray else {
            return 0
        }
        return array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = self.tableView?.data(at: indexPath)?.name
        return cell
    }

    func loadEmptyData() {
    }
    func loadError(_ error: Error) {
        print("error = \(error)")
    }
}
