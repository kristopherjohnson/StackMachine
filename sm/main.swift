//
//  main.swift
//  sm
//
//  Created by Kristopher Johnson on 7/23/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

do {
    print("sm, Copyright 2017 Kristopher Johnson")
    print("Type \"words\" for list of available words.")
    print("Type \"bye\" to exit.")

    let sm = StackMachineInterpreter()
    try sm.quit()
}
catch let error {
    print("fatal error: \(error)")
}
