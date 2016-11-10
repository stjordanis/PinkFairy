-module(variables).
-compile(export_all).
%-export([]).

%these variables define how the consensus protocol works. At every height, the validators modify them slightly, so that the blockchain can adapt to its conditions.

%when we process a vote transaction, we make an update. the vote transaction is big, it says an optimal number for each value. The update is small, it only says a 1 or -1.
%combining updates is simple, just increment then all by one.

-record(vars, {validator_participation_minimum,
	       census_participation_minimum,
	       census_period,
	       create_block_pow, 
	       create_block_cost, 
	       create_account_cost, 
	       delete_account_reward, 
	       create_channel_cost, 
	       delete_channel_reward,
	       block_size_limit,
	       census_per_block,
	       validators_per_block,
	       account_rent,
	       channel_rent,
	       pow_price,
	       minimum_oracle_lifespan,
	       difficulty,
	       %below this line isn't voted on.
	       height}).
update_size() -> 17.
    

combine_updates(A, B) ->
    C = tuple_to_list(A),
    D = tuple_to_list(B),
    L = length(C),
    L = length(D),
    L = update_size(),
    list_to_tuple(map_add(C, D)).
map_add([], []) -> [];
map_add([H|T], [I|U]) -> [(H+I)|map_fun(T, U)].
list_to_vars(T) ->
    list_to_tuple([vars|T]).
vars_to_list(V) ->
    tl(tuple_to_list(V)).

adjust(Values, Friction, DValues, DFriction) ->
    V = vars_to_list(Values),
    F = vars_to_list(Friction),
    DV = tuple_to_list(DValues),
    DF = tuple_to_list(DFriction),
    FF = hd(V),
    {NewV, NewF} = adjust2(V, F, DV, DF, FF, [], []),
    {list_to_vars(flip(NewV)), list_to_vars(flip(NewF))}.
flip(X) -> flip(X, []).
flip([X|T], Y) -> flip(T, [X|Y]).
    
adjust2([],[],[],[],_,V,F) -> {V, F};
adjust2([V|Vals],[F|Fric],[DV|DVals],[DF|DFric],Slippery,NewV,NewF) -> 
    ok = case DV of
	     -1 -> ok;
	     1 ->ok
	 end,
    true = frac:gt(DF, Slippery),
    true = frac:lt(DF, frac:divide(1, Slippery)),
    NV = frac:add(frac:mul(F, DV), V),
    NF = frac:mul(F, DF),
    adjust2(Vals, Fric, DVals, DFric, Slippery,[NV|NewV],[NF|NewF]).
channel_rent(X) ->
    X#vars.channel_rent.
account_rent(X) ->
    X#vars.account_rent.
validators_per_block(X) ->
    X#vars.validators_per_block.
census_per_block(X) ->
    X#vars.census_per_block.
block_size_limit(X) ->
    X#vars.block_size_limit.
delete_channel_reward(X) ->
    X#vars.delete_channel_reward.
create_channel_cost(X) ->
    X#vars.create_channel_cost.
delete_account_reward(X) ->
    X#vars.delete_account_reward.
create_account_cost(X) ->
    X#vars.create_account_cost.
create_block_pow(X) ->
    X#vars.create_block_pow.
create_block_cost(X) ->
    X#vars.create_block_cost.
mininum_oracle_lifespan(X) ->
    X#vars.minimum_oracle_lifespan.
path(difficulty) ->
    0.
