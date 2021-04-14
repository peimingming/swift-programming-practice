//
//  Copyright © 2021 Eric Pei. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private let bag = DisposeBag()
    
    private lazy var label = UILabel()
    private var setupLabelFlag = false
    
    private lazy var button = UIButton()
    private var setupButtonFlag = false
    
    private lazy var tableView = UITableView()
    private var setupTableViewFlag = false
    
    private lazy var textField = UITextField()
    private lazy var slider = UISlider()
    private var setupObservableAndObserverFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testDisposable()
    }
    
}

// MARK: - Rx Examples

private extension ViewController {
    func testObservable1() {
        print("---", #function, "---")
        print("equivalent sample code")
        
        var observables = [Observable<Int>]()
        
        do {
            let observable = Observable<Int>.create { observer in
                observer.onNext(1)
                observer.onCompleted()
                return Disposables.create()
            }
            observables.append(observable)
        }
        do {
            let observable = Observable.just(1)
            observables.append(observable)
        }
        do {
            let observable = Observable.of(1)
            observables.append(observable)
        }
        do {
            let observable = Observable.from([1])
            observables.append(observable)
        }
        
        for (index, observable) in observables.enumerated() {
            print("*** sample", index, "***")
            observable.subscribe { event in
                print(event)
            }.dispose()
        }
    }
    
    func testObservable2() {
        print("---", #function, "---")
        print("equivalent sample code")
        
        var observables = [Observable<Int>]()
        
        do {
            let observable = Observable<Int>.create { observer in
                observer.onNext(1)
                observer.onNext(2)
                observer.onNext(3)
                observer.onCompleted()
                return Disposables.create()
            }
            observables.append(observable)
        }
        do {
            let observable = Observable.of(1, 2, 3)
            observables.append(observable)
            
        }
        do {
            let observable = Observable.from([1, 2, 3])
            observables.append(observable)
        }
        
        for (index, observable) in observables.enumerated() {
            print("*** sample", index, "***")
            observable.subscribe { event in
                print(event)
            }.dispose()
        }
    }
    
    func testObservableWithTimer() {
        print("---", #function, "---")
        setupLabel(withInitialText: "Coming in 3 seconds...")
        let observable = Observable<Int>.timer(.seconds(3), period: .seconds(1), scheduler: MainScheduler.instance)
        observable
            .map {
                """
                The value is \($0)
                (Duration: 1 sec)
                """
            }
            .bind(to: label.rx.text)
            .disposed(by: bag)
    }
    
    func testObserver() {
        print("---", #function, "---")
        do {
            print("*** observer case 1 ***")
            let observer = AnyObserver<Int>.init { event in
                switch event {
                case .next(let data):
                    print(data)
                case .error(let error):
                    print(error)
                case .completed:
                    print("completed")
                }
            }
            Observable.just(1).subscribe(observer).dispose()
        }
        do {
            setupLabel()
            print("*** observer case 2 ***")
            let binder = Binder<String>(label) { label, text in
                label.text = text
            }
            Observable.just(1).map { "The 1st value is \($0)" }.subscribe(binder).dispose()
            Observable.just(1).map { "The 2nd value is \($0)" }.bind(to: binder).dispose()
        }
    }
    
    func testBinder() {
        print("---", #function, "---")
        setupButton()
        let observable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        observable.map { $0 % 2 == 0 }.bind(to: button.rx.isHidden).disposed(by: bag)
    }
    
    func testCustomBinder() {
        print("---", #function, "---")
        setupButton()
        let observable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        observable.map { $0 % 2 == 0 }.bind(to: button.rx.hidden).disposed(by: bag)
    }
    
    func testObservableSubscription() {
        print("---", #function, "---")
        let observable = Observable.just(1)
        
        print("*** subscription sample 1 ***")
        observable.subscribe { event in
            print(event)
        }.dispose()
        
        print("*** subscription sample 2 *** ")
        observable.subscribe(
            onNext: { element in
                print(element)
            },
            onError: { error in
                print(error)
            },
            onCompleted: {
                print("completed")
            },
            onDisposed: {
                print("disposed")
            }
        ).dispose()
    }
    
    func testEventListener1() {
        print("---", #function, "Target-Action", "---")
        setupButton()
        button
            .rx
            .tap
            .subscribe(onNext: { print("the button is pressed") })
            .disposed(by: bag)
    }
    
    func testEventListener2() {
        print("---", #function, "Delegate", "---")
        
        let cellID = "cellID"
        setupTableView(withCellID: cellID)
        
        struct Person {
            let name: String
            let age: Int
        }
        
        let data = Observable.just(
            [
                Person(name:"Eric", age: 20),
                Person(name: "Jack", age: 28),
                Person(name: "Kate", age: 18)
            ]
        )
        
        data.bind(to: tableView.rx.items(cellIdentifier: "cellID")) { row, person, cell in
            cell.textLabel?.text = person.name
            cell.detailTextLabel?.text = "\(person.age)"
        }.disposed(by: bag)
        
        tableView
            .rx
            .modelSelected(Person.self)
            .subscribe(
                onNext: { person in
                    print(person)
                }
            )
            .disposed(by: bag)
    }
    
    func testEventListener3() {
        print("---", #function, "KVO", "---")
        
        class Dog: NSObject {
            @objc dynamic var name: String?
        }
        
        let dog = Dog()
        dog
            .rx
            .observe(String.self, "name", options: [.new])
            .subscribe(
                onNext: { name in
                    print(name as Any)
                }
            )
            .disposed(by: bag)
        
        dog.name = "er ha"
    }
    
    func testEventListener4() {
        print("---", #function, "Notification", "---")
        NotificationCenter
            .default
            .rx
            .notification(UIApplication.didEnterBackgroundNotification)
            .subscribe(
                onNext: { notification in
                    print("App did enter background:", notification)
                }
            )
            .disposed(by: bag)
    }
    
    func testObservableAndObserver() {
        print("---", #function, "---")
        setupObservableAndObserver()
        Observable.just(0.8).bind(to: slider.rx.value).dispose()
        
        slider.rx.value.map { "\($0)" }.bind(to: textField.rx.text).disposed(by: bag)
        
        textField.rx.text.subscribe(onNext: { text in print(text as Any)}).disposed(by: bag)        
    }
    
    func testDisposable() {
        print("---", #function, "---")
        
        func disposable1() {
            Observable.just(1).subscribe(onNext: { print($0) }).dispose()
        }
        
        let observable = button.rx.tap
        
        func disposable2() {
            setupButton()
            observable.subscribe(onNext: { print("button pressed.") }).disposed(by: bag)
        }
        
        func disposable3() {
            setupButton()
            _ = observable.take(until: rx.deallocated).subscribe(onNext: { print("button pressed.") })
        }
        
        let alert = UIAlertController(title: "disposable cases", message: nil, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: ".dispose()",
                style: .default,
                handler: { _ in
                    disposable1()
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: ".disposed(by: bag)",
                style: .default,
                handler: { _ in
                    disposable2()
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: ".takeUntil(xxx.rx.deallocated)",
                style: .default,
                handler: { _ in
                    disposable3()
                }
            )
        )
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

// MARK: - Private Helpers

private extension ViewController {
    func setupLabel(withInitialText initialText: String = "Coming soon...") {
        guard setupLabelFlag == false else {
            return
        }
        defer {
            setupLabelFlag = true
        }
        view.addSubview(label)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.textColor = .gray
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = initialText
        NSLayoutConstraint.activate(
            [
                label.leftAnchor.constraint(equalTo: view.leftAnchor),
                label.rightAnchor.constraint(equalTo: view.rightAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    func setupButton(withTitle title: String = "Button") {
        guard setupButtonFlag == false else {
            return
        }
        defer {
            setupButtonFlag = true
        }
        view.addSubview(button)
        button.setTitle(" \(title) ", for: .normal)
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    func setupTableView(withCellID cellID: String) {
        guard setupTableViewFlag == false,
              !cellID.isEmpty else {
            return
        }
        defer {
            setupTableViewFlag = true
        }
        class CustomTableViewCell: UITableViewCell {
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
            }
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        view.addSubview(tableView)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ]
        )
    }
    
    func setupObservableAndObserver() {
        guard setupObservableAndObserverFlag == false else {
            return
        }
        defer {
            setupObservableAndObserverFlag = true
        }
        
        let stackView = UIStackView(arrangedSubviews: [textField, slider])
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 20
        textField.borderStyle = .line
        stackView.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        let statusBarHeight = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        NSLayoutConstraint.activate(
            [
                stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: statusBarHeight + 40),
                stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
            ]
        )
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - Custom Binder for the Attribute of UIView

fileprivate extension Reactive where Base: UIView {
    var hidden: Binder<Bool> {
        Binder<Bool>(base) { view, value in
            view.isHidden = value
        }
    }
}
