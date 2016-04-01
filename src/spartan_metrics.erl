-module(spartan_metrics).
-author("Christopher Meiklejohn <christopher.meiklejohn@gmail.com>").
-author("Sargun Dhillon <sargun@mesosphere.com").

-export([update/3,
         setup/0]).

-include("spartan.hrl").

%% @doc Bump a metric.
update(Metric, Value, Type) ->
    case exometer:update(Metric, Value) of
        {error, not_found} ->
            ok = exometer:ensure(Metric, Type, []),
            ok = exometer:update(Metric, Value);
        _ ->
            ok
    end.

%% @doc Configure all metrics.
setup() ->
    %% Successes and failures for the UDP server.
    ok = exometer:ensure([spartan_udp_server, successes], ?COUNTER, []),
    ok = exometer:ensure([spartan_udp_server, failures], ?COUNTER, []),

    %% Successes and failures for the TCP server.
    ok = exometer:ensure([spartan_tcp_handler, successes], ?COUNTER, []),
    ok = exometer:ensure([spartan_tcp_handler, failures], ?COUNTER, []),

    %% Number of queries received where we've answered only one of
    %% multiple questions presented.
    ok = exometer:ensure([spartan, ignored_questions], ?COUNTER, []),

    %% No upstreams responded.
    ok = exometer:ensure([spartan, upstreams_failed], ?COUNTER, []),

    %% No upstreams available.
    ok = exometer:ensure([spartan, no_upstreams_available], ?COUNTER, []),

    %% Number of times the spartan_handler_fsm fell into being killed by a timer
    ok = exometer:ensure([spartan, timeout_kill], ?COUNTER, []).
