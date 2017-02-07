function Track = swapTracks(Track, a, b, trackSwap, trackSel, m)
if m
    
    Z1 = Track.ind(a:b,trackSwap);
    Z2 = Track.cost(a:b,trackSwap);
    Z3 = Track.mstate(a:b,trackSwap);
    Z4 = Track.parent(a:b,trackSwap);
    Z5 = Track.parentGap(a:b,trackSwap);
    
    Track.ind(a:b,trackSwap) = Track.ind(a:b,trackSel);
    Track.cost(a:b,trackSwap) = Track.cost(a:b,trackSel);
    Track.mstate(a:b,trackSwap) = Track.mstate(a:b,trackSel);
    Track.parent(a:b,trackSwap) = Track.parent(a:b,trackSel);
    Track.parentGap(a:b,trackSwap) = Track.parentGap(a:b,trackSel);
    
    Track.ind(a:b,trackSel) = Z1;
    Track.cost(a:b,trackSel) = Z2;
    Track.mstate(a:b,trackSel) = Z3;
    Track.parent(a:b,trackSel) = Z4;
    Track.parentGap(a:b,trackSel) = Z5;
    
    
else
    Z1 = Track.ind(a:b,trackSwap);
    Z2 = Track.cost(a:b,trackSwap);
    Z4 = Track.parent(a:b,trackSwap);
    Z5 = Track.parentGap(a:b,trackSwap);
    
    Track.ind(a:b,trackSwap) = Track.ind(a:b,trackSel);
    Track.cost(a:b,trackSwap) = Track.cost(a:b,trackSel);
    Track.parent(a:b,trackSwap) = Track.parent(a:b,trackSel);
    Track.parentGap(a:b,trackSwap) = Track.parentGap(a:b,trackSel);
    
    Track.ind(a:b,trackSel) = Z1;
    Track.cost(a:b,trackSel) = Z2;
    Track.parent(a:b,trackSel) = Z4;
    Track.parentGap(a:b,trackSel) = Z5;
end