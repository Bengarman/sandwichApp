//
//  ActivitiesCartView.swift
//  SwiftUIStarterKitApp
//
//  Created by Osama Naeem on 03/08/2019.
//  Copyright © 2019 NexThings. All rights reserved.
//

import SwiftUI
import Combine

var cartData = CartViewModel()


struct ActivitiesCartViewNav: View {
    var body: some View {
        if #available(iOS 14.0, *) {
            ActivitiesCartView(cartData: cartData)
        } else {
            // Fallback on earlier versions
        }
        
    }
}


@available(iOS 14.0, *)
struct ActivitiesCartView: View {
    @StateObject var cartData : CartViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Divider()
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    HStack {
                        Text("\(cartData.items.count) items")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .padding(.leading, 12)
                            .padding(.top, 8)
                        Spacer()
                        
                    }
                    .navigationBarTitle("Shopping Cart")
                ScrollView (.vertical, showsIndicators: false) {
                    VStack (alignment: .leading) {
                        ForEach(cartData.items){item in
                            ItemView(shoppingCartItem: $cartData.items[getIndex(item: item)],shoppingCartItems: $cartData.items)
                                .frame(width: geometry.size.width - 24, height: 80)
                        }
                    }
                }
                .frame(height: 87 * 4)
                
                Spacer()
                HStack {
                    VStack (alignment: .leading){
                        Spacer()
                        HStack {
                            Spacer()
                        }
                        Text("Shipping to the United Kingdom")
                            .font(.system(size: 12))
                        Text("from £2.25")
                            .font(.system(size: 12))
                    }.frame(width: geometry.size.width / 2 - 12)

                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack {
                            Spacer()
                        }
                        Text("\(cartData.items.count) items on")
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray)
                        Text("\(calculateTotalPrice())")
                            .font(.system(.title))
                    }.frame(width: geometry.size.width / 2 - 12)
                    
                    
                }
                .padding()
                Button(action: {}) {
                        HStack {
                        Text("Checkout")
                    }
                    .padding()
                    .frame(width: geometry.size.width - 24, height: 40)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(5)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
          
            }
        }
    }
        
    func getIndex(item: Item)->Int{
            
        return cartData.items.firstIndex { (item1) -> Bool in
            return item.id == item1.id
        } ?? 0
    }
    
    func additem(item: Item){
            
        cartData.items.append(item)
    }
    
    func calculateTotalPrice()->String{
        
        var price : Float = 0
        
        cartData.items.forEach { (item) in
            price += Float(item.itemPrice)!
        }
        
        return getPrice(value: price)
    }
}


struct ItemView: View {
    // FOr Real Time Updates...
    @Binding var shoppingCartItem : Item
    @Binding var shoppingCartItems : [Item]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack{
                    Print(shoppingCartItem.id)
                    Spacer()
                    Button(action: {
                        withAnimation(.easeIn){deleteItem()}
                    }){
                        
                        Image(systemName: "trash")
                            .font(.title)
                            .frame(width: 90, height: 50)
                            .foregroundColor(Color.red)
                    }
                }

                
                HStack (spacing: 10) {
                    Image("\(shoppingCartItem.itemImage)")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(.trailing, 5)
                        .padding(.leading, 5)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Spacer()
                        }
                        Text("\(shoppingCartItem.itemName)")
                            .lineLimit(nil)
                            .foregroundColor(.primary)
                        Text("\(shoppingCartItem.itemManufacturer)")
                            .foregroundColor(.primary)
                            .font(.system(size: 12))
                            .foregroundColor(Color.gray)
                        Text("\(shoppingCartItem.itemColor)")
                            .foregroundColor(.primary)
                            .font(.system(size: 12))
                            .foregroundColor(Color.gray)
                            .padding(.bottom, 10)
                    }.frame(width: geometry.size.width - 150)
                     .padding(.top, 8)
                    VStack(alignment: .trailing){
                        //Spacer()
                        HStack {
                            Spacer()
                        }
                        Text("£\(shoppingCartItem.itemPrice)")
                            .font(.system(size: 16))
                            .foregroundColor(Color.black)
                            .padding(.trailing, 15)
                           
                          
                    }.padding(.bottom, 10)
                }
                .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
                .contentShape(Rectangle())
                .offset(x: shoppingCartItem.offset)
                .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
                
                
            }
            
            
        }.background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
        .cornerRadius(10)
        
    }
    func onChanged(value: DragGesture.Value){
        if value.translation.width < 0{
            
            if shoppingCartItem.isSwiped{
                shoppingCartItem.offset = value.translation.width - 90
            }
            else{
                shoppingCartItem.offset = value.translation.width
            }
        }
    }
    
    
    func onEnd(value: DragGesture.Value){
        
        withAnimation(.easeOut){
            if value.translation.width < 0{
                if -value.translation.width > UIScreen.main.bounds.width / 2{
                    
                    shoppingCartItem.offset = -1000
                    deleteItem()
                }
                else if -shoppingCartItem.offset > 50{
                    // updating is Swipng...
                    shoppingCartItem.isSwiped = true
                    shoppingCartItem.offset = -90
                }
                else{
                    shoppingCartItem.isSwiped = false
                    shoppingCartItem.offset = 0
                }
            }else{
                shoppingCartItem.isSwiped = false
                shoppingCartItem.offset = 0
            }
        }
    }
    
    func deleteItem(){
        shoppingCartItems.removeAll { (item) -> Bool in
            return self.shoppingCartItem.id == item.id
        }
        
    }
}

func getPrice(value: Float)->String{
    
    let format = NumberFormatter()
    format.numberStyle = .currency
    
    return format.string(from: NSNumber(value: value)) ?? ""
}


