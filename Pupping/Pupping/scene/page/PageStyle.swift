//
//  PageStyle.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/07.
//

import Foundation
import SwiftUI
import Combine
struct PageFull: ViewModifier {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var style:PageStyle = .normal
    @State var marginStart:CGFloat = 0
    @State var marginEnd:CGFloat = 0

    func body(content: Content) -> some View {
        return content
            .padding(.leading, self.marginStart)
            .padding(.trailing, self.marginEnd)
            .background(self.style.bgColor)
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                if self.pagePresenter.isFullScreen {
                    self.marginStart = 0
                    self.marginEnd = 0
                }else{
                    self.marginStart = self.sceneObserver.safeAreaStart
                    self.marginEnd = self.sceneObserver.safeAreaEnd
                }
                
            }
    }
}

struct PageBody: ViewModifier {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var style:PageStyle = .normal
    func body(content: Content) -> some View {
        return content
            .frame(
                width: self.sceneObserver.screenSize.width,
                height: self.sceneObserver.screenSize.height - self.sceneObserver.safeAreaTop - Dimen.app.top - self.sceneObserver.safeAreaBottom)
            .background(self.style.bgColor)
            
    }
}


struct PageDraging: ViewModifier {
    var geometry:GeometryProxy
    var pageDragingModel:PageDragingModel
   
    func body(content: Content) -> some View {
        return content
            .highPriorityGesture(
                DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .global)
                    .onChanged({ value in
                        self.pageDragingModel.uiEvent = .drag(geometry, value)
                    })
                    .onEnded({ value in
                        self.pageDragingModel.uiEvent = .draged(geometry, value)
                    })
            )
            
            .gesture(
                self.pageDragingModel.cancelGesture
                    .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                    .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
            )
    }
}

struct PageDragingSecondPriority: ViewModifier {
    var geometry:GeometryProxy
    var pageDragingModel:PageDragingModel
   
    func body(content: Content) -> some View {
        return content
            .gesture(
                DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .global)
                    .onChanged({ value in
                       self.pageDragingModel.uiEvent = .drag(geometry, value)
                    })
                    .onEnded({ value in
                        self.pageDragingModel.uiEvent = .draged(geometry, value)
                    })
            )
            
            .gesture(
                self.pageDragingModel.cancelGesture
                    .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                    .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
            )
    }
}

struct ContentEdges: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.all, Dimen.margin.light)
    }
}
struct ContentHorizontalEdges: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .padding(.horizontal, Dimen.margin.light)
    }
}


struct ContentVerticalEdges: ViewModifier {
    var margin:CGFloat = Dimen.margin.thin
    func body(content: Content) -> some View {
        return content
            .padding(.vertical, Dimen.margin.light)
    }
}

struct PageTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(BoldTextStyle(size: Font.size.mediumExtra, color: Color.app.greyDeep))
    }
}


struct ContentTitle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(SemiBoldTextStyle( size: Font.size.regular, color: Color.app.greyDeep))
    }
}



struct ContentScrollPull: ViewModifier {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var tag:String? = nil
    var infinityScrollModel:InfinityScrollModel
    var pageDragingModel:PageDragingModel
    
    @State var anyCancellable = Set<AnyCancellable>() 
    private func setScrollList(){
        self.infinityScrollModel.$event.sink(receiveValue: { evt in
            guard let evt = evt else {return}
            switch evt {
            case .ready : self.infinityScrollModel.setup(scrollSize: sceneObserver.screenSize)
            case .pullCompleted : self.pageDragingModel.updateNestedScroll(evt: .pullCompleted)
            case .pullCancel : self.pageDragingModel.updateNestedScroll(evt: .pullCancel)
            default : break
            }
        })
        .store(in: &anyCancellable)
        self.infinityScrollModel.$pullPosition.sink(receiveValue: { pos in
            self.pageDragingModel.updateNestedScroll(evt: .pull(pos))
        })
        .store(in: &anyCancellable)
    }
   
    func body(content: Content) -> some View {
        return content
            .onAppear(){
                self.setScrollList()
                if let tag = self.tag {
                    ComponentLog.d("onAppear " + tag,tag: "ContentScrollPull")
                }
            }
            .onDisappear{
                self.anyCancellable.forEach{$0.cancel()}
                self.anyCancellable.removeAll()
                if let tag = self.tag {
                    ComponentLog.d("onDisappear " + tag,tag: "ContentScrollPull")
                }
            }
    }
}



