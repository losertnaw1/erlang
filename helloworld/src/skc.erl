%% @author datle
%% @doc @todo Add description to skc.


-module(skc).

%% ====================================================================
%% API functions
%% ====================================================================
-export([send/1]).

send(File) ->
	{ok, Socket} = gen_udp:open(0,[binary]),
	{ok, Str} = file:read_file(File),
	io:format("Content of file : ~p ~n",[Str]),
	Bin = term_to_binary(Str),
	ok = gen_udp:send(Socket,"localhost",2345,Bin),
	gen_udp:close(Socket),
	ok.
	
	
%% send(File) ->
%% 	{ok, Socket} = gen_tcp:connect("localhost",2345,[binary]),
%% 	{ok, Str} = file:read_file(File),
%% 	io:format("Content of file : ~p ~n",[Str]),
%% 	Bin = term_to_binary(Str),
%% 	ok = gen_tcp:send(Socket,Bin),
%% 	receive
%% 		{tcp,Socket,Bin} -> 
%% 			io:format("Client got : ~p ~n",[binary_to_term(Bin)]),
%% 			gen_tcp:close(Socket)
%% 	end.
%% ====================================================================
%% Internal functions
%% ====================================================================


