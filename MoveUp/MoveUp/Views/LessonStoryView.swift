//
//  LessonStoryView.swift
//  MoveUp
//
//  Created by MoveUp Team on 14/10/2025.
//  Post-lesson story generator - VIRAL MACHINE
//

import SwiftUI

struct LessonStoryView: View {
    let storyData: StoryData
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            // Background image con gradient overlay
            if let bgImage = storyData.template.backgroundImage {
                Image(bgImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .blur(radius: 3)
            }
            
            // Color overlay
            Color(hex: storyData.template.primaryColor)
                .opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                }
                .padding()
                
                Spacer()
                
                // Story content
                VStack(spacing: 30) {
                    // Badge/Achievement
                    Text(storyData.badge)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Sport icon
                    if let iconImage = storyData.template.iconImage {
                        Image(iconImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    
                    // Sport name
                    Text(storyData.sport.uppercased())
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    // Trainer info
                    VStack(spacing: 8) {
                        Text("Con")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 8) {
                            Text(storyData.trainerName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", storyData.trainerRating))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // Motivational text
                    Text(storyData.motivationalText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Points earned
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("+\(storyData.pointsEarned) PUNTI")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Totale: \(storyData.userTotalPoints) pts • Lv. \(storyData.userLevel)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                }
                
                Spacer()
                
                // CTA
                VStack(spacing: 16) {
                    Text(storyData.cta)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // MoveUp branding
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("MoveUp")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                    }
                    
                    // Hashtags
                    Text(storyData.hashtags.joined(separator: " "))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 4)
                }
                .padding(.bottom, 40)
                
                // Share button
                Button(action: { showShareSheet = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Condividi Storia")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color(hex: storyData.template.primaryColor))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [generateShareImage()])
        }
    }
    
    // Genera immagine per condivisione
    private func generateShareImage() -> UIImage {
        // TODO: Generate actual story image with UIGraphicsImageRenderer
        // For now return placeholder
        return UIImage(systemName: "photo")!
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Data Models
struct StoryData: Codable {
    let template: StoryTemplate
    let sport: String
    let trainerName: String
    let trainerRating: Double
    let pointsEarned: Int
    let badge: String
    let motivationalText: String
    let cta: String
    let hashtags: [String]
    let lessonDate: String
    let userLevel: Int
    let userTotalPoints: Int
}

struct StoryTemplate: Codable {
    let backgroundImage: String?
    let primaryColor: String
    let textColor: String
    let iconImage: String?
}

// MARK: - Preview
struct LessonStoryView_Previews: PreviewProvider {
    static var previews: some View {
        LessonStoryView(
            storyData: StoryData(
                template: StoryTemplate(
                    backgroundImage: "tennis_story_bg",
                    primaryColor: "#00B894",
                    textColor: "#FFFFFF",
                    iconImage: "tennis_icon"
                ),
                sport: "Tennis",
                trainerName: "Marco Bianchi",
                trainerRating: 4.8,
                pointsEarned: 70,
                badge: "🔥 5 Lezioni Completate!",
                motivationalText: "Il tuo gioco migliora ad ogni sessione! 🎾",
                cta: "Prenota anche tu su MoveUp! 🚀",
                hashtags: ["#MoveUp", "#Tennis", "#Sport", "#TennisLife"],
                lessonDate: "14 Oct 2025",
                userLevel: 2,
                userTotalPoints: 250
            )
        )
    }
}
