import SwiftUI

struct InstructorProfileView: View {
    let instructor: Instructor
    @Environment(\.dismiss) private var dismiss
    @State private var showContact = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.moveUpPrimary)
                            .frame(width: 120, height: 120)
                        
                        Text("MT")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Name and Title
                    VStack(spacing: 8) {
                        Text("Marco Trainer")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Istruttore Certificato")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        // Rating and Stats
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.orange)
                                    Text("\(instructor.rating, specifier: "%.1f")")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                Text("Rating")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(instructor.totalLessons)")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Lezioni")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(instructor.specializations.count)")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Sport")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.top, 20)
                
                // Specializations
                VStack(alignment: .leading, spacing: 12) {
                    Text("Specializzazioni")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(instructor.specializations, id: \.self) { sport in
                            HStack(spacing: 8) {
                                Image(systemName: sport.iconName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.moveUpPrimary)
                                
                                Text(sport.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Bio Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Biografia")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(instructor.bio)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Certifications (Mock)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Certificazioni")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 8) {
                        CertificationRow(
                            icon: "checkmark.seal.fill",
                            title: "Certificazione FIT",
                            subtitle: "Federazione Italiana Tennis",
                            color: .green
                        )
                        
                        CertificationRow(
                            icon: "checkmark.seal.fill", 
                            title: "Personal Trainer",
                            subtitle: "CONI - Livello 2",
                            color: .blue
                        )
                        
                        CertificationRow(
                            icon: "checkmark.seal.fill",
                            title: "Primo Soccorso",
                            subtitle: "Croce Rossa Italiana",
                            color: .red
                        )
                    }
                }
                
                // Contact Button
                Button(action: {
                    showContact = true
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Contatta Istruttore")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.moveUpPrimary)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .cornerRadius(12)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Profilo Istruttore")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showContact) {
            ContactInstructorView(instructor: instructor)
        }
    }
}

struct CertificationRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct InstructorProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InstructorProfileView(instructor: Instructor.sampleInstructor)
        }
    }
}