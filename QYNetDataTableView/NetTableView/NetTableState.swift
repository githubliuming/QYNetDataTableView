//
//  NetTableState.swift
//  QYNetDataTableView
//
//  Created by liuming on 2018/7/26.
//  Copyright © 2018年 yoyo. All rights reserved.
//

import UIKit
/*
 1、闲置
 2、正在加载数据
 3、填充数据
 4、加载出错
 5、空数据
 */

public enum NetTableState {
    case Idle                //闲置
    case headerLoading       //正在下拉加载
    case footerLoading       //正在上拉加载
    case populated([Any],isAppend:Bool)   //填充数据，界面刷新
    case empty               //空数据
    case error(Error)        //出错
    
}
