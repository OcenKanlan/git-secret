#!/usr/bin/env bats

load _test_base

FIRST_FILE="$TEST_DEFAULT_FILENAME"
SECOND_FILE="$TEST_SECOND_FILENAME"


function setup {
  install_fixture_key "$TEST_DEFAULT_USER"

  set_state_initial
  set_state_git
  set_state_secret_init
  set_state_secret_tell "$TEST_DEFAULT_USER"
  set_state_secret_add "$FIRST_FILE" "somecontent"
  set_state_secret_add "$SECOND_FILE" "somecontent2"
  set_state_secret_hide
}


function teardown {
  # This also needs to be cleaned:
  rm "$FIRST_FILE" "$SECOND_FILE"

  uninstall_fixture_key "$TEST_DEFAULT_USER"
  unset_current_state
}


function _secret_files_exists {
  echo "$(find . -type f -name "*.$SECRETS_EXTENSION" \
    -print0 2>/dev/null | grep -q .; echo "$?")"
}


@test "run 'clean' normally" {
  run git secret clean
  [ "$status" -eq 0 ]

  # There must be no .secret files:
  [ "$(_secret_files_exists)" -ne 0 ]
}


@test "run 'clean' with extra filename" {
  run git secret clean extra_filename
  [ "$status" -ne 0 ]
}


@test "run 'clean' with bad arg" {
  run git secret clean -Z
  [ "$status" -ne 0 ]
}


@test "run 'clean' with '-v'" {
  run git secret clean -v
  [ "$status" -eq 0 ]

  # There must be no .secret files:
  [ "$(_secret_files_exists)" -ne 0 ]

  local first_filename
  local second_filename
  first_filename=$(_get_encrypted_filename "$FIRST_FILE")
  second_filename=$(_get_encrypted_filename "$SECOND_FILE")

  # Output must be verbose:
  [[ "$output" == *"deleted"* ]]
  [[ "$output" == *"$first_filename"* ]]
  [[ "$output" == *"$second_filename"* ]]
}

# this test is like above, but uses SECRETS_VERBOSE env var
@test "run 'clean' with 'SECRETS_VERBOSE=1'" {
  SECRETS_VERBOSE=1 run git secret clean
  [ "$status" -eq 0 ]

  # Output must be verbose:
  [[ "$output" == *"deleted:"* ]]
}

# this test is like above, but sets SECRETS_VERBOSE env var to 0
# and expected non-verbose output
@test "run 'clean' with 'SECRETS_VERBOSE=0'" {
  SECRETS_VERBOSE=0 run git secret clean
  [ "$status" -eq 0 ]

  # Output must not be verbose:
  [[ "$output" != *"cleaning"* ]]
}
