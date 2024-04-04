//
//  TaskRowView.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/24/22.
//

import SwiftUI

struct TaskRowView: View {
    var taskText: String
    var consecutive: Int32
    var total: Int32
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                CustomText(taskText)
                    .font(.headline)
            }
            Spacer()
            Text("\(consecutive)")
                .font(.caption)
                .fontWeight(.black)
                .padding(5)
                .background(Constants.colorYellow)
                .clipShape(Rectangle())
                .foregroundColor(.white)
            
            Text("\(total)")
                .font(.caption)
                .fontWeight(.black)
                .padding(5)
                .background(Constants.colorRed)
                .clipShape(Circle())
                .foregroundColor(.white)
        }
    }
}

struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        TaskRowView(taskText: "", consecutive: 0, total: 0)
    }
}
