%% @author quale
%% @doc @todo Add description to strsearch.
-module(strsearch).
-import(string,[len/1,left/2]).
-export([search/2]).

search(W,[H|T]) ->
	Str = [H|T],
	Head = left(Str,len(W)),
	if
		W =:= Head -> {ok, true};
		true ->
			search(W,T)
	end;
search(_,[]) -> {ok, false}.
	
