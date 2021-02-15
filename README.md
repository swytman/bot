# ARBITRAGE BOT

## Configuration

See the .env.development file.


## Installation

``docker-compose --env-file .env.development build``

``docker-compose --env-file .env.development up``

## Working principle

The Bot creates websocket connections to ftx.com and deribit.com (test.deribit.com) exchanges
and subscribes to the **BTC-PERP** orderbook at ftx.com and to the **BTC-PERPETUAL** orderbook at deribit.com.

The Bot saves orderbooks to a redis store.

After an every update from deribit.com (every 100ms) the bot executes a decision algorithm and compare bids/asks between exchanges.
If bid values on one of exchanges more than ask values on another exchange on some percent (parameter DELTA in the configuration file)
bot calculates amount and price for limit orders and sends this orders to exchanges.

If the decision algorithm find an opportunity to make money it will log an amount and a price of orders,

``bot_1    | 17:05:10 deribit_sync.1 | "BUY 2.392 at 48577.0 on FTX"``

``bot_1    | 17:05:11 deribit_sync.1 | "SELL 2.392 at 48777.0 on Deribit``

execute parallel requests to exchanges and log response bodies and execution time.


``bot_1    | 17:05:11 deribit_sync.1 | "DERIBIT response 400"``

`` bot_1    | 17:05:11 deribit_sync.1 | {"jsonrpc"=>"2.0",``
  
`` bot_1    | 17:05:11 deribit_sync.1 |  "error"=>{"message"=>"not_enough_funds", "code"=>10009},``
  
``bot_1    | 17:05:11 deribit_sync.1 |  "usIn"=>1613408711523636,``
  
`` bot_1    | 17:05:11 deribit_sync.1 |  "usOut"=>1613408711524835,``
  
`` bot_1    | 17:05:11 deribit_sync.1 |  "usDiff"=>1199,``
  
`` bot_1    | 17:05:11 deribit_sync.1 |  "testnet"=>true}``
  
`` bot_1    | 17:05:11 deribit_sync.1 | "FTX response 400"``
  
`` bot_1    | 17:05:11 deribit_sync.1 | {"error"=>"Account does not have enough margin for order.", "success"=>false}``

`` bot_1    | 17:05:11 deribit_sync.1 | "Decision at 393ms" ``

And I hope all will be fine later, because no further actions are provided yet:)

## Tests

Only one test for order's amount and price calculation was done :(

``docker-compose --env-file .env.development build --build-arg ENV=test``

``docker-compose run bot rspec ./spec``

## Question

####Briefly write why in your opinion the bot will not work(=will not make money for you)

It won't work because of exchange's trade and withdrawal fees and competition with other bots, at least if you have low volumes.