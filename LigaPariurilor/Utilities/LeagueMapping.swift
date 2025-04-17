//
//  LeagueMapping.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

struct LeagueInfo {
  static let names = LEAGUE_NAMES
  static func region(for key: String) -> String { regionFromLeagueKey(key) }
}

fileprivate let LEAGUE_NAMES: [String: String] = [
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
    "soccer_usa_mls": "USA Major League Soccer"
]

fileprivate func regionFromLeagueKey(_ key: String) -> String {
    if key.contains("uefa") || key.contains("england") || key.contains("denmark") || key.contains("epl") || key.contains("finland") || key.contains("france") || key.contains("germany") || key.contains("spain") || key.contains("italy") || key.contains("portugal") || key.contains("netherlands") || key.contains("sweden") || key.contains("austria") || key.contains("belgium") || key.contains("switzerland") || key.contains("norway") || key.contains("poland") || key.contains("greece") || key.contains("ireland") || key.contains("scotland") || key.contains("turkey") || key.contains("fa_cup") || key.contains("efl_champ") {
        return "🇪🇺 Europa"
    } else if key.contains("brazil") || key.contains("argentina") || key.contains("mexico") || key.contains("chile") || key.contains("conmebol") {
        return "🌎 America de Sud"
    } else if key.contains("japan") || key.contains("korea") || key.contains("china") {
        return "🌏 Asia"
    } else if key.contains("usa") {
        return "🇺🇸 America de Nord"
    } else if key.contains("australia") {
        return "🇦🇺 Oceania"
    }
    return "🌐 Alta"
}
