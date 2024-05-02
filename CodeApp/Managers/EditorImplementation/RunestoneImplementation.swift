//
//  RunestoneImplementation.swift
//  Code
//
//  Created by Ken Chung on 23/03/2024.
//

import Runestone
import TreeSitterCPPRunestone
import TreeSitterCRunestone
import TreeSitterJavaScriptRunestone
import TreeSitterPythonRunestone

class DynamicTheme: Runestone.Theme {

    private var lightTheme: Runestone.Theme
    private var darkTheme: Runestone.Theme
    var editorFont: UIFont

    init(light: Runestone.Theme, dark: Runestone.Theme, font: UIFont) {
        self.lightTheme = light
        self.darkTheme = dark
        self.editorFont = font

        self.backgroundColor = UIColor(dynamicProvider: { trait in
            UIColor(id: "editor.background")
        })
        self.textColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light ? light.textColor : dark.textColor
        })
        self.gutterBackgroundColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light
                ? light.gutterBackgroundColor : dark.gutterBackgroundColor
        })
        self.gutterHairlineColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light
                ? light.gutterHairlineColor : dark.gutterHairlineColor
        })
        self.lineNumberColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light ? light.lineNumberColor : dark.lineNumberColor
        })
        self.lineNumberFont = editorFont
        self.selectedLineBackgroundColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light
                ? light.selectedLineBackgroundColor : dark.selectedLineBackgroundColor
        })
        self.selectedLinesLineNumberColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light
                ? light.selectedLinesLineNumberColor : dark.selectedLinesLineNumberColor
        })
        self.selectedLinesGutterBackgroundColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light
                ? light.selectedLinesGutterBackgroundColor : dark.selectedLinesGutterBackgroundColor
        })
        self.invisibleCharactersColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light
                ? light.invisibleCharactersColor : dark.invisibleCharactersColor
        })
        self.pageGuideHairlineColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light
                ? light.pageGuideHairlineColor : dark.pageGuideHairlineColor
        })
        self.pageGuideBackgroundColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light
                ? light.pageGuideBackgroundColor : dark.pageGuideBackgroundColor
        })
        self.markedTextBackgroundColor = UIColor(dynamicProvider: { trait in
            trait.userInterfaceStyle == .light
                ? light.markedTextBackgroundColor : dark.markedTextBackgroundColor
        })
    }

    var backgroundColor: UIColor

    var font: UIFont {
        editorFont
    }

    var textColor: UIColor

    var gutterBackgroundColor: UIColor

    var gutterHairlineColor: UIColor

    var lineNumberColor: UIColor

    var lineNumberFont: UIFont

    var selectedLineBackgroundColor: UIColor

    var selectedLinesLineNumberColor: UIColor

    var selectedLinesGutterBackgroundColor: UIColor

    var invisibleCharactersColor: UIColor

    var pageGuideHairlineColor: UIColor

    var pageGuideBackgroundColor: UIColor

    var markedTextBackgroundColor: UIColor

    func textColor(for highlightName: String) -> UIColor? {
        return UIColor(dynamicProvider: { trait in
            return
                (trait.userInterfaceStyle == .light
                ? self.lightTheme.textColor(for: highlightName)
                : self.darkTheme.textColor(for: highlightName)) ?? UIColor.white
        })
    }
}

class RunestoneTheme: Runestone.Theme {

    private var vsTheme: Theme
    private var baseTheme = DefaultTheme()
    private var editorFont: UIFont
    var backgroundColor: UIColor? {
        UIColor(hex: vsColors["editor.background"] ?? "")
    }

    init(vsTheme: Theme) {
        self.vsTheme = vsTheme
        self.editorFont = UIFont()
    }

    private var vsColors: [String: String] {
        vsTheme.dictionary as? [String: String] ?? [:]
    }

    private lazy var vsTokenColors: [String: String] = {
        var result: [String: String] = [:]
        guard let tokenColors = vsTheme.dictionary["tokenColors"] as? [[String: Any]] else {
            return result
        }
        for tokenColor in tokenColors {
            var scopes = tokenColor["scope"] as? [String]
            if let scope = tokenColor["scope"] as? String {
                scopes = [scope]
            }
            guard let scopes,
                let settings = tokenColor["settings"] as? [String: Any],
                let foreground = settings["foreground"] as? String
            else {
                continue
            }
            for scope in scopes {
                result[scope] = foreground
            }
        }
        return result
    }()

    var font: UIFont {
        editorFont
    }

    var textColor: UIColor {
        UIColor(hex: vsColors["editor.foreground"] ?? "") ?? baseTheme.textColor
    }

    var gutterBackgroundColor: UIColor {
        UIColor.clear
    }

    var gutterHairlineColor: UIColor {
        UIColor.clear
    }

    var lineNumberColor: UIColor {
        UIColor(hex: vsColors["editorLineNumber.foreground"] ?? "") ?? baseTheme.lineNumberColor
    }

