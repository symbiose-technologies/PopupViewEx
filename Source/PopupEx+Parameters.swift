//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 10/30/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import SwiftUI

public struct Popup_Ex {
    
    
    public enum PopupType: Equatable, Hashable {
        case `default`
        case toast
        case floater(verticalPadding: CGFloat = 10, horizontalPadding: CGFloat = 10, useSafeAreaInset: Bool = true)

        var defaultPosition: Position {
            if case .default = self {
                return .center
            }
            return .bottom
        }

        var verticalPadding: CGFloat {
            if case let .floater(verticalPadding, _, _) = self {
                return verticalPadding
            }
            return 0
        }

        var horizontalPadding: CGFloat {
            if case let .floater(_, horizontalPadding, _) = self {
                return horizontalPadding
            }
            return 0
        }

        var useSafeAreaInset: Bool {
            if case let .floater(_, _, use) = self {
                return use
            }
            return false
        }
    }

    
    public enum Position: Equatable, Hashable {
        case topLeading
        case top
        case topTrailing

        case leading
        case center // usual popup
        case trailing

        case bottomLeading
        case bottom
        case bottomTrailing

        var isTop: Bool {
            [.topLeading, .top, .topTrailing].contains(self)
        }

        var isVerticalCenter: Bool {
            [.leading, .center, .trailing].contains(self)
        }

        var isBottom: Bool {
            [.bottomLeading, .bottom, .bottomTrailing].contains(self)
        }

        var isLeading: Bool {
            [.topLeading, .leading, .bottomLeading].contains(self)
        }

        var isHorizontalCenter: Bool {
            [.top, .center, .bottom].contains(self)
        }

        var isTrailing: Bool {
            [.topTrailing, .trailing, .bottomTrailing].contains(self)
        }
    }

    public enum AppearFrom: Equatable, Hashable {
        case top
        case bottom
        case left
        case right
    }
    
    
    public struct PopupParameters {
        var type: PopupType = .default
        
        var position: Position?
        
        var appearFrom: AppearFrom?
        
        var animation: Animation = .easeOut(duration: 0.3)
        
        /// If nil - never hides on its own
        var autohideIn: Double?
        
        /// Should allow dismiss by dragging - default is `true`
        var dragToDismiss: Bool = true
        
        /// Should close on tap - default is `true`
        var closeOnTap: Bool = true
        
        /// Should close on tap outside - default is `false`
        var closeOnTapOutside: Bool = false
        
        /// Background color for outside area
        var backgroundColor: Color = .clear
        
        /// Custom background view for outside area
        var backgroundView: AnyView?
        
        /// If true - taps do not pass through popup's background and the popup is displayed on top of navbar
        var isOpaque: Bool = false
        
        /// move up for keyboardHeight when it is displayed
        var useKeyboardSafeArea: Bool = false
        
        /// called when when dismiss animation starts
        var willDismissCallback: (DismissSource) -> () = {_ in}
        
        /// called when when dismiss animation ends
        var dismissCallback: (DismissSource) -> () = {_ in}
        
        public init(
            type: Popup_Ex.PopupType = .default,
            position: Popup_Ex.Position? = nil,
            appearFrom: Popup_Ex.AppearFrom? = nil,
            animation: Animation = .easeOut(duration: 0.3),
            autohideIn: Double? = nil,
            dragToDismiss: Bool = true,
            closeOnTap: Bool = true,
            closeOnTapOutside: Bool = false,
            backgroundColor: Color = .clear,
            backgroundView: AnyView? = nil,
            isOpaque: Bool = false,
            useKeyboardSafeArea: Bool = false,
            willDismissCallback: @escaping (DismissSource) -> () = {_ in},
            dismissCallback: @escaping (DismissSource) -> () = {_ in}
        ) {
            self.type = type
            self.position = position
            self.appearFrom = appearFrom
            self.animation = animation
            self.autohideIn = autohideIn
            self.dragToDismiss = dragToDismiss
            self.closeOnTap = closeOnTap
            self.closeOnTapOutside = closeOnTapOutside
            self.backgroundColor = backgroundColor
            self.backgroundView = backgroundView
            self.isOpaque = isOpaque
            self.useKeyboardSafeArea = useKeyboardSafeArea
            self.willDismissCallback = willDismissCallback
            self.dismissCallback = dismissCallback
        }
        
        public func type(_ type: PopupType) -> PopupParameters {
            var params = self
            params.type = type
            return params
        }
        
        public func position(_ position: Position) -> PopupParameters {
            var params = self
            params.position = position
            return params
        }
        
        public func appearFrom(_ appearFrom: AppearFrom) -> PopupParameters {
            var params = self
            params.appearFrom = appearFrom
            return params
        }
        
        public func animation(_ animation: Animation) -> PopupParameters {
            var params = self
            params.animation = animation
            return params
        }
        
        public func autohideIn(_ autohideIn: Double?) -> PopupParameters {
            var params = self
            params.autohideIn = autohideIn
            return params
        }
        
