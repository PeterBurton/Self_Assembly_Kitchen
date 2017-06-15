;
;       Author          : Peter Burton 
;
;       File            : kitchen.asm
;
;       Information     : Develop a picture of a kitchen scene in 8086
;                         Assembly language
;

TITLE   G2

SSEG    SEGMENT PARA STACK 'STACK'         ;Stack segment
        DB      64 DUP('STACK   ')
SSEG    ENDS


DSEG    SEGMENT PARA PUBLIC 'DATA'         ;Code segment
DSEG    ENDS
                                        

CSEG    SEGMENT PARA PUBLIC 'CODE'
        ASSUME CS:CSEG, DS:DSEG, SS:SSEG

MAIN    PROC    FAR

        PUSH    DS                         ;These 5 lines are
        MOV     AX,0                       ;required for all .ASM
        PUSH    AX                         ;programs.
        MOV     AX,DSEG                    ;
        MOV     DS,AX                      ;

        MOV     AH,00H                     ;
        MOV     AL,18                      ;SET SCREEN TO GRAPHICS
        INT     10H

        MOV     BX,20H
        MOV     DX,0  
        MOV     CX,0
        MOV     AL,8
        CALL    DRAWCABINET
        MOV     CX,420
        CALL    DRAWCABINET
        CALL    DRAWHOOD
        MOV     CX,0
        MOV     DX,150
        CALL    TILES
        MOV     DX,285
        MOV     DI,15
        MOV     SI,640
        MOV     AL,0
        CALL    FILLBOX
        MOV     AL,8
        MOV     DX,300
        CALL    DRAWCABINET
        MOV     CX,420
        CALL    DRAWCABINET
        MOV     CX,221
        CALL    DRAWERS
        MOV     CX,0
        MOV     DX,451
        MOV     DI,29
        MOV     SI,640
        CALL    FILLBOX
        CALL    DRAWHOB
        CALL    DRAW_END_BUTTON
        CALL    DRAW_SINK
        CALL    DRAW_MICROWAVE
        CALL    MOUSE_EVENT

        MOV     AH,00H
        MOV     AL,2                       ;SET SCREEN TO TEXT
        INT     10H

        RET                                ;The program ends here.

MAIN    ENDP

;--------------------------------------------------------------------------
;MOUSE_EVENT
;       Description:    Subroutine to detect mouse click and trigger an
;                       action, depending on which button was clicked
;       Input Param:    AX = Used for setting the service when interrupted
;                       BX = Used to store value to see if mouse clicked
;                       CX = Co-ordinate of click point (horizontzl)
;                       DX = Co-ordinate of click point (vertical)
;       Registers affected:     All
;--------------------------------------------------------------------------
MOUSE_EVENT      PROC

START_MOUSE:
        MOV     AX,01H
        INT     33H

MOUSE_CHECK:
        MOV     AX,05H
        MOV     BX,0H
        INT     33H
        CMP     BX,1
        JE      CHECK_BUTTON_HOOD
        JMP     MOUSE_CHECK

CHECK_BUTTON_HOOD:
        CMP     DX,115
        JB      CHECK_BUTTON_HOB
        CMP     DX,125
        JA      CHECK_BUTTON_HOB
        CMP     CX,385
        JB      CHECK_BUTTON_HOB
        CMP     CX,395
        JA      CHECK_BUTTON_HOB
        CALL    HOOD_BUTTON_PRESSED
        JMP     START_MOUSE

CHECK_BUTTON_HOB:
        CMP     DX,270
        JB      CHECK_BUTTON_MICROWAVE
        CMP     DX,275
        JA      CHECK_BUTTON_MICROWAVE
        CMP     CX,375
        JB      CHECK_BUTTON_MICROWAVE
        CMP     CX,385
        JA      CHECK_BUTTON_MICROWAVE
        CALL    HOB_BUTTON_PRESSED
        JMP     START_MOUSE

