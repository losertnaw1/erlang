%% @author quale
%% @doc @todo Add description to strsearch.
-module(helloErlang).
-import(string,[len/1,left/2]).
-export([search/2,action/2]).

search(W,[H|T]) ->
	Str = [H|T],
	Head = left(Str,len(W)),
	if
		W =:= Head -> {ok, true};
		true ->
			search(W,T)
	end;
search(_,[]) -> {ok, false}.
	
findmax([H|T]) -> findmax(T,H).
findmax([H|T],PMax) -> 
	if
		H < PMax -> findmax(T,PMax);
		true -> findmax(T,H)
	end;
findmax([],Max) -> Max.

findmin([H|T]) -> findmin(T,H).
findmin([H|T],PMax) -> 
	if
		H > PMax -> findmin(T,PMax);
		true -> findmin(T,H)
	end;
findmin([],Max) -> Max.

oddsum([H|T]) -> oddsum([H|T],0).
oddsum([H|T],Acc) ->
	if
		H rem 2 /= 0 -> oddsum(T,H+Acc);
		true -> oddsum(T,Acc)
	end;
oddsum([],Acc) -> Acc.

evensum([H|T]) -> evensum([H|T],0).
evensum([H|T],Acc) ->
	if
		H rem 2 == 0 -> evensum(T,H+Acc);
		true -> evensum(T,Acc)
	end;
evensum([],Acc) -> Acc.

action([H|T],Action) ->
	if
		Action == oddsum -> oddsum([H|T]);
		Action == evensum -> evensum([H|T]);
		Action == findmax -> findmax([H|T]);
		Action == findmin -> findmin([H|T]);
		true -> {error, "Action not found"}
	end.
