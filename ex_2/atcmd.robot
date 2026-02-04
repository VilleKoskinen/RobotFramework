*** Settings ***
Documentation     Data-driven tests for AT command communication with Raspberry Pi Pico
Library           ./AtCommandLibrary.py
Test Template     Send Text Template

*** Test Cases ***              Input               Expected Response
Connection Test                 AT                  AT
Only Letters                    this is a test      THIS IS A TEST
Only Numbers                    1234567890          1234567890
Mixed Letters and Numbers       test123test         TEST123TEST
Whitespace and Tabs             this${SPACE}is${SPACE}a${SPACE}test    THIS IS A TEST
Special Characters              hello, world!       HELLOX WORLDX

*** Keywords ***
Send Text Template
    [Arguments]    ${text}    ${expected_response}
    Send text    ${text}
    Response should be    SENT="${expected_response}"