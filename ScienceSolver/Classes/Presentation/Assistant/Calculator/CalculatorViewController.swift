import UIKit
import Expression    // Import the Expression library
import SwiftMath     // Import the SwiftMath library for LaTeX rendering

typealias Expression = NumericExpression

// Token enumeration for the tokenizer
enum Token: Equatable {
    case number(String)
    case operatorSymbol(String)
    case function(String)
    case variable(String)
    case leftParenthesis
    case rightParenthesis
    case comma
    case endOfInput
    case error(String)
}

// ExpressionNode enumeration for the parser
indirect enum ExpressionNode {
    case number(String)
    case variable(String)
    case binaryOperation(ExpressionNode, String, ExpressionNode)
    case unaryOperation(String, ExpressionNode)
    case function(String, [ExpressionNode])
    case incomplete(ExpressionNode?) // Handle incomplete expressions
    case error(String)
}

class CalculatorViewController: UIViewController {
    
    private var displayLabelHeightConstraint: NSLayoutConstraint!
    private var scrollViewHeightConstraint: NSLayoutConstraint!
    private var displayLabelWidthConstraint: NSLayoutConstraint!
    private var scrollView: UIScrollView!
    private var spacerView: UIView! // Spacer view to push content to the bottom
    // **Add properties for the history scroll view and stack view**
    private var historyScrollView: UIScrollView!
    private var historyStackView: UIStackView!
    private var historyScrollViewHeightConstraint: NSLayoutConstraint!
    
    private var firstHistoryEntry: Bool = true
  
