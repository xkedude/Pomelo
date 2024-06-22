//
//  INIEditController.swift
//  Pomelo
//
//  Created by Jarrod Norwell on 13/3/2024.
//

import Sudachi
import Foundation
import UIKit

class INIEditController : UIViewController, UITextViewDelegate {
    var textView: UITextView!
    
    var console: Core.Console
    var url: URL
    init(console: Core.Console, url: URL) {
        self.console = console
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in self.dismiss(animated: true) })), animated: true)
        navigationItem.leftBarButtonItem = nil // Remove the default "Back" button
        navigationItem.setRightBarButton(.init(systemItem: .save, primaryAction: .init(handler: { _ in
            self.save()
            
            switch self.console {
#if canImport(Sudachi)
            case .nSwitch:
                Sudachi.shared.settingsSaved()
#endif
            default:
                break
            }
            
            self.dismiss(animated: true)
        })), animated: true)
        view.backgroundColor = .systemBackground
        
        
        textView = .init()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.font = .preferredFont(forTextStyle: .body)
        view.addSubview(textView)
        bottomConstraint = textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomConstraint.priority = .defaultLow
        view.addConstraints([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomConstraint,
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        textView.text = try? String(contentsOf: url)
        
        NotificationCenter.default.addObserver(forName: .init(UIResponder.keyboardWillShowNotification), object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo, let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            self.bottomConstraint.constant = -frame.height
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .init(UIResponder.keyboardWillHideNotification), object: nil, queue: .main) { notification in
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func save() {
        guard let text = textView.text else {
            return
        }
        
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }
}
