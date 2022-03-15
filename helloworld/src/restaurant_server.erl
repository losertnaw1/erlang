%% @author quale
%% @doc @todo Add description to fridge.


-module(restaurant_server).
-behavior(gen_server).
-record(food, {name,status,description}).

-compile(export_all).

start_link() -> gen_server:start_link(?MODULE, [], []).

%% Synchronous call
order_food(Pid, Name, Status, Description) ->
	gen_server:call(Pid, {order, Name, Status, Description}).
 
%% This call is asynchronous
return_food(Pid, Food = #food{}) ->
	gen_server:cast(Pid, {return, Food}).
 
%% Synchronous call
close_res(Pid) ->
	gen_server:call(Pid, terminate).

%%% Server functions
init([]) -> {ok, []}. %% no treatment of info here!
 
handle_call({order, Name, Status, Description}, _From, Foods) ->
	if
		Foods =:= [] ->
		io:format("We'll make ~p now ~n",[Name]),
		{reply, make_food(Name, Status, Description), Foods};
		Foods =/= [] ->
		{reply, hd(Foods), tl(Foods)}
	end;
handle_call(terminate, _From, Foods) ->
	{stop, normal, ok, Foods}.
 
handle_cast({return, Food = #food{}}, Foods) ->
	io:format("Here's your ~p , Have a good time ! ~n",[Food#food.name]),
	{noreply, [Food|Foods]}.

handle_info(Msg, Foods) ->
	io:format("Unexpected message: ~p~n",[Msg]),
	{noreply, Foods}.

terminate(normal, Foods) ->
	[io:format("Get out all of you, we're closing !.~n")],
	ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

%%% Private functions
make_food(Name, Status, Description) ->
	#food{name=Name, status=Status, description=Description}.


