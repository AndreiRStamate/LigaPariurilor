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
    "🇬🇧 England": [
        "england",
        "epl",
        "fa_cup",
        "efl_champ",
        "soccer_england_efl_cup",
        "soccer_england_league1",
        "soccer_england_league2"
    ],
    "🏴 Scotland": [
        "soccer_spl"
    ],
    "🇩🇰 Denmark": [
        "soccer_denmark_superliga"
    ],
    "🇫🇮 Finland": [
        "soccer_finland_veikkausliiga"
    ],
    "🇸🇪 Sweden": [
        "soccer_sweden_allsvenskan",
        "soccer_sweden_superettan"
    ],
    "🇫🇷 France": [
        "soccer_france_ligue_one",
        "soccer_france_ligue_two"
    ],
    "🇩🇪 Germany": [
        "soccer_germany_bundesliga",
        "soccer_germany_bundesliga2",
        "soccer_germany_liga3"
    ],
    "🇮🇹 Italy": [
        "soccer_italy_serie_a",
        "soccer_italy_serie_b"
    ],
    "🇪🇸 Spain": [
        "soccer_spain_la_liga",
        "soccer_spain_segunda_division"
    ],
    "🇵🇹 Portugal": [
        "soccer_portugal_primeira_liga"
    ],
    "🇳🇱 Netherlands": [
        "soccer_netherlands_eredivisie"
    ],
    "🇦🇹 Austria": [
        "soccer_austria_bundesliga"
    ],
    "🇧🇪 Belgium": [
        "soccer_belgium_first_div"
    ],
    "🇨🇭 Switzerland": [
        "soccer_switzerland_superleague"
    ],
    "🇳🇴 Norway": [
        "soccer_norway_eliteserien"
    ],
    "🇵🇱 Poland": [
        "soccer_poland_ekstraklasa"
    ],
    "🇬🇷 Greece": [
        "soccer_greece_super_league"
    ],
    "🇮🇪 Ireland": [
        "soccer_league_of_ireland"
    ],
    "🇹🇷 Turkey": [
        "soccer_turkey_super_league"
    ],
    "🇧🇷 Brazil": [
        "soccer_brazil_campeonato",
        "soccer_brazil_serie_b"
    ],
    "🇦🇷 Argentina": [
        "soccer_argentina_primera_division"
    ],
    "🇲🇽 Mexico": [
        "soccer_mexico_ligamx"
    ],
    "🇨🇱 Chile": [
        "soccer_chile_campeonato"
    ],
    "🌎 CONMEBOL": [
        "soccer_conmebol_copa_libertadores",
        "soccer_conmebol_copa_sudamericana"
    ],
    "🇯🇵 Japan": [
        "soccer_japan_j_league"
    ],
    "🇰🇷 South Korea": [
        "soccer_korea_kleague1"
    ],
    "🇨🇳 China": [
        "soccer_china_superleague"
    ],
    "🇺🇸 USA": [
        "soccer_usa_mls",
        "basketball_nba"
    ],
    "🇦🇺 Australia": [
        "soccer_australia_aleague",
        "basketball_nbl"
    ],
    "🌍 Africa": [
        "soccer_africa_cup_of_nations"
    ],
    "🌐 International": [
        "soccer_fifa_world_cup",
        "soccer_fifa_world_cup_qualifiers_europe",
        "soccer_fifa_world_cup_winner",
        "soccer_uefa_champs_league",
        "soccer_uefa_champs_league_women",
        "soccer_uefa_europa_league",
        "soccer_uefa_europa_conference_league",
        "soccer_uefa_nations_league",
        "basketball_euroleague",
        "basketball_ncaab",
        "basketball_ncaab_championship_winner",
        "basketball_nba_championship_winner"
    ]
]

private let leagueNames: [String: String] = [
    "soccer_africa_cup_of_nations": "Africa Cup of Nations",
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
    "soccer_england_efl_cup": "EFL Cup",
    "soccer_england_league1": "England League One",
    "soccer_england_league2": "England League Two",
    "soccer_epl": "English Premier League",
    "soccer_fa_cup": "FA Cup",
    "soccer_fifa_world_cup": "FIFA World Cup",
    "soccer_fifa_world_cup_qualifiers_europe": "FIFA World Cup Qualifiers (Europe)",
    "soccer_fifa_world_cup_winner": "FIFA World Cup Winner",
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
    "soccer_spl": "Scottish Premiership",
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
    "basketball_euroleague": "Basketball EuroLeague",
    "basketball_nba": "NBA",
    "basketball_nba_championship_winner": "NBA Championship Winner",
    "basketball_nbl": "National Basketball League (Australia)",
    "basketball_ncaab": "NCAA Men's Basketball",
    "basketball_ncaab_championship_winner": "NCAA Men's Basketball Championship Winner"
]
