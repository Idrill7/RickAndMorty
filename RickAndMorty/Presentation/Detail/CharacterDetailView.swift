//
//  CharacterDetailView.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 31/1/23.
//

import Foundation
import SwiftUI
import Kingfisher

private extension Color {
    static var background: Self { Color("background") }
}

private extension Gradient {
    static var linearTopBlack: Self { Gradient(colors: [.background.opacity(1), .background.opacity(0.8),
                                                        .background.opacity(0.5), .background.opacity(0)])}
    
    static var linearBottomBlack: Self { Gradient(colors: [.background.opacity(0), .background.opacity(0.3),
                                                           .background.opacity(1)])}
}

struct CharacterDetailView: View {
    let character: Character
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                
                KFImage
                    .url(character.image)
                    .placeholder {
                        Image("character_placeholder_ic")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: UIScreen.main.bounds.height / 2.2)
                            .overlay {
                                ZStack(alignment: .top) {
                                    Rectangle().fill(
                                        .linearGradient(.linearBottomBlack,
                                                        startPoint: .top,
                                                        endPoint: .bottom)
                                    )
                                }
                            }
                    }
                    .resizable()
                    .frame(height: UIScreen.main.bounds.height / 2.2)
                    .overlay {
                        ZStack() {
                            Rectangle().fill(
                                .linearGradient(.linearTopBlack,
                                                startPoint: .top,
                                                endPoint: .center)
                            )
                            Rectangle().fill(
                                .linearGradient(.linearBottomBlack,
                                                startPoint: .center,
                                                endPoint: .bottom)
                            )
                        }
                    }
                
                VStack(spacing: 10) {
                    
                    HStack(spacing: 8) {
                        Text(character.name)
                            .font(.title.bold())
                            .foregroundColor(Color("characterText"))
                        character.status.image
                            .frame(width: 16, height: 16)
                            .padding(.top, 4)
                    }
                    Divider()
                    
                    Group {
                        InfoCell(title: "Last known location", text: character.location)
                        InfoCell(title: "Specie", text: character.species)
                        InfoCell(title: "Gender", text: character.gender.rawValue)
                        InfoCell(title: "Type", text: character.type)
                        InfoCell(title: "Origin", text: character.origin)
                    }
                    .padding([.top, .bottom], 8)
                    
                }
                .padding(.horizontal)
                Spacer()
            }
        }
        .background{
            Color
                .background
                .ignoresSafeArea()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

private struct InfoCell: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .padding(.leading, 8)
                .font(.caption2)
                .fontWeight(.light)
                .foregroundColor(Color("characterText").opacity(0.8))
            Text(text.isNotEmpty ? text.capitalized : "Unknown")
                .foregroundColor(.black.opacity(0.8))
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                }
            
        }
    }
    
}
