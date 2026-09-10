*** Settings ***
Library    AtCommandLibrary.py    ${COM_PORT}

*** Keywords ***
Suite setup
    Send command    AT
    Response should be with optional echo    OK    AT
    Send command    ATE0
    Response should be with optional echo    OK    ATE0
    Check echo status    OFF

Suite teardown
    TRY
        Send command    ATE1
        Response should be with optional echo    OK    ATE1
        Check echo status    ON
    FINALLY
        Close port
    END

Check echo status
    [Arguments]    ${expected_status}
    Send command    ATE
    Response should be with optional echo    ${expected_status}    ATE
    Response should be    OK

Send text to Pico
    [Arguments]    ${text}    ${expected_response}
    Send text    ${text}
    Response should be    SENT="${expected_response}"
    Response should be    OK
