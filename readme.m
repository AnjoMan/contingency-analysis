%% Describes changes to matpower:


%% Case format:
%
% Added branch_geo - for each branch listing, a vector of x-y points
% describing the path of the transmission line from bus a to bus b
%
% Added bus_geo - for each bus listing, a x-y point describing position of
% the bus
%
% Added trans: a listing of elements that are part of a transformer. Since
% transformers are modelled by transmission lines and busses, and are
% sometimes used to attach a generator, we have to fault multiple elements
% to simulate a transformer fault
%
%   makeup:    trans{i} = [ [branch connections (e.g. [[1,2]; [1,3]]) ], [bus
%   connections (e.g. [1,2]), [generators {by bus connection} (e.g. [1])]