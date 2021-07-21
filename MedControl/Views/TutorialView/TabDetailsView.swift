//
//  TabDetailsView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 21/07/21.
//

import SwiftUI

struct TabDetailsView: View {
    let index: Int
    var body: some View {
        VStack {
            Image(tabs[index].image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
            
            Text(tabs[index].title)
                .font(.title)
                .bold()
            
            Text(tabs[index].text)
                .padding()
    }
        .foregroundColor(.white)
}
}

struct TabDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientView()
            TabDetailsView(index: 0)
        }
    }
}
