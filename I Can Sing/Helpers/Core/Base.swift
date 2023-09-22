//
//  Base.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/21/23.
//

import Foundation
import RxSwift
import RxRelay

class Base {
    
    class MVVMViewController<T: ViewModel>: ViewController {
        internal let disposeBag = DisposeBag()
        
        let viewModel: T
        
        init(viewModel: T) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class ViewModel {
        internal let disposeBag = DisposeBag()
    }
}
