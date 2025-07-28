EMPTY = " "
PLAYER_O = "O"
PLAYER_X = "X"
SIZE = 3

def create_grid():
    """3x3の空盤面を作成"""
    return [[EMPTY] * SIZE for _ in range(SIZE)]

def print_grid(grid):
    """盤面を表示"""
    for i, row in enumerate(grid):
        print(" | ".join(cell if cell != EMPTY else str(i * SIZE + j)
              for j, cell in enumerate(row)))
        if i < SIZE - 1:
            print("--+---+--")

def is_full(grid):
    """盤面が埋まっているか"""
    return all(cell != EMPTY for row in grid for cell in row)

def check_win(player, grid):
    """指定プレイヤーが勝利しているか"""
    win_lines = grid + list(zip(*grid))  # rows & cols
    win_lines.append([grid[i][i] for i in range(SIZE)])  # diagonal
    win_lines.append([grid[i][SIZE - i - 1] for i in range(SIZE)])  # anti-diagonal
    return any(all(cell == player for cell in line) for line in win_lines)

def minimax(grid, player, depth=0):
    """Minimaxアルゴリズムで評価値を返す"""
    if check_win(PLAYER_X, grid):  # AI勝利
        return 10 - depth
    if check_win(PLAYER_O, grid):  # 人間勝利
        return depth - 10
    if is_full(grid):  # 引き分け
        return 0

    scores = []
    for i in range(SIZE):
        for j in range(SIZE):
            if grid[i][j] == EMPTY:
                grid[i][j] = player
                score = minimax(grid, PLAYER_O if player == PLAYER_X else PLAYER_X, depth + 1)
                scores.append(score)
                grid[i][j] = EMPTY

    return max(scores) if player == PLAYER_X else min(scores)

def best_move(grid):
    """AIの最善手を決定（浅い木優先）"""
    best_score = -float("inf")
    move = None
    min_depth = float("inf")
    for i in range(SIZE):
        for j in range(SIZE):
            if grid[i][j] == EMPTY:
                grid[i][j] = PLAYER_X
                score = minimax(grid, PLAYER_O, depth=1)
                grid[i][j] = EMPTY
                # スコアが良い、または同じスコアで浅い場合に更新
                if score > best_score or (score == best_score and 1 < min_depth):
                    best_score = score
                    min_depth = 1
                    move = (i, j)
    return move

def choose_player():
    """人間が先手/後手を選ぶ"""
    while True:
        try:
            choice = input("Do you want to go first (O) or second (X)? ").upper()
            if choice in ["O", "X"]:
                return PLAYER_O if choice == "O" else PLAYER_X
            print("Invalid choice. Please enter O or X.")
        except KeyboardInterrupt:
            print("\nInterrupted by user. Exiting...")
            sys.exit()

def main():
    grid = create_grid()
    human = choose_player()
    ai = PLAYER_X if human == PLAYER_O else PLAYER_O

    while True:
        print_grid(grid)
        if check_win(PLAYER_X, grid):
            print("AI (X) wins!")
            break
        if check_win(PLAYER_O, grid):
            print("You (O) win!")
            break
        if is_full(grid):
            print("It's a draw!")
            break

        if turn(grid) == human:
            # 人間のターン
            while True:
                move = input(f"Player {human}, enter your move (0-8): ")
                if move.isdigit():
                    move = int(move)
                    row, col = divmod(move, SIZE)
                    if 0 <= move < SIZE * SIZE and grid[row][col] == EMPTY:
                        grid[row][col] = human
                        break
                print("Invalid move. Try again.")
        else:
            # AIのターン
            print(f"AI ({ai}) is thinking...")
            row, col = best_move(grid)
            grid[row][col] = ai

def turn(grid):
    """現在のターンを判定"""
    flat = [cell for row in grid for cell in row]
    o_count = flat.count(PLAYER_O)
    x_count = flat.count(PLAYER_X)
    return PLAYER_O if o_count <= x_count else PLAYER_X

if __name__ == "__main__":
    main()


