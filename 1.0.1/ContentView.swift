//
//  ContentView.swift
//  Notizen App
//
//  Created by Oliver Henkel on 28.09.24.
//

import SwiftUI

struct ContentView: View {
    @State private var pickerSelected = "Notiz"
    let pickerAuswahl: [String] = ["Notiz", "Einkaufsliste"]
    
    // Popups
    @State private var showSheet = false
    
    @State private var notizenTitles: [String] = UserDefaults.standard.stringArray(forKey: "notizenTitles") ?? []
    @State private var notizenInhalt: [String] = UserDefaults.standard.stringArray(forKey: "notizenInhalt") ?? []
    @State private var notizenDatum: [String] = UserDefaults.standard.stringArray(forKey: "notizenDatum") ?? []
    
    @State private var EinkaufslistenItemQuantity: Int = 1
    @State private var einkaufslistenMenge: [[Int]] = UserDefaults.standard.array(forKey: "einkaufslistenMenge") as? [[Int]] ?? []
    
    @State private var einkaufslistenTitles: [String] = UserDefaults.standard.stringArray(forKey: "einkaufslistenTitles") ?? []
    @State private var einkaufslistenInhalt: [[String]] = UserDefaults.standard.array(forKey: "einkaufslistenInhalt") as? [[String]] ?? []
    @State private var einkaufslistenDatum: [String] = UserDefaults.standard.stringArray(forKey: "einkaufslistenDatum") ?? []
    
    @State private var einkaufslistenNotizInhalt: [String] = UserDefaults.standard.stringArray(forKey: "einkaufslistenNotizInhalt") ?? []
    @State private var notiz = ""
    @State private var einkaufsliste = ""
    
    @State private var EinkaufslistenPickerAuswahl: [String] = ["Liste", "Notiz"]
    @State private var EinkaufslistenPickerSelection = "Liste"

    struct NotizInhaltView: View {
        @Binding var notizenInhalt: String
        @Binding var notizenTitle: String
        @State private var isEditing = false
        var saveData: () -> Void
        var existingTitles: [String] // Liste der vorhandenen Titel

        var body: some View {
            VStack {
                if isEditing {
                    Spacer()
                    TextField("Notiz Titel", text: $notizenTitle)
                        .font(.headline)
                        .padding()
                        .onChange(of: notizenTitle) { newTitle in
                            // Überprüfe, ob der Titel leer ist oder bereits existiert
                            if !newTitle.isEmpty && !existingTitles.contains(newTitle) {
                                saveData() // Speichere die Änderungen nur, wenn der Titel gültig ist
                            } else {
                                // Rücksetzen auf alten Titel, wenn der neue Titel leer ist oder existiert
                                notizenTitle = existingTitles.contains(newTitle) ? "" : notizenTitle
                            }
                        }
                }

                TextEditor(text: $notizenInhalt)
                    .border(Color.gray, width: 1)
                    .padding()
                    .onChange(of: notizenInhalt) {
                        saveData() // Speichere die Änderungen im Inhalt automatisch
                    }
            }
            .navigationTitle(notizenTitle)
            .toolbar {
                Button(isEditing ? "Fertig" : "Bearbeiten") {
                    isEditing.toggle() // Zwischen Ansichts- und Bearbeitungsmodus wechseln
                }
            }
        }
    }
    
    struct EinkaufsListenView: View {
        @Binding var einkaufslistenInhalt: [String]
        @Binding var einkaufslistenMenge: [Int]
        @Binding var notizenTitle: String
        var saveData: () -> Void
        @Binding var EinkaufslistenPickerSelection: String
        @Binding var einkaufslistenNotizInhalt: String
        @Binding var EinkaufslistenItemQuantity: Int
        @State private var einkaufslistenNewElement: String = ""
        @State private var isSheetOpen: Bool = false
        @State private var isEditing = false
        var existingTitles: [String] // Liste der vorhandenen Titel

