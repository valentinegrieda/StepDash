//
//  PlayerSetup.swift
//  StepDash
//
//  Created by Valentine Grieda Sahuburua on 30/06/26.
//

import SwiftUI
import SwiftData

extension OnboardingView {
    func submitLog() {
        guard nameValid else { return }
        
        let heightInMeters = Double(heightCm) / 100.0
        
        if gender == "male" {
            self.stepLength = 0.415 * heightInMeters
        } else {
            self.stepLength = 0.413 * heightInMeters
        }
        
        
        let newPlayer = Player(
            name: name,
            gender: gender,
            height: heightCm,
            stepLength: stepLength
        )
        
        do {
            
            context.insert(newPlayer)
            print("Inserted:", newPlayer)
            print("Persistent Model ID:", newPlayer.persistentModelID)
            print("Has changes:", context.hasChanges)
            print("Step length:", stepLength)
            
            try context.save()
            
            let descriptor = FetchDescriptor<Player>()
            let players = try context.fetch(descriptor)
            print("Fetched players:", players.count)
            
        } catch {
            print("Save error:", error)
            return
        }
        
        finish()   // only navigate after save succeeds
    }
}
