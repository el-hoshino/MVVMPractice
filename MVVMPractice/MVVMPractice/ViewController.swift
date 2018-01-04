//
//  ViewController.swift
//  MVVMPractice
//
//  Created by 史 翔新 on 2017/10/19.
//  Copyright © 2017年 史 翔新. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - View
class ViewController: UIViewController {
    
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var labelA: UILabel!
    @IBOutlet weak var labelB: UILabel!
    
    private(set) lazy var viewModel: ViewModel = {
        let input = self.input.rx.text.orEmpty.asDriver(onErrorDriveWith: .empty())
        return ViewModel(input: input)
    }()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let display = viewModel.output.shareReplay(1).subscribeOn(MainScheduler.instance)
        display.bind(to: labelA.rx.text).disposed(by: bag)
        display.bind(to: labelB.rx.text).disposed(by: bag)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - ViewModel
class ViewModel {
    
    let model = Model()
    
    private let result: Variable<String> = .init("")
    
    private let disposeBag = DisposeBag()
    
    let output: Observable<String>
    
    init(input: Driver<String>) {
        
        self.output = self.result.asObservable()
        
        self.model.setOnResultChangedAction { (newValue) in
            self.result.value = newValue.map({ "\($0)" }) ?? ""
        }
        
        input.drive(onNext: { (string) in
            let components = string.components(separatedBy: "+").map({ $0.trimmingCharacters(in: .whitespaces) })
            if components.count >= 2, let a = Int(components[0]), let b = Int(components[1]) {
                self.model.add(a, with: b)
            } else {
                self.model.reset()
            }
        }, onCompleted: nil, onDisposed: nil).disposed(by: self.disposeBag)
        
    }
    
}

// MARK: - Model
class Model {
    
    private var onResultChanged: ((_ newResult: Int?) -> Void)?
    
    private(set) var result: Int? = nil {
        willSet {
            self.onResultChanged?(newValue)
        }
    }
    
    init(onResultChanged: ((_ newResult: Int?) -> Void)? = nil) {
        self.onResultChanged = onResultChanged
    }
    
    func setOnResultChangedAction(_ action: @escaping (_ newResult: Int?) -> Void) {
        self.onResultChanged = action
    }
    
    func reset() {
        DispatchQueue.global().async {
            self.result = nil
        }
    }
    
    func add(_ a: Int, with b: Int) {
        DispatchQueue.global().async {
            self.result = a + b
        }
    }
    
}
