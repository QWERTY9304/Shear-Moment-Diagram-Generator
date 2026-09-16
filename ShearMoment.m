% variable list/function
% validUnitsLength/Force - list of accepted units for system
% unitl asks for which distance unit is being used
% unitf asks which force unit is being used
% len is the length of the beam

% srcount is the amount of support reactions
% srlocation is the position of each of the support reactions as an array
% srprompt is the text for the question
% srquest gets a numerical value to be stored in srlocation

% pfcount is how many point forces there are
% pfvalue is the numerical value of each force
% pfprompt is the text for the question
% pfquest gets a numerical value to be stored in pfvalue
% pflocation stores the value of the force locations
% pfpromptloc is the text for the point force location question
% pfquestloc gets a numerical value to be stored in pflocation

% dlcount is how many distributed loads there are
% dlvalue is the magnitude (intensity) of each distributed load
% dlprompt is the text for the distributed load magnitude question
% dlquest gets a numerical value to be stored in dlvalue
% dlstart stores the start location of each distributed load
% dlpromptstart is the text for the distributed load start location question
% dlqueststart gets a numerical value to be stored in dlstart
% dlend stores the end location of each distributed load
% dlpromptend is the text for the distributed load end location question
% dlquestend gets a numerical value to be stored in dlend
% dllocation stores the centroid location of each distributed load segment

% llcount is how many linearly increasing distributed loads there are
% llstart stores the start location of each linear load
% llend stores the end location of each linear load
% llstartvalue stores the starting magnitude of each linear load
% llendvalue stores the ending magnitude of each linear load
% llpromptstart is the text for the linear load start location question
% llqueststart gets a numerical value to be stored in llstart
% llpromptend is the text for the linear load end location question
% llquestend gets a numerical value to be stored in llend
% llpromptstartvalue is the text for the linear load starting magnitude question
% llqueststartvalue gets a numerical value to be stored in llstartvalue
% llpromptendvalue is the text for the linear load ending magnitude question
% llquestendvalue gets a numerical value to be stored in llendvalue

% amcount is the amount of applied moments on the beam
% amvalue stores the magnitude of each applied moment
% amlocation stores the location of each applied moment
% ampromptvalue is the text for the applied moment magnitude question
% amquestvalue gets a numerical value to be stored in amvalue
% ampromptlocation is the text for the applied moment location question
% amquestlocation gets a numerical value to be stored in amlocation

% llLength stores the length of each linear load segment (llend-llstart)
% llconcentrated stores the equivalent concentrated force from the triangular portion of each linear load
% llconLoc stores the location (centroid) of the triangular equivalent concentrated force for each linear load
% lltodl stores the equivalent concentrated force from the rectangular portion of each linear load (converted to a uniform load resultant)
% lltodlloc stores the location (centroid) of the rectangular equivalent concentrated force for each linear load

% netpfvalue stores the net sum of all point forces
% netdlvalue stores the net sum of all distributed load resultants (intensity * length)
% netllvalue stores the net sum of all linear-load resultants (triangle + rectangle equivalents)

% momentsr1 stores the sum of moments of all applied loads about support reaction 1 (at srlocation(1))
% R1 stores the vertical reaction force at support 1
% R2 stores the vertical reaction force at support 2




function ShearMoment()
validUnitsLength = {'m','mm','in','ft'};
validUnitsForce = {'n','kn','lbf','kip'};

% Basic info section 
while true 
    unitf = lower(input('Please select a unit for the force: N, KN, lbf, kip: ','s'));
    if ismember(unitf, validUnitsForce)
        break
    else
        disp('Error. please select one of the listed options');
    end
end

while true 
    unitl = lower(input('Please select a unit for the length of the beam: m, mm, in, ft: ', 's'));
    if ismember(unitl, validUnitsLength)
        break
    else
        disp('Error. please select one of the listed options');
    end
end


while true
    len = input('Please enter the full length of the beam: ');
    if ~isnumeric(len) || len <= 0 || ~isscalar(len)
        disp("beam length must be a posotive number");
    else
        break
    end
end

