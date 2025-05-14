; Health and Fitness Tracker in x86 Assembly (emu8086)
; Features:
; 1) Weekly Progress Comparison
; 2) Goal Completion Reminder
; 3) Calories Burned Per Exercise Type (IMPROVED)
; 4) Body Fat Percentage Estimator
; 5) Time-to-Goal Estimator
; 6) Automatic Calorie Intake Suggestion
; 7) Hydration Reminder & Tracker
; 8) Sleep Duration Tracker & Analysis

.model small
.stack 100h
.data
msg_feedback_prompt db 13,10,"HOW DO YOU FEEL ABOUT YOUR WEEK? (1=GREAT 2=OKAY 3=TIRED): $"
msg_feedback_tip_1 db 13,10,"KEEP SETTING NEW GOALS AND BREAKING THEM!$"

; ---------------- DATA SECTION ----------------
; Data arrays for tracking progress for each day
week1 db 7 dup(?), 10, 10, 10, 10, 10, 10, 10   ; Monday to Sunday initial values
week2 db 7 dup(?), 15, 15, 15, 15, 15, 15, 15   ; Previous week data for comparison
goal db 50
calories_burned db 0
duration db ?
rate db ?
goal_remaining db 30   ; Initialize to 30 days
prev_goal_remaining db 30  ; Track previous day count for calorie adjustment

menu db 13,10,"========== HEALTH & FITNESS TRACKER =========="
     db 13,10,"1. WEEKLY PROGRESS COMPARISON"
     db 13,10,"2. GOAL-COMPLETION REMINDER"
     db 13,10,"3. CALORIES BURNED PER EXERCISE TYPE"
     db 13,10,"4. BODY FAT PERCENTAGE ESTIMATOR"
     db 13,10,"5. TIME-TO-GOAL ESTIMATOR"
     db 13,10,"6. AUTOMATIC CALORIE INTAKE SUGGESTION"
     db 13,10,"7. HYDRATION REMINDER & TRACKER"
     db 13,10,"8. SLEEP DURATION TRACKER & ANALYSIS"
     db 13,10,"ENTER CHOICE (1-8): $"

msg_compare db 13,10,"PROGRESS INCREASED TODAY. KEEP IT UP!$"
msg_decreased db 13,10,"PROGRESS DECREASED TODAY. DON'T GIVE UP!$"
msg_goal_done db 13,10,"GOAL ACHIEVED! CONGRATULATIONS!$"
msg_goal_not_reached db 13,10,"GOAL NOT REACHED YET. KEEP PUSHING!$"
msg_calories db 13,10,"CALORIES BURNED: $"

msg_feedback_1 db 13,10,"AWESOME! STAY MOTIVATED!$"
msg_feedback_2 db 13,10,"STEADY WINS THE RACE!$"
msg_feedback_3 db 13,10,"REST IS IMPORTANT. TAKE CARE!$"

exercise_menu db 13,10,"SELECT EXERCISE - 1=RUN  2=WALK  3=JUMP: $"
duration_prompt db 13,10,"ENTER DURATION (IN MINUTES): $"
run_rate db 10    ; Running: 10 calories per minute
walk_rate db 5     ; Walking: 5 calories per minute
jump_rate db 7     ; Jumping: 7 calories per minute

msg_weight db 13,10,"ENTER WEIGHT (0-99): $"
msg_waist db 13,10,"ENTER WAIST SIZE (0-99): $"
msg_bodyfat db 13,10,"ESTIMATED BODY FAT: $"
weight db ?
waist db ?
bodyfat db ?
percent_sign db " %$"  ; Added for proper display

msg_estimate db 13,10,"ESTIMATED DAYS TO REACH GOAL: $"
daily_avg db 5
estimated_days db ?

msg_calsug db 13,10,"SUGGESTED DAILY CALORIE INTAKE: $"
days_label db " days$"
kcal_label db " kcal$"
age db 25
activity_factor db 15
calorie_suggestion db ?
calorie_increase_prompt db 13,10,"ENTER CALORIE INCREMENT (IN 100s): $"
calorie_increase_msg db 13,10,"CALORIES INCREASED BY: $"

msg_water_input db 13,10,"ENTER NUMBER OF GLASSES OF WATER TODAY: $"
hydration db 0
msg_water_low db 13,10,"DRINK MORE WATER!$"
msg_water_good db 13,10,"GOOD HYDRATION LEVEL.$"

msg_sleep_input db 13,10,"ENTER AVERAGE HOURS OF SLEEP (1-9): $"
sleep_avg db ?
msg_sleep_low db 13,10,"YOU NEED MORE SLEEP.$"
msg_sleep_good db 13,10,"SLEEP DURATION IS OPTIMAL.$"
msg_sleep_high db 13,10,"TOO MUCH SLEEP.$"

