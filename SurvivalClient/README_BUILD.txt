SurvivalClient (SwiftUI + SpriteKit) - quick build notes for Windows builder

1) Open this folder in your iOS-capable builder tool:
   C:\Users\sivma\Desktop\ios программа\ios-client\SurvivalClient

2) Ensure these source groups are included in target:
   - App/
   - Domain/Models/
   - Data/Network/
   - Presentation/ViewModels/
   - Presentation/Views/
   - Game/Scene/
   - Game/Systems/

3) Main entry point:
   - App/SurvivalApp.swift

4) Server URL default in app:
   - ws://127.0.0.1:8080

5) If your builder requires project generation, generate Xcode project with app target named "SurvivalClient" and iOS 16+.

6) Common issue:
   If networking blocked on device, replace 127.0.0.1 with LAN IP of server host.