% Reaction Force section 
while true
    srcount = input('How many vertical support reactions are on the beam (if resting on surface do not count, include in distributed load): ');
    if ~isnumeric(srcount)|| srcount < 0 || ~isscalar(srcount) || fix(srcount) ~= srcount 
        disp('Error, please select a posotive whole number: ');
    elseif srcount > 2
        disp('To be statically determinant there can only be 2 or less support reactions');
    else 
        break
    end
end

% Support Reaction section
srlocation = zeros(1,srcount);
for n = 1:srcount
    while true
        srprompt = sprintf('Please enter the location of support reaction %d assuming that the left most point is 0 and the supports are labeled 1 to %d: ', n,srcount);
        srquest = input(srprompt);
        if ~isnumeric(srquest)|| ~isscalar(srquest)
            disp('error needs to be scalar single value')
        elseif any(srlocation(1:n-1) == srquest)
            disp('Error: each support location must be unique')
        elseif srquest < 0 || srquest > len
            disp('Error: location must be between 0 and the beam length.');
        else
            srlocation(n)=srquest;
            break
        end
    end
end

% Point Force section 
while true 
    pfcount = input('how many vertical point forces are there on the beam NOT including support reactions: ');
    if ~isnumeric(pfcount)|| pfcount < 0 || ~isscalar(pfcount) || fix(pfcount) ~= pfcount 
        disp('Error, please select a posotive number or zero: ');
    else
        break
    end
end

pfvalue = zeros(1,pfcount);
pflocation = zeros(1, pfcount);
for n = 1:pfcount 
    while true
        pfprompt = sprintf('Please enter the magnitude of force %d making sure to include a - if facing downward or negative: ', n);
        pfquest = input(pfprompt);
        if ~isnumeric(pfquest)|| ~isscalar(pfquest) 
            disp('error needs to be scalar single value')
        else
            pfvalue(n)=pfquest;
            break
        end
    end
 
    while true 
        pfpromptloc  = sprintf('Please enter the location of force %d making sure to to consider 0 is on the furthest left point: ', n);
        pfquestloc = input(pfpromptloc);
        if ~isnumeric(pfquestloc) || ~isscalar(pfquestloc)
            disp ('error needs to be scalar single value')
        else
            pflocation(n) = pfquestloc;
            break
        end
    end
end

% Distributed Load section 
while true
    dlcount = input('how many distributed loads (not increasing) are there: ');
    if ~isnumeric(dlcount) || dlcount < 0 || ~isscalar(dlcount) || fix(dlcount) ~= dlcount
        disp('Error, Ivalid answer: ')
    else 
        break
    end
end


dlvalue = zeros(1, dlcount);
dlstart = zeros(1, dlcount);
dlend = zeros(1, dlcount);
dllocation = zeros(1, dlcount);
for n = 1:dlcount
    while true 
        dlprompt = sprintf ('Please enter the magnitude of distributed load number %d including a - if downward: ',n);
        dlquest = input(dlprompt);
        if ~isnumeric(dlquest) || ~isscalar(dlquest)
            disp('error needs to be scalar single value')
        else 
            dlvalue(n) = dlquest;
            break
        end
    end

    while true
        dlpromptstart = sprintf ('Please enter the start location of distributed load number %d: ',n);
        dlqueststart = input(dlpromptstart);
        if ~isnumeric(dlqueststart) || ~isscalar(dlqueststart) || dlqueststart > len || dlqueststart < 0
            disp('error needs to be scalar single value')
        else
            dlstart(n) = dlqueststart;
            break
        end
    end

    while true
        dlpromptend = sprintf ('Please enter the end location of distributed load number %d: ',n);
        dlquestend = input(dlpromptend);
        if ~isnumeric(dlquestend) || ~isscalar(dlquestend) || dlquestend > len || dlquestend < 0
            disp('Error needs to be scalar single value')
        elseif dlquestend <= dlstart(n)
            disp('Error: distributed load must have a posotive length from left to right: ')
        else
            dlend(n) = dlquestend;
            break
        end
    end
    dllocation(n) = (dlend(n) - dlstart(n))/2 +dlstart(n);
end

