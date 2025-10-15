import SwiftUI
import MapKit
import CoreLocation

// MARK: - Map Pin Models
struct InstructorMapPin: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let sport: String
    let rating: Double
}

struct EventMapPin: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
    let sport: String
    let date: Date
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964), // Roma default
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Raggio di ricerca in metri
    @State private var searchRadius: Double = 2000 // 2km default
    
    // Pins da visualizzare
    @State private var instructorPins: [InstructorMapPin] = []
    @State private var eventPins: [EventMapPin] = []
    
    // Filtro visualizzazione
    @State private var showInstructors = true
    @State private var showEvents = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sfondo
                Color.moveUpBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("🗺️ Esplora")
                            .font(MoveUpFont.title(28))
                            .fontWeight(.bold)
                            .foregroundColor(.moveUpTextPrimary)
                        
                        Spacer()
                        
                        // Location button
                        Button(action: {
                            if let userLocation = locationManager.userLocation {
                                updateRegion(for: userLocation)
                            } else {
                                locationManager.requestLocationPermission()
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .font(.title3)
                                .foregroundColor(.moveUpPrimary)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .cornerRadius(22)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .background(Color.moveUpBackground)
                    
                    // Filtri
                    HStack(spacing: 12) {
                        FilterToggleButton(
                            isActive: $showInstructors,
                            icon: "person.fill",
                            label: "Istruttori",
                            color: .moveUpPrimary
                        )
                        
                        FilterToggleButton(
                            isActive: $showEvents,
                            icon: "figure.run",
                            label: "Eventi",
                            color: .moveUpAccent1
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    
                    // Mappa
                    MapWithPins(
                        region: $region,
                        searchRadius: searchRadius,
                        instructorPins: showInstructors ? instructorPins : [],
                        eventPins: showEvents ? eventPins : []
                    )
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    // Controllo raggio
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "map.circle.fill")
                                .foregroundColor(.moveUpPrimary)
                            
                            Text("Raggio: \(Int(searchRadius/1000)) km")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(.moveUpTextPrimary)
                            
                            Spacer()
                        }
                        
                        Slider(value: $searchRadius, in: 500...10000, step: 500)
                            .accentColor(.moveUpPrimary)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // Stats
                    HStack(spacing: 24) {
                        if showInstructors {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.moveUpPrimary)
                                Text("\(instructorPins.count) istruttori")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(.moveUpTextSecondary)
                            }
                        }
                        
                        if showEvents {
                            HStack(spacing: 8) {
                                Image(systemName: "figure.run")
                                    .foregroundColor(.moveUpAccent1)
                                Text("\(eventPins.count) eventi")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(.moveUpTextSecondary)
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            locationManager.requestLocationPermission()
            updateRegionForUserLocation()
            loadNearbyPins()
        }
        .onChange(of: locationManager.userLocation) { location in
            if let location = location {
                updateRegion(for: location)
                loadNearbyPins()
            }
        }
        .onChange(of: searchRadius) { _ in
            loadNearbyPins()
        }
    }
    
    private func updateRegionForUserLocation() {
        if let userLocation = locationManager.userLocation {
            updateRegion(for: userLocation)
        }
    }
    
    private func updateRegion(for location: CLLocation) {
        let span = MKCoordinateSpan(
            latitudeDelta: searchRadius / 111320.0 * 2, // Conversione metri -> gradi
            longitudeDelta: searchRadius / 111320.0 * 2
        )
        
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: span
        )
    }
    
    // Carica pins nelle vicinanze (dati mock per ora)
    private func loadNearbyPins() {
        guard let userLocation = locationManager.userLocation else { return }
        
        // Mock data - In produzione, questi verrebbero dal backend filtrati per raggio
        instructorPins = [
            InstructorMapPin(
                name: "Marco Trainer",
                coordinate: offsetCoordinate(from: userLocation.coordinate, meters: 500, bearing: 45),
                sport: "Tennis",
                rating: 4.8
            ),
            InstructorMapPin(
                name: "Laura Fitness",
                coordinate: offsetCoordinate(from: userLocation.coordinate, meters: 1200, bearing: 120),
                sport: "Yoga",
                rating: 4.9
            ),
            InstructorMapPin(
                name: "Giovanni Runner",
                coordinate: offsetCoordinate(from: userLocation.coordinate, meters: 1800, bearing: 200),
                sport: "Running",
                rating: 4.7
            )
        ]
        
        eventPins = [
            EventMapPin(
                title: "Lezione di Tennis",
                coordinate: offsetCoordinate(from: userLocation.coordinate, meters: 800, bearing: 90),
                sport: "Tennis",
                date: Date().addingTimeInterval(86400)
            ),
            EventMapPin(
                title: "Yoga al Parco",
                coordinate: offsetCoordinate(from: userLocation.coordinate, meters: 1500, bearing: 270),
                sport: "Yoga",
                date: Date().addingTimeInterval(172800)
            )
        ]
    }
    
    // Helper per calcolare coordinate offset
    private func offsetCoordinate(from coord: CLLocationCoordinate2D, meters: Double, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6371000.0 // meters
        let bearingRad = bearing * .pi / 180
        let latRad = coord.latitude * .pi / 180
        let lonRad = coord.longitude * .pi / 180
        
        let newLatRad = asin(sin(latRad) * cos(meters / earthRadius) +
                            cos(latRad) * sin(meters / earthRadius) * cos(bearingRad))
        
        let newLonRad = lonRad + atan2(sin(bearingRad) * sin(meters / earthRadius) * cos(latRad),
                                       cos(meters / earthRadius) - sin(latRad) * sin(newLatRad))
        
        return CLLocationCoordinate2D(
            latitude: newLatRad * 180 / .pi,
            longitude: newLonRad * 180 / .pi
        )
    }
}

