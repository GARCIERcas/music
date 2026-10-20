import SwiftUI
import UIKit

@main
struct SonicApp: App {
    var body: some Scene {
        WindowGroup {
            MusicHomeView()
                .preferredColorScheme(.dark)
        }
    }
}

struct Track: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    let album: String
    let symbol: String
    let colors: [Color]
    let duration: String

    static let library: [Track] = [
        .init(title: "Midnight City", artist: "M83", album: "Hurry Up, We're Dreaming",
              symbol: "building.2.crop.circle", colors: [.purple, .blue], duration: "4:03"),
        .init(title: "The Less I Know", artist: "Tame Impala", album: "Currents",
              symbol: "waveform", colors: [.pink, .orange], duration: "3:36"),
        .init(title: "After Dark", artist: "Mr.Kitty", album: "Time",
              symbol: "moon.stars.fill", colors: [.indigo, .black], duration: "4:17"),
        .init(title: "505", artist: "Arctic Monkeys", album: "Favourite Worst Nightmare",
              symbol: "sparkles", colors: [.cyan, .blue], duration: "4:13"),
        .init(title: "Space Song", artist: "Beach House", album: "Depression Cherry",
              symbol: "planet.fill", colors: [.red, .purple], duration: "5:20"),
        .init(title: "Sunset Lover", artist: "Petit Biscuit", album: "Presence",
              symbol: "sunset.fill", colors: [.orange, .pink], duration: "3:57")
    ]
}

struct MusicHomeView: View {
    @State private var selectedTrack = Track.library[0]
    @State private var isPlaying = false
    @State private var isLiked = false
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var progress = 0.32
    @State private var showPlayer = false

    private var filteredTracks: [Track] {
        guard !searchText.isEmpty else { return Track.library }
        return Track.library.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.artist.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            background
            TabView(selection: $selectedTab) {
                homeTab
                    .tabItem { Label("Слушать", systemImage: "house.fill") }
                    .tag(0)
                searchTab
                    .tabItem { Label("Поиск", systemImage: "magnifyingglass") }
                    .tag(1)
                libraryTab
                    .tabItem { Label("Медиатека", systemImage: "square.stack.fill") }
                    .tag(2)
            }
            .tint(.white)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                miniPlayer
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPlayer) {
            NowPlayingView(track: selectedTrack, isPlaying: $isPlaying, isLiked: $isLiked, progress: $progress)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }

    private var background: some View {
        ZStack {
            Color(red: 0.035, green: 0.04, blue: 0.09)
            RadialGradient(colors: [.purple.opacity(0.34), .clear],
                           center: .topTrailing, startRadius: 10, endRadius: 430)
            RadialGradient(colors: [.blue.opacity(0.22), .clear],
                           center: .bottomLeading, startRadius: 0, endRadius: 360)
        }
        .ignoresSafeArea()
    }

    private var homeTab: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    greeting
                    featuredCard
                    sectionHeader("Недавно слушали", action: "Все")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(Array(Track.library.prefix(4))) { track in
                                Button { play(track) } label: {
                                    VStack(alignment: .leading, spacing: 9) {
                                        AlbumArtwork(track: track, size: 142)
                                        Text(track.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                        Text(track.artist)
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.58))
                                            .lineLimit(1)
                                    }
                                    .frame(width: 142, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    sectionHeader("Для твоего настроения", action: "Миксы")
                    VStack(spacing: 10) {
                        ForEach(Track.library.suffix(3)) { track in
                            trackRow(track)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)
                .padding(.bottom, 18)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(1.6)
                        .foregroundStyle(.white.opacity(0.5))
                    Text("Твоя музыка.")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .tracking(-1.1)
                }
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 36))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .white.opacity(0.22))
                    .padding(5)
                    .glassEffect(.regular, in: Circle())
            }
        }
        .padding(.horizontal, 20)
    }

    private var featuredCard: some View {
        Button { play(Track.library[0]) } label: {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: [.purple, .indigo, Color(red: 0.08, green: 0.12, blue: 0.3)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle()
                    .fill(.white.opacity(0.13))
                    .frame(width: 210, height: 210)
                    .blur(radius: 1)
                    .offset(x: 175, y: -80)
                Image(systemName: "waveform.path")
                    .font(.system(size: 115, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.7))
                    .rotationEffect(.degrees(-12))
                    .offset(x: 185, y: -35)
                VStack(alignment: .leading, spacing: 10) {
                    Text("ПЛЕЙЛИСТ ДНЯ")
                        .font(.caption2.weight(.heavy))
                        .tracking(1.8)
                        .foregroundStyle(.white.opacity(0.76))
                    Text("Ночной\nвайб")
                        .font(.system(size: 31, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.leading)
                    Text("Мягкие биты для поздних часов")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Слушать")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 17)
                    .padding(.vertical, 11)
                    .background(.white, in: Capsule())
                    .padding(.top, 5)
                }
                .padding(22)
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            }
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    private var searchTab: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Поиск")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.white.opacity(0.6))
                        TextField("Треки, исполнители", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(15)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.08)))
                    Text(searchText.isEmpty ? "Популярное сейчас" : "Результаты")
                        .font(.title3.bold())
                        .padding(.top, 4)
                    ForEach(filteredTracks) { track in trackRow(track) }
                }
                .padding(20)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var libraryTab: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Медиатека")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    HStack(spacing: 14) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundStyle(.pink)
                            .frame(width: 58, height: 58)
                            .background(.pink.opacity(0.16), in: RoundedRectangle(cornerRadius: 16))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Любимые треки").font(.headline)
                            Text(isLiked ? "Добавлен текущий трек" : "Твои музыкальные открытия")
                                .font(.caption).foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(14)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22))
                    sectionHeader("Все треки", action: "\(Track.library.count)")
                    ForEach(Track.library) { track in trackRow(track) }
                }
                .padding(20)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var miniPlayer: some View {
        HStack(spacing: 12) {
            AlbumArtwork(track: selectedTrack, size: 46)
            VStack(alignment: .leading, spacing: 3) {
                Text(selectedTrack.title).font(.subheadline.weight(.semibold)).lineLimit(1)
                Text(selectedTrack.artist).font(.caption).foregroundStyle(.white.opacity(0.62)).lineLimit(1)
            }
            Spacer(minLength: 4)
            Button { isPlaying.toggle() } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3.weight(.semibold))
                    .frame(width: 38, height: 42)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            Button { playNext() } label: {
                Image(systemName: "forward.end.fill").font(.title3)
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.white)
        .padding(9)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 21, style: .continuous))
        .overlay(alignment: .bottomLeading) {
            GeometryReader { proxy in
                Capsule().fill(.white.opacity(0.85))
                    .frame(width: proxy.size.width * progress, height: 2)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .clipShape(RoundedRectangle(cornerRadius: 21))
            .padding(.horizontal, 12)
            .padding(.bottom, 1)
        }
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 21, style: .continuous))
        .onTapGesture { showPlayer = true }
    }

    private func sectionHeader(_ title: String, action: String) -> some View {
        HStack {
            Text(title).font(.title2.bold())
            Spacer()
            Text(action).font(.subheadline.weight(.medium)).foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 20)
    }

    private func trackRow(_ track: Track) -> some View {
        Button { play(track) } label: {
            HStack(spacing: 13) {
                AlbumArtwork(track: track, size: 54)
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                    Text(track.artist).font(.caption).foregroundStyle(.white.opacity(0.58))
                }
                Spacer()
                Text(track.duration).font(.caption.monospacedDigit()).foregroundStyle(.white.opacity(0.4))
                Image(systemName: "ellipsis").font(.title3).foregroundStyle(.white.opacity(0.65))
                    .padding(.leading, 3)
            }
            .padding(9)
            .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private func play(_ track: Track) {
        selectedTrack = track
        isPlaying = true
        showPlayer = true
    }

    private func playNext() {
        let tracks = Track.library
        let index = tracks.firstIndex(of: selectedTrack) ?? 0
        selectedTrack = tracks[(index + 1) % tracks.count]
        isPlaying = true
        progress = 0
    }
}

