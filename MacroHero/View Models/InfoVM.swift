//
//  InfoVM.swift
//  MacroHero
//
//  Created by Nadia Siddiqah on 1/18/22.
//

import Foundation
import Combine
import Alamofire

class InfoVM {
    @Published var userData: UserData?
    @Published var dailyMacro: MacroBreakdown?
}
