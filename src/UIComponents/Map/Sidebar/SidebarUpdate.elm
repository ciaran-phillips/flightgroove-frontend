module UIComponents.Map.Sidebar.SidebarUpdate
    exposing
        ( focusGridOn
        , updateGridPosition
        )

import UIComponents.Map.Sidebar.SidebarModel as SidebarModel
import UIComponents.Map.Sidebar.SidebarMessages exposing (..)
import UIComponents.Map.Model as Model
import API.Response as Response


{-| Move the grid to display the given X and Y coordinates.

    focusGridOn { x = 10, y = 10 } 4 5 { x = 2, y = 3 }
-}
focusGridOn : SidebarModel.GridSize -> Int -> Int -> SidebarModel.GridPosition
focusGridOn gridSize x y =
    limitToGrid gridSize { x = x - 2, y = y - 2 }


{-| Move the grid to the stated position. These coordinates refer
to the upper-leftmost cell shown in the grid

    updateGridPosition MoveGridUp model
-}
updateGridPosition : MoveGridMsg -> SidebarModel.SidebarModel -> SidebarModel.GridPosition
updateGridPosition msg sidebar =
    let
        maxPosY =
            sidebar.gridSize.rows - 6

        maxPosX =
            sidebar.gridSize.columns - 6

        position =
            sidebar.gridPosition
    in
        case msg of
            MoveGridUp ->
                { position | y = decrease 4 position.y 0 }

            MoveGridDown ->
                { position | y = increase 4 position.y maxPosY }

            MoveGridLeft ->
                { position | x = decrease 4 position.x 0 }

            MoveGridRight ->
                { position | x = increase 4 position.x maxPosX }



{- PRIVATE FUNCTIONS -}


limitToGrid : SidebarModel.GridSize -> SidebarModel.GridPosition -> SidebarModel.GridPosition
limitToGrid gridSize pos =
    let
        maxPosY =
            gridSize.rows - 6

        maxPosX =
            gridSize.columns - 6
    in
        { x = fitIntoRange 0 maxPosX pos.x
        , y = fitIntoRange 0 maxPosY pos.y
        }


fitIntoRange : Int -> Int -> Int -> Int
fitIntoRange min max num =
    if num > max then
        max
    else if num < min then
        min
    else
        num


decrease : Int -> Int -> Int -> Int
decrease stepAmount current minimum =
    if (current - stepAmount) < minimum then
        minimum
    else
        current - stepAmount


increase : Int -> Int -> Int -> Int
increase stepAmount current maximum =
    if (current + stepAmount) > maximum then
        maximum
    else
        current + stepAmount
