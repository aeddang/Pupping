//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageLogin: PageView {
    @EnvironmentObject var snsManager:SnsManager
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    var body: some View {
        VStack(spacing: 0){
            ZStack{
                VStack(spacing: 0){
                    Spacer().modifier(MatchHorizontal(height: 367))
                        .background(Color.brand.primaryExtra)
                    Spacer()
                }
                VStack(spacing: 0){
                    Spacer()
                    Image(Asset.shape.ellipse)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchHorizontal(height: 217))
                }
                HStack(){
                    Image(Asset.image.woman)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.leading, 7)
                    Spacer()
                    Image(Asset.image.man)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.trailing, 2)
                        
                }
                .frame(height: 226)
            }
            .modifier(MatchHorizontal(height: 460))
            Spacer()
            Text(String.pageText.loginText)
                .modifier(SemiBoldTextStyle(size: Font.size.medium, color: Color.app.greyDeep))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            Spacer()
            FaceBookButton()
                .modifier( MatchHorizontal(height: Dimen.button.medium))
                .padding(.horizontal, Dimen.margin.heavy)
                .background(Color.app.blueFB)
                .clipShape(RoundRectMask(radius: Dimen.radius.lightExtra))
                .modifier(ContentHorizontalEdges())
                .padding(.bottom, Dimen.margin.thin)
            
            Button(action: {
                self.snsManager.requestLogin(type: .apple)
            }) {
                AppleButton()
            }
            .modifier( MatchHorizontal(height: Dimen.button.medium))
            .background(Color.app.black)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
            .modifier(ContentHorizontalEdges())
            .padding(.bottom, Dimen.margin.heavy)
        }
        .modifier(PageFull())
        .onReceive(self.snsManager.$error){err in
            guard let err  = err  else { return }
            switch err.event {
                case .login :
                    self.appSceneObserver.alert = .alert(nil, String.alert.snsLoginError)
                case .getProfile :
                    self.join()
                default : break
            }
        }
        .onReceive(self.snsManager.$user){user in
            if user == nil { return }
            self.snsManager.getUserInfo()
            //self.appSceneObserver.event = .initate
        }
        .onReceive(self.snsManager.$userInfo){userInfo in
            if userInfo == nil { return }
            self.join(info: userInfo)
        }
        .modifier(PageFull())
        .onAppear{
            self.repository.clearLogin()
        }
    }//body
   
    private func join(info:SnsUserInfo? = nil){
        guard let user = self.snsManager.user else {
            self.appSceneObserver.alert = .alert(nil, String.alert.snsLoginError)
            return
        }
        self.repository.registerSnsLogin(user, info: info)
    }
}


#if DEBUG
struct PageLogin_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageLogin().contentBody
                .environmentObject(SnsManager())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

