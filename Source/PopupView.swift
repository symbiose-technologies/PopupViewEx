//
//  PopupView.swift
//  PopupView
//
//  Created by Alisa Mylnikova on 23/04/2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import SwiftUI

public enum DismissSource {
    case binding // set isPresented to false ot item to nil
    case tapInside
    case tapOutside
    case drag
    case autohide
}

public struct PopupEx<PopupContent: View>: ViewModifier {

    init(params: Popup_Ex.PopupParameters,
         view: @escaping () -> PopupContent,
         shouldShowContent: Bool,
         showContent: Bool,
         positionIsCalculatedCallback: @escaping () -> (),
         animationCompletedCallback: @escaping () -> (),
         dismissCallback: @escaping (DismissSource)->()) {

        self.position = params.position ?? params.type.defaultPosition
        self.appearFrom = params.appearFrom
        self.verticalPadding = params.type.verticalPadding
        self.horizontalPadding = params.type.horizontalPadding
        self.useSafeAreaInset = params.type.useSafeAreaInset
        self.useKeyboardSafeArea = params.useKeyboardSafeArea
        self.animation = params.animation
        self.dragToDismiss = params.dragToDismiss
        self.closeOnTap = params.closeOnTap
        self.isOpaque = params.isOpaque

        self.view = view

        self.shouldShowContent = shouldShowContent
        self.showContent = showContent
        self.positionIsCalculatedCallback = positionIsCalculatedCallback
        self.animationCompletedCallback = animationCompletedCallback
        self.dismissCallback = dismissCallback
    }
    


    private enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }

    // MARK: - Public Properties

    var position: Popup_Ex.Position
    var appearFrom: Popup_Ex.AppearFrom?
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat
    var useSafeAreaInset: Bool
    var useKeyboardSafeArea: Bool

    var animation: Animation

    /// Should close on tap - default is `true`
    var closeOnTap: Bool

    /// Should allow dismiss by dragging
    var dragToDismiss: Bool

    /// If opaque - taps do not pass through popup's background color
    var isOpaque: Bool

    /// Trigger popup showing/hiding animations and...
    var shouldShowContent: Bool

    /// ... once hiding animation is finished remove popup from the memory using this flag
    var showContent: Bool

    /// called when all the offsets are calculated, so everything is ready for animation
    var positionIsCalculatedCallback: () -> ()

    /// called on showing/hiding sliding animation completed
    var animationCompletedCallback: () -> ()

    /// Call dismiss callback with dismiss source
    var dismissCallback: (DismissSource)->()

    var view: () -> PopupContent

    // MARK: - Private Properties

    @StateObject var keyboardHeightHelper = KeyboardHeightHelper()

    /// The rect and safe area of the hosting controller
    @State private var presenterContentRect: CGRect = .zero

    /// The rect and safe area of popup content
    @State private var sheetContentRect: CGRect = .zero

    @State private var safeAreaInsets: EdgeInsets = EdgeInsets()

    /// Variable used to control what is animated and what is not
    @State var actualCurrentOffset = CGPoint.pointFarAwayFromScreen

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGSize = .zero
    
    /// The offset when the popup is displayed
    private var displayedOffsetY: CGFloat {
        if isOpaque {
            if position.isTop {
                return verticalPadding + (useSafeAreaInset ? 0 :  -safeAreaInsets.top)
            }
            if position.isVerticalCenter {
                return (screenHeight - sheetContentRect.height)/2 - safeAreaInsets.top
            }
            if position.isBottom {
                return screenHeight - sheetContentRect.height
                - (useKeyboardSafeArea ? keyboardHeightHelper.keyboardHeight : 0)
                - verticalPadding
                - (useSafeAreaInset ? safeAreaInsets.bottom : 0)
                - safeAreaInsets.top
            }
        }

        if position.isTop {
            return verticalPadding + (useSafeAreaInset ? 0 : -safeAreaInsets.top)
        }
        if position.isVerticalCenter {
            return (presenterContentRect.height - sheetContentRect.height)/2
        }
        if position.isBottom {
            return presenterContentRect.height
            - sheetContentRect.height
            - (useKeyboardSafeArea ? keyboardHeightHelper.keyboardHeight : 0)
            - verticalPadding
            + safeAreaInsets.bottom
            - (useSafeAreaInset ? safeAreaInsets.bottom : 0)
        }
        return 0
    }

    private var displayedOffsetX: CGFloat {
        if isOpaque {
            if position.isLeading {
                return horizontalPadding + (useSafeAreaInset ? safeAreaInsets.leading : 0)
            }
            if position.isHorizontalCenter {
                return (screenWidth - sheetContentRect.width)/2 - safeAreaInsets.leading
            }
            if position.isTrailing {
                return screenWidth - sheetContentRect.width - horizontalPadding - (useSafeAreaInset ? safeAreaInsets.trailing : 0)
            }
        }

        if position.isLeading {
            return horizontalPadding + (useSafeAreaInset ? safeAreaInsets.leading : 0)
        }
        if position.isHorizontalCenter {
            return (presenterContentRect.width - sheetContentRect.width)/2
        }
        if position.isTrailing {
            return presenterContentRect.width - sheetContentRect.width - horizontalPadding - (useSafeAreaInset ? safeAreaInsets.trailing : 0)
        }
        return 0
    }

    /// The offset when the popup is hidden
    private var hiddenOffset: CGPoint {
        if sheetContentRect.isEmpty {
            return CGPoint.pointFarAwayFromScreen
        }

        switch calculatedAppearFrom {
        case .top:
            return CGPoint(x: displayedOffsetX, y: -presenterContentRect.minY - safeAreaInsets.top - sheetContentRect.height)
        case .bottom:
            return CGPoint(x: displayedOffsetX, y: screenHeight)
        case .left:
            return CGPoint(x: -screenWidth, y: displayedOffsetY)
        case .right:
            return CGPoint(x: screenWidth, y: displayedOffsetY)
        }
    }

    /// Passes the desired position to actualCurrentOffset allowing to animate selectively
    private var targetCurrentOffset: CGPoint {
        shouldShowContent ? CGPoint(x: displayedOffsetX, y: displayedOffsetY) : hiddenOffset
    }

    private var calculatedAppearFrom: Popup_Ex.AppearFrom {
        let from: Popup_Ex.AppearFrom
        if let appearFrom = appearFrom {
            from = appearFrom
        } else if position.isLeading {
            from = .left
        } else if position.isTrailing {
            from = .right
        } else if position == .top {
            from = .top
        } else {
            from = .bottom
        }
        return from
    }

    var screenSize: CGSize {
#if os(iOS)
        return UIScreen.main.bounds.size
#elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
#else
        return CGSize(width: presenterContentRect.size.width, height: presenterContentRect.size.height - presenterContentRect.minY)
#endif
    }

    private var screenWidth: CGFloat {
        screenSize.width
    }

    private var screenHeight: CGFloat {
        screenSize.height
    }

    // MARK: - Content Builders

    public func body(content: Content) -> some View {
        content
            .frameGetter($presenterContentRect)
            .safeAreaGetter($safeAreaInsets)
            .overlay(
                Group {
                    if showContent, presenterContentRect != .zero {
                        sheet()
                    }
                }
            )
    }

    /// This is the builder for the sheet content
    func sheet() -> some View {
        let sheet = ZStack {
            self.view()
                .addTapIfNotTV(if: closeOnTap) {
                    dismissCallback(.tapInside)
                }
                .frameGetter($sheetContentRect)
                .position(x: sheetContentRect.width/2 + actualCurrentOffset.x, y: sheetContentRect.height/2 + actualCurrentOffset.y)
                .onChange(of: targetCurrentOffset) { newValue in
                    if !shouldShowContent, newValue == hiddenOffset { // don't animate initial positioning outside the screen
                        actualCurrentOffset = newValue
                    } else {
                        if #available(iOS 17.0, tvOS 17.0, macOS 14.0, watchOS 10.0, *) {
                            withAnimation(animation) {
                                actualCurrentOffset = newValue
                            } completion: {
                                animationCompletedCallback()
                            }
                        } else {
                            withAnimation(animation) {
                                actualCurrentOffset = newValue
                            }
                        }
                    }
                }
                .onChange(of: sheetContentRect.size) { sheetContentRect in
                    positionIsCalculatedCallback()
                }
        }