        /// Should allow dismiss by dragging - default is `true`
        public func dragToDismiss(_ dragToDismiss: Bool) -> PopupParameters {
            var params = self
            params.dragToDismiss = dragToDismiss
            return params
        }
        
        /// Should close on tap - default is `true`
        public func closeOnTap(_ closeOnTap: Bool) -> PopupParameters {
            var params = self
            params.closeOnTap = closeOnTap
            return params
        }
        
        /// Should close on tap outside - default is `false`
        public func closeOnTapOutside(_ closeOnTapOutside: Bool) -> PopupParameters {
            var params = self
            params.closeOnTapOutside = closeOnTapOutside
            return params
        }
        
        public func backgroundColor(_ backgroundColor: Color) -> PopupParameters {
            var params = self
            params.backgroundColor = backgroundColor
            return params
        }
        
        public func backgroundView<BackgroundView: View>(_ backgroundView: ()->(BackgroundView)) -> PopupParameters {
            var params = self
            params.backgroundView = AnyView(backgroundView())
            return params
        }
        
        public func isOpaque(_ isOpaque: Bool) -> PopupParameters {
            var params = self
            params.isOpaque = isOpaque
            return params
        }
        
        public func useKeyboardSafeArea(_ useKeyboardSafeArea: Bool) -> PopupParameters {
            var params = self
            params.useKeyboardSafeArea = useKeyboardSafeArea
            return params
        }
        
        // MARK: - dismiss callbacks
        
        public func willDismissCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> PopupParameters {
            var params = self
            params.willDismissCallback = dismissCallback
            return params
        }
        
        public func willDismissCallback(_ dismissCallback: @escaping () -> ()) -> PopupParameters {
            var params = self
            params.willDismissCallback = { _ in
                dismissCallback()
            }
            return params
        }
        
        @available(*, deprecated, renamed: "dismissCallback")
        public func dismissSourceCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> PopupParameters {
            var params = self
            params.dismissCallback = dismissCallback
            return params
        }
        
        public func dismissCallback(_ dismissCallback: @escaping (DismissSource) -> ()) -> PopupParameters {
            var params = self
            params.dismissCallback = dismissCallback
            return params
        }
        
        public func dismissCallback(_ dismissCallback: @escaping () -> ()) -> PopupParameters {
            var params = self
            params.dismissCallback = { _ in
                dismissCallback()
            }
            return params
        }
    }
}

//public extension Popup_Ex.PopupParameters {
//    init(
//        type: Popup_Ex.PopupType = .default,
//        position: Popup_Ex.Position? = nil,
//        appearFrom: Popup_Ex.AppearFrom? = nil,
//        animation: Animation = .easeOut(duration: 0.3),
//        autohideIn: Double? = nil,
//        dragToDismiss: Bool = true,
//        closeOnTap: Bool = true,
//        closeOnTapOutside: Bool = false,
//        backgroundColor: Color = .clear,
//        backgroundView: AnyView? = nil,
//        isOpaque: Bool = false,
//        useKeyboardSafeArea: Bool = false,
//        willDismissCallback: @escaping (DismissSource) -> () = {_ in},
//        dismissCallback: @escaping (DismissSource) -> () = {_ in}
//    ) {
//        self.type = type
//        self.position = position
//        self.appearFrom = appearFrom
//        self.animation = animation
//        self.autohideIn = autohideIn
//        self.dragToDismiss = dragToDismiss
//        self.closeOnTap = closeOnTap
//        self.closeOnTapOutside = closeOnTapOutside
//        self.backgroundColor = backgroundColor
//        self.backgroundView = backgroundView
//        self.isOpaque = isOpaque
//        self.useKeyboardSafeArea = useKeyboardSafeArea
//        self.willDismissCallback = willDismissCallback
//        self.dismissCallback = dismissCallback
//    }
//}

extension Popup_Ex.PopupParameters: Equatable, Hashable {
    // Overriding the == operator for Equatable
       public static func == (lhs: Self, rhs: Self) -> Bool {
           return lhs.type == rhs.type &&
               lhs.position == rhs.position &&
               lhs.appearFrom == rhs.appearFrom &&
               lhs.animation == rhs.animation &&
               lhs.autohideIn == rhs.autohideIn &&
               lhs.dragToDismiss == rhs.dragToDismiss &&
               lhs.closeOnTap == rhs.closeOnTap &&
               lhs.closeOnTapOutside == rhs.closeOnTapOutside &&
               lhs.backgroundColor == rhs.backgroundColor &&
               lhs.isOpaque == rhs.isOpaque &&
               lhs.useKeyboardSafeArea == rhs.useKeyboardSafeArea
       }

       // Implementing hash(into:) for Hashable
       public func hash(into hasher: inout Hasher) {
           hasher.combine(type)
           hasher.combine(position)
           hasher.combine(appearFrom)
//           hasher.combine(animation)
           hasher.combine(autohideIn)
           hasher.combine(dragToDismiss)
           hasher.combine(closeOnTap)
           hasher.combine(closeOnTapOutside)
           hasher.combine(backgroundColor)
           hasher.combine(isOpaque)
           hasher.combine(useKeyboardSafeArea)
       }
}