struct AlbumArtwork: View {
    let track: Track
    let size: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(colors: track.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().stroke(.white.opacity(0.25), lineWidth: 1)
                .frame(width: size * 0.76, height: size * 0.76)
                .offset(x: size * 0.2, y: -size * 0.18)
            Circle().fill(.white.opacity(0.13))
                .frame(width: size * 0.62, height: size * 0.62)
                .blur(radius: 2)
                .offset(x: -size * 0.2, y: size * 0.2)
            Image(systemName: track.symbol)
                .font(.system(size: size * 0.34, weight: .light))
                .foregroundStyle(.white.opacity(0.95))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.19, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: size * 0.19).stroke(.white.opacity(0.12), lineWidth: 1))
    }
}

struct NowPlayingView: View {
    let track: Track
    @Binding var isPlaying: Bool
    @Binding var isLiked: Bool
    @Binding var progress: Double
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(colors: [track.colors[0].opacity(0.55), Color.black, Color.black],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: { Image(systemName: "chevron.down").font(.title3.bold()) }
                    Spacer()
                    VStack(spacing: 3) {
                        Text("СЕЙЧАС ИГРАЕТ").font(.caption2.weight(.bold)).tracking(1.6)
                        Text("Из твоей медиатеки").font(.caption).foregroundStyle(.white.opacity(0.55))
                    }
                    Spacer()
                    Image(systemName: "ellipsis").font(.title3)
                }
                .buttonStyle(.plain)
                .padding(.top, 24)
                .padding(.bottom, 34)

                AlbumArtwork(track: track, size:  min(UIScreen.main.bounds.width - 56, 340))
                    .shadow(color: track.colors[0].opacity(0.35), radius: 35, y: 18)
                    .padding(.bottom, 35)

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(track.title).font(.system(size: 27, weight: .bold, design: .rounded)).lineLimit(1)
                        Text(track.artist).font(.title3).foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Button { isLiked.toggle() } label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(isLiked ? .pink : .white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 28)

                VStack(spacing: 8) {
                    Slider(value: $progress, in: 0...1)
                        .tint(.white)
                    HStack {
                        Text(progress.formatted(.percent.precision(.fractionLength(0))))
                        Spacer()
                        Text(track.duration)
                    }
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.bottom, 24)

                HStack(spacing: 36) {
                    Button {} label: { Image(systemName: "shuffle").font(.title3) }
                    Button {} label: { Image(systemName: "backward.end.fill").font(.title2) }
                    Button { isPlaying.toggle() } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 76, height: 76)
                            .background(.white, in: Circle())
                            .contentTransition(.symbolEffect(.replace))
                    }
                    Button {} label: { Image(systemName: "forward.end.fill").font(.title2) }
                    Button {} label: { Image(systemName: "repeat").font(.title3) }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 32)
                HStack {
                    Image(systemName: "hifispeaker")
                    Spacer()
                    Image(systemName: "list.bullet")
                }
                .font(.title3)
                .foregroundStyle(.white.opacity(0.65))
                Spacer(minLength: 20)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
        }
    }
}