    var lineNumberFont: UIFont {
        editorFont
    }

    var selectedLineBackgroundColor: UIColor {
        UIColor(hex: vsColors["editor.background"] ?? "") ?? baseTheme.selectedLineBackgroundColor
    }

    var selectedLinesLineNumberColor: UIColor {
        UIColor(hex: vsColors["editorLineNumber.activeForeground"] ?? "")
            ?? baseTheme.selectedLinesLineNumberColor
    }

    var selectedLinesGutterBackgroundColor: UIColor {
        UIColor(hex: vsColors["editor.background"] ?? "")
            ?? baseTheme.selectedLinesGutterBackgroundColor
    }

    var invisibleCharactersColor: UIColor {
        baseTheme.invisibleCharactersColor
    }

    var pageGuideHairlineColor: UIColor {
        UIColor(hex: vsColors["editor.background"] ?? "")
            ?? baseTheme.pageGuideHairlineColor
    }

    var pageGuideBackgroundColor: UIColor {
        UIColor(hex: vsColors["editor.background"] ?? "")
            ?? baseTheme.pageGuideBackgroundColor
    }

    var markedTextBackgroundColor: UIColor {
        UIColor(hex: vsColors["editor.selectionBackground"] ?? "")
            ?? baseTheme.markedTextBackgroundColor
    }

    func textColor(for highlightName: String) -> UIColor? {
        // https://github.com/yonihemi/TM2Runestone/blob/main/Sources/TM2Runestone/Convert.swift
        let mapping = [
            "delimeter": "punctuation.separator",
            "text.strong_emphasis": "markup.bold",
            "text.emphasis": "markup.italic",
            "text.title": "markup.heading",
            "text.link": "markup.underline.link",

            "attribute": "entity.other.attribute-name",
            "constant": "support.constant",
            "constant.builtin": "constant.language",
            "constructor": "",
            "comment": "comment",
            "delimiter": "",
            "escape": "constant.character.escape",
            "field": "",
            "function": "entity.name.function",
            "function.builtin": "entity.name.function",
            "function.method": "entity.name.function",
            "keyword": "keyword",
            "number": "constant.numeric",
            "operator": "keyword.operator",
            "property": "variable",
            "punctuation.bracket": "punctuation",
            "punctuation.delimiter": "punctuation",
            "punctuation.special": "punctuation",
            "string": "string",
            "string.special": "constant.other.symbol",
            "tag": "entity.name.tag",
            "type": "storage.type",
            "type.builtin": "storage.type",
            "variable": "variable",
            "variable.builtin": "variable",

        ]
        guard let tokenName = mapping[highlightName],
            let hex = vsTokenColors[tokenName]
        else {
            return baseTheme.textColor
        }
        return UIColor(hex: hex)
    }

}

struct URLTextState {
    var url: String
    var version: Int
    var state: TextViewState

    init(url: String, state: TextViewState) {
        self.url = url
        self.version = 0
        self.state = state
    }
}

class RunestoneImplementation: NSObject {
    private var textView: TextView
    private let workerQueue = DispatchQueue.global(qos: .userInitiated)

    var options: EditorOptions {
        didSet {
            configureTextViewForOptions(options: options)
        }
    }
    var theme: EditorTheme {
        didSet {
            self.runeStoneTheme = DynamicTheme(
                light: theme.light != nil ? RunestoneTheme(vsTheme: theme.light!) : DefaultTheme(),
                dark: theme.dark != nil ? RunestoneTheme(vsTheme: theme.dark!) : DefaultTheme(),
                font: UIFont(name: options.fontFamily, size: CGFloat(options.fontSize))
                    ?? DefaultTheme().font
            )
        }
    }
    private var runeStoneTheme: DynamicTheme

    weak var delegate: EditorImplementationDelegate? {
        didSet {
            delegate?.didFinishInitialising()
        }
    }
    private var states: [String: URLTextState] = [:]
    private var currentURL: String? = nil

    @MainActor func setState(state: URLTextState) {
        states[state.url] = state
        currentURL = state.url
        self.textView.setState(state.state)
    }

    init(options: EditorOptions, theme: EditorTheme) {
        self.options = options
        self.theme = theme
        self.runeStoneTheme = DynamicTheme(
            light: theme.light != nil ? RunestoneTheme(vsTheme: theme.light!) : DefaultTheme(),
            dark: theme.dark != nil ? RunestoneTheme(vsTheme: theme.dark!) : DefaultTheme(),
            font: UIFont(name: options.fontFamily, size: CGFloat(options.fontSize))
                ?? DefaultTheme().font
        )

        let textView = TextView()
        textView.showLineNumbers = true
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.backgroundColor = runeStoneTheme.backgroundColor
        self.textView = textView

        super.init()

        textView.editorDelegate = self
        configureTextViewForOptions(options: options)
    }

