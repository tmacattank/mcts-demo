% 示例游戏初始状态
board = [0, 0, 0; 0, 0, 0; 0, 0, 0];
% 迭代次数
numIterations = 1000;
% 运行MCTS算法选择最佳移动
bestMove = ticTacToeMCTS(board, numIterations);

disp("最佳移动: " + num2str(bestMove));

function bestMove = ticTacToeMCTS(board, numIterations)
    rootNode = struct('move', [], 'parent', [], 'children', [], 'visits', 0, 'score', 0);
    
    for i = 1:numIterations
        node = rootNode;
        
        while ~isempty(node.children)
            node = selectChild(node);
        end
        
        if ~isTerminal(board)
            availableMoves = getAvailableMoves(node);
            move = availableMoves(randi(numel(availableMoves)));
            newNode = struct('move', move, 'parent', node, 'children', [], 'visits', 0, 'score', 0);
            node.children(end+1) = newNode;
            node = newNode;
        end
        
        result = simulateGame(node);
        
        backpropagate(node, result);
    end
    
    bestChild = selectBestChild(rootNode);
    bestMove = bestChild.move;
end

function node = selectChild(node)
    % 根据UCB公式选择最佳子节点
    % UCB公式：UCB = score / visits + C * sqrt(log(totalVisits) / visits)
    C = sqrt(2);  % 探索参数，调整探索和利用之间的平衡
    totalVisits = node.visits;
    
    childScores = arrayfun(@(c) c.score / c.visits + C * sqrt(log(totalVisits) / c.visits), node.children);
    [~, idx] = max(childScores);
    
    node = node.children(idx);
end

function result = simulateGame(node)
    % 随机模拟剩余游戏
    board = node.board;
    currentPlayer = node.currentPlayer;
    
    while ~isTerminal(board)
        availableMoves = getAvailableMoves(board);
        move = availableMoves(randi(numel(availableMoves)));
        
        board(move) = currentPlayer;
        currentPlayer = getNextPlayer(currentPlayer);
    end
    
    result = getGameResult(board);
end

function backpropagate(node, result)
    % 回溯并更新节点统计数据
    while ~isempty(node)
        node.visits = node.visits + 1;
        node.score = node.score + result;
        node = node.parent;
    end
end

function moves = getAvailableMoves(board)
    % 获取当前游戏状态下的可用移动
    moves = find(board == 0);  % 找到棋盘上值为0的位置，即空格子
end

function isTerminal = isTerminal(board)
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


% 其他辅助函数的实现