; Add this for the improved calories calculator
msg_invalid_exercise db 13,10,"INVALID EXERCISE TYPE SELECTED.$"

; Added for progress display and day selection
msg_progress_updated db 13,10,"PROGRESS UPDATED: INCREASED BY 10$"
msg_select_day db 13,10,"SELECT DAY (1=MON, 2=TUE, 3=WED, 4=THU, 5=FRI, 6=SAT, 7=SUN): $"
msg_day_selected db 13,10,"DAY SELECTED: $"
msg_current_progress db 13,10,"CURRENT PROGRESS: $"


.code
main:
    mov ax, @data
    mov ds, ax

menu_loop:
    lea dx, menu
    call print_msg
    call get_single_digit_input
    cmp al, 1
    je weekly_progress_comparison
    cmp al, 2
    je goal_completion_reminder
    cmp al, 3
    je calories_burned_calc
    cmp al, 4
    je body_fat_estimator
    cmp al, 5
    je time_to_goal_estimator
    cmp al, 6
    je calorie_intake_suggestion
    cmp al, 7
    je hydration_tracker
    cmp al, 8
    je sleep_tracker
    jmp menu_loop

weekly_progress_comparison:
    ; Ask user to select a day
    lea dx, msg_select_day
    call print_msg
    call get_single_digit_input
    
    ; Validate day input (1-7)
    cmp al, 1
    jb invalid_day
    cmp al, 7
    ja invalid_day
    
    ; Store selected day (convert to 0-based index + 8 offset)
    mov bl, al
    add bl, 7              ; Add 7 to get to the valid data portion (index 8)
    
    ; Show which day was selected
    lea dx, msg_day_selected
    call print_msg
    mov al, bl
    sub al, 7              ; Convert back to 1-7 for display
    call print_number
    
    ; Show current progress for selected day
    lea dx, msg_current_progress
    call print_msg
    
    ; Get and display current progress value
    lea si, week1
    mov bx, 0              ; Clear BX first
    mov bl, al             ; Put day number (1-7) in BL
    add bl, 7              ; Add 7 to get to the valid data portion (index 8)
    mov al, [si+bx]
    xor ah, ah
    call print_number
    
    ; Increment progress by 10 for selected day
    lea si, week1
    add al, 10             ; Increment by 10
    mov [si+bx], al        ; Store updated value
    
    ; Display update message
    lea dx, msg_progress_updated
    call print_msg
    
    ; Display new progress value
    lea dx, msg_current_progress
    call print_msg
    xor ah, ah
    mov al, [si+bx]
    call print_number
    
    ; Now compare with previous week's progress for the selected day
    lea si, week1
    lea di, week2
    mov al, [si+bx]
    cmp al, [di+bx]
    ja label_msg_up
    jb label_msg_down
    jmp ask_feedback       ; Skip messages if equal
    
label_msg_up:
    lea dx, msg_compare
    call print_msg
    jmp ask_feedback
    
label_msg_down:
    lea dx, msg_decreased
    call print_msg
    
ask_feedback:
    ; Ask user for feedback
    lea dx, msg_feedback_prompt
    call print_msg
    call get_single_digit_input
    cmp al, 1
    je feedback_1
    cmp al, 2
    je feedback_2
    cmp al, 3
    je feedback_3
    jmp menu_loop

invalid_day:
    ; Handle invalid day selection
    lea dx, msg_invalid_exercise    ; Reuse this message
    call print_msg
    jmp menu_loop
   
feedback_1:
    lea dx, msg_feedback_1
    call print_msg
    lea dx, msg_feedback_tip_1
    call print_msg
    jmp menu_loop

feedback_1_shared:
    jmp feedback_1

feedback_2:
    lea dx, msg_feedback_2
    call print_msg
    jmp menu_loop

feedback_2_shared:
    jmp feedback_2

feedback_3:
    lea dx, msg_feedback_3
    call print_msg
    jmp menu_loop

feedback_3_shared:
    jmp feedback_3

goal_completion_reminder:
    ; Save previous goal_remaining for comparison
    mov al, goal_remaining
    mov prev_goal_remaining, al
   
    cmp goal_remaining, 0
    jbe goal_achieved
   
    ; First print message
    lea dx, msg_goal_not_reached
    call print_msg
   
    ; Convert goal_remaining to decimal and print
    xor ah, ah              ; Clear AH
    mov al, goal_remaining  ; Load value into AL to form a clean AX
    call print_number       ; Use a simpler decimal printing routine
   
    ; Print "days" label
    lea dx, days_label
    call print_msg
   
    ; Decrement the counter
    dec goal_remaining
    jmp menu_loop

goal_achieved:
    lea dx, msg_goal_done
    call print_msg
   
    ; Reset goal to 30 days
    mov goal_remaining, 30
    mov prev_goal_remaining, 30
   
    ; Print congratulatory message
    lea dx, msg_feedback_tip_1
    call print_msg
    jmp menu_loop