% Linear Load section 
while true
    llcount = input('how many linearly increasing distributed loads (triangular above a rectangle goes here) are there: ');
    if ~isnumeric(llcount) || llcount < 0 || ~isscalar(llcount) || fix(llcount) ~= llcount
        disp('Error, Ivalid answer: ')
    else 
        break
    end
end

llstart = zeros(1,llcount);
llend = zeros(1, llcount);
llstartvalue = zeros(1,llcount);
llendvalue = zeros(1,llcount);
for n =1:llcount
    while true
        llpromptstart = sprintf ('Please enter the start location of linear load number %d: ',n);
        llqueststart = input(llpromptstart);
        if ~isnumeric(llqueststart) || ~isscalar(llqueststart) || llqueststart > len || llqueststart < 0
            disp('Error needs to be scalar single value')
        else
            llstart(n) = llqueststart;
            break
        end
    end

    while true
        llpromptend = sprintf ('Please enter the end location of linear load number %d: ',n);
        llquestend = input(llpromptend);
        if ~isnumeric(llquestend) || ~isscalar(llquestend) || llquestend > len || llquestend < 0
            disp('Error needs to be scalar single value')
        elseif llquestend <= llstart(n)
            disp('Error: linear load must have a posotive length from left to right: ')
        else
            llend(n) = llquestend;
            break
        end
    end

    while true
        llpromptstartvalue = sprintf ('Please enter the starting magnitude of linear load number %d: ',n);
        llqueststartvalue = input(llpromptstartvalue);
        if ~isnumeric(llqueststartvalue) || ~isscalar(llqueststartvalue) 
            disp('Error, needs to be scalar single value')
        else
            llstartvalue(n) = llqueststartvalue;
            break
        end
    end

    while true
        llpromptendvalue = sprintf ('Please enter the end magnitude of linear load number %d: ',n);
        llquestendvalue = input(llpromptendvalue);
        if ~isnumeric(llquestendvalue) || ~isscalar(llquestendvalue) 
            disp('Error, needs to be scalar single value')
        elseif llquestendvalue == llstartvalue(n) || (llstartvalue(n) > 0 && llquestendvalue < 0) || (llstartvalue(n) < 0 && llquestendvalue > 0)
            disp('Error, needs to be a linear load with a consistent direction ')
        else
            llendvalue(n) = llquestendvalue;
            break
        end
    end
end

% Applied Moment section 
while true 
    amcount = input('Please enter the amount of applied moments that are on the beam: ');
    if ~isscalar(amcount) || amcount < 0 || ~isnumeric(amcount) || fix(amcount) ~= amcount
        disp('Error needs to be a whole posotive number or 0 ')
    else
        break
    end
end

amvalue = zeros(1, amcount);
amlocation = zeros(1,amcount);
for n = 1:amcount
    while true 
        ampromptvalue = sprintf('Please enter the magnitude for applied moment %d ',n);
        amquestvalue = input(ampromptvalue);
        if ~isscalar(amquestvalue) || ~isnumeric(amquestvalue)
            disp('Error, needs to be a numeric scalar value')
        else
            amvalue(n) = amquestvalue;
            break
        end
    end

    while true
        ampromptlocation = sprintf('Please enter the location for applied moment %d ',n);
        amquestlocation = input(ampromptlocation);
        if ~isscalar(amquestlocation)||~isnumeric(amquestlocation)|| amquestlocation > len || amquestlocation < 0
            disp('Error must be between o and the beam length ')
        else
            amlocation(n) = amquestlocation;
            break
        end
    end
end

% Solving for support reactions 


