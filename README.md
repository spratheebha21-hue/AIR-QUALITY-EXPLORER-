# Air Quality Explorer

A single-page R Shiny dashboard for exploring air quality data across cities and time ranges.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [Running the App](#running-the-app)
- [Data Format](#data-format)
- [Usage Guide](#usage-guide)
- [Error Handling](#error-handling)
- [Technical Details](#technical-details)
- [Verification](#verification)

---

## Overview

Air Quality Explorer is a lightweight, self-contained Shiny dashboard that lets users interactively filter air quality measurements by city and date range, visualise AQI trends over time, and review per-pollutant summary statistics — all within a single `app.R` file under 150 lines.

---

## Features

| Feature | Details |
|---------|---------|
| City filter | Dropdown — auto-populated from data |
| Date range filter | Date-range slider, initialised to full data extent |
| AQI line chart | ggplot2, weekly x-axis, labelled axes |
| Summary table | Mean / Max / Min for PM2.5, PM10, NO2, AQI |
| Dummy data fallback | 20 generated rows if no CSV is present |
| Empty-filter guard | Both outputs show a friendly message instead of crashing |

---

## Project Structure

```
kiro R/
├── app.R          # Complete Shiny application (140 lines)
├── README.md      # This file
└── aqi_data.csv   # Optional — real data (see Data Format below)
```

---

## Requirements

| Dependency | Version tested |
|-----------|---------------|
| R         | 4.6.1         |
| shiny     | 1.14.0        |
| dplyr     | 1.2.1         |
| ggplot2   | 4.0.3         |

No other packages are required.

---

## Installation

1. **Install R** from <https://cran.r-project.org/> (4.x recommended).
2. **Install packages** (one-time, run in an R console):

```r
install.packages(c("shiny", "dplyr", "ggplot2"), repos = "https://cloud.r-project.org")
```

3. **Clone / download** this repository into any local folder.

---

## Running the App

### From RStudio
Open `app.R` and click **Run App**.

### From an R console
```r
shiny::runApp("path/to/kiro R/app.R")
```

### From a terminal (R on PATH)
```bash
Rscript -e "shiny::runApp('app.R')"
```

The app opens at `http://127.0.0.1:<port>` in your default browser.

---

## Data Format

Drop a file named `aqi_data.csv` in the same directory as `app.R`.  
Required columns (names are case-sensitive):

| Column | Type    | Description                  |
|--------|---------|------------------------------|
| date   | Date    | ISO-8601 format `YYYY-MM-DD` |
| city   | String  | City name                    |
| pm25   | Numeric | PM2.5 concentration (µg/m³)  |
| pm10   | Numeric | PM10 concentration (µg/m³)   |
| no2    | Numeric | NO2 concentration (µg/m³)    |
| aqi    | Integer | Air Quality Index            |

If no CSV is found, the app auto-generates 20 reproducible dummy rows spanning three cities (Chicago, Los Angeles, New York) from 2024-01-01 to 2024-05-13.

---

## Usage Guide

1. **Select a city** from the dropdown in the sidebar.
2. **Adjust the date range** using the date-range input.
3. The **line chart** updates to show AQI over time for the selected city and period.
4. The **summary table** shows Mean, Max, and Min values for PM2.5, PM10, NO2, and AQI across the filtered rows.

---

## Error Handling

- If the selected city/date combination returns no rows, both the chart and table display the message: *"No data for the selected filters."*
- The app will not crash on an empty filtered result.

---

## Technical Details

- **Architecture**: single `app.R` file — no modules, no external config.
- **Packages**: `shiny` (UI + reactivity), `dplyr` (data filtering), `ggplot2` (charting).
- **No tidyr dependency**: the summary table is built with base-R `lapply` + `do.call(rbind, ...)`.
- **Reproducibility**: dummy data uses `set.seed(42)`.
- **Line count**: 140 lines.

---

## Verification

All checks were run against R 4.6.1 on Windows:

| Check | Result |
|-------|--------|
| Syntax (`parse()`) | ✅ OK |
| Dependencies present | ✅ shiny 1.14.0 · dplyr 1.2.1 · ggplot2 4.0.3 |
| Launch (headless, port 8901) | ✅ HTTP 200 |
| Dummy-data fallback | ✅ 20 rows generated correctly |