; Simple routine to print a number in AX without leading zeros
print_number:
    push ax
    push bx
    push cx
    push dx
   
    mov bx, 10          ; Divisor
    xor cx, cx          ; Counter for digits
   
    ; Special case for zero
    test ax, ax
    jnz convert_digits
   
    mov dl, '0'         ; Just print '0'
    mov ah, 2
    int 21h
    jmp print_number_done
   
convert_digits:
    ; Divide by 10 and push remainder
    xor dx, dx          ; Clear DX for division
    div bx              ; AX/10, quotient in AX, remainder in DX
    push dx             ; Save digit
    inc cx              ; Count digit
    test ax, ax         ; Check if quotient is zero
    jnz convert_digits  ; If not, continue dividing
   
print_digits:
    ; Pop and print each digit
    pop dx
    add dl, '0'         ; Convert to ASCII
    mov ah, 2
    int 21h
    loop print_digits   ; Repeat for all digits
   
print_number_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print_msg:
    mov ah, 9
    int 21h
    ret

get_single_digit_input:
    mov ah, 1
    int 21h
    sub al, '0'
    and al, 0Fh
    ret

print_decimal:
    xor cx, cx        ; clear CX to count digits
    xor dx, dx        ; clear DX for division
    mov bl, 10
   
    ; Special case for zero
    test ax, ax
    jnz not_zero
    mov dl, '0'
    mov ah, 2
    int 21h
    ret
   
not_zero:
    push ax           ; preserve AX

convert_loop:
    xor ah, ah
    div bl            ; divide AX by 10
    push dx           ; save remainder
    inc cx            ; increment digit count
    xor dx, dx
    test ax, ax
    jnz convert_loop

print_loop:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop print_loop

    pop ax            ; restore AX
    ret

; FIXED calories burned calculator function
calories_burned_calc:
    ; Display exercise selection menu
    lea dx, exercise_menu
    call print_msg
    call get_single_digit_input
   
    ; Validate exercise choice (1-3)
    cmp al, 1
    jb invalid_exercise
    cmp al, 3
    ja invalid_exercise
   
    ; Store valid exercise type
    mov bl, al                   ; Store exercise type in BL (1=run, 2=walk, 3=jump)
   
    ; Get exercise duration
    lea dx, duration_prompt
    call print_msg
    call get_two_digit_input     ; Get exercise duration in AL (0-99 minutes)
    mov duration, al             ; Store duration
   
    ; Set rate based on exercise type
    cmp bl, 1
    je set_run_rate
    cmp bl, 2
    je set_walk_rate
    ; If not 1 or 2, must be 3 (jumping)
   
    ; Set jumping rate
    mov al, jump_rate            ; 7 calories/minute
    jmp perform_calculation
   
set_run_rate:
    mov al, run_rate             ; 10 calories/minute
    jmp perform_calculation
   
set_walk_rate:
    mov al, walk_rate            ; 5 calories/minute
   
perform_calculation:
    ; Store rate for reference
    mov rate, al
   
    ; Clear registers for proper multiplication
    xor ah, ah                   ; Clear AH to ensure clean multiplication
    mov bl, duration             ; Get duration
    xor bh, bh                   ; Clear BH to ensure clean multiplication
   
    ; Perform multiplication (rate * duration)
    mul bx                       ; AX = AL * BX
   
    ; Result is in AX - handle potential overflow
    cmp ax, 255
    jbe store_result             ; If <= 255, store directly
    mov ax, 255                  ; Otherwise cap at 255
   
store_result:
    mov calories_burned, al      ; Store result
   
    ; Display calories burned
    lea dx, msg_calories
    call print_msg
   
    ; Print calculated calories
    xor ah, ah                   ; Ensure AH is clear again
    mov al, calories_burned      ; Load value to print
    call print_number            ; Print the decimal number
   
    jmp menu_loop                ; Return to the menu
   
invalid_exercise:
    lea dx, msg_invalid_exercise
    call print_msg
    jmp menu_loop

; FIXED body fat percentage estimator
body_fat_estimator:
    ; Get weight input
    lea dx, msg_weight
    call print_msg
    call get_two_digit_input
    mov weight, al
   
    ; Get waist size input
    lea dx, msg_waist
    call print_msg
    call get_two_digit_input
    mov waist, al
   
    ; Calculate body fat percentage using more realistic formula
    ; Simple formula: body fat % = (waist - weight/2) / 2
    xor ah, ah              ; Clear AH to ensure clean operations
    mov al, weight          ; Load weight into AL
    shr al, 1               ; Divide weight by 2 (weight/2)
   
    mov bl, waist           ; Load waist into BL
    sub bl, al              ; BL = waist - (weight/2)
   
    ; Simple bodyfat = BL / 2 (divide by 2)
    mov al, bl
    shr al, 1               ; Divide by 2
    mov bodyfat, al         ; Store result
   
    ; Display body fat percentage
    lea dx, msg_bodyfat
    call print_msg
   
    ; Print calculated body fat percentage
    xor ah, ah
    mov al, bodyfat
    call print_number       ; Print the decimal number
   
    ; Print percent sign
    lea dx, percent_sign
    call print_msg
   
    jmp menu_loop

