% 游戏序列
sequence = [5, 1, 8, 3, 6, 9, 2, 7, 4, 10];
% 迭代次数
numIterations = 1000;
% 运行MCTS算法选择最佳移动
bestMove = findNumberMCTS(sequence, numIterations);
disp("最佳移动: " + num2str(bestMove));

function bestMove = findNumberMCTS(sequence, numIterations)
    rootNode = struct('move', [], 'parent', [], 'children', {}, 'visits', 0, 'score', 0);
    
    for i = 1:numIterations
        node = rootNode;
        
        while isempty(node.children) || ~isempty(node.children{1}.children)
            node = selectChild(node);
        end
        
        if ~isTerminal(node, sequence)
            availableMoves = getAvailableMoves(node, sequence);
            move = availableMoves(randi(numel(availableMoves)));
            newNode = struct('move', move, 'parent', node, 'children', {}, 'visits', 0, 'score', 0);
            node.children{end+1} = newNode;
            node = newNode;
        end
        
        result = simulateGame(node, sequence);
        
        backpropagate(node, result);
    end

    bestChild = selectBestChild(rootNode);
    if isempty(bestChild)
        bestMove = [];  % 无可用的子节点
    else
        bestMove = bestChild.move;
    end
end

function selectedChild = selectChild(node)
    selectedChild = [];
    bestUCBValue = -Inf;
    
    for i = 1:numel(node.children)
        child = node.children(i);
        UCBValue = child.score / child.visits + sqrt(2 * log(node.visits) / child.visits);
        
        if UCBValue > bestUCBValue
            bestUCBValue = UCBValue;
            selectedChild = child;
        end
    end
end

function bestChild = selectBestChild(node)
    bestScore = -Inf;
    bestChild = struct('move', [], 'parent', [], 'children', [], 'visits', 0, 'score', 0);

    for i = 1:numel(node.children)
        child = node.children(i);
        score = child.score / child.visits;

        if score > bestScore
            bestScore = score;
            bestChild = child;
        end
    end
end

function terminal = isTerminal(node, sequence)
    terminal = numel(node.move) == numel(sequence);
end

function availableMoves = getAvailableMoves(node, sequence)
    availableMoves = setdiff(1:numel(sequence), node.move);
end

function result = simulateGame(node, sequence)
    move = node.move;
    availableMoves = getAvailableMoves(node, sequence);
    
    while numel(move) < numel(sequence)
        nextMove = availableMoves(randi(numel(availableMoves)));
        move = [move, nextMove];
        availableMoves = setdiff(availableMoves, nextMove);
    end
    
    result = mod(sum(sequence(move)), 2) * 2 - 1;
end

function backpropagate(node, result)
    while ~isempty(node.parent)
        node.visits = node.visits + 1;
        node.score = node.score + result;
        node = node.parent;
    end
end

