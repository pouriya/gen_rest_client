%%% ------------------------------------------------------------------------------------------------
%%% "gen_rest_client" is available for use under the following license, commonly known as the 3-clause
%%% (or "modified") BSD license:
%%%
%%% Copyright (c) 2017-2018, Pouriya Jahanbakhsh
%%% (pouriya.jahanbakhsh@gmail.com)
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without modification, are permitted
%%% provided that the following conditions are met:
%%%
%%% 1. Redistributions of source code must retain the above copyright notice, this list of
%%%    conditions and the following disclaimer.
%%%
%%% 2. Redistributions in binary form must reproduce the above copyright notice, this list of
%%%    conditions and the following disclaimer in the documentation and/or other materials provided
%%%    with the distribution.
%%%
%%% 3. Neither the name of the copyright holder nor the names of its contributors may be used to
%%%    endorse or promote products derived from this software without specific prior written
%%%    permission.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
%%% IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
%%% FITNESS FOR A  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
%%% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%%% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
%%% THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
%%% OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%%% POSSIBILITY OF SUCH DAMAGE.
%%% ------------------------------------------------------------------------------------------------
%% @author   Pouriya Jahanbakhsh <pouriya.jahanbakhsh@gmail.com>
%% @version  17.12.24
%% @doc
%%           Generic ReST client.
%% @end
%% -------------------------------------------------------------------------------------------------
-module(gen_rest_client).
-author("pouriya.jahanbakhsh@gmail.com").
%% -------------------------------------------------------------------------------------------------
%% Exports:

%% API:
-export([request/5
        ,request/6
        ,request/7
        ,request/8
        ,request/9
        ,value/2]).

%% -------------------------------------------------------------------------------------------------
%% Records & Macros & Includes:

-define(DEF_TIMEOUT, 10000).
-define(DEF_REQ_OPTS, [{response_format, binary}]).
-define(DEF_HEADERS, []).
-define(DEF_BODY, <<>>).

%% -------------------------------------------------------------------------------------------------
%% Types:

-type host() :: string().
-type init_argument() :: any().
-type filter() :: fun((InitArg::init_argument(), Status::string(), Body::body()) ->
                      {'ok', Result::term()} | {'error', {Reason::atom(), ErrorParams::list()}}).
-type  body() :: jiffy:json_value().
-type send_body() :: binary().
-type path() :: string().
-type method() :: atom().
-type headers() :: [{atom() | string() | binary(), atom() | string() | binary()}] | [].
-type request_type() :: atom().

-export_type([host/0
             ,init_argument/0
             ,filter/0
             ,body/0
             ,send_body/0
             ,path/0
             ,method/0
             ,headers/0
             ,request_type/0]).

%% -------------------------------------------------------------------------------------------------
%% API:

-spec
request(host(), init_argument(), filter(), path(), request_type()) ->
    {'ok', term()} | {'error', {atom(), list()}}.
%% @doc
%%      See request/9 details.
%% @end
%% @equiv request/9
request(Host, InitArg, Filter, Path, ReqType) when erlang:is_list(Host) andalso
                                                   erlang:is_function(Filter, 3) andalso
                                                   erlang:is_list(Path) ->
    request(Host, InitArg, Filter, Path, ReqType, get).


-spec
request(host(), init_argument(), filter(), path(), request_type(), method()) ->
    {'ok', term()} | {'error', {atom(), list()}}.
%% @doc
%%      See request/9 details.
%% @end
request(Host, InitArg, Filter, Path, ReqType, Method) when erlang:is_list(Host) andalso
                                                           erlang:is_function(Filter, 3) andalso
                                                           erlang:is_list(Path) andalso
                                                           erlang:is_atom(Method) ->
    request(Host, InitArg, Filter, Path, ReqType, Method, ?DEF_HEADERS, ?DEF_BODY).


-spec
request(host(), init_argument(), filter(), path(), request_type(), method(), headers()) ->
    {'ok', term()} | {'error', {atom(), list()}}.
%% @doc
%%      See request/9 details.
%% @end
request(Host
       ,InitArg
       ,Filter
       ,Path
       ,ReqType
       ,Method
       ,Headers) when erlang:is_list(Host) andalso
                      erlang:is_function(Filter, 3) andalso
                      erlang:is_list(Path) andalso
                      erlang:is_atom(Method) andalso
                      erlang:is_list(Headers) ->
    request(Host, InitArg, Filter, Path, ReqType, Method, Headers, ?DEF_BODY).


-spec
request(host(), init_argument(), filter(), path(), request_type(), method(), headers(), body()) ->
    {'ok', term()} | {'error', {atom(), list()}}.
