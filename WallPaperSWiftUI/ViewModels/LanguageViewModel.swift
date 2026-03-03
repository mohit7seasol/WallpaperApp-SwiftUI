//
//  LanguageViewModel.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 03/03/26.
//

import Foundation
import Combine
import SwiftUI

class LanguageViewModel: BaseViewModel {
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    @Published var selectedLanguage: Language?
}
