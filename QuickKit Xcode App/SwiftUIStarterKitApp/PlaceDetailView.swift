//
//  PlaceDetailView.swift
//  SwiftUIStarterKitApp
//
//  Created by Osama Naeem on 11/08/2019.
//  Copyright © 2019 NexThings. All rights reserved.
//

import SwiftUI
import Combine

class SelectedPoint: ObservableObject {
    @Published var selectedIndex: Int = 0
}
extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}

struct PlaceDetailView : View {
    @Binding var isShowing: Bool
    @Binding var placeItem: ActivitiesPlaces?
    let defaultPoint = ActivitiesFamousPoints(id: 0, pointName: "Default", pointImage: "Default PlaceHolder", pointDescription: "Default Description PlaceHolder")
    
    @ObservedObject var selectedPoint = SelectedPoint()
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Image(self.placeItem?.famousPointsArray[self.selectedPoint.selectedIndex].pointImage ?? "")
                    .resizable()
                    .frame(width: g.size.width, height: g.size.height)
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.3)
                    .background(Color.black)
                    .onDisappear {
                        self.isShowing = false
                }
                
                VStack(alignment: .leading) {
                    Text(self.placeItem?.activityPlace ?? "")
                        .foregroundColor(Color.white)
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .padding(.top, 34)
                        .padding(.leading, 30)
                    HStack{
                        Spacer()
                    }
                    
                    Spacer()
                    
                    PlacesDetail(placeItems: self.placeItem?.famousPointsArray[self.selectedPoint.selectedIndex] ?? self.defaultPoint)
                        .padding(.bottom, 50)
                    
                    if self.placeItem?.activityDisplay == true {
                        ZStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack{
                                    ForEach(self.placeItem?.famousPointsArray ?? [], id: \.id) { item in
                                        //PlacesCircleView(placeItems: item, selectedPoint: self.selectedPoint)
                                        
                                        Button(action: {
                                            self.selectedPoint.selectedIndex = item.id
                                        })
                                        {
                                            ZStack {
                                                Image(item.pointImage).renderingMode(.original)
                                                    .resizable()
                                                    .frame(width: 110, height: 110)
                                                    .background(Color.red)
                                                    .clipShape(Circle())
                                                
                                                if (self.selectedPoint.selectedIndex == item.id) {
                                                       Text("✓")
                                                            .font(.system(size: 30, weight: .bold, design: Font.Design.default))
                                                            .foregroundColor(Color.white)
                                                }
                                            }
                                        }
                                    }
                                }.frame(width: g.size.width, height: 130)
                            }
                        }.padding(.bottom, 50)
                    }
                    
                    Button(action: {
                        let newelement = ActivitiesCartItem(itemID: String(Int.random(in: 6 ..< 100)), itemName: (self.placeItem?.activityPlace)!, itemPrice: 500, itemColor: "", itemManufacturer: (self.placeItem?.famousPointsArray[self.selectedPoint.selectedIndex].pointName)!, itemImage: "4")
                            ActivitiesMockStore.shoppingCartData.append(newelement)
                        
                        
                        }) {
                            HStack {
                            Text("Checkout")
                        }
                        .padding()
                        .frame(width: g.size.width - 24, height: 40)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(5)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct PlacesCircleView: View {
    var placeItems: ActivitiesFamousPoints
    @ObservedObject var selectedPoint: SelectedPoint
    
    var body: some View {
        GeometryReader { g in
            
        }
    }
}

struct PlacesDetail: View {
    var placeItems: ActivitiesFamousPoints
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(placeItems.pointName)
                .foregroundColor(Color.white)
                .font(.system(size: 24, weight: .bold, design: .default))
                .padding(.leading, 30)
            
            Text(placeItems.pointDescription)
                .foregroundColor(Color.white)
                .font(.system(size: 16, weight: .regular, design: .default))
                .padding(.leading, 30)
                .padding(.trailing, 30)
        }
    }
}