llLength = llend-llstart;
llconcentrated = zeros(1,llcount);
llconLoc = zeros(1,llcount);
lltodl = zeros(1,llcount);
lltodlloc = zeros(1,llcount);
for n = 1:llcount 
    if llstartvalue(n) < llendvalue(n) && llendvalue(n) == 0 %downward acting triangle with peak at start, end = 0 
        llconcentrated(n) = (llLength(n)*llstartvalue(n))/2;
        llconLoc(n) = 1/3*llLength(n)+llstart(n);
    elseif llstartvalue(n) > llendvalue(n) && llstartvalue(n) == 0 %downward acting triangle with peak at end, start = 0 
        llconcentrated(n) = (llLength(n)*llendvalue(n))/2;
        llconLoc(n) = 2/3*llLength(n)+llstart(n);
    elseif llstartvalue(n) > llendvalue(n) && llendvalue(n) == 0 %upward acting triangle with peak at start, end = 0
        llconcentrated(n) =  (llLength(n)*llstartvalue(n))/2;
        llconLoc(n) = 1/3*llLength(n)+llstart(n);
    elseif llstartvalue(n) < llendvalue(n) && llstartvalue(n) == 0 %upward acting triangle with peak at end, start = 0 
        llconcentrated(n) = (llLength(n)*llendvalue(n))/2;
        llconLoc(n) = 2/3*llLength(n)+llstart(n);
    elseif llstartvalue(n) < llendvalue(n) && llendvalue(n) < 0 %downward acting triangle with peak at start, end nonzero, rectangle base 
        llconcentrated(n) = (llLength(n)*(llstartvalue(n)-llendvalue(n)))/2;
        llconLoc(n) =  1/3*llLength(n)+llstart(n);
        lltodl(n) = llLength(n)*llendvalue(n);
        lltodlloc(n) = llLength(n)/2+llstart(n);
    elseif llstartvalue(n) > llendvalue(n) && llstartvalue(n) < 0 %downward acting triangle with peak at end, start nonzero, rectangle base 
        llconcentrated(n) = (llLength(n)*(llendvalue(n)-llstartvalue(n)))/2;
        llconLoc(n) =  2/3*llLength(n)+llstart(n);
        lltodl(n) = llLength(n)*llstartvalue(n);
        lltodlloc(n) = llLength(n)/2+llstart(n);
    elseif llstartvalue(n) > llendvalue(n) && llendvalue(n) > 0 %upward acting triangle with peak at start, end nonzero, rectangle base
        llconcentrated(n) = (llLength(n)*(llstartvalue(n)-llendvalue(n)))/2;
        llconLoc(n) =  1/3*llLength(n)+llstart(n);
        lltodl(n) = llLength(n)*llendvalue(n);
        lltodlloc(n) = llLength(n)/2+llstart(n);
    elseif llstartvalue(n) < llendvalue(n) && llstartvalue(n) > 0 %upward acting triangle peak at end, start nonzero, rectanlge base
        llconcentrated(n) = (llLength(n)*(llendvalue(n)-llstartvalue(n)))/2;
        llconLoc(n) =  2/3*llLength(n)+llstart(n);
        lltodl(n) = llLength(n)*llstartvalue(n);
        lltodlloc(n) = llLength(n)/2+llstart(n);
    end
end
        

netpfvalue = sum(pfvalue);
netdlvalue = sum(dlvalue .* (dlend-dlstart));
netllvalue = sum(llconcentrated) + sum(lltodl);

momentsr1 = sum(pfvalue.*(pflocation-srlocation(1))) + sum(dlvalue.*(dlend-dlstart).*(dllocation-srlocation(1))) + sum(llconcentrated.*(llconLoc-srlocation(1))) + sum(lltodl.*(lltodlloc-srlocation(1))) + sum(amvalue);


if srcount == 0
    R1 = 0;
    R2 = 0;
elseif srcount == 1
    R1 = -1*(netpfvalue + netdlvalue + netllvalue);
    R2 = 0;
else 
    R2 = -1*momentsr1/(srlocation(2)-srlocation(1));
    R1 = -1*(netpfvalue + netdlvalue + netllvalue + R2);
end
disp(momentsr1)
disp(R1)
disp(R2)

% variable list / diagram section
% eventPoints stores all "important x-locations" (0, L, supports, point loads, load starts/ends, moments)
% refineN is the amount of extra points added between each pair of event points (smoother curves)
% x is the final event-aware x-grid used for plotting/integration
% dx is spacing between adjacent x points (not constant everywhere if you refine by segments, but x is still ordered)
% w stores the total distributed load intensity at each x (uniform + linear), units = force/length
% loadRegion is a logical array marking where a particular load applies along x
% xi is the subset of x inside loadRegion (used to compute linear load intensity)
% V stores the shear force diagram values at each x, units = force
% M stores the bending moment diagram values at each x, units = force*length
% addJump is a function that adds a step/jump to V or M at a location (models point forces and applied moments)
% V(end) should be ~0 for a free end if equilibrium is satisfied 



