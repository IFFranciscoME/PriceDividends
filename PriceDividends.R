
suppressMessages(library (grid))        # Grid modifications for plotting
suppressMessages(library (gridExtra))   # Extra grid for text positioning 
suppressMessages(library (ggplot2))     # Gramatics of Graphics
suppressMessages(library (lubridate))   # treatment and modification for dates
suppressMessages(library (quantmod))    # Stock Prices and Dividends from YAHOO
suppressMessages(library (reshape2))    # Use the function MELT
suppressMessages(library (simsalapar))  # Special Error Handler "TryCatch()"
suppressMessages(library (scales))      # Add comma separator Y-axis en plots
suppressMessages(library (tseries))     # Time series utilities
suppressMessages(library (xts))         # Time series utilities
suppressMessages(library (zoo))         # Time series utilities

# -- Inputs --------------------------------------------------------------------------- #

InitialDate <- Sys.Date()-1000          # System Current Date - 1000 days
FinalDate   <- Sys.Date()               # System Current Date
ticker      <- "GFINBURO.MX"            # Exactly as it appears in Yahoo Finance

# -- Get Dividends -------------------------------------------------------------------- #

DFDividend  <- fortify.zoo(getDividends(ticker,from = InitialDate, to = FinalDate))
colnames(DFDividend) <- c("Date","Dividend")

# -- Get Prices ----------------------------------------------------------------------- #

DFPrices <- fortify.zoo(get(getSymbols(Symbols = ticker, verbose = F,
warnings = F, src = "yahoo", from = InitialDate, to = FinalDate)))
colnames(DFPrices)  <- c("Date","Open","Max","Min","Close","Volume","AdjClose")

# errors   <- which(DFPrices$Volume == 0) IF YOU NEED TO REMOVE VOLUME 0 DAYS
# DFPrices <- DFPrices[-errors,]

# -- Match Dividends & Prices Dates --------------------------------------------------- #

Events <- data.frame(matrix(ncol = length(DFPrices[1,]), nrow = length(DFDividend[,1])))

Match  <- c()
for(j in 1:length(DFDividend$Date))                  # Counter for Dividends Dates 
{
  for(i in 1:length(DFPrices$Date))                  # Counter for Prices Dates
  {
    if(DFPrices$Date[i] == DFDividend$Date[j])       # Check matches for Dates
    {        
      Match[i] <- i
    }
  }
}
Match  <- na.omit(Match)                             # Remove rows with "NA"
Events <- data.frame(DFPrices$Date[Match],
DFPrices$Volume[Match],DFPrices$AdjClose[Match])
colnames(Events) <- c("Date","Volume","AdjClose")    # Events Matched (Prices)
Dates  <- DFPrices$Date[Match]                       # Events Matched (Dates)
for(i in 1:length(Events$Date))                      # Add Dividend to events
{
  Events$Dividends[i] <- DFDividend$Dividend[which(DFDividend$Date == Dates[i])]
}
ValDate <- as.Date(Events$Date)
Values  <- as.numeric(Events$Date)
Ymin    <- round(min(DFPrices$AdjClose),2)
Ymax    <- round(max(DFPrices$AdjClose),2)
Ynum    <- round((Ymax-Ymin)/10,2)

PriceVolumeSimple <- cbind(DFPrices[,c(1,7)],(DFPrices$Volume)/1000)
colnames(PriceVolumeSimple) <- c("Date","AdjClose","Volume")

PriceVolume <- melt(PriceVolumeSimple, id = "Date", 
variable.name = "InfoType", value.name = "Values")

ggPriceVolume <- ggplot(PriceVolume,  aes(x = Date, y = Value), group = InfoType) + 
  geom_line(colour = "dark green ", size = .75, alpha = .8) + 
  labs(title = paste("Price & Volume When Dividends",ticker)) +
  facet_grid(InfoType ~ ., scales = "free_y") +
  theme(panel.background = element_rect(fill="white"),
  panel.grid.minor.y = element_line(size = .25, color = "light gray"),
  panel.grid.major.y = element_line(size = .25, color = "light gray"),
  panel.grid.major.x = element_line(size = .25, color = "light gray"),
  panel.grid.major.x = NULL ,
  axis.text.x=element_text(colour = "black",size = 12, hjust =.5,vjust = 0),
  axis.text.y=element_text(colour = "black",size = 12, hjust =.5,vjust = 0),
  axis.title.x=element_text(colour = "black",size = 16, hjust =.5,vjust = -.75),
  axis.title.y=element_text(colour = "black",size = 16, hjust =.5,vjust = 1),
  title = element_text(colour = "black",size = 16, hjust =1,vjust = 1),
  panel.border=element_rect(linetype = 1, colour = "black", fill = NA)) + 
  scale_y_continuous(labels = comma)                  +
  scale_x_date(breaks = ValDate, labels = date_format("%m/%y")) +
  geom_vline(xintercept=Values, linetype = 5,size=.5,colour="dark grey",alpha = 0.9)
ggPriceVolume
