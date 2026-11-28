# Ruby 3.4 compatibility verification

Crystalball supports Ruby `>= 3.1` without an upper version ceiling. Ruby 3.4 is
explicitly verified by this change. Its runtime dependencies
are `git >= 1.13, < 4.0`, `psych >= 5.2, < 6.0`, and RSpec `>= 3.13, < 3.14`.
Development and CI use SimpleCov `~> 0.22` and TestProf `~> 1.4`; exact
resolved versions are recorded in `Gemfile.lock`.

## Acceptance verification plan

| Criterion | Verification | Evidence |
| --- | --- | --- |
| Modern Psych map persistence | Permanent focused spec writes a map through `YAMLStorage`, then safely reloads it. | `spec/map_storage/yaml_storage_spec.rb` |
| Existing SimpleCov session | Permanent integration spec starts SimpleCov in a fresh Ruby process before Crystalball, verifies pre-existing counters never decrease after registration, and executes a file that Crystalball collects. | `spec/integration/coverage_with_simplecov_spec.rb` |
| Ruby 3.4 CI and package smoke test | GitHub Actions installs the locked dependencies on Ruby 3.4, verifies `git` 3 merge-base arguments are passed individually, runs the focused compatibility specs, then builds and locally installs the gem into a new gem home. The installed artifact writes and loads a map and collects coverage. | `.github/workflows/ci.yml`, `spec/extensions/git/base_spec.rb` |

## Commands and results

Run the same checks locally with:

```sh
bundle install
bundle exec rubocop
bundle exec rspec spec/extensions/git/base_spec.rb spec/integration/coverage_with_simplecov_spec.rb spec/map_storage/yaml_storage_spec.rb
gem build crystalball.gemspec
gem_home="$(mktemp -d)"
GEM_HOME="$gem_home" GEM_PATH="$gem_home" gem install --no-document crystalball-*.gem
```

The change was developed against Ruby 3.4.13 and Psych 5.2.2. The focused
Psych regression initially failed with `ArgumentError: wrong number of
arguments` from the old positional `YAML.safe_load` call. It passes with the
keyword API while retaining `safe_load` and permitting only `Symbol`.

The SimpleCov integration test is an isolated compatibility check, not a
claim of full Paid integration compatibility. Paid's application-level
configuration, its full TestProf usage, and downstream Rails dependency
matrix remain integration gaps for Paid to verify in its own test suite.

The broader `bundle exec rspec spec features` command is intentionally not a
Ruby 3.4 CI gate: current dependencies expose unrelated failures in Ruby 3
keyword-matcher expectations and I18n patch
recursion. The CI command runs the focused compatibility coverage this change
can verify without presenting those known failures as a runnable suite.

## Related forks reviewed

[`stephenbinns/crystalball-slim`](https://github.com/stephenbinns/crystalball-slim)
uses the same keyword `permitted_classes:` Psych fix. The change here is a
small independent reimplementation under this project's existing MIT license.
[`sartsing/crystalball`](https://github.com/sartsing/crystalball) retained the
positional call, so it was not used as a compatibility source. Neither fork is
treated as validation for this project.
