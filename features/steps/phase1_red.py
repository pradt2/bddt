"""Phase 1 test harness, deliberately without a candidate design."""

import json

from behave import given, when, then


@given("the following private system fixture:")
def setup_private_fixture(context):
    # Test-side data, not information supplied to the user.
    context.private_fixture = json.loads(context.text)
    assert isinstance(context.private_fixture, dict)


@given("the user is given the following task brief:")
def setup_user_brief(context):
    context.user_brief = context.text.strip()
    assert context.user_brief


@when("the user attempts the task")
def attempt_task(context):
    # Phase 2 will replay a design-specific witness in a simulated system.
    # No user, design, mock application or successful result exists yet.
    context.observed = None


@then("the independent evaluator must observe:")
def evaluate_outcome(context):
    expected = json.loads(context.text)
    assert set(expected) == {"outcome", "process_effects"}
    assert isinstance(expected["outcome"], dict)
    assert isinstance(expected["process_effects"], list)
    assert context.observed is not None, (
        "PHASE_1_RED: no candidate workflow has been implemented"
    )
    assert context.observed == expected
