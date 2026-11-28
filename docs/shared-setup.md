# Shared RSpec setup dependencies

`CoverageStrategy` records Ruby dependencies from RSpec suite and group setup
as well as individual examples. Registration leaves an existing SimpleCov
session running and does not reset counters. Use the normal RSpec runner:

```ruby
Crystalball::MapGenerator.start! do |config|
  config.register Crystalball::MapGenerator::CoverageStrategy.new
end
```

RSpec's reporter notifications delimit suite and group setup. Dependencies
executed before a group's first example or child group apply to every example
in that group and its descendants. Suite setup applies to all examples. The
collector preserves `before(:context)`, TestProf `before_all`/`let_it_be` and
FactoryBot setup; it does not replace hooks, fixtures or transaction adapters.
Existing per-example coverage snapshots also delimit shared setup, avoiding
additional snapshots per example. One extra snapshot is taken per group.

The permanent integration fixture uses SQLite in memory, real TestProf
transactions and FactoryBot. Two randomized orders verify nested groups,
parents without direct examples, inherited fixtures, unrelated siblings and
suite setup. The existing prediction strategy consumes the resulting map and
selects all affected examples. Separate lifecycle checks reject unbalanced
group notifications and prevent dependency leakage between collection sessions.

## Scope and uncertainty

This is Ruby line-execution evidence within the observed RSpec process. Setup
before the reporter's start event, uninstrumented native code, subprocesses,
JavaScript, external data and files read without executing Ruby are not complete
dependency evidence. Consumers must use conservative broad/full fallbacks for
such changes. Suite dependencies deliberately widen selection. A successful
trace is not permission to omit unknown inputs or to reuse a stale/incomplete
map. Collection recipe/provenance and publication policy remain separate
requirements for a CI consumer.

## Measurement

`shared-setup-measurements.json` records six local measurements on 2026-11-28.
Both modes run SimpleCov and the same nine-example RSpec/TestProf/FactoryBot
fixture. Collection is toggled only in this fixture using
`COLLECT_SHARED_SETUP=false`; normal collection remains enabled by registration.
Total time includes child process startup, test execution and map handling.
The three paired samples add 0.15–0.42 seconds; maps are approximately 6.4 KB.
This fixture does not establish Paid's full-suite overhead or selection savings.

Reproduce a sample from the repository root, with a fresh output directory:

```sh
shared_setup_output="$(mktemp -d)"
bundle exec ruby -Ilib spec/fixtures/shared_setup/runner.rb "$shared_setup_output" 17
```

Set `COLLECT_SHARED_SETUP=false` for the baseline. Keep the same Ruby, locked
dependencies, SimpleCov configuration and seed when comparing modes.
