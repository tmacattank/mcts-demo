% 创建一个3x3的初始棋盘
board = zeros(3, 3);
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

function bestMove = mctsTicTacToe(board, player, numIterations)
    rootNode = createNode(board, player);
    
    for i = 1:numIterations
        % 选择节点并模拟游戏
        selectedNode = selectBestChild(rootNode);
        result = simulateGame(selectedNode.board, selectedNode.player);

        % 更新选中节点及其祖先节点
        backpropagate(selectedNode, result);
    end
    
    % 选择最佳移动
    bestChild = rootNode.children{1};
    bestMove = bestChild.move;
    bestScore = bestChild.score;
    
    for i = 2:numel(rootNode.children)
        child = rootNode.children{i};
        if child.score > bestScore
            bestMove = child.move;
            bestScore = child.score;
        end
    end
end

function selectedNode = selectBestChild(node)
    % 使用UCB公式选择最佳子节点
    c = 1.4; % 调整UCB公式中的探索权重
    scores = zeros(1, numel(node.children));
    
    for i = 1:numel(node.children)
        child = node.children{i};
        explorationTerm = sqrt(log(node.visitCount) / child.visitCount);
        scores(i) = child.score + c * explorationTerm;
    end
    
    [~, maxIndex] = max(scores);
    selectedNode = node.children{maxIndex};
end

function result = simulateGame(board, player)
    % 创建一个使用随机移动的简单AI
    while true
        if checkTerminal(board)
            break;
        end
        
        emptyCells = find(board == 0);
        randomIndex = randi(numel(emptyCells));
        randomMove = emptyCells(randomIndex);
        
        board(randomMove) = player;
        player = -player;
    end
    
    if checkWin(board, player)
        result = -player;
    else
        result = 0;
    end
end

function backpropagate(node, result)
    % 反向更新节点及其祖先节点的访问次数和得分
    while ~isempty(node)
        node.visitCount = node.visitCount + 1;
        node.score = node.score + result;
        node = node.parent;
    end
end



function node = createNode(board, player)
    % 创建一个节点对象并初始化相关属性
    node = struct();
    node.board = board;
    node.player = player;
    node.visitCount = 0;
    node.score = 0;
    node.children = {};
end

function isTerminal = checkTerminal(board)
    isTerminal = checkWin(board, 1) || checkWin(board, -1) || all(board(:) ~= 0);
end

function isWin = checkWin(board, player)
    % 检查横向获胜
    for row = 1:3
        if all(board(row,:) == player)
            isWin = true;
            return;
        end
    end

    % 检查纵向获胜
    for col = 1:3
        if all(board(:,col) == player)
            isWin = true;
            return;
        end
    end

    % 检查对角线获胜
    if all(diag(board) == player) || all(diag(fliplr(board)) == player)
        isWin = true;
        return;
    end

    isWin = false;
end