time_to_goal_estimator:
    ; Calculate days based on goal_remaining
    xor ah, ah              ; Clear AH
    mov al, goal_remaining  ; Use the remaining days from goal reminder
    mov bl, 1               ; No need to divide, just use as is
    div bl                  ; Just to maintain structure (result stays in AL)
    mov estimated_days, al  ; Store the result
   
    ; Display the estimated days
    lea dx, msg_estimate
    call print_msg
    xor ah, ah
    mov al, estimated_days
    call print_number
    lea dx, days_label
    call print_msg
    jmp menu_loop

calorie_intake_suggestion:
    ; Use weight and activity level to calculate calories
    ; Simple formula: 2000 + (weight - 70) * 20 for men
    xor ah, ah              ; Clear AH
    mov al, weight          ; Get user's weight
   
    ; Cap calorie suggestion between 1500-4000 calories
    cmp al, 0               ; Check if weight is too low
    ja calc_calories        ; If weight > 0, proceed with calculation
   
    ; Default value for very low weight
    mov calorie_suggestion, 15 ; Set to 1500/100
    jmp get_calorie_increase

calc_calories:
    ; Simple calorie calculation
    ; Scaling down by 100 to fit in a byte (2000 becomes 20, etc.)
    mov calorie_suggestion, 20  ; Base 2000 calories = 20*100
   
    ; Adjust based on weight
    cmp al, 70
    je get_calorie_increase    ; If weight = 70, use default calories
    jb reduce_calories         ; If weight < 70, reduce calories
   
    ; Weight > 70, increase calories
    sub al, 70              ; Calculate weight difference
    shr al, 1               ; Divide by 2 to scale adjustment
    add calorie_suggestion, al  ; Add adjustment
    jmp get_calorie_increase
   
reduce_calories:
    ; Weight < 70, reduce calories
    mov bl, 70
    sub bl, al              ; Calculate weight difference
    shr bl, 1               ; Divide by 2 to scale adjustment
    sub calorie_suggestion, bl  ; Subtract adjustment
   
get_calorie_increase:
    ; Ask user for calorie increment input
    lea dx, calorie_increase_prompt
    call print_msg
    call get_single_digit_input  ; Get increment in units of 100 kcal
   
    ; Store the increment in BL to display it later
    mov bl, al
   
    ; Add user-provided increment to calorie suggestion
    add calorie_suggestion, al
   
    ; Show increased calorie message
    lea dx, calorie_increase_msg
    call print_msg
   
    ; Show the increment amount (multiply by 100 for display)
    xor ah, ah
    mov al, bl
    mov bl, 100
    mul bl
    call print_number
   
    ; Display kcal unit label
    lea dx, kcal_label
    call print_msg
   
display_calories:
    ; Display suggested calorie intake
    lea dx, msg_calsug
    call print_msg
   
    ; Print the calorie value (multiply by 100 for display)
    xor ah, ah
    mov al, calorie_suggestion
    mov bl, 100
    mul bl
    call print_number
   
    ; Display kcal unit label
    lea dx, kcal_label
    call print_msg
    jmp menu_loop

hydration_tracker:
    lea dx, msg_water_input
    call print_msg
    call get_single_digit_input
    mov hydration, al
    cmp hydration, 8
    jb not_enough_water
    lea dx, msg_water_good
    call print_msg
    jmp menu_loop
not_enough_water:
    lea dx, msg_water_low
    call print_msg
    jmp menu_loop

sleep_tracker:
    lea dx, msg_sleep_input
    call print_msg
    call get_single_digit_input
    mov sleep_avg, al
    cmp al, 5
    jb too_little_sleep
    cmp al, 8
    ja too_much_sleep
    lea dx, msg_sleep_good
    call print_msg
    jmp menu_loop
too_little_sleep:
    lea dx, msg_sleep_low
    call print_msg
    jmp menu_loop
too_much_sleep:
    lea dx, msg_sleep_high
    call print_msg
    jmp menu_loop

get_two_digit_input:
    mov ah, 1
    int 21h
    sub al, '0'
    mov bl, al       ; store first digit
    mov ah, 1
    int 21h
    sub al, '0'
    mov bh, al       ; store second digit
    mov al, bl
    mov ah, 0
    mov cl, 10
    mul cl           ; AL = first_digit * 10
    add al, bh       ; AL = AL + second_digit
    ret

end main