CHECK_BUTTON_MICROWAVE:
        CMP     DX,245
        JB      CHECK_BUTTON_TAP
        CMP     DX,250
        JA      CHECK_BUTTON_TAP
        CMP     CX,155
        JB      CHECK_BUTTON_TAP
        CMP     CX,165
        JA      CHECK_BUTTON_TAP
        CALL    MICROWAVE_BUTTON_PRESSED
        JMP     START_MOUSE

CHECK_BUTTON_TAP:
        CMP     DX,265
        JB      CHECK_BUTTON_END
        CMP     DX,275
        JA      CHECK_BUTTON_END
        CMP     CX,530
        JB      CHECK_BUTTON_END
        CMP     CX,560
        JA      CHECK_BUTTON_END
        CALL    TAP_BUTTON_PRESSED
        JMP     START_MOUSE

CHECK_BUTTON_END:
        CMP     DX,20
        JA      CONTINUE    ;JUST A WAY TO AVOID JUMP OUT OF RANGE ERROR
        CMP     CX,620
        JL      CONTINUE
        JMP     MOUSE_FIN

CONTINUE:
        JMP     MOUSE_CHECK  ;USING THIS TO AVOID OUT OF RANGE ERROR

MOUSE_FIN:      ;NOTHING IN THIS SECTION AS IT JUST NEEDS TO RETURN TO
                ;THE MAIN SECTION
        RET
MOUSE_EVENT      ENDP

;--------------------------------------------------------------------------
;HOOD_BUTTON_PRESSED
;       Description:    Take action when the button on the cooker hood is
;                       pressed
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = width
;                       DI = Depth
;       Registers affected:     none
;--------------------------------------------------------------------------
HOOD_BUTTON_PRESSED   PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    AX
        PUSH    DI

        MOV     AX,02H
        INT     33H
        MOV     DX,130
        MOV     CX,300
        MOV     SI,40
        MOV     DI,100
        MOV     AL,14
        CALL    DRAWTRAPEZIUM
        
FINISH_HOOD_BUTT:
        POP     DI
        POP     AX
        POP     DX
        POP     SI
        POP     CX
        RET

HOOD_BUTTON_PRESSED   ENDP

;--------------------------------------------------------------------------
;HOB_BUTTON_PRESSED
;       Description:    Take action when the button on the hob is
;                       pressed
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = width
;                       DI = Depth
;       Registers affected:     none
;--------------------------------------------------------------------------
HOB_BUTTON_PRESSED   PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    AX
        PUSH    DI

        MOV     AX,02H
        INT     33H
        MOV     DX,265
        MOV     CX,269
        MOV     DI,5
        MOV     SI,2
        MOV     AL,1
        CALL    DRAWFLAMES
        
FINISH_HOB_BUTT:
        POP     DI
        POP     AX
        POP     DX
        POP     SI
        POP     CX
        RET

HOB_BUTTON_PRESSED   ENDP

;--------------------------------------------------------------------------
;MICROWAVE_BUTTON_PRESSED
;       Description:    Take action when the button on the microwave is
;                       pressed
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = width
;                       DI = Depth
;       Registers affected:     none
;--------------------------------------------------------------------------
MICROWAVE_BUTTON_PRESSED   PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    AX
        PUSH    DI

        MOV     AX,02H
        INT     33H
        MOV     AL,15
        MOV     CX,55
        MOV     DX,265
        MOV     DI,5
        MOV     SI,90
        CALL    FILLBOX
        MOV     DX,235       
        MOV     DI,30
        MOV     SI,30
        MOV     AL,2
        CALL    FILLBOX
        MOV     SI,5

DEC_SI_LEFT:
        DEC     SI

MIC_LEFT:
        CMP     SI,0
        JE      FINISH_MIC_BUTT
        CMP     CX,115
        JE      DEC_SI_RIGHT
        ADD     CX,30
        CALL    DRAWVLINE
        MOV     AL,0
        SUB     CX,30
        CALL    DRAWVLINE
        MOV     AL,2
        INC     CX
        CALL    DELAY
        JMP     MIC_LEFT