    func configureTextViewForOptions(options: EditorOptions) {
        runeStoneTheme.editorFont =
            UIFont(name: options.fontFamily, size: CGFloat(options.fontSize)) ?? DefaultTheme().font
        textView.isEditable = !options.readOnly
        textView.showLineNumbers = options.lineNumbersEnabled
        textView.isLineWrappingEnabled = !(options.wordWrap == .off)
        if let currentState = states[currentURL ?? ""] {
            textView.setState(currentState.state)
        }
    }
}

extension RunestoneImplementation: EditorImplementation {
    var view: UIView {
        textView
    }

    func setModel(url: String) async {
        if let state = states[url] {
            await setState(state: state)
        }
    }

    func setModelToEmpty() async {
        await MainActor.run {
            self.textView.text = ""
        }
    }

    private func detectLangauge(url: String) -> TreeSitterLanguage? {
        if url.hasSuffix(".js") {
            return .javaScript
        } else if url.hasSuffix(".py") {
            return .python
        } else if url.hasSuffix(".c") || url.hasSuffix(".h") {
            return .c
        } else if url.hasSuffix(".cpp") {
            return .cpp
        }

        return nil
    }

    func createNewModel(url: String, value: String) async {
        workerQueue.async {
            if let language = self.detectLangauge(url: url) {
                let state = URLTextState(
                    url: url,
                    state: TextViewState(
                        text: value,
                        theme: self.runeStoneTheme,
                        language: language
                    ))
                DispatchQueue.main.async {
                    self.setState(state: state)
                }
            } else {
                let state = URLTextState(
                    url: url,
                    state: TextViewState(
                        text: value,
                        theme: self.runeStoneTheme
                    ))
                DispatchQueue.main.async {
                    self.setState(state: state)
                }
            }
        }
    }

    func renameModel(oldURL: String, updatedURL: String) async {
        guard let state = states[oldURL] else { return }
        states.removeValue(forKey: oldURL)
        states[updatedURL] = state
    }

    func setValueForModel(url: String, value: String) async {
        let currentState = states[currentURL ?? ""]
        guard let originalState = states[url] else { return }
        Task { @MainActor in
            self.setState(state: originalState)
            self.textView.text = value
            if let currentState {
                self.setState(state: currentState)
            }

        }
    }

    func removeAllModels() async {
        states.removeAll()
    }

    func getViewState() async -> String {
        return "[]"
    }

    func setVSTheme(theme: Theme) async {
        if theme.isDark {
            self.theme.dark = theme
        } else {
            self.theme.light = theme
        }
        await MainActor.run {
            self.textView.backgroundColor = self.runeStoneTheme.backgroundColor
        }
    }

    func focus() async {

    }

    func blur() async {

    }

    func searchTermInEditor(term: String) async {

    }

    func scrollToLine(line: Int) async {

    }

    func openSearchWidget() async {
    }

    func undo() async {

    }

    func redo() async {

    }

    func getSelectedValue() async -> String {
        return await MainActor.run {
            if let range = textView.selectedTextRange {
                return textView.text(in: range) ?? ""
            }
            return ""
        }
    }

    func pasteText(text: String) async {

    }

    func insertTextAtCurrentCursor(text: String) async {

    }

    func moveCursor(direction: CursorDirection) async {

    }

    func editorInFocus() async -> Bool {
        return await MainActor.run {
            return textView.isFirstResponder
        }
    }

    func invalidateDecorations() async {

    }

    func switchToDiffMode(
        originalContent: String, modifiedContent: String, originalUrl: String, modifiedUrl: String
    ) async {

    }

    func switchToInlineDiffView() async {

    }

    func switchToNormalMode() async {

    }

    func moveToNextDiff() async {

    }

    func moveToPreviousDiff() async {

    }

    func isEditorInDiffMode() async -> Bool {
        return false
    }

    func _applyCustomShortcuts() async {

    }

    func _toggleCommandPalatte() async {

    }

    func _toggleGoToLineWidget() async {

    }

    func _restoreEditorState(state: String) async {

    }

    func _getMonacoActions() async -> [MonacoEditorAction] {
        return []
    }

}

extension RunestoneImplementation: TextViewDelegate {
    func textViewDidChange(_ textView: TextView) {
        guard let delegate, let currentURL else { return }

        var updatedState = states[currentURL]!
        updatedState.version += 1
        states[currentURL] = updatedState

        delegate.editorImplementation(
            contentDidChangeForModelURL: currentURL, content: textView.text,
            versionID: updatedState.version)
    }

    func textViewDidChangeSelection(_ textView: TextView) {
        if let textLocation = textView.textLocation(at: textView.selectedRange.location) {
            delegate?.editorImplementation(
                cursorPositionDidChange: textLocation.lineNumber + 1,
                column: textLocation.column + 1)
        }
    }
}
