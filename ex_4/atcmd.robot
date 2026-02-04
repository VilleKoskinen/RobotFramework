*** Settings ***
Resource          atcmd_resources.resource

Suite Setup       Suite setup
Suite Teardown    Suite teardown

*** Test Cases ***
Send text only
    [Tags]    text_only
    Verify Send Text Response   hello world    HELLO WORLD

Send number only
    [Tags]    number_only
    Verify Send Text Response    1234567890    1234567890

Send Special Characters, number and letter
    [Tags]    mixed
    Verify Send Text Response    hello5588, world00!    HELLO5588X WORLD00X