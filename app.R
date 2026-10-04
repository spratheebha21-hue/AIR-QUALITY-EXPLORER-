library(shiny)
library(dplyr)
library(ggplot2)

# ---------------------------------------------------------------------------
# Data loading — use aqi_data.csv if present, otherwise generate 20 dummy rows
# ---------------------------------------------------------------------------
load_data <- function() {
  if (file.exists("aqi_data.csv")) {
    df <- read.csv("aqi_data.csv", stringsAsFactors = FALSE)
    df$date <- as.Date(df$date)
    return(df)
  }

  set.seed(42)
  cities <- c("New York", "Los Angeles", "Chicago")
  dates  <- seq.Date(as.Date("2024-01-01"), by = "week", length.out = 20)

  data.frame(
    date = rep(dates, times = ceiling(20 / length(cities)))[seq_len(20)],
    city = rep(cities, length.out = 20),
    pm25 = round(runif(20, 5,  80),  1),
    pm10 = round(runif(20, 10, 120), 1),
    no2  = round(runif(20, 5,  60),  1),
    aqi  = round(runif(20, 20, 150), 0),
    stringsAsFactors = FALSE
  )
}

aqi_data <- load_data()

# ---------------------------------------------------------------------------
# Helper: build summary data frame without tidyr
# ---------------------------------------------------------------------------
make_summary <- function(df) {
  pollutants <- c("pm25", "pm10", "no2", "aqi")
  rows <- lapply(pollutants, function(col) {
    vals <- df[[col]]
    data.frame(
      Pollutant = toupper(col),
      Mean      = round(mean(vals), 1),
      Max       = round(max(vals),  1),
      Min       = round(min(vals),  1),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Air Quality Explorer"),

  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId  = "city",
        label    = "Select City",
        choices  = sort(unique(aqi_data$city)),
        selected = sort(unique(aqi_data$city))[1]
      ),
      dateRangeInput(
        inputId  = "date_range",
        label    = "Date Range",
        min      = min(aqi_data$date),
        max      = max(aqi_data$date),
        start    = min(aqi_data$date),
        end      = max(aqi_data$date)
      )
    ),

    mainPanel(
      plotOutput("aqi_plot"),
      br(),
      h4("Summary Statistics (filtered selection)"),
      tableOutput("summary_table")
    )
  )
)

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------
server <- function(input, output, session) {

  # Reactive: filtered data
  filtered <- reactive({
    aqi_data %>%
      filter(
        city == input$city,
        date >= input$date_range[1],
        date <= input$date_range[2]
      )
  })

  # Line chart: AQI over time
  output$aqi_plot <- renderPlot({
    df <- filtered()

    if (nrow(df) == 0) {
      return(
        ggplot() +
          annotate("text", x = 0.5, y = 0.5,
                   label = "No data for the selected filters.",
                   size = 6, colour = "grey50") +
          theme_void()
      )
    }

    ggplot(df, aes(x = date, y = aqi)) +
      geom_line(colour = "#2c7bb6", linewidth = 1) +
      geom_point(colour = "#2c7bb6", size = 2.5) +
      scale_x_date(date_labels = "%b %d", date_breaks = "1 week") +
      labs(
        title = paste("AQI Over Time \u2014", input$city),
        x     = "Date",
        y     = "AQI"
      ) +
      theme_minimal(base_size = 14) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })

  # Summary table: mean / max / min per pollutant
  output$summary_table <- renderTable({
    df <- filtered()

    if (nrow(df) == 0) {
      return(data.frame(Message = "No data for the selected filters."))
    }

    make_summary(df)
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
