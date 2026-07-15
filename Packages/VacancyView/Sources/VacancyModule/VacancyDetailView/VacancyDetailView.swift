//
//  VacancyDetailView.swift
//  VacancyView
//
//  Created by Gabriel Gonçalves Guimarães on 09/07/26.
//

import SwiftUI
import Components
import FirebaseData

public struct VacancyDetailView: View {
    public let job: JobDTO
        
    public init(job: JobDTO) {
        self.job = job
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(job.companyName.prefix(1).uppercased())
                        .robotoFont(.bold, size: 22, color: .white)
                        .frame(width: 56, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(RandomGradient.random())
                        )
                    VStack(alignment: .leading, spacing: 8) {
                        Text(job.title)
                            .robotoFont(.bold, size: 22)
                        Text(job.companyName)
                            .robotoFont(.regular, size: 14, color: .gray)
                    }
                    HStack {
                        if job.remote {
                            Text("📍 \(job.location)")
                                .robotoFont(.regular, size: 11)
                                .padding(.vertical, 7)
                                .padding(.horizontal, 8)
                                .background(Color.white)
                                .cornerRadius(11)
                        }
                        
                        if !job.jobTypes.isEmpty {
                            ForEach(job.jobTypes, id: \.self) { item in
                                Text("👝\(item)")
                                    .robotoFont(.regular, size: 11)
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 8)
                                    .background(Color.white)
                                    .cornerRadius(11)
                            }
                        }
                        
                        if !job.relativeTime.isEmpty {
                            Text("⏱️ \(job.relativeTime)")
                                .robotoFont(.regular, size: 11)
                                .padding(.vertical, 7)
                                .padding(.horizontal, 8)
                                .background(Color.white)
                                .cornerRadius(11)
                            
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TAGS")
                            .robotoFont(.bold, size: 13, color: .secondGray)
                        HStack {
                            ForEach(job.tags, id: \.self) { tag in
                                Text(tag)
                                    .robotoFont(.regular, size: 11)
                                    .padding(.vertical, 3)
                                    .padding(.horizontal, 8)
                                    .background(Color("VacancyDetailView.Background", bundle: .module))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DESCRIÇÃO")
                            .robotoFont(.bold, size: 13, color: .secondGray)
                        Text(job.descriptionStripped)
                            .robotoFont(.regular, size: 14)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    Spacer()
                    ButtonView(
                        typeStyleButton: .backgroundBlue(
                            .init(
                                text: "Apply ➡️",
                                tapGesture: {
                                    Task {
                                        await FirebaseConfig.shared.save(VacancyViewFirebase.tapApply)
                                    }
                                }
                            )
                        )
                    )
                }
                .padding(16)
            }
            .background(Color("VacancyDetailView.Background", bundle: .module))
        }
    }
}
