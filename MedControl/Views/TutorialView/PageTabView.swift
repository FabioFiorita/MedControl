//
//  PageTabView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 21/07/21.
//

import SwiftUI

struct PageTabView: View {
    @Binding var selection: Int
    var body: some View {
        TabView(selection: $selection) {
            ForEach(tabs.indices, id: \.self) { index in
                TabDetailsView(index: index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .padding(.horizontal)
    }
}

struct PageTabView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientView()
            PageTabView(selection: Binding.constant(0))
        }
    }
}
