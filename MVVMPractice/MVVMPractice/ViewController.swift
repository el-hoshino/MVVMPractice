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
    
    let viewModel = ViewModel()
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let text = input.rx.text.shareReplay(1)
        text.bind(to: viewModel.rx.text).disposed(by: bag)
        
        let display = viewModel.rx.display.shareReplay(1).subscribeOn(MainScheduler.instance)
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
    
    let bag: DisposeBag = .init()
    
}

extension ViewModel: ReactiveCompatible {
    
}

extension Reactive where Base: ViewModel {
    
    var text: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: self.base, binding: { (base, text) in
            base.model.updateText(text)
        })
    }
    
    var display: Observable<String> {
        return base.model.int.asObservable().map {
            if let result = $0 {
                return "\(result)"
            } else {
                return "Invalid"
            }
        }
    }
    
}

// MARK: - Model
class Model {
    
    let int: Variable<Int?> = .init(nil)
    
    func updateText(_ text: String?) {
        
        guard let components = text?.components(separatedBy: "+") else { int.value = nil; return }
        guard let a = components.first, let b = components.dropFirst().first else { int.value = nil; return }
        guard let intA = Int(a), let intB = Int(b) else { int.value = nil; return }
        
        int.value = intA + intB
        
    }
    
}