    private let dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        
        // Set the image instead of title
        if let dismissImage = UIImage(named: "AssistantResult.Close") {
            button.setImage(dismissImage, for: .normal)
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 24.scale).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24.scale).isActive = true
        return button
    }()
    // Calculator display label using MTMathUILabel for LaTeX rendering
    private let displayLabel: MTMathUILabel = {
        let label = MTMathUILabel()
        label.textAlignment = .right
        label.fontSize = 29.scale
        let font = MTFontManager().font(withName: "FiraMath-Regular", size: 29.scale)
        label.font = font!
        label.latex = "0"
        label.textAlignment = .right
        label.backgroundColor = .clear//.yellow
        label.contentInsets = UIEdgeInsets(top: 10.scale, left: 10.scale, bottom: 10.scale, right: 10.scale)
        return label
    }()
    
    // StackView to hold buttons
    private var buttonStackView: UIStackView!
    
    // Keep track of input expression
    private var currentExpression: String = ""
    
    // Flag to toggle between symbolic and decimal display
    private var isDecimalDisplay: Bool = true
    
    // Store the last result for toggling display modes
    private var lastResult: Double?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.mono100
        setupUI()
        currentExpression = ""
        updateDisplay()
        updateDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    private func setupUI() {
        view.backgroundColor = Appearance.main100
      
        view.addSubview(dismissButton)
           dismissButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)

           // Set dismiss button constraints (top-left of the screen)
           NSLayoutConstraint.activate([
               dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12.scale),
               dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale)
           ])
        // **Initialize the history scroll view**
        historyScrollView = UIScrollView()
        historyScrollView.showsHorizontalScrollIndicator = false
        historyScrollView.showsVerticalScrollIndicator = true
        historyScrollView.bounces = true // Enable bouncing
        historyScrollView.backgroundColor = .clear//.systemPink
        view.addSubview(historyScrollView)
        historyScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // **Initialize the history stack view**
        historyStackView = UIStackView()
        historyStackView.axis = .vertical
        historyStackView.alignment = .fill
        historyStackView.distribution = .fill
        historyStackView.spacing = 8.scale
        historyScrollView.addSubview(historyStackView)
        historyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // **Add a flexible spacer view at the top of the stack view**
        spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        historyStackView.addArrangedSubview(spacerView)
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        // Initialize the scroll view for the display label
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false // Disable bouncing
        scrollView.backgroundColor = .clear//.blue
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add display label to the scroll view
        scrollView.addSubview(displayLabel)
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
      
        let greenView = UIView()
            greenView.backgroundColor = Appearance.main300 // Set the background color to Appearance.main300
            greenView.translatesAutoresizingMaskIntoConstraints = false
            displayLabel.addSubview(greenView)
      
        // Create calculator buttons
        setupButtons()
        
        displayLabelHeightConstraint = displayLabel.heightAnchor.constraint(equalToConstant: 10.scale)
        displayLabelWidthConstraint = displayLabel.widthAnchor.constraint(equalToConstant: 100) // Initial width
        
        scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: 30.scale)
        
        // **Set up the history scroll view constraints**
        NSLayoutConstraint.activate([
            historyScrollView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 12.scale),
            historyScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.scale),
            historyScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.scale),
            // Height constraint will be adjusted dynamically
        ])
        
        historyScrollViewHeightConstraint = historyScrollView.heightAnchor.constraint(equalToConstant: 0)
        historyScrollViewHeightConstraint.isActive = true
        
        // **Set up the history stack view constraints**
        NSLayoutConstraint.activate([
            historyStackView.topAnchor.constraint(equalTo: historyScrollView.topAnchor),
            historyStackView.leadingAnchor.constraint(equalTo: historyScrollView.leadingAnchor),
            historyStackView.trailingAnchor.constraint(equalTo: historyScrollView.trailingAnchor),
            historyStackView.bottomAnchor.constraint(equalTo: historyScrollView.bottomAnchor),
            historyStackView.widthAnchor.constraint(equalTo: historyScrollView.widthAnchor)
        ])
        
        // **Set up constraints for the scroll view and display label**
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: historyScrollView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.scale),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.scale),
            scrollViewHeightConstraint,
            
            // Display label constraints inside the scroll view
            displayLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            displayLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            displayLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            
            // Constraint to set displayLabel width to the scrollView width
            displayLabelWidthConstraint, // Make label as wide as the scroll view
            displayLabelHeightConstraint
        ])
        NSLayoutConstraint.activate([
              greenView.topAnchor.constraint(equalTo: displayLabel.topAnchor),
              greenView.bottomAnchor.constraint(equalTo: displayLabel.bottomAnchor),
              greenView.trailingAnchor.constraint(equalTo: displayLabel.trailingAnchor), // Pin to the right
              greenView.widthAnchor.constraint(equalToConstant: 2.scale) // Set the width to 2.scale
          ])
    }
    
    @objc private func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func adjustDisplayLabelHeight() {
        guard let displayList = displayLabel.displayList else { return }

        // Calculate the height of the rendered LaTeX content
        let totalHeight = displayList.ascent + displayList.descent + displayLabel.contentInsets.top + displayLabel.contentInsets.bottom

        // Update the height constraint with the calculated height
        displayLabelHeightConstraint.constant = totalHeight + 0.scale // Adding additional padding if needed

        // Update the scroll view's height to match the label's height
        scrollViewHeightConstraint.constant = displayLabelHeightConstraint.constant

        // Calculate the width of the rendered LaTeX content
        let totalWidth = displayList.width + displayLabel.contentInsets.left + displayLabel.contentInsets.right

        // Update the width constraint with the calculated width
        displayLabelWidthConstraint.constant = totalWidth

        // Update the scroll view's content size to match the label's content size
        scrollView.contentSize = CGSize(width: totalWidth, height: totalHeight)

        // Scroll to the far right to align content to the right
        scrollView.setContentOffset(CGPoint(x: totalWidth - scrollView.bounds.width, y: 0), animated: false)

        // Adjust the history scroll view's height
        adjustHistoryScrollViewHeight()

        // Animate the height change if needed
        self.view.layoutIfNeeded()
    }

    
    private func adjustHistoryScrollViewHeight() {
        let totalUsedHeight = displayLabelHeightConstraint.constant + 460.scale + 30.scale // 24.scale is total vertical spacing
        
        let availableHeight = view.frame.height - totalUsedHeight - view.safeAreaInsets.top
        
        historyScrollViewHeightConstraint.constant = max(availableHeight, 0)
    }
    
    private func setupButtons() {
        // Grid of buttons
        
        buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 4.scale
        
        let buttonTitles = [
            ["nCr", "log10", "(", ")", ","],
            ["e^x", "x²", "√", "x^y","n!", "nPr"],
            ["y√x", "π", "e", "|x|","AC", "DEL"],
            ["sin", "cos","7", "8", "9", "/"],
            ["tan", "ln","4", "5", "6","×"],
            [ "asin", "acos","1", "2", "3","−"],
            ["atan", "S<=>D","0", ".", "=", "+"],
        ]
        class CustomButton: UIButton {
            override var isHighlighted: Bool {
                didSet {
                    // Prevent any highlight effect
                    super.isHighlighted = false
                }
            }
        }
        for row in buttonTitles {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 4.scale
            
            for title in row {
                if title.isEmpty {
                    let spacer = UIView()
                    rowStackView.addArrangedSubview(spacer)
                    continue
                }
                let button = CustomButton(type: .custom)
                button.setTitle(title, for: .normal)
                button.setTitleColor(.clear, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18.scale)
                button.backgroundColor = .lightGray
                button.layer.cornerRadius = 16.scale
                
                var cellImage = UIImage(named: "Cell")
                setImageName(button, &cellImage)
                button.setBackgroundImage(cellImage, for: .normal)
                
                button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
                button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
                
                rowStackView.addArrangedSubview(button)
            }
            
            buttonStackView.addArrangedSubview(rowStackView)
        }
        
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.heightAnchor.constraint(equalToConstant: 400.scale),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.scale),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.scale),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.scale)
        ])
    }
    
    @objc func buttonReleased(_ sender: UIButton) {
        // Revert back to the default image when released
        var cellImage = UIImage(named: "Cell")
        setImageName(sender, &cellImage)
        sender.setBackgroundImage(cellImage, for: .normal)
    }
    
    // Handle button press events
    @objc private func buttonPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        
        var cellImage = UIImage(named: "Cell")
        setDimmedImageName(sender, &cellImage)
        sender.setBackgroundImage(cellImage, for: .normal)
        
        switch title {
        case "AC":
            currentExpression = ""
            displayLabel.latex = "0"
            lastResult = nil
            updateDisplay()
            updateDisplay()
        case "DEL":
            if !currentExpression.isEmpty {
                // Special case: if currentExpression is exactly "log10(", clear it
                if currentExpression == "log10(" {
                    currentExpression = ""
                }
                // Existing check: if no digits or decimals are present, clear it completely.
                else if currentExpression.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil &&
                        !currentExpression.contains(".") {
                    currentExpression = ""
                } else {
                    currentExpression.removeLast()
                }
                updateDisplay()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.adjustDisplayLabelHeight()
            }
        case "(":
              if currentExpression.isEmpty {
                  // Do nothing if expression is empty
                  return
              } else {
                  currentExpression += "("
                  updateDisplay()
              }
          case ")":
              if currentExpression.isEmpty {
                  // Do nothing if expression is empty
                  return
              } else {
                  currentExpression += ")"
                  updateDisplay()
              }
        case "=":
            balanceParentheses()
            
            let originalExpression = currentExpression
            if let result = evaluateExpression(originalExpression) {
                addExpressionToHistory(originalExpression, result: result)
                currentExpression = "" // Clear current expression
                lastResult = result
            } else {
                currentExpression = ""
                lastResult = nil
            }
            updateDisplay()
            updateDisplay()
        case "e^x":
            currentExpression += "exp("
            updateDisplay()
            updateDisplay()
        case "x²":
            if currentExpression.isEmpty {
                    // If there's no base number, default to 0
                    currentExpression = "0"
            }
            currentExpression += "^(2)"
            updateDisplay()
            updateDisplay()
            delay(0.01) {
                self.updateDisplay()
            }
        case "√":
            currentExpression += "sqrt("
            updateDisplay()
            updateDisplay()
        case "n!":
            if currentExpression.isEmpty {
                    // If there's no base number, default to 0
                    currentExpression = "0"
            }
            currentExpression += "!"
            updateDisplay()
            updateDisplay()
            delay(0.01) {
                self.updateDisplay()
            }
        case "nPr":
            currentExpression += "nPr("
            updateDisplay()
            updateDisplay()
        case "nCr":
            currentExpression += "nCr("
            updateDisplay()
            updateDisplay()
        case "|x|":
            currentExpression += "abs("
            updateDisplay()
            updateDisplay()
        case "π":
            currentExpression += "pi"
            updateDisplay()
            updateDisplay()
        case "e":
            currentExpression += "e"
            updateDisplay()
            updateDisplay()
        case "S<=>D":
            let originalExpression = currentExpression
            if let result = evaluateExpressionToToggleDisplayMode(originalExpression) {
               // addExpressionToHistory(originalExpression, result: result)
                currentExpression = "\(result)" // Clear current expression
                lastResult = result
            } else {
                currentExpression = ""
                lastResult = nil
            }
            self.adjustDisplayLabelHeight()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.adjustDisplayLabelHeight()
            }
        //    updateDisplay()
        case ",":
            currentExpression += ","
            updateDisplay()
            updateDisplay()
        case "sin", "cos", "tan", "asin", "acos", "atan", "log10", "ln":
            currentExpression += "\(title)("
            updateDisplay()
            updateDisplay()
            delay(0.01) {
                self.updateDisplay()
            }
        case "x^y":
            if currentExpression.isEmpty {
                    // If there's no base number, default to 0
                    currentExpression = "0"
            }
            currentExpression += "^("
            updateDisplay()
            updateDisplay()
            delay(0.01) {
                self.updateDisplay()
            }
        case "y√x":
            if currentExpression.isEmpty {
                    // If there's no base number, default to 0
                    currentExpression = "0"
            }
            currentExpression += "^(1/("
            updateDisplay()
            updateDisplay()
            delay(0.01) {
                self.updateDisplay()
            }
        case "×":
            if currentExpression.isEmpty {
                    // If there's no base number, default to 0
                    currentExpression = "0"
            }
            currentExpression += "*"
            updateDisplay()
            updateDisplay()
            delay(0.01) {
                self.updateDisplay()
            }
        case "−":
            if currentExpression.isEmpty {
                    // If there's no base number, default to 0
                    currentExpression = "0"
            }
            currentExpression += "-"
            updateDisplay()
            updateDisplay()
            delay(0.01) {
                self.updateDisplay()
            }
        case "+":
            if currentExpression.isEmpty {
                    // If there's no base number, default to 0
                    currentExpression = "0"
            }
            currentExpression += "+"
            updateDisplay()
            updateDisplay()
            delay(0.01) {
                self.updateDisplay()
            }
        case "/":
            if currentExpression.isEmpty {
                    // If there's no base number, default to 0
                    currentExpression = "0"
            }
            currentExpression += "/"
            updateDisplay()
            updateDisplay()
            delay(0.01) {
                self.updateDisplay()
            }
        default:
            currentExpression += title
            updateDisplay()
            updateDisplay()
        }
        print("Current Expression: \(currentExpression)")
    }
    
    // **Function to add the current display to the history**
    private func addExpressionToHistory(_ expression: String, result: Double) {
           // Check if this is the first time the history is being updated
           if firstHistoryEntry {
               // Add the big blue spacer view to the history
               let bigBlueSpacerView = UIView()
               bigBlueSpacerView.backgroundColor = .clear
               bigBlueSpacerView.translatesAutoresizingMaskIntoConstraints = false
               bigBlueSpacerView.heightAnchor.constraint(equalToConstant: historyScrollView.frame.height).isActive = true
               historyStackView.addArrangedSubview(bigBlueSpacerView)
               
               // Set the flag to false to prevent further additions of the blue spacer
               firstHistoryEntry = false
           }

           // Create a label for the expression
           let expressionLabel = MTMathUILabel()
           expressionLabel.textAlignment = .right
           expressionLabel.fontSize = displayLabel.fontSize
           expressionLabel.font = displayLabel.font
           let tokens = tokenize(expression: expression)
           let parser = Parser(tokens: tokens)
           let expressionNode = parser.parseExpression()
           let latexCode = expressionNodeToLatex(expressionNode)
           expressionLabel.latex = latexCode
           expressionLabel.contentInsets = displayLabel.contentInsets
           expressionLabel.backgroundColor = .clear
       
        expressionLabel.layoutSubviews()
        var displayList = expressionLabel.displayList!
        
        var totalWidth = displayList.width + displayLabel.contentInsets.left + displayLabel.contentInsets.right
      
        var fontSize = expressionLabel.fontSize
           while totalWidth > historyScrollView.frame.width {
               fontSize -= 0.1
               expressionLabel.font =  MTFontManager().font(withName: "FiraMath-Regular", size: fontSize)
               if expressionLabel.fontSize < 1 {  // Prevent font size from becoming too small
                   expressionLabel.font =  MTFontManager().font(withName: "FiraMath-Regular", size: 1)
                   break
               }
               expressionLabel.layoutSubviews()
               let displayList = expressionLabel.displayList!
               totalWidth = displayList.width + displayLabel.contentInsets.left + displayLabel.contentInsets.right
               print("totalWidth: \(totalWidth), fontSize: \(fontSize)")
           }

        
           // Create a label for the result
           let resultLabel = MTMathUILabel()
           resultLabel.textAlignment = .right
        resultLabel.fontSize = displayLabel.fontSize * 1.5 // Double the font size
        resultLabel.font = MTFontManager().font(withName: "FiraMath-Regular", size: 29*1.5.scale) // S
           let resultLatex: String
           if isDecimalDisplay {
               resultLatex = "= " + formatDecimalResult(result)
           } else {
               resultLatex = "= " + formatSymbolicResult(result)
           }
           resultLabel.latex = resultLatex
           resultLabel.contentInsets = displayLabel.contentInsets
           resultLabel.backgroundColor = .clear
        
        resultLabel.layoutSubviews()
         displayList = resultLabel.displayList!
        
         totalWidth = displayList.width + displayLabel.contentInsets.left + displayLabel.contentInsets.right
        
        fontSize = resultLabel.fontSize
           while totalWidth > historyScrollView.frame.width {
               fontSize -= 0.1
               resultLabel.font =  MTFontManager().font(withName: "FiraMath-Regular", size: fontSize)
               if resultLabel.fontSize < 1 {  // Prevent font size from becoming too small
                   resultLabel.font =  MTFontManager().font(withName: "FiraMath-Regular", size: 1)
                   break
               }
               resultLabel.layoutSubviews()
               let displayList = resultLabel.displayList!
               totalWidth = displayList.width + displayLabel.contentInsets.left + displayLabel.contentInsets.right
               print("totalWidth: \(totalWidth), fontSize: \(fontSize)")
           }


        // Create the separator view
           let separatorView = UIView()
           separatorView.translatesAutoresizingMaskIntoConstraints = false
           separatorView.backgroundColor = .clear
           separatorView.heightAnchor.constraint(equalToConstant: 30.scale).isActive = true

           let innerSeparatorView = UIView()
           innerSeparatorView.translatesAutoresizingMaskIntoConstraints = false
           innerSeparatorView.backgroundColor = Appearance.main200
           separatorView.addSubview(innerSeparatorView)

           NSLayoutConstraint.activate([
               innerSeparatorView.heightAnchor.constraint(equalToConstant: 1.scale),
               innerSeparatorView.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
               innerSeparatorView.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
               innerSeparatorView.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor)
           ])

           // Create a container stack view to hold expressionLabel, separatorView, and resultLabel
           let containerStackView = UIStackView()
           containerStackView.axis = .vertical
           containerStackView.alignment = .fill
           containerStackView.distribution = .fillProportionally
           containerStackView.spacing = 2.scale
           containerStackView.addArrangedSubview(expressionLabel)
           containerStackView.addArrangedSubview(resultLabel)
            containerStackView.addArrangedSubview(separatorView)  // Add the separator view here
           // Insert the container stack view before the spacer view
           historyStackView.addArrangedSubview(containerStackView)

           // Adjust the history scroll view's content size
           adjustHistoryScrollViewHeight()

        // Dynamically enable or disable scrolling based on content size
       
        
           // Scroll to the bottom of the history to show the latest entry
           historyScrollView.layoutIfNeeded()
      
           let bottomOffset = CGPoint(x: 0, y: max(historyScrollView.contentSize.height - historyScrollView.bounds.height, 0))
           historyScrollView.setContentOffset(bottomOffset, animated: true)
        delay(0.1) { [self] in
            DispatchQueue.main.async {
                if historyScrollView.contentSize.height >= (historyScrollView.frame.height * 2) {
                    historyScrollView.isScrollEnabled = true
                    // Reduce visible content by 200 points from the top
                    historyScrollView.contentInset.top = -historyScrollView.frame.height
                } else {
                    historyScrollView.isScrollEnabled = false
                    // Reset the top inset when scrolling is disabled
                    historyScrollView.contentInset.top = 0
                }
            }
        }
       }
    
    // Toggle between symbolic and decimal display modes
    private func toggleDisplayMode() {
        isDecimalDisplay.toggle()
        if let result = lastResult {
            if isDecimalDisplay {
                displayLabel.latex = formatDecimalResult(result)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.adjustDisplayLabelHeight()
                }
            } else {
                displayLabel.latex = formatSymbolicResult(result)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.adjustDisplayLabelHeight()
                }
            }
        } else {
            // Handle the case where there's no last result
            updateDisplay()
        }
       
     
    }
    
    // Update the display label
    private func updateDisplay() {
        if currentExpression.isEmpty {
            displayLabel.latex = "0"
        } else {
            let tokens = tokenize(expression: currentExpression)
            let parser = Parser(tokens: tokens)
            let expressionNode = parser.parseExpression()
            let latexCode = expressionNodeToLatex(expressionNode)
            displayLabel.latex = latexCode
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.adjustDisplayLabelHeight()
        }
    }
    
    // Preprocess the expression to handle factorials
    private func preprocessExpression(_ expression: String) -> String {
        var newExpression = expression
        newExpression = preprocessFactorials(in: newExpression)
        return newExpression
    }
    
    // Preprocess the expression to handle factorials
    private func preprocessFactorials(in expression: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(\\d+|\\)|\\w+)!")
        let range = NSRange(location: 0, length: expression.utf16.count)
        var newExpression = expression
        let matches = regex.matches(in: expression, options: [], range: range)
        
        for match in matches.reversed() {
            let matchRange = match.range(at: 1)
            if let numberRange = Range(matchRange, in: expression) {
                let matchedString = String(expression[numberRange])
                let replacement = "factorial(\(matchedString))"
                let totalRange = Range(match.range, in: expression)!
                newExpression.replaceSubrange(totalRange, with: replacement)
            }
        }
        return newExpression
    }
    
    // Ensure parentheses are balanced by adding any missing closing parentheses
    private func balanceParentheses() {
        var openParentheses = 0
        var closeParentheses = 0
        
        for char in currentExpression {
            if char == "(" {
                openParentheses += 1
            } else if char == ")" {
                closeParentheses += 1
            }
        }
        
        if openParentheses > closeParentheses {
            let missingClosingParentheses = openParentheses - closeParentheses
            currentExpression += String(repeating: ")", count: missingClosingParentheses)
            updateDisplay()
        }
    }
    private func evaluateExpression(_ expression: String) -> Double? {
        do {
            if isExpressionComplete(expression) {
                let preprocessedExpression = preprocessExpression(expression)
                let exp = NumericExpression(preprocessedExpression, constants: ["pi": Double.pi, "e": M_E], symbols: supportedSymbols())
                let result = try exp.evaluate()

                lastResult = result

                return result
            } else {
                displayLabel.latex = "\\text{Incomplete Expression}"
                return nil
            }
        } catch {
            displayLabel.latex = "\\text{Error}"
            return nil
        }
    }
    private func evaluateExpressionToToggleDisplayMode(_ expression: String) -> Double? {
        do {
            if isExpressionComplete(expression) {
                let preprocessedExpression = preprocessExpression(expression)
                let exp = NumericExpression(preprocessedExpression, constants: ["pi": Double.pi, "e": M_E], symbols: supportedSymbols())
                let result = try exp.evaluate()

                lastResult = result
                
                isDecimalDisplay.toggle()
                if let result = lastResult {
                    if isDecimalDisplay {
                        displayLabel.latex = formatDecimalResult(result)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            self.adjustDisplayLabelHeight()
                        }
                    } else {
                        displayLabel.latex = formatSymbolicResult(result)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            self.adjustDisplayLabelHeight()
                        }
                    }
                } else {
                    // Handle the case where there's no last result
                    updateDisplay()
                }

                return result
            } else {
                displayLabel.latex = "\\text{Incomplete Expression}"
                return nil
            }
        } catch {
            displayLabel.latex = "\\text{Error}"
            return nil
        }
    }
    // Evaluate the expression using NumericExpression from the Expression library
    private func evaluateExpression() {
        do {
            if isExpressionComplete(currentExpression) {
                let preprocessedExpression = preprocessExpression(currentExpression)
                let expression = NumericExpression(preprocessedExpression, constants: ["pi": Double.pi, "e": M_E], symbols: supportedSymbols())
                let result = try expression.evaluate()
                
                lastResult = result
                
                if isDecimalDisplay {
                    displayLabel.latex = formatDecimalResult(result)
                } else {
                    displayLabel.latex = formatSymbolicResult(result)
                }
                
                currentExpression = "\(result)"
            } else {
                displayLabel.latex = "\\text{Incomplete Expression}"
            }
        } catch {
            displayLabel.latex = "\\text{Error}"
            currentExpression = ""
        }
    }
    
    // Function to check if the expression is complete
    private func isExpressionComplete(_ expression: String) -> Bool {
        var openParentheses = 0
        var closeParentheses = 0
        
        for char in expression {
            if char == "(" {
                openParentheses += 1
            } else if char == ")" {
                closeParentheses += 1
            }
        }
        
        return openParentheses == closeParentheses
    }
    
    // Define custom symbols for NumericExpression to handle advanced operations
    private func supportedSymbols() -> [Expression.Symbol: NumericExpression.SymbolEvaluator] {
        return [
            .function("sin", arity: 1): { args in sin(args[0]) },
            .function("cos", arity: 1): { args in cos(args[0]) },
            .function("tan", arity: 1): { args in tan(args[0]) },
            .function("asin", arity: 1): { args in asin(args[0]) },
            .function("acos", arity: 1): { args in acos(args[0]) },
            .function("atan", arity: 1): { args in atan(args[0]) },
            .function("log10", arity: 1): { args in log10(args[0]) },
            .function("ln", arity: 1): { args in log(args[0]) },
            .function("exp", arity: 1): { args in exp(args[0]) },
            .function("sqrt", arity: 1): { args in sqrt(args[0]) },
            .function("abs", arity: 1): { args in abs(args[0]) },
            .function("factorial", arity: 1): { args in self.factorial(args[0]) },
            .function("nPr", arity: 2): { args in self.permutation(args[0], args[1]) },
            .function("nCr", arity: 2): { args in self.combination(args[0], args[1]) },
            .infix("^"): { args in pow(args[0], args[1]) },
            .variable("pi"): { _ in Double.pi },
            .variable("e"): { _ in M_E }
        ]
    }
    
    // Implement factorial function
    private func factorial(_ n: Double) -> Double {
        if n < 0 || floor(n) != n {
            return Double.nan // Factorial not defined for negative or non-integer numbers
        }
        if n == 0 || n == 1 {
            return 1
        }
        return tgamma(n + 1) // Use gamma function for better accuracy
    }
    
    // Implement permutation function
    private func permutation(_ n: Double, _ r: Double) -> Double {
        if n < 0 || r < 0 || n < r || floor(n) != n || floor(r) != r {
            return Double.nan
        }
        return factorial(n) / factorial(n - r)
    }
    
    // Implement combination function
    private func combination(_ n: Double, _ r: Double) -> Double {
        if n < 0 || r < 0 || n < r || floor(n) != n || floor(r) != r {
            return Double.nan
        }
        return factorial(n) / (factorial(r) * factorial(n - r))
    }
    
    // Tokenizer function to convert expression string to tokens
    private func tokenize(expression: String) -> [Token] {
        var tokens = [Token]()
        var index = expression.startIndex
        
        while index < expression.endIndex {
            let char = expression[index]
            
            if char.isWhitespace {
                // Skip whitespace
                index = expression.index(after: index)
                continue
            } else if char.isNumber || char == "." {
                // Parse number
                var numberString = String(char)
                index = expression.index(after: index)
                while index < expression.endIndex && (expression[index].isNumber || expression[index] == ".") {
                    numberString.append(expression[index])
                    index = expression.index(after: index)
                }
                tokens.append(.number(numberString))
            } else if char.isLetter {
                // Parse function name or variable
                var name = String(char)
                index = expression.index(after: index)
                while index < expression.endIndex && (expression[index].isLetter || expression[index].isNumber) {
                    name.append(expression[index])
                    index = expression.index(after: index)
                }
                // Check if it's a function or variable
                if ["sin", "cos", "tan", "asin", "acos", "atan", "log10", "ln", "exp", "sqrt", "abs", "factorial", "nPr", "nCr"].contains(name) {
                    tokens.append(.function(name))
                } else if ["pi", "e"].contains(name) {
                    tokens.append(.variable(name))
                } else {
                    tokens.append(.error("Unknown identifier \(name)"))
                }
            } else if "+-*/^".contains(char) {
                tokens.append(.operatorSymbol(String(char)))
                index = expression.index(after: index)
            } else if char == "(" {
                tokens.append(.leftParenthesis)
                index = expression.index(after: index)
            } else if char == ")" {
                tokens.append(.rightParenthesis)
                index = expression.index(after: index)
            } else if char == "," {
                tokens.append(.comma)
                index = expression.index(after: index)
            } else if char == "!" {
                // Factorial operator
                tokens.append(.operatorSymbol("!"))
                index = expression.index(after: index)
            } else {
                tokens.append(.error("Unknown character \(char)"))
                index = expression.index(after: index)
            }
        }
        
        tokens.append(.endOfInput) // Add end of input token
        return tokens
    }
    
    
    
    // Convert expression tree to LaTeX code
    private func expressionNodeToLatex(_ node: ExpressionNode) -> String {
        switch node {
        case .number(let value):
            return value
        case .variable(let name):
            if name == "pi" {
                return "\\pi"
            } else if name == "e" {
                return "e"
            } else {
                return name
            }
        case .binaryOperation(let left, let op, let right):
            let leftLatex = wrapIfNeeded(left, forOperator: op)
            let rightLatex = wrapIfNeeded(right, forOperator: op)
            let opLatex: String
            switch op {
            case "+":
                opLatex = "+"
            case "-":
                opLatex = "-"
            case "*":
                opLatex = "\\times"
            case "/":
                return "\\frac{\(leftLatex)}{\(rightLatex)}"
            case "^":
                return "{\(leftLatex)}^{\(rightLatex)}"
            default:
                opLatex = op
            }
            return "\(leftLatex) \(opLatex) \(rightLatex)"
        case .unaryOperation(let op, let expr):
            let exprLatex = expressionNodeToLatex(expr)
            if op == "-" {
                return "-\(exprLatex)"
            } else {
                return "\(op)\(exprLatex)"
            }
        case .function(let name, let args):
            let argsLatex = args.map { expressionNodeToLatex($0) }.joined(separator: ", ")
            if name == "sqrt" {
                return "\\sqrt{\(argsLatex)}"
            } else if name == "log10" {
                return "\\log_{10}{\(argsLatex)}"
            } else if name == "ln" {
                return "\\ln{\(argsLatex)}"
            } else if name == "exp" {
                return "e^{\(argsLatex)}"
            } else if name == "abs" {
                return "\\left| \(argsLatex) \\right|"
            } else if name == "factorial" {
                return "(\(argsLatex))!"
            } else if name == "nPr" {
                return "P(\(argsLatex))"
            } else if name == "nCr" {
                return "C(\(argsLatex))"
            } else {
                // Trigonometric functions
                let functionName: String
                switch name {
                case "asin":
                    functionName = "\\arcsin"
                case "acos":
                    functionName = "\\arccos"
                case "atan":
                    functionName = "\\arctan"
                default:
                    functionName = "\\\(name)"
                }
                return "\(functionName)\\left( \(argsLatex) \\right)"
            }
        case .incomplete(let subNode):
            if let subNode = subNode {
                return expressionNodeToLatex(subNode)
            } else {
                return ""
            }
        case .error(_):
            // Instead of displaying an error, display as much as possible
            return ""
        }
    }
    
    // Helper function to wrap expressions in parentheses if needed
    private func wrapIfNeeded(_ node: ExpressionNode, forOperator op: String) -> String {
        if shouldWrap(node, forOperator: op) {
            return "\\left( \(expressionNodeToLatex(node)) \\right)"
        } else {
            return expressionNodeToLatex(node)
        }
    }
    
    // Determine if an expression node should be wrapped in parentheses
    private func shouldWrap(_ node: ExpressionNode, forOperator op: String) -> Bool {
        switch node {
        case .binaryOperation(_, let innerOp, _):
            let currentPrecedence = operatorPrecedence(op)
            let innerPrecedence = operatorPrecedence(innerOp)
            return innerPrecedence < currentPrecedence
        default:
            return false
        }
    }
    
    // Operator precedence for wrapping decisions
    private func operatorPrecedence(_ op: String) -> Int {
        switch op {
        case "+" , "-":
            return 1
        case "*", "/":
            return 2
        case "^":
            return 3
        case "!":
            return 4
        default:
            return 0
        }
    }
    
    // Format the decimal result for display
    private func formatDecimalResult(_ result: Double) -> String {
        return "\(result)"
    }
    
    // Format the symbolic result for display
    private func formatSymbolicResult(_ result: Double) -> String {
        if let fraction = approximateFraction(result) {
            return "\\frac{\(fraction.numerator)}{\(fraction.denominator)}"
        } else if abs(result - Double.pi) < 1e-6 {
            return "\\pi"
        } else if abs(result - M_E) < 1e-6 {
            return "e"
        } else {
            return "\(result)"
        }
    }
    
    // Approximate a decimal number as a fraction
    private func approximateFraction(_ value: Double, withPrecision epsilon: Double = 1e-6, maxDenominator: Int = 10000) -> (numerator: Int, denominator: Int)? {
        var x = value
        var a = floor(x)
        var (numerator1, denominator1) = (Int(a), 1)
        var (numerator2, denominator2) = (1, 0)
        var (numerator, denominator) = (numerator1, denominator1)
        
        while x - a > epsilon * Double(denominator * denominator) {
            x = 1.0 / (x - a)
            a = floor(x)
            numerator = Int(a) * numerator1 + numerator2
            denominator = Int(a) * denominator1 + denominator2
            
            if denominator > maxDenominator {
                break
            }
            
            numerator2 = numerator1
            denominator2 = denominator1
            numerator1 = numerator
            denominator1 = denominator
        }
        
        return (denominator == 0) ? nil : (numerator, denominator)
    }
}








func delay(_ seconds: Double, execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        execute()
    }
}
