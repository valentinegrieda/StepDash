/*import SwiftUI
import SwiftData

struct PlayerForm: View {
    
    @State private var gender = "Male"
    @State private var height = 0
    @State private var name = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let genders = ["Male", "Female"]
    
    @Environment(\.modelContext) private var context
    
    let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .none
        return f
    }()
    
    
    var body: some View {
        
        
        Form {
            
            Section {
                
                TextField("Name", text: $name)
                    .keyboardType(.default)
                
                Picker("Gender", selection: $gender) {
                    ForEach(genders, id: \.self) { gender in
                        Text(gender)
                    }
                }
                
                TextField(
                    "Height (cm)",
                    value: $height,
                    formatter: numberFormatter
                )
                .keyboardType(.numberPad)
            }
            
            Button {
                submitLog()
                
            } label: {
                Text("Add")
                    .frame(maxWidth: 250)
            }
            .buttonStyle(.borderedProminent)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .frame(maxWidth: .infinity)
            
        }
        .navigationTitle("Player Setup")
        .alert("Message", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .scrollContentBackground(.hidden)
        .background(Color.white)
    }
    
    
    func submitLog() {

        print("ModelContext:", context)
        print("Container exists:", context.container)

        let newPlayer = Player(
            name: name,
            gender: gender,
            height: height,
            
        )

        print("Has changes before insert:", context.hasChanges)

        context.insert(newPlayer)

        print("Has changes after insert:", context.hasChanges)

        do {
            try context.save()

            let descriptor = FetchDescriptor<Player>()
            let players = try context.fetch(descriptor)

            print("Fetched players:", players.count)

        } catch {
            print("Save error:", error)
        }
    }
}

#Preview {
    PlayerForm()
        .modelContainer(for: Player.self)
}
*/
