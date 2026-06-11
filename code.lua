--variables

poke(0x5f2d, 1) -- enable keyboard input

--chart to number helper
chars=" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
-- '
s2c={}
c2s={}
for i=1,95 do
 c=i+31
 s=sub(chars,i,i)
 c2s[c]=s
 s2c[s]=c
end

function ord(s,i)
 return s2c[sub(s,i or 1,i or 1)]
end

function equals(s1, s2)
    if #s1 != #s2 then return false end

    for i=1,#s1 do
        if ord(s1, i) != ord(s2, i) then return false end
    end
    return true
end



--test "quetions" sturgles
test_messages = {
    "you can't seem to remember\nwhat you just read",
    "you've read this three times.",
    "the words are kinda jumbled up\nin your head",
    "all the answers look the same.",
    "you know it, but can't see\nthe correct answer option.",
    "your eyes skip to the\nwrong line.",
    "the text blurs when you focus.",
    "the question makes no sense.",
    "you lose your place reading.",
    "you have a sudden rush of\nfrustration from trying\nto read."
}

-- test status tracking
test_status = "playing"

function _init()

-- player "time" (helth bar)
 player_time = 45
 max_time = 45

-- test points to obtain (test helth bar)
 test_points = 100
 max_points = 100
 pass_mark = 50

--current quetion
 current_question = 1
 total_questions = 20

-- teacher asks limit
 teacher_asks_left = 5  -- Player can ask the teacher 5 times
 show_teacher_message = false  -- Flag to control the message display

--skipped_questions list
 skipped_questions = {}
 game_state = "playing"

--game state
 game_state = "playerturn"

-- call the function to set the initial message
 pick_random_message()

end


-- helper function to pick a random message
function pick_random_message()
    local random_index = ceil(rnd(#test_messages))
    current_message = test_messages[random_index]


end
-->8
-- visual visual

function _draw()
    cls()
    spr(1,2,100,2,4)
    spr(65, 110, 2, 2, 2)

-- test points health bar
    rect(2,10,82,20,7) -- outline
    rectfill(3,11,3 + (test_points / max_points) * 78, 19, 8)
    print(tostr(test_points).."pt", 84, 12, 7)

-- player time health bar
    rect(25,119,86,126,7)
    rectfill(26,120,26 + (player_time / max_time) * 59, 125, 11)
    print(sub(tostr(player_time),1,4).."min", 90, 120, 7)

-- question text box
    rect(2,22,126,42,7)
    rectfill(3,23,125,41,0)
    print(current_message, 4, 24, 7)

-- player action options
    rect(21, 98, 125, 116, 7)
    rectfill(22, 99, 124, 115, 0)
    print("z:try again x:guess", 23, 101, 7)

    -- skip option
    if #skipped_questions == total_questions then
       print("c:skip", 23, 109, 5) -- Gray color
    else
       print("c:skip", 23, 109, 7) -- White color
    end 

    -- teacher ask option (grayed out if no asks left)
    if teacher_asks_left > 0 then
        print("v:ask teacher", 50, 109, 7)
    else
        print("v:ask teacher", 50, 109, 5) -- Gray color
    end

    -- Show the "teacher can not help you any more" message if the flag is set
    if show_teacher_message then
        local message = "the teacher can not\n help you any more"
        local x = (128 - #message * 4) / 2  
        print(message, 30, 64, 5) 
    end

-- ending screen display

if game_state == "end_screen" then
    cls()
    rect(10, 10, 118, 100, 7) -- outline only
    -- "press Z to retake" (restart the)
    local retake_text = "press Z to retake"
    local retake_x = (128 - #retake_text * 4) / 2
    print(retake_text, retake_x, 72, 7)

-- text inside: "passed" or "failed"
    local result_text = ""
    if equals(ending_message, "victory") then
        result_text = "passed: "..tostr(100 - test_points).."pt"
    elseif equals(ending_message, "defeat") then
        result_text = "failed: "..tostr(100 - test_points).."pt"
    elseif equals(ending_message, "perfect victory") then
        result_text = "perfect victory: "..tostr(100 - test_points).."pt"
    end

    local text_x = (128 - #result_text * 4) / 2
    print(result_text, text_x, 62, 7)
 end
end
-->8
-- game updates

-- check if a value exists in a table
function has(t, val)
    for v in all(t) do
        if v == val then return true end
    end
    return false
end

function _update()
    -- restart game if on end screen and z pressed
    if game_state == "end_screen" then
        if btnp(4) then -- z key
            _init()
        end
        return
    end

    -- Check for key presses
    if stat(30) then
        local key = stat(31) -- Declare key as a local variable

        -- Handle "ask teacher" input
        if key == 'v' then
            if teacher_asks_left > 0 and player_time >= 5 and test_points >= 5 then
                -- Deduct resources and decrement asks left
                player_time -= 5
                test_points -= 5
                teacher_asks_left -= 1
                current_question += 1

                if current_question > total_questions then
                    if test_points <= 0 then
                        ending_message = "perfect victory"
                    elseif test_points <= 40 then
                        ending_message = "victory"
                    else
                        ending_message = "defeat"
                    end
                    game_state = "end_screen"
                else
                    pick_random_message()
                end
            elseif teacher_asks_left == 0 then
                -- Show the message if no asks left
                show_teacher_message = true
            end
        end

        -- try again (z)
        if key == 'z' then
            if player_time >= 3 and test_points >= 3 then  -- Ensure player has enough resources
                player_time -= 3  -- Deduct 2 minutes
                test_points -= 3  -- Deduct 3 points
                current_question += 1

                if current_question > total_questions then
                    if test_points <= 0 then
                        ending_message = "perfect victory"
                    elseif test_points <= 40 then
                        ending_message = "victory"
                    else
                        ending_message = "defeat"
                    end
                    game_state = "end_screen"
                else
                    pick_random_message()
                end
            end
        end

        -- guess (x)
        if key == 'x' then
            if player_time >= 1 then
                player_time -= 1

                if rnd(1) <= 0.25 then
                    test_points -= 5
                end

                current_question += 1
                if current_question > total_questions then
                    if test_points <= 0 then
                        ending_message = "perfect victory"
                    elseif test_points <= 40 then
                        ending_message = "victory"
                    else
                        ending_message = "defeat"
                    end
                    game_state = "end_screen"
                else
                    pick_random_message()
                end
            end
        end

        -- skip (c)
        if key == 'c' then
            -- Check if all questions have been skipped
            if #skipped_questions < total_questions then
                add(skipped_questions, current_question)

                -- Check if all questions have been skipped
                if #skipped_questions == total_questions then
                    -- Do nothing, skip is now disabled
                else
                    local next_question
                    repeat
                        next_question = ceil(rnd(total_questions))
                    until next_question != current_question and not has(skipped_questions, next_question)

                    current_question = next_question
                    pick_random_message()
                end
            end
        end
    end

    -- end game if time runs out
    if player_time <= 0 then
        if test_points <= pass_mark then
            test_status = "passed"
            ending_message = "victory"
        else
            test_status = "failed"
            ending_message = "defeat"
        end
        test_finished = true
        game_state = "end_screen"
    end
end