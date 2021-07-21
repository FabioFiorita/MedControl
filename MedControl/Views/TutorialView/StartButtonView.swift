//
//  StartButtonView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 21/07/21.
//

import SwiftUI

struct StartButtonView: View {
    @Binding var isWalkthroughViewShowing: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        Button(action: {dismiss()}, label: {
            Text("Começar a utilizar o App")
                .foregroundColor(.white)
                .underline()
                .padding(.vertical)
        })
    }
    
    func dismiss() {
        withAnimation {
            isWalkthroughViewShowing.toggle()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct StartButtonView_Previews: PreviewProvider {
    static var previews: some View {
        StartButtonView(isWalkthroughViewShowing: Binding.constant(true))
    }
}
