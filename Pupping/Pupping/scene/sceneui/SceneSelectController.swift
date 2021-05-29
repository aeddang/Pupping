//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct SceneSelectController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:AppSceneObserver
    
    @State var isShow = false
    @State var selected:Int = 0
    @State var buttons:[SelectBtnData] = []
    @State var currentSelect:SceneSelect? = nil
        
    var body: some View {
        Form{
            Spacer()
        }
        .select(
            isShowing: self.$isShow,
            index: self.$selected,
            buttons: self.buttons)
        { idx in
            switch self.currentSelect {
            case .select(_ , _) , .selectBtn(_ , _), .imgPicker(_): self.selectedSelect(idx ,data:self.currentSelect!)
                default: do { return }
            }
            withAnimation{
                self.isShow = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        }
        
        .onReceive(self.sceneObserver.$select){ select in
            self.currentSelect = select
            switch select{
                case .select(let data, let idx): self.setupSelect(data:data, idx: idx)
                case .selectBtn(let data, let idx): self.setupSelect(data:data, idx: idx)
                case .imgPicker(let key): self.setupImagePicker(key: key)
                default: do { return }
            }
            withAnimation{
                self.isShow = true
            }
        }
        
    }//body
    
    func reset(){
        self.buttons = []
        self.currentSelect = nil
    }
    func setupImagePicker(key:String){
        let imgSelect:[String] = [
            String.button.album,
            String.button.camera,
            String.button.delete
        ]
        self.setupSelect(data:(key,imgSelect), idx: imgSelect.count-1)
    }

    func setupSelect(data:(String,[String]), idx:Int) {
        self.selected = idx
        let range = 0 ..< data.1.count
        self.buttons = zip(range, data.1).map {index, text in
            SelectBtnData(title: text, index: index)
        }
    }
    func setupSelect(data:(String,[SelectBtnData]), idx:Int) {
        self.selected = idx
        self.buttons = data.1
    }
    
    func selectedSelect(_ idx:Int, data:SceneSelect) {
        self.sceneObserver.selectResult = .complete(data, idx)
        self.sceneObserver.selectResult = nil
    }
    
   
}


