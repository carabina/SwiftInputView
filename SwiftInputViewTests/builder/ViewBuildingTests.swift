//
//  ViewBuildingTests.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/24/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import UIKit
import SwiftUIUtilities
import SwiftUtilities
import SwiftUtilitiesTests
import XCTest

class ViewBuildingTests: XCTestCase {
    let tries = 1000
    
    func test_buildAndConfigWithInputs_shouldIncludeAppropriateViews() {
        // Setup
        let allInputs = (0..<tries).map({_ in InputDetail.randomValues})
        let allBuilders = allInputs.map(InputViewBuilder.init)
        let allConfigs = allInputs.map(InputViewBuilderConfig.init)
        
        let view = UIAdaptableInputView()
        
        let testBuilder: (UIView, InputDetail) -> Void = {
            let componentViews = $0.0.subviews
            
            let inputField = componentViews.filter({
                $0.accessibilityIdentifier == self.inputFieldId
            }).first
            
            XCTAssertTrue(inputField is InputFieldType)
            
            if let inputField = inputField as? InputFieldType {
                XCTAssertEqual(inputField.autocorrectionType, .no)
                
                if let iTextColor = $0.1.inputTextColor {
                    XCTAssertEqual(inputField.textColor, iTextColor)
                }
                
                if let iTintColor = $0.1.inputTintColor {
                    XCTAssertEqual(inputField.tintColor, iTintColor)
                }
            }
            
            if $0.1.displayRequiredIndicator {
                let indicator = componentViews.filter({
                    $0.accessibilityIdentifier == self.requiredIndicatorId
                }).first
                
                XCTAssertTrue(indicator is UILabel)
                
                if let indicator = indicator as? UILabel {
                    XCTAssertEqual(indicator.text, $0.1.requiredIndicatorText)
                    
                    if let riTextColor = $0.1.requiredIndicatorTextColor {
                        XCTAssertEqual(indicator.textColor, riTextColor)
                    }
                }
            }
        }
        
        // When
        
        // Then
        for (builder, config) in zip(allBuilders, allConfigs) {
            let components = builder.builderComponents(for: view)
            let inputs = builder.inputs.flatMap({$0 as? InputDetail})
            
            view.populateSubviews(from: components)
            config.configure(for: view)
            
            if inputs.count == 1, let input = inputs.first {
                XCTAssertTrue(components.count > inputs.count)
                testBuilder(view, input)
            } else {
                XCTAssertEqual(inputs.count, components.count)
                
                for (input, component) in zip(inputs, components) {
                    let subview = component.viewToBeAdded
                    XCTAssertTrue(subview is UIInputComponentView)
                    testBuilder(subview!, input)
                }
            }
            
            view.subviews.forEach({$0.removeFromSuperview()})
            view.constraints.forEach({view.removeConstraint($0)})
        }
    }
}

extension XCTestCase: TextInputViewIdentifierType {}

enum InputDetail: Int {
    case mock1 = 1
    case mock2
    case mock3
    case mock4
    case mock5
    case mock6
    case mock7
    case mock8
    case mock9
    case mock10
    
    static var values: [InputDetail] {
        return (mock1.rawValue...mock10.rawValue).flatMap(InputDetail.init)
    }
    
    static var randomValues: [InputDetail] {
        let values = self.values
        let upperBound = Int.random(1, values.count)
        return values[0..<upperBound].map(eq)
    }
}

extension InputDetail: InputViewDetailType {

    public var identifier: String {
        return String(describing: rawValue)
    }
    
    public var isRequired: Bool {
        return rawValue.isEven
    }

    var viewBuilderComponentType: InputViewBuilderComponentType.Type {
        return TextInputViewBuilderComponent.self
    }
    
    var inputType: InputType {
        return TextInput.default
    }
    
    var inputViewWidth: CGFloat? {
        return nil
    }
    
    var inputViewHeight: CGFloat? {
        return nil
    }
    
    var shouldDisplayRequiredIndicator: Bool {
        return rawValue % 4 == 0
    }
}

extension InputDetail: TextInputViewDecoratorType {
    var configComponentType: InputViewConfigComponentType.Type {
        return TextInputViewConfigComponent.self
    }
    
    var inputBackgroundColor: UIColor? { return .gray }
    var inputCornerRadius: CGFloat? { return 5 }
    var inputTextColor: UIColor? { return .white }
    var inputTintColor: UIColor? { return .white }
    var inputTextAlignment: NSTextAlignment? { return .natural }
    var horizontalSpacing: CGFloat? { return nil }
    var requiredIndicatorTextColor: UIColor? { return .white }
    var requiredIndicatorText: String? { return "*R" }
    var placeholderTextColor: UIColor? { return .lightGray }
}
