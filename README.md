This is a benchmark intended to answer some questions [in this thread.](https://github.com/rails/rails/issues/50450#issuecomment-1880220829)

## How To Use

1. You must install `k6`. You can `brew install k6`.
2. `bundle install`
3. Run the breakpoint benchmark with `bin/bench`. You can provide a different number of puma threads as the first argument, e.g. `bin/bench 5` for 5 threads.

## Configuration

There are several sensitive parameters here:

| Parameter                              | Location                        | Default                                                                    | Notes                                                                                                        |
|----------------------------------------|---------------------------------|----------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| Puma server thread count               | bin/bench ARGUMENT              | 1                                                                          | Puma threadpool size                                                                                         |
| % of time spent waiting on I/O vs CPU  | config.ru                       | 25% I/O                                                                    | Maybe the most sensitive parameter in the whole analysis.                                                    |
| Response time of the app               | config.ru                       | 250 ms                                                                     | This is approximate, because it doesn't account for GC time. The app will try to do about this many ms of work. |
| Garbage objects generated per response | config.ru                       | 300000                                                                     | Intended to simulate tail latencies.                                                                         |
| Tick rate                              | config.ru                       | 10ms                                                                       | Every tick, we decide randomly to do either IO or CPU work for the entire tick.                              |
| Thresholds for failure                 | k6/script.js and j6/constant.js | Average response time must be less than 375ms p99 must be less than 1000ms | The benchmark will stop and fail if these thresholds are met                                                 |

## Design

The benchmark application is designed to simulate The Typical, Decently Optimized Rails App (tm).

We use a [open model](https://k6.io/docs/using-k6/scenarios/concepts/open-vs-closed/) for traffic, rather than the typical closed model used by tools such as ab. Closed models for traffic lead to highly unrealistic results, because requests never queue for an already-busy server, which means tail latencies are nonexistent.

There are two benchmarks:

* `bin/bench` is a ramping breakpoint test. It ramps the arrival rate of requests from 2/sec upward, and stops the benchmark when it's failure conditions have been met.
* `bin/constant` is a constant rate test. It will send requests at a constant rate.