DEC_SI_RIGHT:
        DEC     SI

MIC_RIGHT:
        CMP     SI,0
        JE      FINISH_MIC_BUTT        
        CMP     CX,55
        JE      DEC_SI_LEFT
        
        CALL    DRAWVLINE
        MOV     AL,0
        ADD     CX,30
        CALL    DRAWVLINE
        SUB     CX,30
        MOV     AL,2
        DEC     CX
        CALL    DELAY
        JMP     MIC_RIGHT

FINISH_MIC_BUTT:
        POP     DI
        POP     AX
        POP     DX
        POP     SI
        POP     CX
        RET

MICROWAVE_BUTTON_PRESSED   ENDP

;--------------------------------------------------------------------------
;TAP_BUTTON_PRESSED
;       Description:    Take action when the button on the tap is
;                       pressed
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = width
;                       DI = Depth
;       Registers affected:     none
;--------------------------------------------------------------------------
TAP_BUTTON_PRESSED   PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    AX
        PUSH    DI

        MOV     AX,02H
        INT     33H
        MOV     DI,9
        MOV     CX,500
        MOV     DX,250
        MOV     SI,10
        
DEC_DI_BLUE:
        DEC     DI
        MOV     DX,250

TAP_BLUE:
        CMP     DI,0
        JE      FINISH_TAP_BUTT
        CMP     DX,280
        JE      DEC_DI_GREY
        MOV     AL,9
        CALL    DRAWHLINE
        INC     DX
        CALL    DELAY
        JMP     TAP_BLUE

DEC_DI_GREY:
        DEC     DI
        MOV     DX,250

TAP_GREY:
        CMP     DI,0
        JE      FINISH_TAP_BUTT        
        CMP     DX,280
        JE      DEC_DI_BLUE
        MOV     AL,8
        CALL    DRAWHLINE
        INC     DX
        CALL    DELAY
        JMP     TAP_GREY

FINISH_TAP_BUTT:
        POP     DI
        POP     AX
        POP     DX
        POP     SI
        POP     CX
        RET

TAP_BUTTON_PRESSED   ENDP

;--------------------------------------------------------------------------
;WRITEPIXEL
;       Description:    Write pixel to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;       Registers affected:     none
;--------------------------------------------------------------------------
WRITEPIXEL      PROC
        PUSH    AX
        PUSH    BX
        MOV     AH,0CH
        MOV     BH,0
        INT     10H
        POP     BX
        POP     AX
        RET
WRITEPIXEL      ENDP

;--------------------------------------------------------------------------
;DRAWHLINE
;       Description:    Write HORIZONTAL LINE to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWHLINE      PROC

        PUSH    CX
        PUSH    SI

AGAIN_DHL:

        CMP     SI,00H
        JE      FINISH_DHL
        CALL    WRITEPIXEL
        INC     CX
        DEC     SI
        JMP     AGAIN_DHL
        
FINISH_DHL:

        POP     SI
        POP     CX
        RET

DRAWHLINE      ENDP

;--------------------------------------------------------------------------
;DRAWVLINE
;       Description:    Write VERTICAL to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       DI = HEIGHT
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWVLINE      PROC

        PUSH    DX
        PUSH    DI

AGAIN_DVL:

        CMP     DI,00H
        JE      FINISH_DVL
        CALL    WRITEPIXEL
        INC     DX
        DEC     DI
        JMP     AGAIN_DVL
        
FINISH_DVL:

        POP     DI
        POP     DX
        RET

DRAWVLINE      ENDP
;--------------------------------------------------------------------------
;DRAWTRAPEZIUM
;       Description:    Write a trapezium to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = width
;                       DI = Depth
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWTRAPEZIUM   PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    AX
        PUSH    DI

