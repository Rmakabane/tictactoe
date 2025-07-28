import Data.Char
import Data.List
import System.IO

--盤面サイズ(3*3の三目ならべ)
size :: Int
size = 3

--盤面の型(Playerの二次元リスト)
type Grid = [[Player]]

--Playerの定義
data Player = O | B | X
  deriving (Eq, Ord, Show)

--次のPlayerを返す
next :: Player -> Player
next O = X
next B = B
next X = O

-- 空の盤面を生成
empty :: Grid
empty = replicate size (replicate size B)

-- 盤面がすべて埋まっているか判定
full :: Grid -> Bool
full = all (/= B) . concat

-- 現在のターンのプレイヤーを決定
turn :: Grid -> Player
turn g = if os <= xs then O else X
  where
    os = length (filter (== O) ps)
    xs = length (filter (== X) ps)
    ps = concat g

-- 指定プレイヤーが勝利しているか判定
wins :: Player -> Grid -> Bool
wins p g = any line (rows ++ cols ++ dias)
  where
    line = all (== p)
    rows = g
    cols = transpose g
    dias = [diag g, diag (map reverse g)]

-- 斜めラインを取得
diag :: Grid -> [Player]
diag g = [g !! n !! n | n <- [0 .. size-1]]

-- 誰かが勝利しているか判定
won :: Grid -> Bool
won g = wins O g || wins X g

-- 盤面を表示
putGrid :: Grid -> IO ()
putGrid =
  putStrLn . unlines . concat . interleave bar . map showRow
  where
    bar = [replicate ((size * 4) - 1) '_']

-- 1行を文字列リストとして表示
showRow :: [Player] -> [String]
showRow = beside . interleave bar . map showPlayer
  where
    beside = foldr1 (zipWith (++))
    bar = replicate 3 "|"

-- プレイヤーを文字で表示
showPlayer :: Player -> [String]
showPlayer O = ["   ", " O ", "   "]
showPlayer B = ["   ", "   ", "   "]
showPlayer X = ["   ", " X ", "   "]

-- リストの要素間に指定要素を挿入
interleave :: a -> [a] -> [a]
interleave x [] = []
interleave x [y] = [y]
interleave x (y : ys) = y : x : interleave x ys

-- 指定位置が有効かどうかチェック
valid :: Grid -> Int -> Bool
valid g i = 0 <= i && i < size ^ 2 && concat g !! i == B

-- 指定位置にプレイヤーのマークを置く
move :: Grid -> Int -> Player -> [Grid]
move g i p =
  if valid g i then [chop size (xs ++ [p] ++ ys)] else []
  where
    (xs, B : ys) = splitAt i (concat g)

-- 一次元リストを二次元リストに変換
chop :: Int -> [a] -> [[a]]
chop n [] = []
chop n xs = take n xs : chop n (drop n xs)

-- 入力から整数を取得
getNat :: String -> IO Int
getNat prompt = do
  putStr prompt
  xs <- getLine
  if xs /= [] && all isDigit xs
    then return (read xs)
    else do
      putStrLn "ERROR: Invalid number"
      getNat prompt

-- プレイヤーへのプロンプトメッセージ
prompt :: Player -> String
prompt p = "Player " ++ show p ++ ", enter your move: "

-- ゲーム木の定義
data Tree a = Node a [Tree a]
  deriving Show

-- ゲーム木を生成
gametree :: Grid -> Player -> Tree Grid
gametree g p = Node g [gametree g' (next p) | g' <- moves g p]

-- 現在の盤面から次の可能な盤面を生成
moves :: Grid -> Player -> [Grid]
moves g p
  | won g = []
  | full g = []
  | otherwise = concat [move g i p | i <- [0 .. ((size ^ 2) - 1)]]

-- ゲーム木の深さを制限
prune :: Int -> Tree a -> Tree a
prune 0 (Node x _) = Node x []
prune n (Node x ts) = Node x [prune (n - 1) t | t <- ts]

depth :: Int
depth = 9

-- Minimax アルゴリズムで盤面を評価
minimax :: Tree Grid -> Tree (Grid,Player)
minimax (Node g [])
  | wins O g = Node (g,O) []
  | wins X g = Node (g,X) []
  |otherwise = Node (g,B) []
minimax (Node g ts)
  | turn g == O = Node (g, minimum ps) ts' 
  | turn g == X = Node (g, maximum ps) ts' 
                  where ts' = map minimax ts
                        ps = [p | Node (_,p) _ <- ts']  

-- 次のノードを取得
nextTree :: Grid -> Tree (Grid, Player) -> Tree (Grid, Player)
nextTree g (Node _ ts) = head (filter (\(Node (g', _) _) -> g' == g) ts)

-- 木の深さを測定
cntDepth :: Tree (Grid, Player) -> Int
cntDepth (Node (_, _) []) = 0
cntDepth (Node (_, _) ts) = 1 + maximum (map cntDepth ts)

-- 最善手を決定
bestmove :: Player -> Tree (Grid, Player) -> Grid
bestmove p (Node _ ts)
  | null bestList = head [g' | Node (g', _) _ <- ts]
  | otherwise = gridWithMinDepth
  where
    best
      | p == O = minimum [p' | Node (_, p') _ <- ts]
      | p == X = maximum [p' | Node (_, p') _ <- ts]
      | otherwise = B
    bestList = [Node (g', p') t | Node (g', p') t <- ts, p' == best]
    Node (gridWithMinDepth, _) _ =
      foldr1 (\n1 n2 -> if cntDepth n1 <= cntDepth n2 then n1 else n2) bestList

-- プレイヤーの選択
choosePlayer :: IO Player
choosePlayer = do
  putStrLn "Do you want to go first (O) or second (X)?"
  choice <- getLine
  case map toUpper choice of
    "O" -> return O
    "X" -> return X
    _   -> do
      putStrLn "Invalid choice. Please enter O or X."
      choosePlayer

-- メイン処理
main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  human <- choosePlayer             
  let ai = next human     
  let fullTree = prune depth (gametree empty O)
  let minimaxedTree = minimax fullTree
  play human ai minimaxedTree

 -- ゲーム進行          
play :: Player -> Player -> Tree (Grid, Player) -> IO ()
play human ai node = case node of
  Node (g, _) _ -> do
    cls
    goto (1, 1)
    putGrid g
    play' human ai node

-- 画面制御
type Pos = (Int, Int)
goto :: Pos -> IO ()
goto (x, y) = putStr ("\ESC[" ++ show y ++ ";" ++ show x ++ "H")
cls :: IO ()
cls = putStr "\ESC[2J"

-- プレイヤーとAIの手番管理
play' :: Player -> Player -> Tree (Grid, Player) -> IO ()
play' human ai node =
  case node of
    Node (g, _) ts
      | wins O g -> putStrLn "Player O wins!\n"
      | wins X g -> putStrLn "Player X wins!\n"
      | full g -> putStrLn "It's a draw!\n"
      | turn g == human -> do i <- getNat (prompt human)
                              case move g i human of
                                [] -> do putStrLn "ERROR: Invalid move"
                                         play' human ai node
                                [g'] -> play human ai (nextTree g' node)
      | turn g == ai -> do putStr "AI is thinking... "
                           play human ai (nextTree (bestmove ai node) node)

