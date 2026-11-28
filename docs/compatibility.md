# Ruby 3.4 compatibility verification

This Paid fork supports Ruby `>= 3.4` without an upper version ceiling. Ruby 3.4
is explicitly verified by this change. Its runtime dependencies
are `git >= 1.13, < 4.0`, `psych >= 5.2, < 6.0`, and RSpec `>= 3.13, < 3.14`.
Development and CI use SimpleCov `~> 0.22` and TestProf `~> 1.4`; exact
resolved versions are recorded in `Gemfile.lock`.

## Acceptance verification plan

| Criterion | Verification | Evidence |
| --- | --- | --- |
| Modern Psych map persistence | Permanent focused spec writes a map through `YAMLStorage`, then safely reloads it. | `spec/map_storage/yaml_storage_spec.rb` |
| Existing SimpleCov session | Permanent integration spec starts SimpleCov in a fresh Ruby process before Crystalball, verifies pre-existing counters never decrease after registration, and executes a file that Crystalball collects. | `spec/integration/coverage_with_simplecov_spec.rb` |
| Ruby 3.4 CI and package smoke test | GitHub Actions checks out two commits so the `HEAD^` merge-base regression has its parent, installs the locked dependencies on Ruby 3.4, runs all specs and features, then builds and installs the gem into a new gem home. The installed artifact writes and loads a map and collects coverage. | `.github/workflows/ci.yml`, `spec/extensions/git/base_spec.rb`, `spec/map_generator/allocated_objects_strategy/object_tracker_spec.rb` |
| Current collector integrations | FactoryBot factory lookup supports its current registry; I18n collection copies frozen translation hashes. ActionView and I18n patches survive repeated registration and collection sessions. | `features/modified_execution_paths/`, `spec/rails/map_generator/` |

## Commands and results

Run the same checks locally with:

```sh
bundle install
bundle exec rubocop
bundle exec rspec spec features
gem build crystalball.gemspec
gem_home="$(mktemp -d)"
GEM_HOME="$gem_home" GEM_PATH="$gem_home" gem install --no-document crystalball-*.gem
```

The change was developed against Ruby 3.4.13 and Psych 5.2.2. The focused
Psych regression initially failed with `ArgumentError: wrong number of
arguments` from the old positional `YAML.safe_load` call. It passes with the
keyword API while retaining `safe_load` and permitting only `Symbol`. The
object tracker is also cold-loaded in a subprocess to verify its `Set`
dependency does not rely on RSpec, Bundler, or another library loading it.

The SimpleCov integration test is an isolated compatibility check, not a
claim of full Paid integration compatibility. Paid's application-level
configuration, its full TestProf usage, and downstream Rails dependency
matrix remain integration gaps for Paid to verify in its own test suite.

On 2026-11-28, the complete suite passed in an isolated container using Ruby
3.4.13 and the locked bundle: 302 examples, zero failures. RuboCop passed, and
the workflow's installed-gem collection/map-load smoke passed. These checks
remain distinct from downstream Paid acceptance.

Full-suite CI covers the modern dependency integrations. Its fixture schema
uses a valid join-table foreign key, views use current ActionView construction
and template lookup, and deletion scenarios use Git's public removal API.
Failed fixture collection prints the child test output so setup errors remain
diagnosable.

## Related forks reviewed

[`stephenbinns/crystalball-slim`](https://github.com/stephenbinns/crystalball-slim)
uses the same keyword `permitted_classes:` Psych fix. The change here is a
small independent reimplementation under this project's existing MIT license.
[`sartsing/crystalball`](https://github.com/sartsing/crystalball) retained the
positional call, so it was not used as a compatibility source. Neither fork is
treated as validation for this project.