AGAIN_TRAP:
        CMP     DI,00H
        JE      FINISH_TRAP
        CALL    DRAWHLINE
        DEC     CX
        INC     DX
        DEC     DI
        ADD     SI,02H
        JMP     AGAIN_TRAP

FINISH_TRAP:
        POP     DI
        POP     AX
        POP     DX
        POP     SI
        POP     CX
        RET

DRAWTRAPEZIUM   ENDP

;--------------------------------------------------------------------------
;DRAWFLAMES
;       Description:    Write a series of coloured triangles to screen to
;                       represent flames
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = width
;                       DI = Depth
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWFLAMES   PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    AX
        PUSH    DI

        CALL    DRAWTRAPEZIUM
        ADD     CX,10
        CALL    DRAWTRAPEZIUM
        ADD     CX,10
        CALL    DRAWTRAPEZIUM
        ADD     CX,40
        CALL    DRAWTRAPEZIUM
        ADD     CX,10
        CALL    DRAWTRAPEZIUM
        ADD     CX,10
        CALL    DRAWTRAPEZIUM
          
FINISH_FLAMES:
        POP     DI
        POP     AX
        POP     DX
        POP     SI
        POP     CX
        RET

DRAWFLAMES   ENDP

;--------------------------------------------------------------------------
;DRAW_END_BUTTON
;       Description:    draw a button with an x in it at the top right side
;                       of the screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = width
;                       DI = Depth
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAW_END_BUTTON   PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    AX
        PUSH    DI

        MOV     DX,0
        MOV     CX,620
        MOV     SI,20
        MOV     DI,20
        MOV     AL,12
        CALL    FILLBOX
        MOV     AL,15
        CALL    DRAWDIAGRLINE
        MOV     CX,640
        CALL    DRAWDIAGLLINE

FINISH_END_BUT:
        POP     DI
        POP     AX
        POP     DX
        POP     SI
        POP     CX
        RET

DRAW_END_BUTTON   ENDP

;--------------------------------------------------------------------------
;DRAWDIAGRLINE
;       Description:    Write DIAGONAL LINE GOING TO THE RIGHT to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWDIAGRLINE   PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX

AGAIN_DRL:

        CMP     SI,00H
        JE      FINISH_DRL
        CALL    WRITEPIXEL
        INC     CX
        INC     DX
        DEC     SI
        JMP     AGAIN_DRL
        
FINISH_DRL:

        POP     DX
        POP     SI
        POP     CX
        RET

DRAWDIAGRLINE   ENDP

;--------------------------------------------------------------------------
;DRAWDIAGLLINE
;       Description:    Write DIAGONAL LINE GOING TO THE LEFT to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWDIAGLLINE   PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX

AGAIN_DLL:

        CMP     SI,00H
        JE      FINISH_DLL
        CALL    WRITEPIXEL
        DEC     CX
        INC     DX
        DEC     SI
        JMP     AGAIN_DLL
        
FINISH_DLL:

        POP     DX
        POP     SI
        POP     CX
        RET

DRAWDIAGLLINE   ENDP

;--------------------------------------------------------------------------
;FILLBOX
;       Description:    Write FILLED BOX to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       DI = HEIGHT
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
FILLBOX      PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    DI

AGAIN_DFB:

        CALL    DRAWHLINE
        ADD     DX,1
        SUB     DI,1
        CMP     DI,0
        JA      AGAIN_DFB
        

FINISH_DFB:

        POP     DI
        POP     DX
        POP     SI
        POP     CX
        RET

FILLBOX      ENDP

;--------------------------------------------------------------------------
;DRAWCABINET
;       Description:    Write CABINET to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       DI = HEIGHT
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWCABINET      PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    DI
        PUSH    AX

        MOV     DI,150
        MOV     SI,110
        CALL    FILLBOX
        ADD     CX,110
        CALL    FILLBOX
        MOV     AL,0
        CALL    DRAWVLINE
        MOV     DI,110
        MOV     SI,70
        SUB     CX,90
        ADD     DX,20
        MOV     AL,7
        CALL    FILLBOX
        ADD     CX,110
        CALL    FILLBOX
        CMP     DX,200
        JB      TOPHANDLE
        JA      BOTHANDLE

