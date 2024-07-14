//
//  MetalView.swift
//  Pomelo
//
//  Created by Stossy11 on 14/7/2024.
//

import SwiftUI
import Metal
import Sudachi

struct MTKViewRepresentable: UIViewRepresentable {
    let device: MTLDevice?
    let configure: (MTKView) -> Void
    
    func makeUIView(context: Context) -> SudachiScreenView {
        let view = SudachiScreenView()
        configure(view.primaryScreen)
        return view
    }
    
    func updateUIView(_ uiView: SudachiScreenView, context: Context) {
        // Update the view if needed
    }
}
