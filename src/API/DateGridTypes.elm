module API.DateGridTypes exposing (..)


type alias DateGrid =
    { columnHeaders : List (Maybe String)
    , rows : List (DateGridRow)
    }


type alias DateGridRow =
    { rowHeader : String
    , cells : List (Maybe DateGridCell)
    }


type alias DateGridCell =
    { priceCredits : Int
    , priceDisplay : String
    , outboundDate : String
    , inboundDate : String
    }


type alias BrowseDates =
    { quotes : Quotes
    , dateOptions : DateOptions
    }


type alias QuoteId =
    Int


type alias DateOptions =
    List (DateOption)


type alias DateOption =
    { partialDate : String
    , price : Int
    , quoteIds : List (QuoteId)
    , quoteDateTime : String
    }


type alias Quotes =
    List (Quote)


type alias Quote =
    { direct : Bool
    , inboundLeg : JourneyLeg
    , minPrice : Int
    , outboundLeg : JourneyLeg
    , quoteDateTime : String
    , quoteId : QuoteId
    }


type alias JourneyLeg =
    { carrierIds : List (Int)
    , departureDate : String
    , destinationNumericId : Int
    , originNumericId : Int
    }
