//
//  Constructors.swift
//  Pods
//
//  Created by Alisa Mylnikova on 11.10.2022.
//

import SwiftUI

extension View {

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        customize: @escaping (Popup_Ex.PopupParameters) -> Popup_Ex.PopupParameters
        ) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: customize(Popup_Ex.PopupParameters()),
                    view: view,
                    itemView: nil)
            )
        }
    
    public func popupWithConf<PopupContent: View>(
        isPresented: Binding<Bool>,
        conf: Popup_Ex.PopupParameters,
        @ViewBuilder view: @escaping () -> PopupContent
        ) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: conf,
                    view: view,
                    itemView: nil)
            )
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        customize: @escaping (Popup_Ex.PopupParameters) -> Popup_Ex.PopupParameters
        ) -> some View {
            self.modifier(
                FullscreenPopup<Item, PopupContent>(
                    item: item,
                    isBoolMode: false,
                    params: customize(Popup_Ex.PopupParameters()),
                    view: nil,
                    itemView: itemView)
            )
        }

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: Popup_Ex.PopupParameters(),
                    view: view,
                    itemView: nil)
            )
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent) -> some View {
            self.modifier(
                FullscreenPopup<Item, PopupContent>(
                    item: item,
                    isBoolMode: false,
                    params: Popup_Ex.PopupParameters(),
                    view: nil,
                    itemView: itemView)
            )
        }
}
