import Foundation
import SwiftUI

class SessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
}

final class OrwejaService {
    private let baseUrl = "https://www.orweja.nl"
    private let urls = [
        "http://www.orweja.nl/agenda/",
        "http://orweja.nl/agenda/",
        "https://orweja.nl/agenda/",
        "https://www.orweja.nl/agenda/"
    ]
    
    enum OrwejaError: LocalizedError {
        case networkError(String)
        case parsingError
        case invalidURL
        case serverError(Int)
        case noInternetConnection
        case allSourcesFailed
        
        var errorDescription: String? {
            switch self {
            case .networkError(let message):
                return "Netwerkfout: \(message)"
            case .parsingError:
                return "Kon de wedstrijdgegevens niet verwerken"
            case .invalidURL:
                return "Ongeldige URL"
            case .serverError(let code):
                return "Server fout: \(code)"
            case .noInternetConnection:
                return "Geen internetverbinding"
            case .allSourcesFailed:
                return "Kon geen verbinding maken met Orweja"
            }
        }
    }
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpMaximumConnectionsPerHost = 1
        
        config.httpAdditionalHeaders = [
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "nl-NL,nl;q=0.9",
            "Accept-Encoding": "gzip, deflate",
            "Connection": "keep-alive",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15"
        ]
        
        let delegate = SessionDelegate()
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }()
    
    func fetchMatches() async throws -> [Match] {
        var allMatches: Set<Match> = []
        var lastError: Error?
        
        for url in urls {
            do {
                let matches = try await fetchFromURL(url)
                allMatches.formUnion(matches)
                if !allMatches.isEmpty {
                    return Array(allMatches).sorted { $0.matchDate < $1.matchDate }
                }
            } catch {
                print("Error fetching from \(url): \(error.localizedDescription)")
                lastError = error
            }
        }
        
        throw lastError ?? OrwejaError.allSourcesFailed
    }
    
    private func fetchFromURL(_ urlString: String) async throws -> Set<Match> {
        guard let url = URL(string: urlString) else {
            throw OrwejaError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OrwejaError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OrwejaError.serverError(httpResponse.statusCode)
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw OrwejaError.parsingError
        }
        
        return try parseMatches(from: html)
    }
    
    private func parseMatches(from html: String) throws -> Set<Match> {
        let document = try SwiftSoup.parse(html)
        var matches: Set<Match> = []
        
        let matchElements = try document.select("tr")
        
        for element in matchElements {
            if let match = try? parseMatch(element) {
                matches.insert(match)
            }
        }
        
        return matches
    }
    
    private func parseMatch(_ element: SwiftSoup.Element) throws -> Match? {
        let columns = try element.select("td")
        guard columns.count >= 6 else { return nil }
        
        let dateText = try columns[0].text()
        let title = try columns[1].text()
        let location = try columns[2].text()
        let organizingClub = try columns[3].text()
        let statusText = try columns[4].text()
        
        // Parse date
        guard let matchDate = Constants.DateFormatters.defaultFormatter.date(from: dateText) else { return nil }
        
        // Extract time if present
        var startTime: String?
        if dateText.contains(":") {
            startTime = dateText.components(separatedBy: " ").last
        }
        
        // Determine match type
        let type = determineMatchType(from: title)
        
        // Calculate enrollment dates based on match date
        let enrollmentStartDate = Constants.Calendar.current.date(
            byAdding: .day,
            value: -Constants.Enrollment.defaultStartDaysBeforeMatch,
            to: matchDate
        )
        let enrollmentEndDate = Constants.Calendar.current.date(
            byAdding: .day,
            value: -Constants.Enrollment.defaultEndDaysBeforeMatch,
            to: matchDate
        )
        
        return Match(
            id: UUID().uuidString,
            title: title,
            type: type,
            location: location,
            address: "", // Not available in table view
            startTime: startTime,
            matchDate: matchDate,
            description: "", // Not available in table view
            enrollmentStartDate: enrollmentStartDate,
            enrollmentEndDate: enrollmentEndDate,
            maxParticipants: 0,
            currentParticipants: 0,
            additionalInfo: nil,
            requirements: nil,
            price: nil,
            organizingClub: organizingClub,
            coOrganizer: nil,
            latitude: nil,
            longitude: nil
        )
    }
    
    private func determineMatchType(from title: String) -> MatchType {
        let text = title.uppercased()
        
        if text.contains("VELDPROEF") { return .veldproef }
        if text.contains("WORKING TEST") || text.contains("WORKINGTEST") { return .workingTest }
        if text.contains("JEUGDPROEF") { return .jeugdproef }
        if text.contains("MAP") { return .map }
        if text.contains("SJP") { return .sjp }
        
        if text.contains("PROEF") { return .sjp }
        return .veldproef
    }
}
