//
//  NetTableView.swift
//  QYNetDataTableView
//
//  Created by liuming on 2018/7/26.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import MJRefresh
import UIKit
open class NetTableView<T>: UITableView {
    /// 加载页码
    public var pageIndex: Int = 1

    /// 每页大小
    public var pageSize: Int = 20

    /// 表视图当前状态
    private var tableState: NetTableState = NetTableState.Idle

    public weak var stateDelegate: NetTableViewStateDelegate?
    /// 数据源
    public var dataArray: Array<T>? = Array<T>.init()

    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 注册下拉刷新
    ///
    /// - Parameter refreshingBlock: 刷新回调
    public func registerHearRefresh(_ refreshingBlock: tableRefreshCallBack?) {
        mj_header = MJRefreshNormalHeader(refreshingBlock: {
            switch self.tableState {
            case .headerLoading:
                print("头部视图正在奋力刷新中.....")
            case .footerLoading:
                print("底部正在刷新中，关闭掉本次头部刷新")
                self.mj_header.endRefreshing()
            default:
                self.pageIndex = 1
                if refreshingBlock != nil {
                    refreshingBlock!()
                }
            }
            self.updateCurrentState(.headerLoading)
        })
    }

    /// 注册上拉刷新
    ///
    /// - Parameter refreshingBlock: 刷新回调
    public func registerFooterRefresh(_ refreshingBlock: tableRefreshCallBack?) {
        mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            switch self.tableState {
            case .headerLoading:
                print("头部视图正在奋力刷新中.....。关掉本次底部刷新")
                self.mj_footer.endRefreshing()
            case .footerLoading:
                print("底部视图正在奋力刷新中.....")
            default:
                if refreshingBlock != nil {
                    refreshingBlock!()
                }
            }
            self.updateCurrentState(.footerLoading)
        })
    }

    /// 获取 indexPath 所在的元素
    ///
    /// - Parameter indexPath: 索引
    /// - Returns: 对应索引的元素
    public func data(at indexPath: IndexPath) -> T? {
        guard let dataArr = self.dataArray else {
            return nil
        }
        let tmp = data(at: indexPath.section, source: dataArr)
        if tmp is Array<Any> {
            let array = tmp as? Array<Any>
            let o = data(at: indexPath.row, source: array)
            return o as? T
        } else {
            return tmp as? T
        }
    }

    // MARK: - 状态改变

    public func updateCurrentState(_ state: NetTableState) {
        switch state {
        case .empty:
            // 显示没有数据提示
            if let stDelegage = self.stateDelegate {
                let action = #selector(NetTableViewStateDelegate.loadEmptyData)
                if stDelegage.responds(to: action) {
                    stDelegage.loadEmptyData()
                }
            }
            print("空数据")
        case let .error(error):
            print("出错 \(error)")
            if let stDelegage = self.stateDelegate {
                if stDelegage.responds(to: #selector(stateDelegate?.loadError(_:))) {
                    stDelegage.loadError(error)
                }
            }
        case let .populated(dataArr, isAppend):
            print("本次拉取到数据\(dataArr.count)")
            fillData(dataArr as! [T], isAppend: isAppend)
        default:
            print("state = \(state)")
        }
        tableState = state
    }

    public func currentSate() -> NetTableState {
        return tableState
    }

    // MARK: - 刷新模块

    /// 开始头部刷新
    public func startHeaderRefresh() {
        if !mj_header.isRefreshing &&
            !mj_footer.isRefreshing {
            mj_header.beginRefreshing()
        }
    }

    /// 结束头部刷新
    public func endHeaderRefresh() {
        if mj_header.isRefreshing {
            mj_header.endRefreshing()
        }
    }

    /// 开始尾部刷新
    public func startFooterRefresh() {
        if !mj_header.isRefreshing &&
            !mj_footer.isRefreshing {
            mj_footer.beginRefreshing()
        }
    }

    /// 结束尾部刷新
    public func endFooterRefresh() {
        if mj_footer.isRefreshing {
            mj_footer.endRefreshing()
        }
    }

    /// 分页加载，最后一页数据
    public func endFooterNoDataRefresh() {
        if mj_footer.isRefreshing {
            mj_footer.endRefreshingWithNoMoreData()
        }
    }
}

extension NetTableView {
    public typealias tableRefreshCallBack = MJRefreshComponentRefreshingBlock

    private func data(at index: Int, source: Any?) -> Any? {
        if source != nil {
            if let array = source as? Array<Any> {
                if !isBeyond(index, array: array) {
                    return array[index]
                }
            } else {
                return source
            }
        }
        return nil
    }

    private func isBeyond(_ index: Int, array: Array<Any>) -> Bool {
        return index > 0 && index < array.count
    }

    /// 将数据填充到表视图上
    ///
    /// - Parameters:
    ///   - dataArr: 要填充的数据
    ///   - append: 填充方式
    private func fillData(_ dataArr: [T], isAppend append: Bool) {
        endHeaderRefresh()
        if append {
            for e in dataArr {
                dataArray?.append(e)
            }
        } else {
            dataArray = dataArr
        }
        if dataArr.count <= 0 {
            // 本次没有数据 尾部刷新显示最后一页
            endFooterNoDataRefresh()
        } else {
            pageIndex += 1
            endFooterRefresh()
            if mj_footer.state == .noMoreData {
                mj_footer.state = .idle
            }
        }
        reloadData()
        if isEmptyArray(dataArray) {
            updateCurrentState(.empty)
        }
    }

    private func isEmptyArray(_ array: Array<Any>?) -> Bool {
        guard let arr = array else {
            return true
        }
        return (arr.count <= 0)
    }
}

@objc
public protocol NetTableViewStateDelegate: NSObjectProtocol {
    func loadEmptyData() -> Void
    func loadError(_ error:Error) -> Void
}
