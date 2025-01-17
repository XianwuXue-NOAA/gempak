      SUBROUTINE PK_SECT3(KFILDO,IPACK,ND5,IS3,NS3,IPKOPT,
     1                    L3264B,LOCN,IPOS,IER,ISEVERE,*)
C
C        MARCH    2000   LAWRENCE  GSC/TDL   ORIGINAL CODING
C        JANUARY  2001   GLAHN     COMMENTS; ADDED CHECK ON SIZE OF
C                                  IS3( ); IER NUMBERS ALTERED
C        JANUARY  2001   GLAHN/LAWRENCE REMOVED NEW FROM CALL
C        FEBRUARY 2001   GLAHN/LAWRENCE ADDED TEMPLATE NAMES
C        FEBRUARY 2002   GLAHN     REMOVED TEST ON IER=301 AT END
C
C        PURPOSE
C            PACKS SECTION 3, THE GRID DEFINITION SECTION, OF A GRIB2
C            MESSAGE.
C
C            THIS ROUTINE IS CAPABLE OF PACKING THE FOLLOWING
C            GRID DEFINITION TEMPLATES:
C               TEMPLATE 3.0   EQUIDISTANT CYLINDRICAL LATITUDE/LONGITUDE
C               TEMPLATE 3.10  MERCATOR
C               TEMPLATE 3.20  POLAR STEREOGRAPHIC
C               TEMPLATE 3.30  LAMBERT
C               TEMPLATE 3.90  ORTHOGRAPHIC SPACE VIEW
C               TEMPLATE 3.110 EQUATORIAL AZIMUTHAL EQUIDISTANT
C               TEMPLATE 3.120 AZIMUTH-RANGE (RADAR)
C
C        DATA SET USE
C           KFILDO - UNIT NUMBER FOR OUTPUT (PRINT) FILE. (OUTPUT)
C
C        VARIABLES
C              KFILDO = UNIT NUMBER FOR OUTPUT (PRINT) FILE. (INPUT)
C            IPACK(J) = THE ARRAY THAT HOLDS THE ACTUAL PACKED MESSAGE
C                       (J=1,ND5). (INPUT/OUTPUT)
C                 ND5 = THE SIZE OF IPACK( ). (INPUT)
C              IS3(J) = CONTAINS THE GRID DEFINITION DATA THAT
C                       WILL BE PACKED INTO IPACK( ) (J=1,NS3).
C                       (INPUT/OUTPUT)
C                 NS3 = SIZE OF IS3( ). (INPUT)
C              IPKOPT = PACKING INDICATOR:
C                       0 = ERROR, DON'T PACK
C                       1 = PACK IA( ), SIMPLE
C                       2 = PACK IA( ) AND IB( ), SIMPLE
C                       3 = PACK COMPLEX OR SPATIAL DIFFERENCING
C                       4 = PACK COMPLEX.
C                       (INPUT)
C              L3264B = THE INTEGER WORD LENGTH IN BITS OF THE MACHINE
C                       BEING USED. VALUES OF 32 AND 64 ARE
C                       ACCOMMODATED. (INPUT)
C                LOCN = THE WORD POSITION TO PLACE THE NEXT VALUE.
C                       (INPUT/OUTPUT)
C                IPOS = THE BIT POSITION IN LOCN TO START PLACING
C                       THE NEXT VALUE. (INPUT/OUTPUT)
C                 IER = RETURN STATUS CODE. (OUTPUT)
C                        0 = GOOD RETURN.
C                       1-4 = ERROR CODES GENERATED BY PKBG. SEE THE 
C                             DOCUMENTATION IN THE PKBG ROUTINE.
C                       5,6 = ERROR CODES GENERATED BY THE LENGTH
C                             FUNCTION. SEE THE DOCUMENTATION FOR THE
C                             LENGTH FUNCTION.
C                       301 = IS3(5) DOES NOT INDICATE SECTION 5.
C                       302 = IS3( ) HAS NOT BEEN DIMENSIONED LARGE
C                             ENOUGH.
C                       303 = MAP PROJECTION IN IS3(13) IS NOT
C                             SUPPORTED.
C                       304 = RETURNED BY A ROUTINE LIKE PK_POLSTER
C                             WHICH INDICATES IT WAS INCORRECTLY CALLED.
C                             THIS SHOULD NOT HAPPEN.
C                       310 = UNRECOGNIZED OR UNSUPPORTED SHAPE OF
C                             EARTH CODE IN IS3(15) RETURNED BY
C                             SUBROUTINE EARTH.
C             ISEVERE = THE SEVERITY LEVEL OF THE ERROR.  THE ONLY
C                       VALUE RETUNED IS:
C                       2 = A FATAL ERROR  (OUTPUT)
C                   * = ALTERNATE RETURN WHEN IER NE 0.
C
C             LOCAL VARIABLES
C               IPOS3 = SAVES THE BIT POSITION IN LOC3
C                       TO STORE THE LENGTH OF SECTION 3
C                       AFTER THE ROUTINE IS DONE PACKING
C                       DATA INTO THE SECTION.
C                LOC3 = SAVES THE WORD POSITION IN IPACK
C                       TO STORE THE LENGTH OF SECTION 3
C                       AFTER THE ROUTINE IS DONE PACKING 
C                       DATA INTO THE SECTION.
C               IZERO = CONTAINS THE VALUE '0'.  THIS IS USED IN THE
C                       CODE SIMPLY TO EMPHASIZE THAT A CERTAIN 
C                       GROUP OF OCTETS IN THE MESSAGE ARE BEING 
C                       ZEROED OUT.
C                   K = A LOOPING INDEX VARIABLE.
C                   N = L3264B = THE INTEGER WORD LENGTH IN BITS OF
C                       THE MACHINE BEING USED. VALUES OF 32 AND
C                       64 ARE ACCOMMODATED.
C
C        NON SYSTEM SUBROUTINES CALLED
C           LENGTH, PK_AZIMUTH, PK_CYLINDER, PK_EQUATOR, PK_LAMBERT,
C           PK_MERCATOR, PK_POLSTER, PK_ORTHOGRAPHIC, PKBG,
C
      PARAMETER(MINSIZE=13)
