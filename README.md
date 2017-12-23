# Generic ReST client
This simple library performs HTTP request and waits for JSON response and passes parsed JSON to your filter function.

# Example
```sh
~/gen_rest_client $ curl http://www.convert-unix-time.com/api?timestamp=now
```
```json
{"localDate":"Saturday 23rd December 2017 08:35:22 PM","utcDate":"Saturday 23rd December 2017 08:35:22 PM","format":"l jS F Y h:i:s A","returnType":"json","timestamp":1514061322,"timezone":"UTC","daylightSavingTime":false,"url":"http:\/\/www.convert-unix-time.com?t=1514061322"}
``` 

Compile code and go to the erlang shell and load code of library and its dependencies
```erlang
Erlang/OTP 19 [erts-8.0] [source] [64-bit] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]
Eshell V8.0  (abort with ^G)
%% Start:
1> application:ensure_all_started(gen_rest_client).
{ok,[ibrowse,jiffy,gen_rest_client]}

%% InitArg: will be passed as first argument of you filter function
%% There is a useful API function gen_rest_client:value/2 which lookups specific keys from a JSON object.
%% Here my init argument is my specific keys that i want from response. I will use valu/2 function in filter function
2> InitArg = [<<"timestamp">>, {<<"timezone">>, <<"GMT">>}]. % GMT is default value
[<<"timestamp">>,{<<"timezone">>,<<"GMT">>}]

%% After successful request library calls my filter function with my init argument, HTTP status code "200" and parsed JSON.
%% By using API function gen_rest_client:value/2 i find elements of InitArg in PropList. You can write your own filter.
3> Filter = fun(InitArg, "200", {PropList}) -> {ok, gen_rest_client:value(InitArg, PropList)} end.
#Fun<erl_eval.18.52032458>

%% Don't forget http:// or https:// before host address:
4> gen_rest_client:request("http://converter-unix-time.com", InitArg, Filter, "/api?timestamp=now", get_timestamp).
{ok,#{<<"timestamp">> => 1514062322,<<"timezone">> => <<"UTC">>}}
```

For more info see the code.

### `Author`
**`pouriya.jahanbakhsh@gmail.com`**

### `Lisence`
**`BSD 3-Clause`**

### `Hex version`
[**`17.12.24`**](https://hex.pm/packages/gen_rest_client)