#if !os(tvOS)
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return sheet
            .applyIf(dragToDismiss) {
                $0.offset(dragOffset())
                    .simultaneousGesture(drag)
            }
#else
        return sheet
#endif
    }

#if !os(tvOS)
    func dragOffset() -> CGSize {
        if dragState.translation == .zero {
            return lastDragPosition
        }

        switch calculatedAppearFrom {
        case .top:
            if dragState.translation.height < 0 {
                return CGSize(width: 0, height: dragState.translation.height)
            }
        case .bottom:
            if dragState.translation.height > 0 {
                return CGSize(width: 0, height: dragState.translation.height)
            }
        case .left:
            if dragState.translation.width < 0 {
                return CGSize(width: dragState.translation.width, height: 0)
            }
        case .right:
            if dragState.translation.width > 0 {
                return CGSize(width: dragState.translation.width, height: 0)
            }
        }
        return .zero
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let referenceX = sheetContentRect.width / 3
        let referenceY = sheetContentRect.height / 3

        var shouldDismiss = false
        switch calculatedAppearFrom {
        case .top:
            if drag.translation.height < 0 {
                lastDragPosition = CGSize(width: 0, height: drag.translation.height)
            }
            if drag.translation.height < -referenceY {
                shouldDismiss = true
            }
        case .bottom:
            if drag.translation.height > 0 {
                lastDragPosition = CGSize(width: 0, height: drag.translation.height)
            }
            if drag.translation.height > referenceY {
                shouldDismiss = true
            }
        case .left:
            if drag.translation.width < 0 {
                lastDragPosition = CGSize(width: drag.translation.width, height: 0)
            }
            if drag.translation.width < -referenceX {
                shouldDismiss = true
            }
        case .right:
            if drag.translation.width > 0 {
                lastDragPosition = CGSize(width: drag.translation.width, height: 0)
            }
            if drag.translation.width > referenceX {
                shouldDismiss = true
            }
        }

        if shouldDismiss {
            dismissCallback(.drag)
        } else {
            withAnimation {
                lastDragPosition = .zero
            }
        }
    }
#endif
}
