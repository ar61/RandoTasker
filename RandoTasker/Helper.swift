//
//  Helper.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/15/22.
//

import UIKit
import Foundation
import SwiftUI

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let url = paths?.appendingPathComponent(file) else {
            // file doesnt exist so create one with empty data
            let emptyData = try? JSONSerialization.data(withJSONObject: T.self, options: [])
            if let p = paths?.path {
                try? emptyData?.write(to: URL(fileURLWithPath: p))
                let decoder = JSONDecoder()
                
                guard let loaded = try? decoder.decode(T.self, from: emptyData ?? Data()) else {
                    fatalError("Unable to decode json file \(file)")
                }
                return loaded
            }
            fatalError("Unable to access documents folder")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            return [] as! T
        }
        
        let decoder = JSONDecoder()
        
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Unable to decode json file \(file)")
        }
        
        return loaded
    }
    func writeJSON<T: Encodable>(_ data: T, to file: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let fileURL = paths?.appendingPathComponent(file) else {
            fatalError("Unable to access documents folder")
        }
        
        let encoder = JSONEncoder()
        do {
            try encoder.encode(data).write(to: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)
    
    let base: Base
    
    var startIndex: Index { base.startIndex }
    
    var endIndex: Index { base.endIndex }
    
    func index(after i: Index) -> Index {
        base.index(after: i)
    }
    
    func index(before i: Index) -> Index {
        base.index(before: i)
    }
    
    func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }
    
    subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(configuration.isOn ? Constants.colorCheck : Constants.colorCompliment)
            
        }.onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

struct EditableList<Element: Identifiable, Content: View>: View {
    @Binding var data: [Element]
    var content: (Binding<Element>) -> Content
    
    init(_ data: Binding<[Element]>,
         content: @escaping (Binding<Element>) -> Content) {
        self._data = data
        self.content = content
    }
    
    var body: some View {
        List {
            ForEach($data, content: content)
                .onMove { indexSet, offset in
                    data.move(fromOffsets: indexSet, toOffset: offset)
                }
                .onDelete { indexSet in
                    data.remove(atOffsets: indexSet)
                }
        }
        .toolbar { EditButton() }
    }
}

struct CustomText: View {
    @State static var color = Constants.color
    @State var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .foregroundColor(CustomText.color)
    }
}

struct Constants {
    static let color = Color(CGColor(red: 1.0, green: 0.523, blue: 0.001, alpha: 1.0))
    static let uiColor = UIColor(red: 0.876, green: 0.537, blue: 0.380, alpha: 1.0)
    static let colorCompliment = Color(CGColor(red: 1.0, green: 0.267, blue: 0.0, alpha: 1.0))
    static let colorCheck = Color(CGColor(red: 0, green: 1, blue: 0.082, alpha: 1.0))
    static let colorYellow = Color(CGColor(red: 1.0, green: 0.769, blue: 0, alpha: 1.0))
    static let colorRed = Color(CGColor(red: 1.0, green: 0.267, blue: 0, alpha: 1.0))
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundColor(.white)
            .background(Constants.color)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