        var body: some View {
            VStack {
                // TextField für das Bearbeiten des Titels, wird nur im Bearbeitungsmodus angezeigt
                if isEditing {
                    TextField("Einkaufslistenname bearbeiten", text: $notizenTitle)
                        .font(.headline)
                        .padding()
                        .onChange(of: notizenTitle) { newValue in
                            // Überprüfen, ob der neue Titel gültig ist
                            if !newValue.isEmpty && !existingTitles.contains(newValue) {
                                saveData() // Speichern, wenn der Name gültig ist
                            } else {
                                // Titel bleibt unverändert, wenn er leer ist oder bereits existiert
                                notizenTitle = existingTitles.contains(newValue) ? notizenTitle : ""
                            }
                        }
                }

                Picker("Wähle aus", selection: $EinkaufslistenPickerSelection) {
                    ForEach(["Liste", "Notiz"], id: \.self) { picked in
                        Text(picked).tag(picked)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if EinkaufslistenPickerSelection == "Liste" {
                    VStack {
                        List {
                            ForEach(einkaufslistenInhalt.indices, id: \.self) { index in
                                HStack {
                                    if isEditing {
                                        TextField("Produktname", text: $einkaufslistenInhalt[index])
                                        Stepper("Menge: \(einkaufslistenMenge[index])", value: $einkaufslistenMenge[index], in: 1...100)
                                    } else {
                                        Text(einkaufslistenInhalt[index])
                                        Spacer()
                                        if index < einkaufslistenMenge.count {
                                            Text("Menge: \(einkaufslistenMenge[index])")
                                        } else {
                                            Text("Menge: N/A")
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: deleteEinkaufslistenItems)
                        }

                        HStack {
                            Button(action: {
                                isSheetOpen.toggle()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 30))
                                    .frame(width: 190, height: 50)
                            }
                            .sheet(isPresented: $isSheetOpen) {
                                Form {
                                    Section {
                                        TextField("Neues Produkt", text: $einkaufslistenNewElement)
                                        Stepper("Anzahl: \(EinkaufslistenItemQuantity)", value: $EinkaufslistenItemQuantity, in: 1...100)
                                    }

                                    Section {
                                        Button(action: {
                                            addEinkaufslistenItem()
                                            isSheetOpen.toggle()
                                        }) {
                                            Text("Hinzufügen")
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else if EinkaufslistenPickerSelection == "Notiz" {
                    TextEditor(text: $einkaufslistenNotizInhalt)
                        .border(Color.gray, width: 1)
                        .padding()
                        .onChange(of: einkaufslistenNotizInhalt) {
                            saveData()
                        }
                }
            }
            .navigationTitle(notizenTitle)
            .toolbar {
                Button(isEditing ? "Fertig" : "Bearbeiten") {
                    isEditing.toggle() // Wechsel zwischen Ansicht und Bearbeitung
                }
            }
        }

        private func addEinkaufslistenItem() {
            if !einkaufslistenNewElement.isEmpty {
                einkaufslistenInhalt.append(einkaufslistenNewElement)
                einkaufslistenMenge.append(EinkaufslistenItemQuantity)
                einkaufslistenNewElement = ""
                EinkaufslistenItemQuantity = 1
                saveData()
            }
        }

        private func deleteEinkaufslistenItems(at offsets: IndexSet) {
            einkaufslistenInhalt.remove(atOffsets: offsets)
            einkaufslistenMenge.remove(atOffsets: offsets)
            saveData()
        }
    }
    
    struct EinkaufslistenListView: View {
        @Binding var einkaufsliste: String
        @Binding var einkaufslistenTitles: [String]
        @Binding var einkaufslistenInhalt: [[String]]
        @Binding var einkaufslistenMenge: [[Int]] // Add this binding
        @Binding var einkaufslistenNotizInhalt: [String]
        @Binding var EinkaufslistenPickerAuswahl: [String]
        @Binding var EinkaufslistenPickerSelection: String
        @Binding var einkaufslistenDatum: [String]
        @Binding var EinkaufslistenItemQuantity: Int
        var saveData: () -> Void
        
        var body: some View {
            VStack {
                List {
                    ForEach(einkaufslistenTitles.indices, id: \.self) { index in
                        NavigationLink(destination: EinkaufsListenView(
                            einkaufslistenInhalt: $einkaufslistenInhalt[index],
                            einkaufslistenMenge: $einkaufslistenMenge[index], // Pass the quantity data here
                            notizenTitle: $einkaufslistenTitles[index], // Binding statt einfacher String
                            saveData: saveData,
                            EinkaufslistenPickerSelection: $EinkaufslistenPickerSelection,
                            einkaufslistenNotizInhalt: $einkaufslistenNotizInhalt[index],
                            EinkaufslistenItemQuantity: $EinkaufslistenItemQuantity,
                            existingTitles: einkaufslistenTitles // Übergibt die Liste der vorhandenen Titel
                        )) {
                            VStack(alignment: .leading) {
                                Text(einkaufslistenTitles[index])
                                Text(einkaufslistenDatum[index])
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteEinkaufslisten)
                }
            }
            .navigationTitle("Einkaufslisten")
        }
        
        private func deleteEinkaufslisten(at offsets: IndexSet) {
            einkaufslistenTitles.remove(atOffsets: offsets)
            einkaufslistenInhalt.remove(atOffsets: offsets)
            einkaufslistenNotizInhalt.remove(atOffsets: offsets)
            einkaufslistenDatum.remove(atOffsets: offsets)
            saveData()
        }
    }

    struct SlideUpPopupViewNotiz: View {
        @Binding var notiz: String
        @Binding var notizenTitles: [String]
        @Binding var notizenInhalt: [String]
        @Binding var notizenDatum: [String]
        @Binding var showSheet: Bool
        var saveData: () -> Void
        
        var body: some View {
            VStack {
                Form {
                    Section {
                        TextField("Notiz Titel eingeben", text: $notiz)
                    }
                    
                    Section {
                        Button(action: {
                            addNotiz()
                            showSheet.toggle()
                        }) {
                            Text("Speichern")
                        }
                    }
                }
            }
        }
        
        private func addNotiz() {
            if !notiz.isEmpty && !notizenTitles.contains(notiz) {
                notizenTitles.insert(notiz, at: 0) // Notizen oben hinzufügen
                notizenInhalt.insert("", at: 0)
                notizenDatum.insert(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short), at: 0)
                notiz = ""
                saveData()
            }
        }
    }
    
    struct SlideUpPopupViewEinkaufslisten: View {
        @Binding var einkaufsliste: String
        @Binding var einkaufslistenTitles: [String]
        @Binding var einkaufslistenInhalt: [[String]]
        @Binding var einkaufslistenDatum: [String]
        @Binding var einkaufslistenNotizInhalt: [String]
        @Binding var einkaufslistenMenge: [[Int]] // Menge der Einkaufsliste
        @Binding var showSheet: Bool
        var saveData: () -> Void

        var body: some View {
            VStack {
                Form {
                    Section {
                        TextField("Einkaufslisten Titel eingeben", text: $einkaufsliste)
                    }
                    
                    Section {
                        Button(action: {
                            addEinkaufslisten()
                            showSheet.toggle()
                        }) {
                            Text("Speichern")
                        }
                    }
                }
            }
        }

        private func addEinkaufslisten() {
            if !einkaufsliste.isEmpty && !einkaufslistenTitles.contains(einkaufsliste) {
                // Neue Einkaufsliste hinzufügen
                einkaufslistenTitles.insert(einkaufsliste, at: 0)
                einkaufslistenInhalt.insert([], at: 0) // Leeres Array für die Produkte hinzufügen
                einkaufslistenMenge.insert([], at: 0) // Leeres Array für die Menge hinzufügen
                einkaufslistenDatum.insert(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short), at: 0)
                einkaufslistenNotizInhalt.insert("", at: 0) // Leere Notiz für die Liste hinzufügen
                
                // Setze den Inhalt des Textfeldes zurück
                einkaufsliste = ""
                saveData()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if pickerSelected == "Notiz" {
                    List {
                        ForEach(notizenTitles.indices, id: \.self) { index in
                            NavigationLink(destination: NotizInhaltView(
                                notizenInhalt: $notizenInhalt[index],
                                notizenTitle: $notizenTitles[index],
                                saveData: saveData,
                                existingTitles: notizenTitles // Liste der vorhandenen Titel übergeben
                            )) {
                                VStack(alignment: .leading) {
                                    Text(notizenTitles[index])
                                    Text(notizenDatum[index])
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteNotizen)
                    }
                    .navigationTitle("Notizen")

                } else if pickerSelected == "Einkaufsliste" {
                    EinkaufslistenListView(
                        einkaufsliste: $einkaufsliste,
                        einkaufslistenTitles: $einkaufslistenTitles,
                        einkaufslistenInhalt: $einkaufslistenInhalt,
                        einkaufslistenMenge: $einkaufslistenMenge, // Pass this binding
                        einkaufslistenNotizInhalt: $einkaufslistenNotizInhalt,
                        EinkaufslistenPickerAuswahl: $EinkaufslistenPickerAuswahl,
                        EinkaufslistenPickerSelection: $EinkaufslistenPickerSelection,
                        einkaufslistenDatum: $einkaufslistenDatum,
                        EinkaufslistenItemQuantity: $EinkaufslistenItemQuantity, // Here as well
                        saveData: saveData
                    )
                }
                
                HStack {
                    Button(action: ShowNotizenView) {
                        if pickerSelected == "Notiz" {
                            Label("", systemImage: "list.clipboard.fill")
                                .padding()
                                .font(.system(size: 30))
                                .frame(width: 190, height: 50)
                        } else {
                            Label("", systemImage: "list.clipboard")
                                .padding()
                                .font(.system(size: 30))
                                .frame(width: 190, height: 50)
                        }
                    }
                    
                    Button(action: {
                        showSheet.toggle()
                    }) {
                        Label("", systemImage: "plus")
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
                    }
                    .sheet(isPresented: $showSheet) {
                        VStack {
                            if pickerSelected == "Einkaufsliste" {
                                SlideUpPopupViewEinkaufslisten(
                                    einkaufsliste: $einkaufsliste,
                                    einkaufslistenTitles: $einkaufslistenTitles,
                                    einkaufslistenInhalt: $einkaufslistenInhalt,
                                    einkaufslistenDatum: $einkaufslistenDatum,
                                    einkaufslistenNotizInhalt: $einkaufslistenNotizInhalt,
                                    einkaufslistenMenge: $einkaufslistenMenge, // Add this binding
                                    showSheet: $showSheet,
                                    saveData: saveData
                                )
                            } else {
                                SlideUpPopupViewNotiz(
                                    notiz: $notiz,
                                    notizenTitles: $notizenTitles,
                                    notizenInhalt: $notizenInhalt,
                                    notizenDatum: $notizenDatum,
                                    showSheet: $showSheet,  // Hier das Binding für showSheet übergeben
                                    saveData: saveData
                                )
                            }
                        }
                    }
                    
                    Button(action: ShowEinkaufslistenView) {
                        if pickerSelected == "Einkaufsliste" {
                            Label("", systemImage: "cart.fill")
                                .padding()
                                .font(.system(size: 30))
                                .frame(width: 190, height: 50)
                        } else {
                            Label("", systemImage: "cart")
                                .padding()
                                .font(.system(size: 30))
                                .frame(width: 190, height: 50)
                        }
                    }
                }
            }
            .onAppear(perform: loadData)
        }
    }
    
    private func ShowEinkaufslistenView() {
        pickerSelected = "Einkaufsliste"
    }
    
    private func ShowNotizenView() {
        pickerSelected = "Notiz"
    }
    
    private func loadData() {
        notizenTitles = UserDefaults.standard.stringArray(forKey: "notizenTitles") ?? []
        notizenInhalt = UserDefaults.standard.stringArray(forKey: "notizenInhalt") ?? []
        notizenDatum = UserDefaults.standard.stringArray(forKey: "notizenDatum") ?? []

        einkaufslistenTitles = UserDefaults.standard.stringArray(forKey: "einkaufslistenTitles") ?? []
        einkaufslistenInhalt = UserDefaults.standard.array(forKey: "einkaufslistenInhalt") as? [[String]] ?? []
        einkaufslistenDatum = UserDefaults.standard.stringArray(forKey: "einkaufslistenDatum") ?? []
        einkaufslistenNotizInhalt = UserDefaults.standard.stringArray(forKey: "einkaufslistenNotizInhalt") ?? []

        // Versuche, die Menge zu laden und initialisiere bei Fehlern neu
        if let menge = UserDefaults.standard.array(forKey: "einkaufslistenMenge") as? [[Int]] {
            einkaufslistenMenge = menge
        } else {
            einkaufslistenMenge = Array(repeating: [], count: einkaufslistenTitles.count)
        }

        // Synchronisiere die Anzahl der Elemente in den verschiedenen Listen
        if einkaufslistenTitles.count != einkaufslistenInhalt.count {
            einkaufslistenInhalt = Array(repeating: [], count: einkaufslistenTitles.count)
        }
        if einkaufslistenTitles.count != einkaufslistenMenge.count {
            einkaufslistenMenge = Array(repeating: [], count: einkaufslistenTitles.count)
        }
        if einkaufslistenTitles.count != einkaufslistenNotizInhalt.count {
            einkaufslistenNotizInhalt = Array(repeating: "", count: einkaufslistenTitles.count)
        }
        if einkaufslistenTitles.count != einkaufslistenDatum.count {
            einkaufslistenDatum = Array(repeating: "", count: einkaufslistenTitles.count)
        }
    }
    
    func saveData() {
        let defaults = UserDefaults.standard

        print("Speichere einkaufslistenTitles...")
        defaults.set(einkaufslistenTitles, forKey: "einkaufslistenTitles")

        print("Speichere einkaufslistenInhalt...")
        defaults.set(einkaufslistenInhalt, forKey: "einkaufslistenInhalt")

        print("Speichere einkaufslistenNotizInhalt...")
        defaults.set(einkaufslistenNotizInhalt, forKey: "einkaufslistenNotizInhalt")

        print("Speichere einkaufslistenDatum...")
        defaults.set(einkaufslistenDatum, forKey: "einkaufslistenDatum")

        print("Speichere einkaufslistenMenge...")
        defaults.set(einkaufslistenMenge, forKey: "einkaufslistenMenge")

        print("Speichere notizenTitles...")
        defaults.set(notizenTitles, forKey: "notizenTitles")

        print("Speichere notizenInhalt...")
        defaults.set(notizenInhalt, forKey: "notizenInhalt")

        print("Speichere notizenDatum...")
        defaults.set(notizenDatum, forKey: "notizenDatum")

        defaults.synchronize()
    }
    
    private func deleteNotizen(at offsets: IndexSet) {
        notizenTitles.remove(atOffsets: offsets)
        notizenInhalt.remove(atOffsets: offsets)
        notizenDatum.remove(atOffsets: offsets)
        saveData()
    }
    
    private func addNotiz() {
        if !notiz.isEmpty && !notizenTitles.contains(notiz) {
            notizenTitles.insert(notiz, at: 0) // Notizen oben hinzufügen
            notizenInhalt.insert("", at: 0)
            notizenDatum.insert(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short), at: 0)
            notiz = ""
            saveData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
