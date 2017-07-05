%%% --------------------------------------------------------------------
%%% BSD 3-Clause License
%%%
%%% Copyright (c) 2016-2017, Pouriya Jahanbakhsh
%%% (pouriya.jahanbakhsh@gmail.com)
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions
%%% are met:
%%%
%%% 1. Redistributions of source code must retain the above copyright
%%% notice, this list of conditions and the following disclaimer.
%%%
%%% 2. Redistributions in binary form must reproduce the above copyright
%%% notice, this list of conditions and the following disclaimer in the
%%% documentation and/or other materials provided with the distribution.
%%%
%%% 3. Neither the name of the copyright holder nor the names of its
%%% contributors may be used to endorse or promote products derived from
%%% this software without specific prior written permission.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%%% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%%% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
%%% FOR A  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
%%% COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
%%% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%%% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%%% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%%% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
%%% LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
%%% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%%% POSSIBILITY OF SUCH DAMAGE.
%%% --------------------------------------------------------------------
%% @author  Pouriya Jahanbakhsh <pouriya.jahanbakhsh@gmail.com>
%% @version
%% @hidden
%% ---------------------------------------------------------------------


-module(sockerl_acceptor_sup).
-author("pouriya.jahanbakhsh@gmail.com").


%% ---------------------------------------------------------------------
%% Exports:





%% API:
-export([start_link/2
        ,fetch/1
        ,sleep/1
        ,wakeup/1]).





%% for other sockerl modules:
-export([add/3]).





%% 'director' callback:
-export([init/1]).





%% ---------------------------------------------------------------------
%% API functions:





-spec
start_link(sockerl_types:start_options(), sockerl_types:socket()) ->
    sockerl_types:start_return().
start_link(Opts, LSock) ->
    director:start_link(?MODULE, {Opts, LSock}).







-spec
fetch(sockerl_types:name()) ->
    [] | [{Id::term(), pid()}].
%% @doc
%%      returns all acceptors.
%% @end
fetch(AccSup) ->
    director:get_pids(AccSup).







-spec
sleep(sockerl_types:name()) ->
    'ok'.
sleep(AccSup) ->
    [sockerl_acceptor:sleep(Pid)
    || {_Id, Pid} <- director:get_pids(AccSup)],
    ok.







-spec
wakeup(sockerl_types:name()) ->
    'ok'.
wakeup(AccSup) ->
    [sockerl_acceptor:wakeup(Pid)
    || {_Id, Pid} <- director:get_pids(AccSup)],
    ok.







-spec
add(Pool::sockerl_types:name(), sockerl_types:name(), term()) ->
    sockerl_types:start_return().
add(ConSup, AccSup, Id) ->
    director:start_child(AccSup
                        ,#{id => Id
                          ,start => {sockerl_acceptor
                                    ,start_link
                                    ,[ConSup]}
                          ,append => true
                          ,plan => []
                          ,count => 1}).





%% ---------------------------------------------------------------------
%% 'director' callback:




%% @hidden
init({Opts, LSock}) ->
    {ok
    ,[]
    ,#{start => {sockerl_acceptor
                ,start_link
                ,[Opts, LSock]}
      ,plan => [stop]}}.