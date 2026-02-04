
*** Settings ***
Library             AtCommandLibrary.py         ${COM_PORT}

***Keywords***
Suite setup
    Send command            AT
    Response should be      AT
    Response should be      OK
    Send command            ATE0
    Response should be      ATE0
    Response should be      OK
    Check echo status       OFF

Suite teardown
    Send command            ATE1
    Response should be      OK
    Check echo status       ATE
    Response should be      ON

Send text to Pico
	[Arguments]		        ${command}		${response}
	Send text  				${command}
	Response should be		SENT="${response}"
	Response should be		OK

Check echo status
    [Arguments]         ${expected_status}
    Send command            ATE
    Response should be      ${expected_status}