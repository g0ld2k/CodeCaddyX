//
//  CommandType.swift
//  CodeCaddyShared
//
//  Created by Chris Golding on 4/22/23.
//

import Foundation

/**
 An enum representing the command types that are supported.
 */
public enum CommandType: String, Equatable {
    case explain
    case codeReview
    case unitTests
    case ask
    case document
    case convertFromObjectiveCToSwift
}
