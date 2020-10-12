function[check] = check_in_poly(poly, bb)
    [bbxs, bbys] = extract_clockwise_point_bb(bb);
    finbb = horzcat(bbxs', bbys');
    incheck = inpoly(finbb, poly);
    check = all(incheck);
end