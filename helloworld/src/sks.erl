%% @author datle
%% @doc @todo Add description to sks.


-module(sks).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1]).

start(Port) ->
	net_adm:ping('ct@127.0.0.5'),
	{ok, Socket} = gen_udp:open(Port,[binary]),
	loop(Socket).

loop(Socket) ->
	receive
		{udp, Socket,_Host,_Port, Bin} ->
			io:format("Server got : ~p ~n", [Bin]),
			io:format("Convert to string : ~p ~n", [binary_to_term(Bin)]),
			loop(Socket)
	end.

%% TCP	
%%-export([start/0])
%% start() ->
%% 	net_adm:ping('ct@127.0.0.5'),
%% 	{ok, Listen} = gen_tcp:listen(2345,[binary]),
%% 	{ok, Socket} = gen_tcp:accept(Listen),
%% 	gen_tcp:close(Listen),
%% 	loop(Socket).
%% 
%% loop(Socket) ->
%% 	receive
%% 		{tcp, Socket, Bin} ->
%% 			io:format("Server got : ~p ~n", [Bin]),
%% 			io:format("Convert to string : ~p ~n", [binary_to_term(Bin)]),
%% 			io:format("Server replying ~n"),
%% 			gen_tcp:send(Socket, Bin),
%% 			loop(Socket);
%% 		{tcp_closed, Socket} ->
%% 			io:format("Server stopped ~n")
%% 	end.

%% ====================================================================
%% Internal functions
%% ====================================================================


