 Settings 
Documentation       Car dealer website test with complete objectives
Library             SeleniumLibrary
Library             Process
Library             Collections

Test Setup          Start Container
Test Teardown       Stop Container

 Variables 
${LOGIN URL}        httplocalhost3000
${BROWSER}          Chrome
@{CAR MAKES}        Toyota    Skoda    Audi
@{CAR MODELS}       Corolla    Civic    Focus    Altima    3-Series
${MILEAGE MIN}      1000
${MILEAGE MAX}      100000
${YEAR MIN}         2000
${YEAR MAX}         2023

 Test Cases 
Remove All Skodas Test
    [Documentation]    This test adds 10 random cars, removes all Skodas, and verifies none exist.
    Open Car Dealer Website
    Wait Until Element Is Visible    locator=link=Add a car    timeout=10s
    Add Multiple Random Cars With Makes    10
    Capture Page Screenshot    screenshots2after_adding_10_cars.png
    Remove All Cars By Make    Skoda
    Verify Cars Not Present By Make    Skoda
    Capture Page Screenshot    screenshots2after_removing_skodas.png
    Close Application

 Keywords 
Open Car Dealer Website
    Open Browser    ${LOGIN URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    locator=link=Add a car    timeout=10s

Add New Car
    [Arguments]    ${make}    ${model}    ${mileage}    ${year}    ${plate}
    Wait Until Element Is Visible    locator=link=Add a car    timeout=10s
    Click Link    Add a car
    Wait Until Element Is Visible    id=make-input    timeout=10s
    Input Text    id=make-input    ${make}
    Input Text    id=model-input   ${model}
    Input Text    id=mileage-input    ${mileage}
    Input Text    id=year-input     ${year}
    Input Text    id=plate-input    ${plate}
    Click Button    Add a new car

Generate Random Plate
    ${letters} =    Evaluate    ''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZ', k=3))    modules=random
    ${numbers} =    Evaluate    ''.join(random.choices('0123456789', k=3))    modules=random
    ${plate} =      Set Variable    ${letters}-${numbers}
    Return From Keyword    ${plate}

Add Multiple Random Cars With Makes
    [Arguments]    ${count}
    [Documentation]    Adds multiple random cars with specified makes.
    FOR    ${index}    IN RANGE    ${count}
        ${make} =      Evaluate    random.choice(${CAR MAKES})    modules=random
        ${model} =     Evaluate    random.choice(${CAR MODELS})    modules=random
        ${mileage} =   Evaluate    random.randint(${MILEAGE MIN}, ${MILEAGE MAX})    modules=random
        ${year} =      Evaluate    random.randint(${YEAR MIN}, ${YEAR MAX})    modules=random
        ${plate} =     Generate Random Plate
        Add New Car    ${make}    ${model}    ${mileage}    ${year}    ${plate}
    END

Remove All Cars By Make
    [Arguments]    ${make}
    ${element_exists}=    Set Variable    ${True}
    WHILE    ${element_exists}
        ${element_exists}=    Run Keyword And Return Status    Page Should Contain Element    xpath=div[divspan[contains(text(),Make)]following-siblingspan[contains(text(),${make})]]
        Run Keyword If    ${element_exists}    Open Context Menu    xpath=div[divspan[contains(text(),Make)]following-siblingspan[contains(text(),${make})]]
        Run Keyword If    ${element_exists}    Handle Alert    ACCEPT
        Run Keyword If    ${element_exists}    Wait Until Keyword Succeeds    10s    1s    Run Keyword And Ignore Error    Page Should Not Contain Element    xpath=div[divspan[contains(text(),Make)]following-siblingspan[contains(text(),${make})]]
        Sleep    1s
    END

Verify Cars Not Present By Make
    [Arguments]    ${make}
    Page Should Not Contain Element    xpath=div[divspan[contains(text(),Make)]following-siblingspan[contains(text(),${make})]]

Close Application
    Close Browser

Start Container
    Run Process     docker-compose     up     --detach
    Sleep    5s

Stop Container
    Run Process     docker-compose     down