//
//  LeagueMapping.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

struct LeagueInfo {
  static let names = leagueNames
  static func region(for key: String) -> String { regionFromLeagueKey(key) }
}

private func regionFromLeagueKey(_ key: String) -> String {
    for (region, keywords) in regionKeywords {
        if keywords.contains(where: key.contains) {
            return region
        }
    }
    return "🌐 International"
}

/// Mapping of regions to the list of substrings identifying leagues in that region
private let regionKeywords: [String: [String]] = [
    "🇬🇧 England": ["england", "epl", "fa_cup", "efl_champ", "soccer_england_league1", "soccer_england_league2"],
    "🇩🇰 Denmark": ["denmark"],
    "🇫🇮 Finland": ["finland", "icehockey_liiga"],
    "🇸🇪 Sweden": ["sweden", "icehockey_sweden_allsvenskan", "icehockey_sweden_hockey_league"],
    "🇫🇷 France": ["france"],
    "🇩🇪 Germany": ["germany", "soccer_germany_bundesliga", "soccer_germany_bundesliga2", "soccer_germany_liga3"],
    "🇮🇹 Italy": ["italy", "soccer_italy_serie_a", "soccer_italy_serie_b"],
    "🇪🇸 Spain": ["spain", "soccer_spain_la_liga", "soccer_spain_segunda_division"],
    "🇵🇹 Portugal": ["portugal"],
    "🇳🇱 Netherlands": ["netherlands"],
    "🇦🇹 Austria": ["austria"],
    "🇧🇪 Belgium": ["belgium"],
    "🇨🇭 Switzerland": ["switzerland"],
    "🇳🇴 Norway": ["norway"],
    "🇵🇱 Poland": ["poland"],
    "🇬🇷 Greece": ["greece"],
    "🇮🇪 Ireland": ["ireland"],
    "🏴 Scotland": ["scotland"],
    "🇹🇷 Turkey": ["turkey"],
    "🇧🇷 Brazil": ["brazil", "soccer_brazil_campeonato", "soccer_brazil_serie_b"],
    "🇦🇷 Argentina": ["argentina", "soccer_argentina_primera_division"],
    "🇲🇽 Mexico": ["mexico", "soccer_mexico_ligamx"],
    "🇨🇱 Chile": ["chile", "soccer_chile_campeonato"],
    "🌎 CONMEBOL": ["conmebol", "soccer_conmebol_copa_libertadores", "soccer_conmebol_copa_sudamericana"],
    "🇯🇵 Japan": ["japan", "soccer_japan_j_league"],
    "🇰🇷 South Korea": ["korea", "soccer_korea_kleague1"],
    "🇨🇳 China": ["china", "soccer_china_superleague"],
    "🇺🇸 USA": ["usa", "nba", "ahl", "nhl", "soccer_usa_mls"],
    "🇦🇺 Australia": ["australia", "soccer_australia_aleague"],
    "🇮🇳 India": ["cricket_ipl"],
    "🇵🇰 Pakistan": ["cricket_psl"]
]

private let leagueNames: [String: String] = [
    "soccer_argentina_primera_division": "Argentina Primera Division",
    "soccer_australia_aleague": "Australia A-League",
    "soccer_austria_bundesliga": "Austria Bundesliga",
    "soccer_belgium_first_div": "Belgium First Division",
    "soccer_brazil_campeonato": "Brazil Campeonato",
    "soccer_brazil_serie_b": "Brazil Serie B",
    "soccer_chile_campeonato": "Chile Campeonato",
    "soccer_china_superleague": "China Super League",
    "soccer_conmebol_copa_libertadores": "CONMEBOL Copa Libertadores",
    "soccer_conmebol_copa_sudamericana": "CONMEBOL Copa Sudamericana",
    "soccer_denmark_superliga": "Denmark Superliga",
    "soccer_efl_champ": "EFL Championship",
    "soccer_england_league1": "England League One",
    "soccer_england_league2": "England League Two",
    "soccer_epl": "English Premier League",
    "soccer_fa_cup": "FA Cup",
    "soccer_finland_veikkausliiga": "Finland Veikkausliiga",
    "soccer_france_ligue_one": "France Ligue 1",
    "soccer_france_ligue_two": "France Ligue 2",
    "soccer_germany_bundesliga": "Germany Bundesliga",
    "soccer_germany_bundesliga2": "Germany Bundesliga 2",
    "soccer_germany_liga3": "Germany Liga 3",
    "soccer_greece_super_league": "Greece Super League",
    "soccer_italy_serie_a": "Italy Serie A",
    "soccer_italy_serie_b": "Italy Serie B",
    "soccer_japan_j_league": "Japan J-League",
    "soccer_korea_kleague1": "Korea K-League 1",
    "soccer_league_of_ireland": "League of Ireland",
    "soccer_mexico_ligamx": "Mexico Liga MX",
    "soccer_netherlands_eredivisie": "Netherlands Eredivisie",
    "soccer_norway_eliteserien": "Norway Eliteserien",
    "soccer_poland_ekstraklasa": "Poland Ekstraklasa",
    "soccer_portugal_primeira_liga": "Portugal Primeira Liga",
    "soccer_spain_la_liga": "La Liga",
    "soccer_spain_segunda_division": "Spain Segunda Division",
    "soccer_sweden_allsvenskan": "Sweden Allsvenskan",
    "soccer_sweden_superettan": "Sweden Superettan",
    "soccer_switzerland_superleague": "Switzerland Super League",
    "soccer_turkey_super_league": "Turkey Super League",
    "soccer_uefa_champs_league": "UEFA Champions League",
    "soccer_uefa_champs_league_women": "UEFA Champions League Women",
    "soccer_uefa_europa_conference_league": "UEFA Europa Conference League",
    "soccer_uefa_europa_league": "UEFA Europa League",
    "soccer_uefa_nations_league": "UEFA Nations League",
    "soccer_usa_mls": "USA Major League Soccer",
    "basketball_euroleague":"Basketball Euroleague",
    "basketball_nba":"NBA",
    "basketball_nba_championship_winner":"NBA Championship Winner",
    "icehockey_ahl": "American Hockey League",
    "icehockey_liiga": "Finnish SM League",
    "icehockey_nhl": "US Ice Hockey",
    "icehockey_nhl_championship_winner": "NHL Championship Winner",
    "icehockey_sweden_allsvenskan": "HockeyAllsvenskan",
    "icehockey_sweden_hockey_league": "SHL",
    "cricket_international_t20": "International Twenty20",
    "cricket_ipl": "Indian Premier League",
    "cricket_psl": "Pakistan Super League",
    "cricket_test_match": "Test Matches"
]
