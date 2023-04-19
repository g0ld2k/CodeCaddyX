// -------------------------------------------------------------------------
// This item is the property of ResMed Ltd, and contains confidential and trade
// secret information. It may not be transferred from the custody or control of
// ResMed except as authorized in writing by an officer of ResMed. Neither this
// item nor the information it contains may be used, transferred, reproduced,
// published, or disclosed, in whole or in part, and directly or indirectly,
// except as expressly authorized by an officer of ResMed, pursuant to written
// agreement.
//
// Copyright (c) 2023 ResMed Ltd.  All rights reserved.
//-------------------------------------------------------------------------

import Foundation
import XcodeKit
import AppKit

class RememberCommand: BaseCommand {
    override func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
        let url = URL(string: "codecaddyx://some/path")!
        NSWorkspace.shared.open(url)
    }
}
