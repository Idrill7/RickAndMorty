//
//  Character+Status.swift
//  RickAndMorty
//
//  Created by Alejandro Gonzalez Casado on 1/2/23.
//

import Foundation
import SwiftUI

extension Character.Status {

    var image: some View {
        switch self {
        case .alive:
            return Image(systemName: "circle.fill")
                .resizable()
                .foregroundColor(Color(.green))
        case .dead:
            return Image(systemName: "circle.fill")
                .resizable()
                .foregroundColor(Color(.red))
        case .unknown:
            return Image(systemName: "circle.fill")
                .resizable()
                .foregroundColor(Color(.gray))
        }
    }
    
}
