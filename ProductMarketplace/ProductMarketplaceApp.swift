//
//  ProductMarketplaceApp.swift
//  ProductMarketplace
//
//  Created by Umoh, David on 2023/11/03.
//
import AWSS3StoragePlugin
import AWSAPIPlugin
import AWSCognitoAuthPlugin
import AWSDataStorePlugin
import Amplify
import SwiftUI

@main
struct ProductMarketplaceApp: App {
    var body: some Scene {
        WindowGroup {
//            LoginView()
            SessionView()
        }
    }
    
    init() {
        configureAmplify()
    }
    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            let models = AmplifyModels()
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: models))
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: models))
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Successfully configured Amplify")
            
        } catch {
            print("Failed to initialize Amplify", error)
        }
    }
}
