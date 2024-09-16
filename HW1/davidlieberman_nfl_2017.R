#' ---
#' title: "NFL Best Attempt of Data Gathering!"
#' author: "David Lieberman"
#' output: html_document
#' ---

# Setting up environment
setwd(file.path(Sys.getenv("USERPROFILE"),"Desktop","Dropbox","Homework Scans","2024F_SDS625","HW1", fsep="\\"))
x = scan("17nflog.html", what = "", sep = "\n")
formals(gsub)$perl = TRUE


# Cleaning up HTML syntax artifacts
x = gsub('&nbsp;', '', x)
x = gsub('</span>', ',', x)
x = gsub("<br>", "br", x)  # Preserving the break tag to split on by groups
x = gsub("<[^<>]*>", "", x)

# Data cleaning to standardize the team names
x = gsub("CINCY", "CINCINNATI", x)
x = gsub("G\\.\\sBAY", "GREEN BAY", x)
x = gsub("INDI\\.|INDY", "INDIANAPOLIS", x)
x = gsub("J\\'VILLE", "JACKSONVILLE", x)
x = gsub("KAN\\.", "KANSAS", x)
x = gsub("LA\\sCHARG\\.", "LOS ANGELES CHARGERS", x)
x = gsub("LA\\sChargers\\.", "Los Angeles Chargers", x)
x = gsub("LA\\sRAMS\\.", "LOS ANGELES RAMS", x)
x = gsub("LA\\sRams\\.", "Los Angeles Rams", x)
x = gsub("N\\.\\sENGLAND|NEW\\sENG\\.", "NEW ENGLAND", x)
x = gsub("N\\.\\sORLEANS", "NEW ORLEANS", x)
x = gsub("N\\.\\sOrleans", "New Orleans", x)
x = gsub("NY\\sGIANTS", "NEW YORK GIANTS", x)
x = gsub("NY\\sGiants", "New York Giants", x)
x = gsub("Ny\\sJets", "New York Jets", x)
x = gsub("NY\\sJets|NY\\sJETS", "NEW YORK JETS", x)
x = gsub("PHILA\\.", "PHILADELPHIA", x)
x = gsub("PITT(?!\\w)", "PITTSBURGH", x)
x = gsub("S\\.\\sFRAN\\.|S\\.\\sFRANCISCO", "SAN FRANCISCO", x)
x = gsub("T\\.\\sBAY", "TAMPA BAY", x)
x = gsub("TENN\\.", "TENNESSEE", x)
x = gsub("WASH\\.", "WASHINGTON", x)

x = gsub("\\*", "", x)
x = gsub("-ot", "", x)
x = gsub("\\s\\(AT\\)", "", x)
x = gsub("\\s\\(P\\.A\\.T\\.?\\)", "", x)

# Standardizing the start and removing a couple lines of misc syntax garbage
x = c("br", x[-c(1:19, length(x))])


# The break tag delineates the teams' data chunks, so using that as an index factor over which to split groups then reshape
y = tapply(x, factor(cumsum(x == "br"), labels = x[which(x == "br") + 1]), tail, -3)
z = array2DF(y) |>
   setNames(c("team1", "game"))


# Splitting the comma-delimited information fields into DF columns
games_split = t(data.frame(strsplit(z$game, ",")))
games_split = data.frame(games_split, row.names = NULL)[-c(3,6)] |>
   setNames(c("dates", "team2", "pointspread", "score_interval"))

# Splitting the hyphenated score intervals into DF columns
scores_split = t(data.frame(strsplit(games_split$score_interval, "-")))
scores_split = data.frame(scores_split, row.names = NULL) |>
   setNames(c("score1", "score2"))

# Substituting the ' for decimal representation 
pointspread = gsub("\\'", ".5", games_split$pointspread)

# The visiting-site games can be identified by their lowercase letter(s), 
# while the neutral-site games' can identified by the parentheses in subsequent rows 
# that occur immediately after each data row of the neutral-site games themselves
location = ifelse(grepl("[[:lower:]]", games_split$team2), "V", "H")
location[which(grepl("\\(.*\\)", z$game)) - 1] = "N"

# Cleaning up the date typing and reformatting correctly
dates = games_split$dates
dates = gsub("S\\.(\\d*)", "Sep.\\1.17", dates)
dates = gsub("O\\.(\\d*)", "Oct.\\1.17", dates)
dates = gsub("N\\.(\\d*)", "Nov.\\1.17", dates)
dates = gsub("D\\.(\\d*)", "Dec.\\1.17", dates)
dates = gsub("J\\.(\\d*)", "Jan.\\1.18", dates)
dates = gsub("F\\.(\\d*)", "Feb.\\1.18", dates)


# Collecting all the pieces together into the final data structure, and converting to their proper types
results_df = data.frame("dates" = format(as.Date(dates, "%b.%d.%y"), format = "%Y/%m/%d"),
                        z["team1"],
                        games_split["team2"],
                        "pointspread" = as.numeric(pointspread),
                        sapply(scores_split, as.numeric),
                        "location" = as.factor(location), row.names = NULL)

# Removing the neutral-site games' empty lines, which now have NA dates after the coercion above,
# and completing BYE WEEKs' remaining field with NAs
results_df = subset(results_df, !is.na(dates))
results_df = within(results_df, location[grepl("BYE WEEK", team2)] <- NA)

# Save result to disk as .CSV
write.csv(results_df, "davidlieberman_nfl_2017.csv")

results_df