BOTHANDLE:
        SUB     CX,30
        MOV     DI,40
        MOV     SI,5
        CALL    FILLBOX
        ADD     CX,15
        CALL    FILLBOX
        JMP     FINISH_DCB

TOPHANDLE:
        ADD     DX,70
        SUB     CX,30
        MOV     DI,40
        MOV     SI,5
        CALL    FILLBOX
        ADD     CX,15
        CALL    FILLBOX
        JMP     FINISH_DCB
        
FINISH_DCB:

        POP     AX
        POP     DI
        POP     DX
        POP     SI
        POP     CX
        RET

DRAWCABINET      ENDP

;--------------------------------------------------------------------------
;DRAWERS
;       Description:    Write DRAWERS to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       DI = HEIGHT
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWERS      PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    DI
        PUSH    AX

DWRS:
        MOV     DI,49
        MOV     SI,198
        MOV     AL,8
        CALL    FILLBOX
        ADD     DX,50
        CALL    FILLBOX
        ADD     DX,50
        CALL    FILLBOX
        ADD     CX,60
        MOV     DI,10
        MOV     SI,79
        SUB     DX,80
        MOV     AL,7
        CALL    FILLBOX
        ADD     DX,50
        CALL    FILLBOX
        ADD     DX,50
        CALL    FILLBOX
     
FINISH_DWRS:

        POP     AX
        POP     DI
        POP     DX
        POP     SI
        POP     CX
        RET

DRAWERS      ENDP

;--------------------------------------------------------------------------
;TILES
;       Description:    Write a tile splashback to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       DI = HEIGHT
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
TILES      PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    DI
        PUSH    AX

        MOV     DI,20
        MOV     SI,20

DRAWRTILE:
        CMP     DX,280     
        JAE     FINISH_TILES
        MOV     AL,4
        CALL    FILLBOX
        ADD     CX,20
        CMP     CX,640
        JB      DRAWWTILE
        ADD     DX,20
        SUB     CX,640
        JMP     DRAWRTILE
DRAWWTILE:
        CMP     DX,280
        JAE     FINISH_TILES
        MOV     AL,15
        CALL    FILLBOX
        ADD     CX,20
        CMP     CX,640
        JB      DRAWRTILE
        ADD     DX,20
        SUB     CX,640
        JMP     DRAWWTILE

FINISH_TILES:

        POP     AX
        POP     DI
        POP     DX
        POP     SI
        POP     CX
        RET

TILES     ENDP

;--------------------------------------------------------------------------
;DRAWHOOD
;       Description:    Write COOKER HOOD to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       DI = HEIGHT
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWHOOD      PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    DI
        PUSH    AX

HOOD:
        MOV     CX,295
        MOV     DI,50
        MOV     SI,50
        MOV     AL,8
        CALL    FILLBOX
        MOV     DX,50
        MOV     DI,60
        CALL    DRAWTRAPEZIUM
        MOV     CX,235
        MOV     DX,110
        MOV     DI,20
        MOV     SI,170
        CALL    FILLBOX
        MOV     AL,4
        ADD     DX,5
        ADD     CX,150
        MOV     DI,10
        MOV     SI,10
        CALL    FILLBOX
     
FINISH_HOOD:

        POP     AX
        POP     DI
        POP     DX
        POP     SI
        POP     CX
        RET

DRAWHOOD      ENDP

;--------------------------------------------------------------------------
;DRAWHOB
;       Description:    Write Hob and rings to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       DI = HEIGHT
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAWHOB      PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    DI
        PUSH    AX

