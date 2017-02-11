module API.Types.Activities exposing (..)


type alias Params =
    { locationQuery : String }


type alias Activities =
    { destination : String
    , fullName : String
    , activities : List Activity
    }


type alias Activity =
    { title : String
    , fromPrice : String
    , fromPriceLabel : String
    , id : String
    , imageUrl : String
    , supplierName : String
    , duration : String
    }
