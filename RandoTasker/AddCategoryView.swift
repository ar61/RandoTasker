//
//  AddCategoryView.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 3/3/22.
//

import SwiftUI

struct AddCategoryView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(sortDescriptors: [])
    private var sCategories: FetchedResults<Categories>
    
    @State private var newCategory = ""
    
    var body: some View {
        List {
            ForEach(sCategories, id:\.self) { category in
                Text(category.name!)
            }
            .onMove { IndexSet, offset in
                
            }
            .onDelete { indexSet in 
            }
        }
        TextField("New Category...", text: $newCategory)
            .padding()
            .border(.radialGradient(Gradient(colors: [.yellow, .blue]), center: .top, startRadius: 5, endRadius: 90), width: 2)
        Button {
            let category = Categories(context: managedObjectContext)
            category.name = newCategory
            try? managedObjectContext.save()
        } label: {
            Text("Add")
                .frame(maxWidth: 300, maxHeight: 50)
        }
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView()
    }
}
