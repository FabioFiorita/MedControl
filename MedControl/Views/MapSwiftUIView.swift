//
//  MapSwiftUIView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 20/01/21.
//

import SwiftUI
import MapKit

struct MapSwiftUIView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    @State private var pharmacies: String = "Pharmacy"
    @State private var tapped: Bool = false
    
    private func getNearByLandmarks() {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = pharmacies
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let response = response {
                
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                    
                }
                
            }
            
        }
        
    }
    
    func calculateOffset() -> CGFloat {
        
        if self.landmarks.count > 0 && !self.tapped {
            return UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height / 4
        }
        else if self.tapped {
            return 100
        } else {
            return UIScreen.main.bounds.size.height
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            MapView(landmarks: landmarks).ignoresSafeArea(.all)
            
            
//            TextField("Pesquisar", text: $search, onEditingChanged: { _ in })
//            {
//                // commit
//                self.getNearByLandmarks()
//            }.textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//                .offset(y: 44)
            
            
            PlaceListView(landmarks: self.landmarks) {
                // on tap
                self.tapped.toggle()
            }.animation(.spring())
                .offset(y: calculateOffset())
            .padding(.vertical)
            
        }.onAppear(perform: {
            self.getNearByLandmarks()
        })
    }
}

struct MapSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MapSwiftUIView()
    }
}
