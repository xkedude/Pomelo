//
//  GameButtonListView.swift
//  Pomelo
//
//  Created by TechGuy on 20/8/24.
//  Copyright © 2024 TechGuy. All rights reserved.
//

import SwiftUI
import Foundation
import UIKit

struct GameButtonListView: View {
    var game: PomeloGame
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 15) {
            if let image = UIImage(data: game.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)

                
                Text(game.developer)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
