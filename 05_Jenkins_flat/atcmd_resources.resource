
*** Variables ***
${COM_PORT}        ${ENV:COM_PORT}

*** Settings ***
Library    AtCommandLibrary.py    ${COM_PORT}

***Keywords***
Suite setup
    Send AT command
    Switch local echo off
    Check echo status       OFF

Suite teardown
    Switch local echo on
    Check echo status       ATE
    Response should be      ON

Verify Send Text Response
    [Arguments]    ${command}    ${Response}
    Send text    ${command}
    Response should be    SENT="${Response}"
    Response should be    OK

Send AT command
    Send command            AT
    ${response} =    Run Keyword And Return Status    Response should be      OK
    IF  ${response} 
        Log    Success
    ELSE
        Response should be      OK
    END

Switch local echo off
    Send command            ATE0
    ${response} =    Run Keyword And Return Status    Response should be      OK
    IF  ${response} 
        Log    Success
    ELSE
        Response should be      OK
    END

Switch local echo on
    Send command            ATE1
    Response should be      OK

Check echo status
    [Arguments]         ${expected_status}
    Send command            ATE
    Response should be      ${expected_status}