HOB:

        MOV     DX,275
        MOV     CX,245
        MOV     DI,10
        MOV     SI,150
        MOV     AL,7
        CALL    FILLBOX
        MOV     DX,270
        MOV     CX,265
        MOV     DI,5
        MOV     SI,30
        MOV     AL,0
        CALL    DRAWTRAPEZIUM
        MOV     CX,325
        CALL    DRAWTRAPEZIUM
        MOV     CX,375
        MOV     SI,5
        CALL    FILLBOX

FINISH_HOB:

        POP     AX
        POP     DI
        POP     DX
        POP     SI
        POP     CX
        RET

DRAWHOB      ENDP

;--------------------------------------------------------------------------
;DRAW_SINK
;       Description:    Write sink tap and splashback to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       DI = HEIGHT
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAW_SINK      PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    DI
        PUSH    AX

SINK:

        MOV     AL,8
        MOV     SI,150
        MOV     DI,80
        MOV     CX,450
        MOV     DX,205
        CALL    FILLBOX
        MOV     AL,7
        MOV     CX,460
        MOV     DX,280
        MOV     DI,5
        MOV     SI,130
        CALL    FILLBOX
        MOV     CX,540
        MOV     DX,230
        MOV     DI,50
        MOV     SI,10
        CALL    FILLBOX
        MOV     DI,10
        MOV     SI,30
        MOV     CX,530
        MOV     DX,265
        CALL    FILLBOX
        MOV     CX,500
        MOV     DX,230
        MOV     DI,10
        MOV     SI,40
        CALL    FILLBOX
        MOV     DX,240
        MOV     SI,10
        CALL    FILLBOX

FINISH_SINK:

        POP     AX
        POP     DI
        POP     DX
        POP     SI
        POP     CX
        RET

DRAW_SINK      ENDP

;--------------------------------------------------------------------------
;DRAW_MICROWAVE
;       Description:    Write microwave to screen
;       Input Param:    Dx = Row
;                       CX = Column
;                       AL = Colour
;                       DI = HEIGHT
;                       SI = LENGTH
;       Registers affected:     none
;--------------------------------------------------------------------------
DRAW_MICROWAVE      PROC

        PUSH    CX
        PUSH    SI
        PUSH    DX
        PUSH    DI
        PUSH    AX

MICROWAVE:
        MOV     DX,280
        MOV     CX,50
        MOV     DI,5
        MOV     SI,5
        MOV     AL,0
        CALL    FILLBOX
        MOV     CX,160
        CALL    FILLBOX
        MOV     DX,200
        MOV     CX,45
        MOV     DI,80
        MOV     SI,125
        MOV     AL,7
        CALL    FILLBOX
        MOV     DX,205
        MOV     CX,50
        MOV     DI,70
        MOV     SI,100
        MOV     AL,0
        CALL    FILLBOX
        MOV     CX,155
        MOV     DI,5
        MOV     SI,10
        CALL    FILLBOX
        MOV     DX,245
        MOV     AL,4
        CALL    FILLBOX

FINISH_MICROWAVE:

        POP     AX
        POP     DI
        POP     DX
        POP     SI
        POP     CX
        RET

DRAW_MICROWAVE      ENDP


;--------------------------------------------------------------------------
;DELAY
;       Description:    Create a delay using busy wait, keeping the CPU
;                       occupied doing nothing
;       Input Param:    none
;       Registers affected:     none
; 
;--------------------------------------------------------------------------
DELAY   PROC

        PUSH    CX
        PUSH    DX
        MOV     CX,50H

OUTER_LOOP:

        DEC     CX
        CMP     CX,0
        JE      FINISH_DELAY
        MOV     DX,0111H

INNER_LOOP:

        DEC     DX
        CMP     DX,0
        JE      OUTER_LOOP
        JMP     INNER_LOOP

FINISH_DELAY:

        POP     DX
        POP     CX
        RET

DELAY      ENDP

CSEG    ENDS
        END     MAIN

