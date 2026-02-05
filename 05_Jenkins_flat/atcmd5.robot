*** Settings ***
Library           AtCommandLibrary.py    ${COM_PORT}
Resource          atcmd_resources.resource

Suite Setup       Suite setup
Suite Teardown    Suite teardown
Test Template     Verify Send Text Response

*** Variables ***
${COM_PORT}       ${ENV:COM_PORT}

*** Test Cases ***

Send text                 hello world           HELLO WORLD
Send Mixed Letters               test 123           TEST 123
Send Special Characters        hello, world!        HELLOX WORLDX
