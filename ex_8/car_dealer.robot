Documentation       Car dealer website test with complete objectives
Library             SeleniumLibrary
Library             Process
Library             Collections

Test Setup          Start Container
Test Teardown       Stop Container

*** Variables ***
${LOGIN URL}        http://localhost:3000
${BROWSER}          Chrome
@{CAR MAKES}        Toyota    Honda    Ford    BMW    Nissan
@{CAR MODELS}       Corolla    Civic    Focus    Altima    3-Series
${MILEAGE MIN}      1000
${MILEAGE MAX}      100000
${YEAR MIN}         2000
${YEAR MAX}         2023

*** Test Cases ***
Car Dealer Full Test
    Open Car Dealer Website
    Wait Until Element Is Visible    locator=link=Add a car    timeout=10s
    Add Multiple Random Cars    3
    Add Random Car With Plate    ABC-123
    Add Multiple Random Cars    2
    Capture Page Screenshot    screenshots/after_cars_added.png
    Remove Car By Plate    ABC-123
    Verify Car Not Present    ABC-123
    Capture Page Screenshot    screenshots/after_car_removed.png
    Close Application

*** Keywords ***
Open Car Dealer Website
    Open Browser    ${LOGIN URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    locator=link=Add a car    timeout=10s

Add New Car
    [Arguments]    ${make}    ${model}    ${mileage}    ${year}    ${plate}
    Wait Until Element Is Visible    locator=link=Add a car    timeout=10s
    Click Link    Add a car
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

Add Multiple Random Cars
    [Arguments]    ${count}
    FOR    ${index}    IN RANGE    ${count}
        ${make} =      Evaluate    random.choice(${CAR MAKES})    modules=random
        ${model} =     Evaluate    random.choice(${CAR MODELS})    modules=random
        ${mileage} =    Evaluate    random.randint(${MILEAGE MIN}, ${MILEAGE MAX})    modules=random
        ${year} =      Evaluate    random.randint(${YEAR MIN}, ${YEAR MAX})    modules=random
        ${plate} =     Generate Random Plate
        Add New Car    ${make}    ${model}    ${mileage}    ${year}    ${plate}
    END

Add Random Car With Plate
    [Arguments]    ${plate}
    ${make} =      Evaluate    random.choice(${CAR MAKES})    modules=random
    ${model} =     Evaluate    random.choice(${CAR MODELS})    modules=random
    ${mileage} =    Evaluate    random.randint(${MILEAGE MIN}, ${MILEAGE MAX})    modules=random
    ${year} =      Evaluate    random.randint(${YEAR MIN}, ${YEAR MAX})    modules=random
    Add New Car    ${make}    ${model}    ${mileage}    ${year}    ${plate}

Remove Car By Plate
    [Arguments]    ${plate}
    Wait Until Page Contains Element    xpath=//div[div/span[contains(text(),"Plate")]/following-sibling::span[contains(text(),"${plate}")]]
    Open Context Menu    xpath=//div[div/span[contains(text(),"Plate")]/following-sibling::span[contains(text(),"${plate}")]]
    Handle Alert    ACCEPT

Verify Car Not Present
    [Arguments]    ${plate}
    Page Should Not Contain Element    xpath=//div[div/span[contains(text(),"Plate")]/following-sibling::span[contains(text(),"${plate}")]]

Close Application
    Close Browser

Start Container
    Run Process     docker-compose     up     --detach
    Sleep    5s

Stop Container
    Run Process     docker-compose     down