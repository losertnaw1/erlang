%% @author quale
%% @doc @todo Add description to process.
%% @formatter:on

-module(process).
-compile(export_all).

auto_reply_robot() ->
	receive
		{From,hello} -> From ! "Hello !" , 
						auto_reply_robot();
		{From,how_r_u} -> From ! "Im fine. Thank you ! And you ?" , 
						  auto_reply_robot();
		{From,who_r_u} -> From ! "Im a robot. I will automatic response your some basic action !",
						  auto_reply_robot();
		{From,im_fine} -> From ! "Good !",
						  auto_reply_robot();
		{From,bye} -> From ! "Bye ! See ya";
		_ -> io:format("Error ! What are you saying ? I can't understand yet :((")
	end.
	
fridge(FoodList) ->
	receive
		{From, show} -> From ! {self(), FoodList},
						fridge(FoodList);
		{From, {store, Food}} -> From ! {self(), ok},
								 fridge([Food|FoodList]);
		{From, {take, Food}} ->
			case lists:member(Food, FoodList) of
				true -> From ! {self(), {ok, Food}},
				fridge(lists:delete(Food, FoodList));
				false -> From ! {self(), not_found},
				fridge(FoodList)
	end;
terminate -> ok
end.

store(Pid, Food) ->
	Pid ! {self(), {store, Food}},
	receive
		{Pid, Msg} -> Msg
	end.
 
take(Pid, Food) ->
	Pid ! {self(), {take, Food}},
	receive
		{Pid, Msg} -> Msg
	end.

show(Pid) ->
	Pid ! {self(), show},
	receive
		{Pid, Msg} -> Msg
	end.

start(FoodList) -> 
	spawn(process, fridge, [FoodList]).




	
