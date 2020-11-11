//
//  PresentationTimingInformationProvider.swift
//  CleanArhitecture
//
//  Created by MSI on 06/09/2019.
//  Copyright © 2019 IA. All rights reserved.
//

import Foundation

public protocol PresentationTimingInformationProvider {
    var presentationTiming: PresentationTiming { get set}
}