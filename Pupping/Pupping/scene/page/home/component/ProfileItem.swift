//
//  ProfileItem.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/23.
//

import Foundation
import SwiftUI

struct ProfileItem: PageComponent, Identifiable {
    let id = UUID().uuidString
    let profile:PetProfile
    var body: some View {
         PetProfileInfo(profile: profile)
            .modifier(MatchParent())
            .background(Color.transparent.clearUi)
    }
}