C
      DIMENSION IPACK(ND5),IS3(NS3)
C
      DATA IZERO/0/
C
      N=L3264B
      IER=0
C
      LOC3=LOCN
      IPOS3=IPOS
C
C        ALL ERRORS GENERATED BY THIS ROUTINE ARE FATAL.
      ISEVERE=2
C
C        CHECK MINIMUM SIZE OF IS3( ).  TEMPLATE SIZES CHECKED
C        IN TEMPLATE SUBROUTINES.
C
      IF(NS3.LT.MINSIZE)THEN
         IER=302
         GO TO 900
      ENDIF
C
C        CHECK FOR CORRECT SECTION NUMBER.
C  
      IF(IS3(5).NE.3)THEN
         IER=301
         GO TO 900
      ENDIF
C
C        BYTES 1-4 MUST BE FILLED IN LATER WITH THE RECORD LENGTH
C        IN BYTES; BELOW STATEMENT HOLDS THE PLACE.  LOC3 AND IPOS3
C        HOLD THE LOCATION.
      CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IZERO,32,N,IER,*900)
C
C        PACK THE SECTION NUMBER
      CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,3,8,N,IER,*900)
C
C        PACK SOURCE OF GRID DEFINITION
      CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(6),8,N,IER,*900)
C
C        PACK NUMBER OF DATA POINTS
      CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(7),32,N,IER,*900)
C
C        PACK THE NUMBER OF OCTETS FOR OPTIONAL LIST OF NUMBERS
C        DEFINING NUMBER OF POINTS.
      CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(11),8,N,IER,*900)