% ===== Shear & Moment Diagram  =====

% Build event-aware x grid
eventPoints = [0 len];

% supports
eventPoints = [eventPoints srlocation];

% point forces
eventPoints = [eventPoints pflocation];

% uniform distributed load boundaries
eventPoints = [eventPoints dlstart dlend];

% linear load boundaries
eventPoints = [eventPoints llstart llend];

% applied moments
eventPoints = [eventPoints amlocation];

% unique + sorted
eventPoints = sort(unique(eventPoints));

% refine each interval for smooth curves (increase for smoother, decrease for faster)
refineN = 200;

x = [];
for i = 1:(length(eventPoints)-1)
    xSeg = linspace(eventPoints(i), eventPoints(i+1), refineN);
    x = [x xSeg(1:end-1)]; %#ok<AGROW>
end
x = [x eventPoints(end)];

% Build distributed load intensity w(x) on the grid
w = zeros(size(x));

% uniform distributed loads
for i = 1:dlcount
    loadRegion = (x >= dlstart(i)) & (x < dlend(i));
    w(loadRegion) = w(loadRegion) + dlvalue(i);
end

% linearly varying distributed loads
for i = 1:llcount
    loadRegion = (x >= llstart(i)) & (x < llend(i));
    if any(loadRegion)
        xi = x(loadRegion);
        w(loadRegion) = w(loadRegion) + ...
            ( llstartvalue(i) + ...
              (llendvalue(i) - llstartvalue(i)) ...
              .* (xi - llstart(i)) ...
              ./ (llend(i) - llstart(i)) );
    end
end

% Shear V(x): add jumps for point forces + reactions, then integrate -w
V = zeros(size(x));

% addJump(Varr, location, magnitude) adds a step of "magnitude" for all x >= location
addJump = @(Varr, location, magnitude) (Varr + magnitude * (x >= location));

% support reactions (treated as point forces)
if srcount >= 1
    V = addJump(V, srlocation(1), R1);
end
if srcount == 2
    V = addJump(V, srlocation(2), R2);
end

% point forces
for i = 1:pfcount
    V = addJump(V, pflocation(i), pfvalue(i));
end

% distributed loads contribution: dV/dx = -w(x)
V = V + cumtrapz(x, w);

% Moment M(x): integrate shear, then add applied moment jumps
M = cumtrapz(x, V);

% applied moments cause a jump in M at their location
% If your convention makes the jump go the wrong direction, flip the sign here.
for i = 1:amcount
    M = M + amvalue(i) * (x >= amlocation(i));
    % alternative if needed:
    % M = M - amvalue(i) * (x >= amlocation(i));
end

% enforce M(0)=0
M = M - M(1);
if amcount == 0
    M = M - (x/len)*M(end);
end

% Plot diagrams

% Plot diagrams (stacked + start vertical line + y=0 dotted line)
figure;

% ===== Shear Plot (top) =====
subplot(2,1,1);
plot(x, V, 'LineWidth', 2);
hold on;

% 1) vertical line at the start (x=0) from 0 to V(0+)
plot([0 0], [0 V(1)], 'k', 'LineWidth', 2);

% 2) dotted x-axis at y=0
yline(0, '--k', 'LineWidth', 1);

grid on;
xlim([0 len]);
ylabel(['V [' unitf ']']);
title('Shear Force Diagram');
hold off;

% ===== Moment Plot (bottom) =====
subplot(2,1,2);
plot(x, M, 'LineWidth', 2);
hold on;

% 2) dotted x-axis at y=0
yline(0, '--k', 'LineWidth', 1);

grid on;
xlim([0 len]);
xlabel(['x [' unitl ']']);
ylabel(['M [' unitf '*' unitl ']']);
title('Bending Moment Diagram');
hold off;


disp(['V(end) ~ ' num2str(V(end))]);
disp(['M(end) ~ ' num2str(M(end))]);
