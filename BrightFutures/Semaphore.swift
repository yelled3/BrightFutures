//
//  Semaphore.swift
//  BrightFutures
//
//  Created by Thomas Visser on 17/01/15.
//  Copyright (c) 2015 Thomas Visser. All rights reserved.
//

import Foundation

public enum TimeInterval {
    case Forever
    case In(NSTimeInterval)
    
    var dispatchTime: dispatch_time_t {
        get {
            switch self {
            case .Forever:
                return DISPATCH_TIME_FOREVER
            case .In(let interval):
                return dispatch_time(DISPATCH_TIME_NOW, Int64(interval * NSTimeInterval(NSEC_PER_SEC)))
            }
        }
    }
}

/**
 * A tiny wrapper around dispatch_semaphore
 */
class Semaphore {
    
    private var semaphore: dispatch_semaphore_t
    
    init(value: Int) {
        self.semaphore = dispatch_semaphore_create(value)
    }
    
    convenience init() {
        self.init(value: 1)
    }
    
    func wait() {
        self.wait(.Forever)
    }
    
    func wait(timeout: TimeInterval) {
        dispatch_semaphore_wait(self.semaphore, timeout.dispatchTime)
    }
    
    func signal() {
        dispatch_semaphore_signal(self.semaphore)
    }
}

extension Semaphore : ExecutionContext {

    func execute(task: () -> ()) {
        self.wait()
        task()
        self.signal()
    }
    
}