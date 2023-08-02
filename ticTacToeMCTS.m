function ticTacToeMCTS()
    % 创建一个3x3的初始棋盘
    board = zeros(3);
    % 假设玩家1开始
    player = 1;
    % 设定迭代次数
    numIterations = 1000;

    while true
        % 显示当前棋盘状态
        disp(board);

        % 判断游戏是否结束
        if checkTerminal(board)
            winner = checkWin(board, player);
            if winner == 1
                disp('玩家1获胜！');
            elseif winner == -1
                disp('玩家2获胜！');
            else
                disp('平局！');
            end
            break;
        end

        % 根据MCTS算法选择最佳移动
        move = mctsTicTacToe(board, player, numIterations);

        % 在棋盘上放置棋子
        board(move) = player;

        % 切换到下一个玩家
        player = -player;
    end
end