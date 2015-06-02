# PriceDividends

ggplot2 package for plotting price and volume of a stock in order to 
visualize price and volume movements in a dividends payment day

- *Initial Developer:* FranciscoME
- *License:* GNU General Public License
- *GUADALAJARA, INGENIERÍA FINANCIERA ITESO

### Here's an example:
for stock *Fomento Económico Mexicano S.A.B. de C.V.* **(UBD Series)**:

``` R
# -- Inputs --------------------------------------------------------------------------- #
InitialDate <- Sys.Date()-1000          # System Current Date - 1000 days
FinalDate   <- Sys.Date()               # System Current Date
ticker      <- "FEMSAUBD.MX"            # Exactly as it appears in Yahoo Finance
```
Note that the *ticker* must be written as **exactly** as it appears in **Yahoo Finance**

And in order to avoid failures you must write dates in this format **yyyy-mm-dd**
