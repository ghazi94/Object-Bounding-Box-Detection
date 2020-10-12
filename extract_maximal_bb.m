function [bounding_box] = extract_maximal_bb(x_set, y_set)
    nulx = x_set(1);
    nurx = x_set(2);
    nlrx = x_set(3);
    nllx = x_set(4);
    nuly = y_set(1);
    nury = y_set(2);
    nlry = y_set(3);
    nlly = y_set(4); 

    % Check the lowest bound of X
    if nulx < nllx
        bb_new_x = nulx;
    else
        bb_new_x = nllx;
    end

    % Check the lowest bound of Y
    if nuly < nury
        bb_new_y = nuly;
    else
        bb_new_y = nury;
    end

    % Check the highest bound of X
    if nurx > nlrx
        bb_new_W = -1*(bb_new_x - nurx);
    else
        bb_new_W = -1*(bb_new_x - nlrx);
    end

    % Check the highest bound of Y
    if nlly > nlry
        bb_new_H = -1*(bb_new_y - nlly);
    else
        bb_new_H = -1*(bb_new_y - nlry);
    end

    bounding_box = [bb_new_x, bb_new_y, bb_new_W, bb_new_H];
end