// MARK: - Header Section
struct MapHeaderSection: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mappa")
                    .font(.largeTitle.bold())
                    .foregroundColor(.moveUpPrimary)
                
                Text("Trova istruttori ed eventi vicini")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Filter Toggle Button
struct FilterToggleButton: View {
    @Binding var isActive: Bool
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isActive.toggle()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body)
                Text(label)
                    .font(MoveUpFont.body())
                    .fontWeight(.medium)
            }
            .foregroundColor(isActive ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(isActive ? color : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Radius Selector
struct RadiusSelector: View {
    @Binding var radius: Double
    
    let radiusOptions: [Double] = [500, 1000, 2000, 5000, 10000]
    let radiusLabels: [String] = ["500m", "1km", "2km", "5km", "10km"]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Raggio di ricerca")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(formatRadius(radius))
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.moveUpPrimary)
            }
            
            // Slider personalizzato
            HStack(spacing: 8) {
                ForEach(0..<radiusOptions.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            radius = radiusOptions[index]
                        }
                    }) {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(radius == radiusOptions[index] ? 
                                      Color.moveUpPrimary : 
                                      Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                            
                            Text(radiusLabels[index])
                                .font(.caption2)
                                .foregroundColor(radius == radiusOptions[index] ? .moveUpPrimary : .secondary)
                        }
                    }
                    
                    if index < radiusOptions.count - 1 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatRadius(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.0f km", meters / 1000)
        } else {
            return "\(Int(meters)) m"
        }
    }
}

// MARK: - Map with Pins
struct MapWithPins: View {
    @Binding var region: MKCoordinateRegion
    let searchRadius: Double
    let instructorPins: [InstructorMapPin]
    let eventPins: [EventMapPin]
    
    var body: some View {
        Map(coordinateRegion: $region, 
            interactionModes: .all,
            showsUserLocation: true,
            annotationItems: instructorPins) { pin in
            MapAnnotation(coordinate: pin.coordinate) {
                InstructorPinView(pin: pin)
            }
        }
        .overlay(
            // Cerchio del raggio di ricerca
            GeometryReader { geometry in
                Circle()
                    .stroke(Color.moveUpPrimary.opacity(0.3), lineWidth: 2)
                    .background(Circle().fill(Color.moveUpPrimary.opacity(0.05)))
                    .frame(width: radiusToPixels(searchRadius, in: geometry.size))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        )
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func radiusToPixels(_ meters: Double, in size: CGSize) -> CGFloat {
        // Conversione approssimativa - in produzione usare calcoli più precisi
        let metersPerDegree = 111320.0
        let degreesForRadius = meters / metersPerDegree
        let pixelsPerDegree = size.width / CGFloat(region.span.longitudeDelta)
        return CGFloat(degreesForRadius) * pixelsPerDegree * 2
    }
}

// MARK: - Instructor Pin View
struct InstructorPinView: View {
    let pin: InstructorMapPin
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail.toggle()
        }) {
            ZStack {
                Circle()
                    .fill(Color.moveUpPrimary)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
        }
        .popover(isPresented: $showDetail) {
            VStack(alignment: .leading, spacing: 8) {
                Text(pin.name)
                    .font(.headline)
                Text(pin.sport)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.moveUpGamification)
                    Text(String(format: "%.1f", pin.rating))
                        .font(.subheadline)
                }
            }
            .padding()
        }
    }
}

// MARK: - Map Stats Section
struct MapStatsSection: View {
    let instructorCount: Int
    let eventCount: Int
    let radius: Double
    
    var body: some View {
        HStack(spacing: 12) {
            MapStatCard(
                icon: "person.fill",
                value: "\(instructorCount)",
                label: "Istruttori",
                color: .moveUpPrimary
            )
            
            MapStatCard(
                icon: "figure.run",
                value: "\(eventCount)",
                label: "Eventi",
                color: .moveUpAccent1
            )
            
            MapStatCard(
                icon: "location.circle.fill",
                value: formatRadius(radius),
                label: "Raggio",
                color: .moveUpSecondary
            )
        }
    }
    
    private func formatRadius(_ meters: Double) -> String {
        if meters >= 1000 {
            return "\(Int(meters / 1000))km"
        } else {
            return "\(Int(meters))m"
        }
    }
}

// MARK: - Map Stat Card
struct MapStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    MapView()
}