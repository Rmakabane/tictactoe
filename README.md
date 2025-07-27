# Tic-Tac-Toe with Minimax AI (Haskell & Python)

このプロジェクトは三目並べ（Tic-Tac-Toe）の対戦プログラムです。

- **Haskell版** と **Python版** の両方を実装
- ユーザー vs コンピュータ (AI) の対戦形式
- AIはミニマックスアルゴリズムにより最適な手を選択します


## 概要

このアプリケーションは、次のことを体験・学習するために開発しました。

- **純粋関数型言語 Haskell** の特徴を活かしたプログラム設計
- **Python** への移植で可読性・汎用性の高いコードを実現
- **ミニマックス法**によるゲーム木探索とAI手選択

人間プレイヤーは先手・後手を選択可能。対戦相手となるAIは先読みを行い、最善手を打ちます。


## 特徴

- ミニマックスアルゴリズムによる先読みAI
- Haskell版では関数型らしい「ゲーム木構築」での探索
- Python版では同ロジックをオブジェクト指向で移植
- コマンドライン上で動作

## ディレクトリ構成
.
├── README.md         # このファイル
├── tictactoe.hs      # Haskell版ソースコード
├── tictactoe.py      # Python版ソースコード

## Haskell版実行方法
ghc tictactoe.hs
./tictactoe
