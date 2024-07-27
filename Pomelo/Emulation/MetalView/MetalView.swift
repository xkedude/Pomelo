//
//  MetalView.swift
//  Pomelo-V2
//
//  Created by Stossy11 on 16/7/2024.
//

import SwiftUI
import Metal
import Sudachi

struct MetalView: UIViewRepresentable {
    let device: MTLDevice?
    let configure: (UIView) -> Void
    
    func makeUIView(context: Context) -> SudachiScreenView {
        let view = SudachiScreenView()
        configure(view.primaryScreen)
        return view
    }
    
    func updateUIView(_ uiView: SudachiScreenView, context: Context) {
        //
    }
}