C
C        PACK THE INTERPRETATION OF LIST OF NUMBERS DEFINING
C        NUMBER OF POINTS. 
      CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(12),8,N,IER,*900)
C
C        PACK GRID DEFINITION TEMPLATE NUMBER
      CALL PKBG(KFILDO,IPACK,ND5,LOCN,IPOS,IS3(13),16,N,IER,*900)
C
C        PACK THE VALUES FOR THE TYPE OF GRID DEFINITION TEMPLATE
C
c      SELECT CASE (IS3(13))
C
c         CASE (0)
       IF (IS3(13).eq.0) THEN
C
C              THIS IS A LATITUDE/LONGITUDE (OR EQUIDISTANT
C              CYLINDRICAL) PROJECTION.
            CALL PK_CYLINDER(KFILDO,IPACK,ND5,IS3,NS3,IPKOPT,N,
     1                       LOCN,IPOS,IER,*900)
C
C         CASE (10)
         ELSEIF (IS3(13).eq.10) THEN
C
C              THIS IS A MERCATOR PROJECTION
            CALL PK_MERCATOR(KFILDO,IPACK,ND5,IS3,NS3,IPKOPT,N,
     1                       LOCN,IPOS,IER,*900)
C
C         CASE (20)
         ELSEIF (IS3(13).eq.20) THEN
C
C              POLAR STEREOGRAPHIC MAP PROJECTION
            CALL PK_POLSTER(KFILDO,IPACK,ND5,IS3,NS3,IPKOPT,N,
     1                      LOCN,IPOS,IER,*900)
C
C         CASE (30)
         ELSEIF (IS3(13).eq.30) THEN
C
C              THIS IS A LAMBERT CONFORMAL PROJECTION
            CALL PK_LAMBERT(KFILDO,IPACK,ND5,IS3,NS3,IPKOPT,N,
     1                      LOCN,IPOS,IER,*900)
C
C         CASE (90)
         ELSEIF (IS3(13).eq.90) THEN
C
C              THIS IS A SPACE VIEW PERSPECTIVE OR
C              ORTHOGRAPHIC PROJECTION
            CALL PK_ORTHOGRAPHIC(KFILDO,IPACK,ND5,IS3,NS3,
     1                           IPKOPT,N,LOCN,IPOS,IER,
     2                           *900)
C
C         CASE (110)
         ELSEIF (IS3(13).eq.110) THEN
C
C              EQUATORIAL AZIMUTHAL EQUIDISTANT PROJECTION
            CALL PK_EQUATOR(KFILDO,IPACK,ND5,IS3,NS3,IPKOPT,N,
     1                      LOCN,IPOS,IER,*900)
C
C         CASE (120)
         ELSEIF (IS3(13).eq.120) THEN
C
C              AZIMUTHAL RANGE PROJECTION
            CALL PK_AZIMUTH(KFILDO,IPACK,ND5,IS3,NS3,IPKOPT,N,
     1                      LOCN,IPOS,IER,*900)
C
C         CASE DEFAULT
         ELSE
C
C              THE MAP PROJECTION TEMPLATE IS NOT SUPPORTED.
            IER=303 
            GO TO 900
C      END SELECT
      ENDIF
C
C        COMPUTE THE LENGTH OF THE SECTION AND PACK IT. LOC3 AND
C        IPOS3 REPRESENT THE LENGTH OF THE RECORD BEFORE SECTION 3.
C        8 IS THE NUMBER OF BITS IN A BYTE, AND EACH SECTION ENDS
C        AT THE END OF A BYTE.
      IS3(1)=LENGTH(KFILDO,IPACK,ND5,L3264B,LOC3,IPOS3,
     1              LOCN,IPOS,IER)
C
C       ERROR RETURN SECTION
 900  IF(IER.NE.0)RETURN 1
C
      RETURN
      END
