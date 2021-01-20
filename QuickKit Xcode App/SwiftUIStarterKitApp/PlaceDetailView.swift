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
extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

@available(iOS 14.0, *)
struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                fatalError("Invalid URL: \(url)")
            }

            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }

    @StateObject private var loader: Loader
    var loading: Image
    var failure: Image

    var body: some View {
        selectImage()
            .resizable()
    }

    init(url: String, loading: Image = Image(systemName: "photo"), failure: Image = Image(systemName: "multiply.circle")) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }

    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = UIImage(data: loader.data) {
                return Image(uiImage: image)
            } else {
                return failure
            }
        }
    }
}

struct PlaceDetailView : View {
    @Binding var isShowing: Bool
    @Binding var placeItem: CategoryItem?
    let defaultPoint = CategoryItemModifier(id: 0, sizeName: "Default", sizePriceAddition: 0)
    @State var top = UIApplication.shared.windows.last?.safeAreaInsets.top
    @ObservedObject var selectedPoint = SelectedPoint()
    @State var selectedSize = "S"
    @State var prices  =  [Int: Double]()
    @State var count = 1

    
    var body: some View {
        GeometryReader { g in
            
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(alignment: .center) {
                        if #available(iOS 14.0, *) {
                            RemoteImage(url: (self.placeItem?.itemImage)!)
                                //.resizable()
                                .frame(width: g.size.width, height: g.size.height / 3)
                                .onDisappear {
                                    self.isShowing = false
                                }
                        } else {
                            // Fallback on earlier versions
                        }
                        VStack(alignment: .leading) {
                            HStack{
                                Text(self.placeItem?.itemName ?? "")
                                    .font(.custom("Montserrat-Bold", size: 25))
                                    .padding(.top, 50)
                                    .padding(.leading, 20)
                                Spacer()
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text((self.placeItem?.itemDescription)!)
                                    .font(.custom("Montserrat-Bold", size: 14))
                                    .padding(.trailing, 30)
                                    .padding(.leading, 20)

                                
                            }
                            Spacer()
                        }.frame(width: g.size.width)
                        .background(RoundedCorner().fill(Color.white))
                        .padding(.top, -top!)
                        Spacer()
                        
                        
                        ForEach(self.placeItem!.itemAdditions, id: \.id) { item in
                            //Modifications
                            HStack{
                                if item.compulsary {
                                    Text(item.modName + ": *")
                                        .padding(.leading,16)
                                        .font(.custom("Montserrat-Bold", size: 17))
                                }else{
                                    Text(item.modName + ":")
                                        .padding(.leading,16)
                                        .font(.custom("Montserrat-Bold", size: 17))
                                }
                                
                                Spacer()
                            }
                            VStack{
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack( alignment: .center){
                                        Spacer()
                                        ForEach(item.modifiers, id: \.id) { i in
                                            let textVal = i.sizeName
                                            let price = String(format: "%.2f", i.sizePriceAddition)
                                            if price != "0.00" {
                                                Button(action: {
                                                    if (self.placeItem!.itemAdditions[item.id].compulsary == false) && (self.placeItem!.itemAdditions[item.id].selected == i.id){
                                                        self.prices.removeValue(forKey: item.id)
                                                        self.placeItem!.itemAdditions[item.id].selected = nil

                                                    }else{
                                                        self.prices[item.id] = i.sizePriceAddition
                                                        self.placeItem!.itemAdditions[item.id].selected = i.id
                                                    }
                                                    
                                                }) {
                                                    
                                                    Text(textVal + " + £" + price)
                                                        .font(.custom("Montserrat-Bold", size: 13))
                                                        .foregroundColor(self.placeItem!.itemAdditions[item.id].selected == i.id ? .white : .black)
                                                        .padding(.vertical,8)
                                                        .padding(.horizontal,10)
                                                        .background(
                                                            
                                                            ZStack{
                                                                
                                                                RoundedRectangle(cornerRadius: 5)
                                                                    .fill(Color.blue.opacity(self.placeItem!.itemAdditions[item.id].selected == i.id ? 1 : 0))
                                                                
                                                                RoundedRectangle(cornerRadius: 5)
                                                                    .stroke(Color.black,lineWidth: 1.5)
                                                            }
                                                        )
                                                }
                                            }else{
                                                Button(action: {
                                                    if (self.placeItem!.itemAdditions[item.id].compulsary == false) && (self.placeItem!.itemAdditions[item.id].selected == i.id){
                                                        self.prices.removeValue(forKey: item.id)
                                                        self.placeItem!.itemAdditions[item.id].selected = nil

                                                    }else{
                                                        self.prices[item.id] = i.sizePriceAddition
                                                        self.placeItem!.itemAdditions[item.id].selected = i.id
                                                    }
                                                }) {
                                                    
                                                    Text(textVal)
                                                        .font(.custom("Montserrat-Bold", size: 13))
                                                        .foregroundColor(self.placeItem!.itemAdditions[item.id].selected == i.id ? .white : .black)
                                                        .padding(.vertical,8)
                                                        .padding(.horizontal,10)
                                                        .background(
                                                            
                                                            ZStack{
                                                                
                                                                RoundedRectangle(cornerRadius: 5)
                                                                    .fill(Color.blue.opacity(self.placeItem!.itemAdditions[item.id].selected == i.id ? 1 : 0))
                                                                
                                                                RoundedRectangle(cornerRadius: 5)
                                                                    .stroke(Color.black,lineWidth: 1.5)
                                                            }
                                                        )
                                                }
                                            }
                                            
                                            
                                        }
                                        .padding(.top,2)
                                        .padding(.bottom,2)
                                        Spacer()
                                    }
                                    .frame(minWidth: g.size.width - 70)
                                    
                                    
                                    
                                }
                                
                            }
                            
                            .padding()
                            .frame(width: g.size.width - 30)
                            .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
                            .cornerRadius(10)
                        }
                        Spacer()
                        
                        HStack{
                            Text("Quantity:")
                                .padding(.leading,20)
                                .font(.custom("Montserrat-Bold", size: 17))
                            
                            Spacer()
                        }
                        VStack{
                                HStack( alignment: .center){
                                    
                                    Spacer()
                                    Button(action: {
                                        if self.count > 1 {
                                            
                                            self.count -= 1
                                        }
                                    }) {
                                        
                                        Image(systemName: "minus.circle").font(.system(size: 24))
                                        
                                    }.foregroundColor(.black)
                                    Spacer()
                                    Text("\(self.count)")
                                        .font(.custom("Montserrat-Bold", size: 16))

                                    Spacer()
                                    Button(action: {
                                        self.count += 1

                                    }) {
                                        
                                        Image(systemName: "plus.circle").font(.system(size: 24))
                                        
                                    }.foregroundColor(.black)
                                    Spacer()
                                    
                                }
                                
                            
                            
                        }
                        
                        .padding()
                        .frame(width: g.size.width - 30)
                        .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
                        .cornerRadius(10)
                        
                    }
                }
                .frame(height: g.size.height )
                .offset(y: -80)
            }
            VStack(alignment: .center){
                
                Spacer()
                HStack(alignment: .bottom){
                    Spacer()
                    
                    
                    Button(action: {
                        var options = ""
                        for tings in self.prices.keys{
                            options += self.placeItem!.itemAdditions[tings].modifiers[self.placeItem!.itemAdditions[tings].selected!].sizeName + ", "
                        }
                        
                        options = String(options.dropLast(2))
                        cartData.items.append(Item(itemName: (self.placeItem?.itemName)!, itemPrice: total(price: self.prices, base: self.placeItem!.itemBasePrice, quantity: self.count), itemOptions: options, itemQuantity: 1, itemImage: (self.placeItem?.itemImage)!))
                        
                        self.isShowing = false
                        
                        
                    })
                    {
                        HStack (alignment: .bottom){
                            Text("Add to basket - £" + String(format: "%.2f", (total(price: self.prices, base: self.placeItem!.itemBasePrice, quantity: self.count))))
                                .font(.custom("Montserrat-Bold", size: 16))

                        }
                        //.padding()
                        .frame(width: g.size.width - 35, height: 40)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(5)
                    }.padding(.bottom, 30)
                    Spacer()
                }
                //.padding(.bottom, 40)
                
            }
            .frame(width: g.size.width)
            
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

func total(price: [Int:Double], base: Double, quantity: Int) -> Double {
    var tot = base
    for item in price.keys {
        print(price.count)
        tot += price[item]!
    }
    return tot * Double(quantity)
}

struct RoundedCorner : Shape {
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 35, height: 35))
        
        return Path(path.cgPath)
    }
}



