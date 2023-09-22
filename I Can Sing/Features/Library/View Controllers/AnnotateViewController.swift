//
//  AnnotateViewController.swift
//  I Can Sing
//
//  Created by Grace, Mu-Hui Yu on 9/22/23.
//

import UIKit
import RxSwift
import RxRelay

class AnnotateViewController: Base.MVVMViewController<AnnotateViewModel> {
    
    // MARK: - Views
    private let textView = UITextView()
    private let activityIndicatorView = UIActivityIndicatorView()
    
    private var highlightedWordRange: NSRange? {
        didSet {
            if let oldValue = oldValue {
                unhighlightWord(range: oldValue)
            }
            if let highlightedWordRange = highlightedWordRange {
                highlightWord(range: highlightedWordRange)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureGestures()
        configureBindings()
    }
    
}

// MARK: - View Config
extension AnnotateViewController {
    private func configureViews() {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        textView.isEditable = false
        textView.isSelectable = false // Disable text selection
        textView.font = .systemFont(ofSize: 16)
        textView.delegate = self
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(textView)
        
        activityIndicatorView.isHidden = true
        view.addSubview(activityIndicatorView)
    }
    
    private func configureConstraints() {
        textView.snp.remakeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
        }
        activityIndicatorView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func configureGestures() {
        let wordTapGestureRecognizer = UITapGestureRecognizer()
        wordTapGestureRecognizer.addTarget(self, action: #selector(handleWordTapGesture(_:)))
        textView.addGestureRecognizer(wordTapGestureRecognizer)
    }
    
    private func configureBindings() {
        viewModel.isFetching
            .asObservable()
            .subscribe { [weak self] isFetching in
                DispatchQueue.main.async {
                    self?.configureActivityIndicatorShows()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.song
            .asObservable()
            .subscribe { [weak self] _ in
                DispatchQueue.main.async {
                    self?.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func configureActivityIndicatorShows() {
        let isFetching = viewModel.isFetching.value
        
        if isFetching {
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
        }
    }
    
}

// MARK: - Handlers
extension AnnotateViewController {
    private func reloadData() {
        title = viewModel.song.value?.name
        textView.text = viewModel.song.value?.lyrics
    }
    
    @objc private func handleWordTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let textView = gestureRecognizer.view as? UITextView else { return }
        
        let tapLocation = gestureRecognizer.location(in: textView)
        
        guard let tappedTextRange = textView.closestPosition(to: tapLocation),
              let tappedWordRange = textView.tokenizer.rangeEnclosingPosition(tappedTextRange, with: .word, inDirection: UITextDirection(rawValue: 1)),
              let tappedWord = textView.text(in: tappedWordRange)
        else {
            // If the user tapped somewhere else, clear the highlighted word
            highlightedWordRange = nil
            return
        }
            
        let tappedWordNSRange = textView.convertToNSRange(from: tappedWordRange)
        
        if tappedWordNSRange == highlightedWordRange {
            highlightedWordRange = nil
        } else {
            highlightedWordRange = tappedWordNSRange
            handleWordTapped(word: tappedWord, at: tappedWordNSRange)
        }
    }
    
    private func highlightWord(range: NSRange) {
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
//        attributedString.addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: range)
        attributedString.addAttribute(.underlineColor, value: UIColor.red, range: range)
        textView.attributedText = attributedString
    }
    
    private func unhighlightWord(range: NSRange) {
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        attributedString.removeAttribute(.underlineStyle, range: range)
        attributedString.removeAttribute(.underlineColor, range: range)
        textView.attributedText = attributedString
    }
    
    private func handleWordTapped(word: String, at range: NSRange) {
        print("did tap word \(word)")
        // show menu and choose
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add Note", style: .default, handler: { [weak self] _ in
            self?.displayAddNoteModal(for: word, at: range)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.highlightedWordRange = nil
        }))
        present(alert, animated: true)
    }
    
    private func displayAddNoteModal(for word: String, at range: NSRange) {
        let alert = UIAlertController(title: "Add note", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter note"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] action in
            guard let textField = alert.textFields?[0] as? UITextField, let text = textField.text else { return }
            do {
                try self?.viewModel.addNote(for: word, at: range, with: text)
            } catch {
                let alert = Factory.makeErrorAlertController(with: "Failed to add note", for: error)
                self?.present(alert, animated: true)
            }
            self?.highlightedWordRange = nil
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.highlightedWordRange = nil
        }))
        present(alert, animated: true)
    }
}

// MARK: - TextViewDelegate
extension AnnotateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Here you can update the lyrics text as the user types if needed
        
    }
}
