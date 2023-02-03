//
//  MainView.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 30/1/23.
//

import SwiftUI
import Combine
import Kingfisher


struct MainView: View {
    
    @ObservedObject private var viewModel: AnyViewModel<MainViewModel.Data, MainViewModel.Action>
    @State private var showingFailureAlert = false
    @State private var failureAlertMessage = "There was an error!"
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var proxyScroll: ScrollViewProxy?
    
    init(viewModel: AnyViewModel<MainViewModel.Data, MainViewModel.Action>) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        LazyVStack {
                            ForEach(viewModel.data.characters) { character in
                                CharacterView(character: character)
                                    .onAppear {
                                        if character == viewModel.data.characters.last && !isLoading {
                                            isLoading = true
                                            searchText.isEmpty ?
                                            viewModel.trigger(.getCharacters) :
                                            viewModel.trigger(.searchCharacters(name: searchText))
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 60)
                }
                .onAppear {
                    proxyScroll = proxy
                }
                .overlay(alignment: .center, content: {
                    ProgressView()
                        .padding(8)
                        .foregroundColor(.black)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                                .frame(width: 80, height: 80)
                        }
                        .opacity(isLoading ? 1 : 0)
                })
                .alert(failureAlertMessage, isPresented: $showingFailureAlert) {
                    Button("Got it!", role: .cancel) {}
                }
                .navigationBarTitle("Characters", displayMode: .automatic)
                .background{
                    ZStack(alignment: .top) {
                        Color("background")
                            .ignoresSafeArea()
                        Text("Wubba lubba dub dub! Nothing there!")
                            .opacity(viewModel.data.characters.isEmpty ? 1 : 0)
                            .foregroundColor(.gray.opacity(0.8))
                            .padding(.top, 16)
                    }
            }
            }
        }
        .searchable(text: $searchText, prompt: Text(verbatim: "Search character name"))
        .autocorrectionDisabled()
        .onChange(of: searchText, perform: { text in
            if let firstCharacterToScroll = viewModel.data.characters.first?.id {
                proxyScroll?.scrollTo(firstCharacterToScroll, anchor: .top)
            }
            isLoading = text.isNotEmpty
            viewModel.trigger(.searchCharacters(name: text))
        })
        .onReceive(viewModel.data.state, perform: { state in
            isLoading = false
            switch state {
            case .failure(let error):
                failureAlertMessage = error.message
                showingFailureAlert = true
            default:
                break
            }
        })
        .onAppear {
            isLoading = true
            viewModel.trigger(.getCharacters)
        }
    }
}

private struct CharacterView: View {
    
    @Environment(\.viewFactory) var viewFactory
    
    let character: Character
    
    var body: some View {
        NavigationLink(destination: viewFactory.makeDetailViewWith(character)) {
            HStack(spacing: 12) {
                
                KFImage
                    .url(character.image)
                    .placeholder {
                        Image("character_placeholder_ic")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .background {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color("character_card_bg"))
                            }
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(width: 120, height: 120)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    HStack(spacing: 4) {
                        character.status.image
                            .frame(width: 8, height: 8)
                        Text(character.status.rawValue)
                        if character.species.isNotEmpty {
                            Text("-")
                            Text(character.species)
                        }
                    }
                    .font(.caption2.bold())
                    .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last known location:")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(.black.opacity(0.7))
                        Text(character.location)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 8, height: 12)
                    .padding(.trailing, 12)
                    .padding(.leading, 4)
                
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                
            }
            .padding(.bottom, 4)
        }
    }
}