%% @doc
%%      See request/9 details.
%% @end
request(Host
       ,InitArg
       ,Filter
       ,Path
       ,ReqType
       ,Method
       ,Headers
       ,Body) when erlang:is_list(Host) andalso
                   erlang:is_function(Filter, 3) andalso
                   erlang:is_list(Path) andalso
                   erlang:is_atom(Method) andalso
                   erlang:is_list(Headers) andalso
                   erlang:is_binary(Body) ->
    request(Host, InitArg, Filter, Path, ReqType, Method, Headers, Body, ?DEF_TIMEOUT).


-spec
request(host()
       ,init_argument()
       ,filter()
       ,path()
       ,request_type()
       ,method()
       ,headers()
       ,body()
       ,timeout()) ->
    {'ok', term()} | {'error', {atom(), list()}}.
%% @doc
%%      Makes HTTP request to host <code>Host</code> for path <code>path</code> with HTTP method<br/>
%%      <code>Method</code> and headers <code>Headers</code> and body <code>Body</code>.Then<br/>
%%      runs <code>Filter(List, HTTPStatusCode, JSON)</code> with parsed body.Filter fun should<br/>
%%      give <code>{ok, Result::term()}</code> or <code>{error, {Rsn, ErrParams}}</code>.<br/>
%%      <code>Rsn</code> is reason of error and <code>ErrParams</code> is a proplist containing<br/>
%%      information about error.
%% @end
request(Host
       ,InitArg
       ,Filter
       ,Path
       ,ReqType
       ,Method
       ,Headers
       ,Body
       ,Timeout) when erlang:is_list(Host) andalso
                      erlang:is_function(Filter, 3) andalso
                      erlang:is_list(Path) andalso
                      erlang:is_atom(Method) andalso
                      erlang:is_list(Headers) andalso
                      erlang:is_binary(Body) andalso
                      (erlang:is_integer(Timeout) orelse Timeout == infinity) ->
    URL = Host ++ Path,
    Info = [{host, Host}
           ,{init_argument, InitArg}
           ,{url, URL}
           ,{request_type, ReqType}
           ,{method, Method}
           ,{headers, Headers}
           ,{body, Body}
           ,{timeout, Timeout}],
    try ibrowse:spawn_link_worker_process(Host) of
        {ok, Pid} ->
            try ibrowse:send_req_direct(Pid
                                       ,URL
                                       ,Headers
                                       ,Method
                                       ,Body
                                       ,?DEF_REQ_OPTS
                                       ,Timeout) of
                {ok, Status, _, Body2} ->
                    try jiffy:decode(Body2) of
                        DecBody ->
                            try Filter(InitArg, Status, DecBody) of
                                {ok, _}=Ok ->
                                    Ok;
                                {error, {Rsn, ErrParams}} when erlang:is_atom(Rsn) andalso
                                                               erlang:is_list(ErrParams) ->
                                    {error, {Rsn, ErrParams ++ Info}};
                                Other ->
                                    {error, {filter, [{value, Other}|Info]}}
                            catch
                                _:Rsn ->
                                    {error, {filter, [{reason, Rsn}
                                                     ,{stacktrace, erlang:get_stacktrace()}
                                                     |Info]}}
                            end
                    catch
                        _:Rsn ->
                            {error, {body, [{reason, Rsn}|Info]}}
                    end;
                {error, Rsn} ->
                    {error, {request, [{reason, Rsn}|Info]}}
            catch
                _:Rsn ->
                    {error, {request, [{reason, Rsn}|Info]}}
            end;
        {error, Rsn} ->
            {error, {request, [{reason, Rsn}|Info]}}
    catch
        _:Rsn ->
            {error, {request, [{reason, Rsn}|Info]}}
    end.


-spec
value(init_argument(), [{Key::binary(), Val::term()}] | []) ->
    map().
%% @doc
%%      Finds in <code>Proplist</code> for keys in option list <code>List</code>. If found a<br/>
%%      value, adds that value with its key in returning map, if did not find and key has<br/>
%%      default adds key with its default value in returning map, otherwise adds key and atom<br/>
%%      'undefined' in returning map.
%% @end
value(OptList, Proplist) ->
    value(OptList, Proplist, #{}).

%% -------------------------------------------------------------------------------------------------
%% Internal functions:

value([{Key, Def}|Rest], Proplist, Ret) ->
    Val =
        case lists:keyfind(Key, 1, Proplist) of
            {_, Val_} ->
                Val_;
            false ->
                Def
        end,
    value(Rest, Proplist, Ret#{Key => Val});
value([Key|Rest], Proplist, Ret) ->
    value([{Key, null}|Rest], Proplist, Ret);
value([], _, Ret) ->
    Ret.