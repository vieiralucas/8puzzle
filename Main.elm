module Main exposing (..)

import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Matrix exposing (Matrix)
import Maybe.Extra


-- MODEL


type alias Cell =
    { x : Int
    , y : Int
    , v : Maybe Int
    }


type alias Board =
    Matrix Cell


type alias Model =
    { board : Board
    }


initial : ( Model, Cmd Msg )
initial =
    let
        board =
            Matrix.fromList
                [ [ Cell 0 0 (Just 8), Cell 1 0 (Just 7), Cell 2 0 (Just 6) ]
                , [ Cell 0 1 (Just 5), Cell 1 1 (Just 4), Cell 2 1 (Just 3) ]
                , [ Cell 0 2 (Just 2), Cell 1 2 (Just 1), Cell 2 2 Nothing ]
                ]
    in
        ( { board = board }, Cmd.none )



-- UPDATE


type Msg
    = Move Cell


neighbours : Cell -> Board -> List Cell
neighbours cell board =
    let
        left =
            Matrix.get (Matrix.loc cell.y (cell.x - 1)) board

        right =
            Matrix.get (Matrix.loc cell.y (cell.x + 1)) board

        top =
            Matrix.get (Matrix.loc (cell.y - 1) cell.x) board

        bot =
            Matrix.get (Matrix.loc (cell.y + 1) cell.x) board
    in
        Maybe.Extra.values [ top, bot, left, right ]


move : Cell -> Board -> Board
move cell board =
    let
        n =
            neighbours cell board

        isBlank c =
            Maybe.Extra.isNothing c.v

        blank =
            List.filter isBlank n
    in
        case blank of
            [] ->
                board

            blank :: _ ->
                board
                    |> Matrix.set (Matrix.loc blank.y blank.x) { blank | v = cell.v }
                    |> Matrix.set (Matrix.loc cell.y cell.x) { cell | v = Nothing }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Move cell ->
            ( { model | board = move cell model.board }, Cmd.none )



-- VIEW


viewValue : Int -> Html Msg
viewValue v =
    Html.text (toString v)


cellStyle : List ( String, String )
cellStyle =
    [ ( "width", "200px" )
    , ( "height", "170px" )
    , ( "padding-top", "30px" )
    , ( "background", "cornsilk" )
    , ( "border", "2px solid #ddd" )
    , ( "font-size", "120px" )
    , ( "text-align", "center" )
    ]


emptyStyle : List ( String, String )
emptyStyle =
    [ ( "width", "200px" )
    , ( "height", "200px" )
    , ( "border", "2px solid #ddd" )
    ]


viewCell : Cell -> Html Msg
viewCell cell =
    case cell.v of
        Just v ->
            Html.div
                [ style cellStyle
                , onClick (Move cell)
                ]
                [ (viewValue v) ]

        Nothing ->
            Html.div [ style emptyStyle ] []


viewRow : List Cell -> List (Html Msg)
viewRow row =
    List.map viewCell row


rowStyle : List ( String, String )
rowStyle =
    [ ( "display", "flex" ) ]


boardStyle : List ( String, String )
boardStyle =
    [ ( "border", "2px solid #ddd" )
    , ( "width", "606px" )
    ]


view : Model -> Html Msg
view model =
    let
        rows =
            model.board
                |> mapRows viewRow
                |> List.map (Html.div [ style rowStyle ])
    in
        Html.div [ style boardStyle ]
            rows


main =
    Html.program
        { init = initial
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }



-- Utils


mapRows : (List a -> List b) -> Matrix a -> List (List b)
mapRows mapper matrix =
    matrix
        |> Matrix.toList
        |> List.map mapper
