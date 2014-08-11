%%%=============================================================================
%%% @doc
%%% @copyright 2014 Klarna AB
%%% @end
%%%=============================================================================

-module(brod_utils).

%% Exports
-export([ get_metadata/1
        , get_metadata/2
        , try_connect/1
        ]).

%%%_* Includes -----------------------------------------------------------------
-include("brod_int.hrl").

%%%_* Code ---------------------------------------------------------------------
%% try to connect to any of bootstrapped nodes and fetch metadata
get_metadata(Hosts) ->
  get_metadata(Hosts, []).

get_metadata(Hosts, Topics) ->
  {ok, Pid} = try_connect(Hosts),
  Request = #metadata_request{topics = Topics},
  Response = brod_sock:send_sync(Pid, Request, 10000),
  brod_sock:stop(Pid),
  Response.

try_connect(Hosts) ->
  try_connect(Hosts, []).

try_connect([], LastError) ->
  LastError;
try_connect([{Host, Port} | Hosts], _) ->
  %% Do not 'start_link' to avoid unexpected 'EXIT' message.
  %% Should be ok since we're using a single blocking request which
  %% monitors the process anyway.
  case brod_sock:start(self(), Host, Port, []) of
    {ok, Pid} -> {ok, Pid};
    Error     -> try_connect(Hosts, Error)
  end.

%%% Local Variables:
%%% erlang-indent-level: 2
%%% End: