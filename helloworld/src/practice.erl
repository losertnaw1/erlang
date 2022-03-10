%% @author quale
%% @doc @todo Add description to collatz.


-module(practice).

-export([collatz/1,shallow_reverse/1,rm_dup/1]).

%% A list start with N number, end at 1,
%% if N is even -> take N/2 in list
%% if N is odd -> take N*3+1 in list
collatz(N) -> collatz(N,[]).
collatz(N,Acc) when N > 1 ->
	if
		N rem 2 == 0 -> collatz(N div 2,[N|Acc]);
		true -> collatz(N*3+1,[N|Acc])
	end;
collatz(1,Acc) -> lists:reverse([1|Acc]).

%% reverse a list.
shallow_reverse(L) -> shallow_reverse(L,[]).
shallow_reverse([H|T],Acc) -> shallow_reverse(T,[H|Acc]);
shallow_reverse([],Acc) -> Acc.

%% remove duplicates element from a list.
rm_dup(L) -> rm_dup(L,[]).
rm_dup([H|T],NewList) -> 
	Inlist = lists:member(H, NewList),
	if
		Inlist == false -> rm_dup(T,[H|NewList]);
		true -> rm_dup(T,NewList)
	end;
rm_dup([],LList) -> lists:reverse(LList).

%% 