/*
struct ItemView: View {
    // FOr Real Time Updates...
    @Binding var item: Item
    @Binding var items: [Item]
    var body: some View {
        
        ZStack{
            
            LinearGradient(gradient: .init(colors: [Color("lightblue"),Color("blue")]), startPoint: .leading, endPoint: .trailing)
            
            // Delete Button..
            
            HStack{
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeIn){deleteItem()}
                }) {
                    
                    Image(systemName: "trash")
                        .font(.title)
                        .foregroundColor(.white)
                        // default Frame....
                        .frame(width: 90, height: 50)
                }
            }
            
            HStack(spacing: 15){
                
                Image(item.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 130, height: 130)
                    .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text(item.name)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text(item.details)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 15){
                        
                        Text(getPrice(value: item.price))
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        
                        Spacer(minLength: 0)
                        
                        // Add - Sub Button...
                        
                        Button(action: {
                            if item.quantity > 1{item.quantity -= 1}
                        }) {
                            
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(.black)
                        }
                        
                        Text("\(item.quantity)")
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                            .padding(.vertical,5)
                            .padding(.horizontal,10)
                            .background(Color.black.opacity(0.06))
                        
                        Button(action: {item.quantity += 1}) {
                            
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .padding()
            .background(Color("gray"))
            .contentShape(Rectangle())
            .offset(x: item.offset)
            .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
        }
    }
    
    func onChanged(value: DragGesture.Value){
        
        if value.translation.width < 0{
            
            if item.isSwiped{
                item.offset = value.translation.width - 90
            }
            else{
                item.offset = value.translation.width
            }
        }
    }
    
    func onEnd(value: DragGesture.Value){
        
        withAnimation(.easeOut){
            
            if value.translation.width < 0{
                
                // Checking...
                
                if -value.translation.width > UIScreen.main.bounds.width / 2{
                    
                    item.offset = -1000
                    deleteItem()
                }
                else if -item.offset > 50{
                    // updating is Swipng...
                    item.isSwiped = true
                    item.offset = -90
                }
                else{
                    item.isSwiped = false
                    item.offset = 0
                }
            }
            else{
                item.isSwiped = false
                item.offset = 0
            }
        }
    }
    
    // removing Item...
    
    func deleteItem(){
        
        items.removeAll { (item) -> Bool in
            return self.item.id == item.id
        }
    }
}
struct ShoppingCartCellView: View {
    @State var shoppingCartItem: ActivitiesCartItem
    @State var shoppingCartItems: [ActivitiesCartItem]
    var offset = CGFloat(0)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack{
                    
                    Spacer()
                    Button(action: deleteIten){
                        
                        Image(systemName: "trash")
                            .font(.title)
                            .frame(width: 90, height: 50)
                            .foregroundColor(Color.red)
                    }
                }

                
                HStack (spacing: 10) {
                    Image("\(self.shoppingCartItem.itemImage)")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(.trailing, 5)
                        .padding(.leading, 5)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Spacer()
                        }
                        Text("\(self.shoppingCartItem.itemName)")
                            .lineLimit(nil)
                            .foregroundColor(.primary)
                        Text("\(self.shoppingCartItem.itemManufacturer)")
                            .foregroundColor(.primary)
                            .font(.system(size: 12))
                            .foregroundColor(Color.gray)
                        Text("\(self.shoppingCartItem.itemColor)")
                            .foregroundColor(.primary)
                            .font(.system(size: 12))
                            .foregroundColor(Color.gray)
                            .padding(.bottom, 10)
                    }.frame(width: geometry.size.width - 150)
                     .padding(.top, 8)
                    VStack(alignment: .trailing){
                        //Spacer()
                        HStack {
                            Spacer()
                        }
                        Text("$\(self.shoppingCartItem.itemPrice)")
                            .font(.system(size: 16))
                            .foregroundColor(Color.black)
                            .padding(.trailing, 15)
                           
                          
                    }.padding(.bottom, 10)
                }
                .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
                .contentShape(Rectangle())
                .offset(x: shoppingCartItem.offset)
                .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
                
                
            }
            
            
        }.background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
        .cornerRadius(10)
       
    }
    func onChanged(value: DragGesture.Value){
        if value.translation.width < 0{
            
            if shoppingCartItem.isSwiped{
                shoppingCartItem.offset = value.translation.width - 90
            }
            else{
                shoppingCartItem.offset = value.translation.width
            }
        }
    }
    
    
    func onEnd(value: DragGesture.Value){
        
        withAnimation(.easeOut){
            if value.translation.width < 0{
                if -value.translation.width > UIScreen.main.bounds.width / 2{
                    
                    shoppingCartItem.offset = -1000
                    deleteIten()
                }
                else if -shoppingCartItem.offset > 50{
                    // updating is Swipng...
                    shoppingCartItem.isSwiped = true
                    shoppingCartItem.offset = -90
                }
                else{
                    shoppingCartItem.isSwiped = false
                    shoppingCartItem.offset = 0
                }
            }else{
                shoppingCartItem.isSwiped = false
                shoppingCartItem.offset = 0
            }
        }
    }
    
    func deleteIten(){
        print(ActivitiesMockStore.shoppingCartData)
        ActivitiesMockStore.shoppingCartData.removeAll {(shoppingCartItem) -> Bool in
            
            return self.shoppingCartItem.itemID == shoppingCartItem.itemID
        }
        
        shoppingCartItems.removeAll {(shoppingCartItem) -> Bool in
            
            return self.shoppingCartItem.itemID == shoppingCartItem.itemID
        }
        
    }
}
*/
