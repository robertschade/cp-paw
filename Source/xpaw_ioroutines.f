!     ==================================================================
!     ==================================================================
!     ==================================================================
!     =====   INPUT AND OUTPUT ROUTINES                             ====
!     ==================================================================
!     ==================================================================
!     ==================================================================
!.......................................................................
MODULE IO_MODULE
USE LINKEDLIST_MODULE, ONLY: LL_TYPE
TYPE(LL_TYPE) :: LL_STRC
TYPE(LL_TYPE) :: LL_CNTL
CONTAINS
!       ................................................................
        SUBROUTINE PUTHEADER(NFILO,VERSIONTEXT)
        USE CLOCK_MODULE
        IMPLICIT NONE
        INTEGER(4)   ,INTENT(IN) :: NFILO
        CHARACTER(*) ,INTENT(IN) :: VERSIONTEXT
        CHARACTER(32)            :: DATIME
        CHARACTER(32)            :: HOSTNAME
        INTEGER(4)               :: ISHOST
        INTEGER                  :: HOSTNM_  ;EXTERNAL HOSTNM_
!       ****************************************************************
        WRITE(NFILO,FMT='()')
        WRITE(NFILO,FMT='(72("*"))')
        WRITE(NFILO,FMT='(72("*"),T15 &
     &             ,"     FIRST-PRINCIPLES MOLECULAR DYNAMICS     ")')
        WRITE(NFILO,FMT='(72("*"),T15 &
     &             ,"   WITH THE PROJECTOR-AUGMENTED WAVE METHOD  ")')
        WRITE(NFILO,FMT='(72("*"))')
        WRITE(NFILO,FMT='(T10 &
     &           ,"P.E. BLOECHL, IBM ZURICH RESEARCH LABORATORY")')
        WRITE(NFILO,FMT='(T10 &
     &      ,"(C) IBM, 1995-1997 * ANY USE REQUIRES WRITTEN LICENSE FROM IBM")')
        IF (VERSIONTEXT (17:17).NE.'%')THEN
          WRITE(NFILO,FMT='(A)') VERSIONTEXT
        ENDIF

        CALL CLOCK$NOW(DATIME)
        ISHOST=HOSTNM_(HOSTNAME)
        WRITE(NFILO,FMT='("PROGRAM STARTED: ",A32," ON ",A)') &
     &           DATIME,HOSTNAME
        CALL LOCK$REPORT(NFILO)
        END SUBROUTINE PUTHEADER
!       ................................................................
        SUBROUTINE WRITER8(NFIL,NAME,VALUE,UNIT)
        INTEGER(4)  ,INTENT(IN) :: NFIL
        CHARACTER(*),INTENT(IN) :: NAME
        REAL(8)     ,INTENT(IN) :: VALUE
        CHARACTER(*),INTENT(IN) :: UNIT
        WRITE(NFIL,FMT='(55("."),": ",T1,A,T58,F10.5,A)')NAME,VALUE,UNIT
        RETURN
        END SUBROUTINE WRITER8
!       ................................................................
        SUBROUTINE WRITEI4(NFIL,NAME,VALUE,UNIT)
        INTEGER(4)  ,INTENT(IN) :: NFIL
        CHARACTER(*),INTENT(IN) :: NAME
        INTEGER(4)  ,INTENT(IN) :: VALUE
        CHARACTER(*),INTENT(IN) :: UNIT
        WRITE(NFIL,FMT='(55("."),": ",T1,A,T58,I10,A)')NAME,VALUE,UNIT
        RETURN
        END SUBROUTINE WRITEI4
END MODULE IO_MODULE
!
!     ..................................................................
      SUBROUTINE IO$REPORT
      USE IO_MODULE
      IMPLICIT NONE
      INTEGER(4) :: NFILO
      INTEGER(4)               :: NTASKs,thistask
!     ******************************************************************
                           CALL TRACE$PUSH('IO$REPORT')
      CALL MPE$QUERY(NTASKS,THISTASK)
      CALL FILEHANDLER$UNIT('PROT',NFILO)
!
!     ==================================================================
!     == WAVES                                                        ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL WAVES$REPORT(NFILO)
!
!     ==================================================================
!     == POTENTIAL                                                    ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL POTENTIAL$REPORT(NFILO)
!
!     ==================================================================
!     == EXTERNAL ORBITAL POTENTIALS                                   ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL EXTERNAL1CPOT$REPORT(NFILO)
!
!     ==================================================================
!     == OCCUPATIONS                                                  ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL DYNOCC$REPORT(NFILO)
!
!     ==================================================================
!     == ISOLATE                                                      ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL ISOLATE$REPORT(NFILO)
!
!     ==================================================================
!     == K-POINTS                                                     ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL OCCUPATION$REPORT(NFILO,'KPOINTS')
!
!     ==================================================================
!     == DFT FUNCTIONAL                                               ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL DFT$REPORT(NFILO)
!
!     ==================================================================
!     == ATOM SPECIES                                                 ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL ATOMTYPELIST$REPORT(NFILO)
!
!     ==================================================================
!     == ATOMS                                                        ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL ATOMS$REPORT(NFILO)
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL ATOMLIST$REPORT(NFILO)
!
!     ==================================================================
!     == CLASSICAL ENVIRONMENT                                        ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL QMMM$REPORT(NFILO)
!
!     ==================================================================
!     == CONTINUUM SOLVATION                                          ==
!     ==================================================================
!     IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
!     CALL CONTINUUM$REPORT(NFILO)
!
!     ==================================================================
!     == ATOM THERMOSTAT                                              ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL THERMOSTAT$SELECT('ATOMS')
      CALL THERMOSTAT$REPORT(NFILO)
!
!     ==================================================================
!     == WAVE FUNCTION THERMOSTAT                                     ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL THERMOSTAT$SELECT('WAVES')
      CALL THERMOSTAT$REPORT(NFILO)
!
!     ==================================================================
!     == MINIMIZER                                                    ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL AUTO$REPORT(NFILO)
!
!     ==================================================================
!     == GROUPS                                                       ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL GROUPLIST$REPORT(NFILO)
!
!     ==================================================================
!     == CONSTRAINTS                                                  ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL CONSTRAINTS$REPORT(NFILO,'LONG')
!
!     ==================================================================
!     == DIALS                                                        ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL DIALS$REPORT(NFILO)
!
!     ==================================================================
!     == FILE HANDLER                                                 ==
!     ==================================================================
      IF(THISTASK.EQ.1)WRITE(NFILO,FMT='()')
      CALL FILEHANDLER$REPORT(NFILO,'USED')
!
!     ==================================================================
!     == FUSH BUFFER OF PROTOCOLL FILE                                ==
!     ==================================================================
      IF(THISTASK.EQ.1)CALL FLUSH_(NFILO)
                            CALL TRACE$POP
      RETURN
      END
!
!     .....................................................READIN.......
      SUBROUTINE READIN(NBEG,NOMORE,IPRINT,DELT,TMERMIN,TNWSTR)
!     **                                                              **
      USE IO_MODULE
      USE LINKEDLIST_MODULE
      USE STRINGS_MODULE
      IMPLICIT NONE
      INTEGER(4)     ,INTENT(OUT)  :: NBEG
      INTEGER(4)     ,INTENT(OUT)  :: NOMORE
      INTEGER(4)     ,INTENT(OUT)  :: IPRINT
      REAL(8)        ,INTENT(OUT)  :: DELT
      LOGICAL(4)     ,INTENT(OUT)  :: TNWSTR
      LOGICAL(4)     ,INTENT(OUT)  :: TMERMIN
      LOGICAL(4)                   :: TCHK
      INTEGER(4)                   :: NFIL
      INTEGER(4)                   :: NFILO
      LOGICAL(4)                   :: TOLATE
      INTEGER(4)                   :: MAXTIM(3)
      CHARACTER(256)               :: VERSIONTEXT
      CHARACTER(256)               :: CNTLNAME
      CHARACTER(256)               :: ROOTNAME
      CHARACTER(5)                 :: CH5SVAR
      LOGICAL(4)                   :: TEQ
      LOGICAL(4)                   :: TPR=.FALSE.
      INTEGER(4)                   :: ISVAR
      INTEGER                      :: IARGC   ! RETURNS #(COMMAND LINE OPTIONS)
      EXTERNAL IARGC
      COMMON/VERSION/VERSIONTEXT
!     ******************************************************************
                          CALL TRACE$PUSH('READIN')
!
!     ==================================================================
!     ==  SET CONTROLFILENAME AND STANDARD ROOT                       ==
!     ==================================================================
      IF (IARGC().LT.1) THEN
        CALL ERROR$MSG('THE NAME OF THE CONTROLFILE MUST BE GIVEN AS ARGUMENT')
        CALL ERROR$STOP('READIN')
      END IF
      CALL GETARG(1,CNTLNAME)
!     == IF ROOTNAME='-' USE THE ROOT OF THE CONTROLFILE ================
      ISVAR=INDEX(CNTLNAME,-'.CNTL',BACK=.TRUE.)
      IF(ISVAR.GT.0) THEN      
        ROOTNAME=CNTLNAME(1:ISVAR-1)
      ELSE
        ROOTNAME=' '
      END IF
!     == CONNECT CONTROL FILE ==========================================
      CALL FILEHANDLER$SETROOT(ROOTNAME)
      CALL FILEHANDLER$SETFILE(+'CNTL',.FALSE.,CNTLNAME)
      CALL FILEHANDLER$SETSPECIFICATION(+'CNTL','STATUS','OLD')
      CALL FILEHANDLER$SETSPECIFICATION(+'CNTL','POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(+'CNTL','ACTION','READ')
      CALL FILEHANDLER$SETSPECIFICATION(+'CNTL','FORM','FORMATTED')
!
!     ==================================================================
!     ==  CHECK EXPIRATION DATE                                       ==
!     ==================================================================
      CALL LOCK$BREAKPOINT
!    
!     ==================================================================
!     ==  READ BUFFER CNTL                                            ==
!     ==================================================================
      CALL LINKEDLIST$NEW(LL_CNTL)
      CALL FILEHANDLER$UNIT('CNTL',NFIL)
      CALL LINKEDLIST$READ(LL_CNTL,NFIL)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!FILES!FILE                              ==
!     ==================================================================
      CALL READIN_FILES(LL_CNTL)
!
!     ==================================================================
!     ==  WRITE HEADER                                                ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      CALL PUTHEADER(NFILO,VERSIONTEXT)
!    
!     ==================================================================
!     ==  READ BLOCK !GENERIC                                         ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'GENERIC')
!
!     == DEFAULT VALUES
      CALL LINKEDLIST$EXISTD(LL_CNTL,'DT',0,TCHK)
      IF(.NOT.TCHK) CALL LINKEDLIST$SET(LL_CNTL,'DT',0,10.D0) 
      CALL LINKEDLIST$EXISTD(LL_CNTL,'NSTEP',0,TCHK)
      IF(.NOT.TCHK) CALL LINKEDLIST$SET(LL_CNTL,'NSTEP',0,100) 
      CALL LINKEDLIST$EXISTD(LL_CNTL,'NWRITE',0,TCHK)
      IF(.NOT.TCHK) CALL LINKEDLIST$SET(LL_CNTL,'NWRITE',0,100) 
      CALL LINKEDLIST$EXISTD(LL_CNTL,'START',0,TCHK)
      IF(.NOT.TCHK) CALL LINKEDLIST$SET(LL_CNTL,'START',0,.FALSE.) 
!
!     == CAPTURE USE OF OUTDATED SYNTAX ============================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'STOREPSIR',1,TCHK)
      IF(TCHK) THEN
        CALL ERROR$MSG('SYNTAX HAS CHANGED')
        CALL ERROR$MSG('PLEASE SPECIFY STOREPSIR INBLOCK PSIDYN')
        CALL ERROR$STOP('READIN$PSIDYN')
      END IF
!
!     ==  READ ACTUAL VALUES  ==========================================
      CALL LINKEDLIST$GET(LL_CNTL,'DT',1,DELT)
      CALL LINKEDLIST$GET(LL_CNTL,'NSTEP',1,NOMORE)
      CALL LINKEDLIST$GET(LL_CNTL,'NWRITE',1,IPRINT)
      CALL LINKEDLIST$GET(LL_CNTL,'START',1,TEQ)
      IF(TEQ) THEN
        NBEG=-1
      ELSE
        NBEG=0
      END IF
                          CALL TRACE$PASS('BLOCK !CONTROL!GENERIC FINISHED')
!    
!     ==================================================================
!     ==  READ BLOCK !DFT                                             ==
!     ==================================================================
      CALL READIN_DFT(LL_CNTL)
!    
!     ==================================================================
!     ==  READ BLOCK !FOURIER                                         ==
!     ==================================================================
      CALL READIN_FOURIER(LL_CNTL)
!    
!     ==================================================================
!     ==  READ BLOCK !PSIDYN                                         ==
!     ==================================================================
      CALL READIN_PSIDYN(LL_CNTL)
!    
!     ==================================================================
!     ==  READ BLOCK !RDYN                                            ==
!     ==================================================================
      CALL READIN_RDYN(LL_CNTL)
      CALL AUTO$SETR8('TOLERANCE',1.D-5)
!    
!     ==================================================================
!     ==  READ BLOCK !MERMIN                                          ==
!     ==================================================================
      CALL READIN_MERMIN(LL_CNTL,TMERMIN)
!    
!     ==================================================================
!     ==  READ BLOCK !CONTROL!SHADOW                                  ==
!     ==================================================================
      CALL READIN_SHADOW(LL_CNTL)
!    
!     ==================================================================
!     ==  READ BLOCK !CONTROL!QM-MM                                   ==
!     ==================================================================
      CALL READIN_QMMM(LL_CNTL)
!    
!     ==================================================================
!     ==  READ BLOCK !CONTROL!CONTINUUM                               ==
!     ==================================================================
      CALL READIN_CONTINUUM(LL_CNTL)
!    
!     ==================================================================
!     ==  READ BLOCK !DATA                                            ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'DATA')
!
!     == DEFAULT VALUES ================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'NEWSTRUC',0,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'NEWSTRUC',0,.FALSE.)
!
!     == GET NON-DEFAULT VALUES=========================================
      CALL LINKEDLIST$GET(LL_CNTL,'NEWSTRUC',0,TNWSTR)
      IF(TNWSTR) THEN
        CALL ERROR$MSG('THE OPTION NEWSTRUC HAS BEEN REMOVED')
        CALL ERROR$STOP('READIN')
      END IF
!    
!     ==================================================================
!     ==  READ BLOCK !ANALYSE                                         ==
!     ==================================================================
!
!     ==================================================================
!     ==  READ BLOCK !ANALYSE!TRAJECTORIES                            ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ANALYSE')
!
!     == DEFAULT VALUES ================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'R.TRA',0,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'R.TRA',0,.TRUE.)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'F.TRA',0,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'F.TRA',0,.FALSE.)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'E.TRA',0,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'E.TRA',0,.FALSE.)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'PDOS',0,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'PDOS',0,.TRUE.)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'BALLSTICK',0,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'BALLSTICK',0,.TRUE.)
!
!     == GET NON-DEFAULT VALUES=========================================
      CALL LINKEDLIST$GET(LL_CNTL,'R.TRA',1,TCHK)
      CALL TRAJECTORYIO$ON('POSITION-TRAJECTORY',TCHK)
!
      CALL LINKEDLIST$GET(LL_CNTL,'F.TRA',1,TCHK)
      CALL TRAJECTORYIO$ON('FORCE-TRAJECTORY',TCHK)
!
      CALL LINKEDLIST$GET(LL_CNTL,'E.TRA',1,TCHK)
      CALL TRAJECTORYIO$ON('ENERGY-TRAJECTORY',TCHK)
!
      CALL LINKEDLIST$GET(LL_CNTL,'BALLSTICK',1,TCHK)
!     CALL EIGSSETBALLSTICK

      CALL LINKEDLIST$GET(LL_CNTL,'PDOS',1,TCHK)
!     CALL EIGSSETPDOS
!
!     ==================================================================
!     ==  READ BLOCK !ANALYSE!WAVE                                    ==
!     ==================================================================
      CALL READIN_ANALYSE_WAVE(LL_CNTL)
!    
!     ==================================================================
!     ==  READ BLOCK !ANALYSE!POINTCHARGEPOT                          ==
!     ==================================================================
      CALL READIN_ANALYSE_POTCHARGEPOT(LL_CNTL)
!    
!     ==================================================================
!     ==  READ BLOCK !ANALYSE!HYPERFINE                               ==
!     ==================================================================
      CALL READIN_ANALYSE_HYPERFINE(LL_CNTL)
!
!     ==================================================================
!     ==  CHECK TIME TO STOP                                          ==
!     ==================================================================
!     IF(MAXTIM(1).EQ.1) WRITE(*,6900)'SUNDAY   ',MAXTIM(2),MAXTIM(3)
!     IF(MAXTIM(1).EQ.2) WRITE(*,6900)'MONDAY   ',MAXTIM(2),MAXTIM(3)
!     IF(MAXTIM(1).EQ.3) WRITE(*,6900)'TUESDAY  ',MAXTIM(2),MAXTIM(3)
!     IF(MAXTIM(1).EQ.4) WRITE(*,6900)'WEDNESDAY',MAXTIM(2),MAXTIM(3)
!     IF(MAXTIM(1).EQ.5) WRITE(*,6900)'THURSDAY ',MAXTIM(2),MAXTIM(3)
!     IF(MAXTIM(1).EQ.6) WRITE(*,6900)'FRIDAY   ',MAXTIM(2),MAXTIM(3)
!     IF(MAXTIM(1).EQ.7) WRITE(*,6900)'SATURDAY ',MAXTIM(2),MAXTIM(3)
!6900  FORMAT(1H ,'STOP ON ',A10,' AT ',I2,':',I2)
!     CALL LATER(MAXTIM,TOLATE)
!     IF(TOLATE) THEN
!       CALL ERROR$MSG('TIME OVER')
!       CALL ERROR$STOP('READIN')
!     END IF
!
!     ==================================================================
!     ==================================================================
!     ==  INTERNAL CHECKS AND PRINOUT                                 ==
!     ==================================================================
!     ==================================================================
      CALL FILEHANDLER$UNIT('PROT',NFILO)
!
!     ==================================================================
!     ==================================================================
!     ==  ELECTRONIC VARIABLES                                        ==
!     ==================================================================
!     ==================================================================
      WRITE(NFILO,FMT='()')
      WRITE(NFILO,FMT='("INFORMATION FROM CONTROL INPUT FILE" &
     &             /"===================================")')
!
      IF(NBEG.LE.-1) THEN
        WRITE(NFILO,FMT='("START WITH RANDOM WAVE FUNCTIONS")')
      ELSE IF(NBEG.GE.0) THEN
        WRITE(NFILO,FMT='("WAVE FUNCTIONS ARE READ FROM FILE")')
      END IF
      IF(TNWSTR) THEN
        WRITE(NFILO,FMT='("ATOMIC STRUCTURE TAKEN FROM " &
     &               ,"STRUCTURE INPUT FILE" &
     &               /T10,"(STRUCTURE FROM RESTART FILE IGNORED)")')
      END IF
      WRITE(NFILO,FMT='(55("."),": " &
     &             ,T1,"NUMBER OF ITERATIONS" &
     &             ,T58,I10)')NOMORE
      WRITE(NFILO,FMT='(55("."),": " &
     &             ,T1,"TIME STEP" &
     &             ,T58,F10.5," A.U.")')DELT
!
!     ==================================================================
!     ==  DATA FILES                                                  ==
!     ==================================================================
      IF(NBEG.GE.0) THEN
        WRITE(NFILO,FMT='(55("."),": " &
     &             ,T1,"START WITH WAVE FUNCTIONS FROM FILE" &
     &             ,T58,"RESTART_IN")')
      END IF
      WRITE(NFILO,FMT='(55("."),": " &
     &         ,T1,"DETAILED INFORMATION AFTER EACH" &
     &         ,T58,I10," TIME STEPS")')IPRINT
!
                          CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_FILES(LL_CNTL_)
      USE LINKEDLIST_MODULE
      USE STRINGS_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)            :: LL_CNTL
      INTEGER(4)               :: NFILE
      INTEGER(4)               :: ITH
      CHARACTER(32)            :: ID
      CHARACTER(32)            :: CH32SVAR2
      CHARACTER(256)           :: NAME
      LOGICAL(4)               :: TCHK
!     ******************************************************************
                           CALL TRACE$PUSH('READIN_FILES')  
      LL_CNTL=LL_CNTL_
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'FILES')
!
!     ==================================================================
!     == SET ROOTNAME AND PRCONNECT FILES                             ==
!     ==================================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'ROOT',1,TCHK)
      IF(TCHK) THEN
        CALL LINKEDLIST$GET(LL_CNTL,'ROOT',1,NAME)
        CALL FILEHANDLER$SETROOT(TRIM(NAME))
      END IF
      CALL STANDARDFILES
!
!     == SCAN SUBLISTS =================================================
      CALL LINKEDLIST$NLISTS(LL_CNTL,'FILE',NFILE)
      DO ITH=1,NFILE
        CALL LINKEDLIST$SELECT(LL_CNTL,'FILE',ITH)
!     
!       ==  READ ACTUAL VALUES  ========================================
        CALL LINKEDLIST$EXISTD(LL_CNTL,'ID',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!CONTROL!FILES!FILE:ID NOT FOUND')
          CALL ERROR$MSG('NOTE: SYNTAX HAS CHANGED FROM IDENT TO ID')
          CALL ERROR$STOP('READIN_FILES')
        END IF
        CALL LINKEDLIST$GET(LL_CNTL,'ID',1,ID)
!
!       == COLLECT FILE NAME ===========================================
        CALL LINKEDLIST$EXISTD(LL_CNTL,'NAME',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_CNTL,'NAME',1,NAME)
        ELSE
          CALL ERROR$MSG('!CONTROL!FILES!FILE:NAME NOT FOUND')
          CALL ERROR$STOP('READIN_FILES')
        END IF
!
!       == DEFAULT FOR EXT=.FALSE.
        CALL LINKEDLIST$EXISTD(LL_CNTL,'EXT',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_CNTL,'EXT',1,TCHK)
        END IF
!     
!       == PERFORM ACTIONS ===========================================
        CALL FILEHANDLER$SETFILE(+ID,TCHK,NAME)
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................     
      SUBROUTINE STANDARDFILES
      USE STRINGS_MODULE
      IMPLICIT NONE
      LOGICAL(4),PARAMETER :: T=.TRUE.
      LOGICAL(4),PARAMETER :: F=.FALSE.
      CHARACTER(32)        :: CH32SVAR1
      CHARACTER(32)        :: ID
      INTEGER(4)           :: NTASKNUM
      INTEGER(4)           :: NTASKID
      INTEGER(4)           :: NFILO
!     ******************************************************************
                                   CALL TRACE$PUSH('STANDARDFILES')
      CALL MPE$QUERY(NTASKNUM,NTASKID)
!  
!     ==================================================================
!     == SET STANDARD FILENAMES                                       ==
!     ==================================================================
!
!     ==  EXIT FILE ===================================================
      ID=+'EXIT'
      CALL FILEHANDLER$SETFILE(ID,T,-'.EXIT')
!
!     ==  ERROR FILE ===================================================
      ID=+'ERR'
      CALL FILEHANDLER$SETFILE(ID,T,-'.ERR')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','REPLACE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','APPEND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  PROTOCOLL FILE================================================
      ID=+'PROT'
      IF(NTASKID.GT.1)THEN
        CALL FILEHANDLER$SETFILE(ID,F,-'/DEV/NULL')
      ELSE
        CALL FILEHANDLER$SETFILE(ID,T,-'.PROT')
      END IF
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','APPEND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  STRUCTURE FILE   =============================================
      ID=+'STRC'
      CALL FILEHANDLER$SETFILE(ID,T,-'.STRC')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','OLD')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','READ')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  STRUCTURE FILE   =============================================
      ID=+'STRC_OUT'
      CALL FILEHANDLER$SETFILE(ID,T,-'.STRC_OUT')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','REPLACE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  RESTART_IN FILE ==============================================
      ID=+'RESTART_IN'
      CALL FILEHANDLER$SETFILE(ID,T,-'.RSTRT')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','OLD')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','READ')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','UNFORMATTED')
!
!     ==  RESTART_OUT FILE =============================================
      ID=+'RESTART_OUT'
      CALL FILEHANDLER$SETFILE(ID,T,-'.RSTRT')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','UNFORMATTED')
!
!     ==  ENERGY TRAJECTORY ============================================
      ID=+'ENERGY-TRAJECTORY'
      CALL FILEHANDLER$SETFILE(ID,T,-'_E.TRA')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','APPEND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','UNFORMATTED')
!
!     ==  BANDS  TRAJECTORY ============================================
      ID=+'BANDS-TRAJECTORY'
      CALL FILEHANDLER$SETFILE(ID,T,-'_B.TRA')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','APPEND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','UNFORMATTED')
!
!     ==  BANDS  TRAJECTORY ============================================
      ID=+'POSITION-TRAJECTORY'
      CALL FILEHANDLER$SETFILE(ID,T,-'_R.TRA')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','APPEND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','UNFORMATTED')
!
!     ==  FORCE TRAJECTORY ============================================
      ID=+'FORCE-TRAJECTORY'
      CALL FILEHANDLER$SETFILE(ID,T,-'_F.TRA')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','APPEND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','UNFORMATTED')
!
!     ==  FORCE TRAJECTORY ============================================
      ID=+'CONSTRAINTS'
      CALL FILEHANDLER$SETFILE(ID,T,-'_CONSTR.REPORT')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','APPEND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  BANDS ======================================================
      ID=+'BANDS'
      CALL FILEHANDLER$SETFILE(ID,T,-'.BANDS')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','APPEND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  PDOS  ======================================================
      ID=+'PDOS'
      CALL FILEHANDLER$SETFILE(ID,T,-'.PDOS')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','REPLACE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  BALLSTICK ==================================================
      ID=+'BALLSTICK.DX'
      CALL FILEHANDLER$SETFILE(ID,T,-'_BALLSTICK.DX')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','REPLACE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  DENSITY  ===================================================
      ID=+'DENSITY.DX'
      CALL FILEHANDLER$SETFILE(ID,T,-'_RHO.DX')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','REPLACE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  DENSITY  ===================================================
      ID=+'POTENTIAL.DX'
      CALL FILEHANDLER$SETFILE(ID,T,-'_POT.DX')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','REPLACE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  DENSITY  ===================================================
      ID=+'PATH.DX'
      CALL FILEHANDLER$SETFILE(ID,T,-'_PATH.DX')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','REPLACE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==  THE STANDARD NAMES FOR THE ATOMIC SPECIES ARE ATOM1,ATOM2 ETC.
!
      CALL FILEHANDLER$UNIT('PROT',NFILO)
!     CALL FILEHANDLER$PRINTFILEOFUNIT(NFILO)
!     CALL FILEHANDLER$REPORT(NFILO,'ALL')
!     STOP
                                   CALL TRACE$POP
      RETURN
      END
!
!     ...................................................................
      SUBROUTINE READIN_DFT(LL_CNTL_)
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)            :: LL_CNTL
      INTEGER(4)               :: ILDA
      LOGICAL(4)               :: TCHK
!     ******************************************************************
                          CALL TRACE$PUSH('READIN_DFT')
      LL_CNTL=LL_CNTL_
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'DFT')
!
!     == GET NON-DEFAULT VALUES ========================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'TYPE',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'TYPE',0,1)
      END IF
      CALL LINKEDLIST$GET(LL_CNTL,'TYPE',1,ILDA)
      CALL DFT$SETI4('TYPE',ILDA)
                          CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_FOURIER(LL_CNTL_)
!     ******************************************************************
!     ** MODIFIES     : WAVES;POTENTIAL                               ** 
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK
      REAL(8)               :: EPWPSI    ! WAVE FUNCTION PLANE WAVE CUTOFF
      REAL(8)               :: EPWRHO    ! DENSITY PLANE WAVE CUTOFF
      REAL(8)               :: CDUAL     ! EPWRHO=EPWPSI*CDUAL
      REAL(8)               :: RY        ! RYDBERG
!     ******************************************************************
                           CALL TRACE$PUSH('READIN_FOURIER')
      LL_CNTL=LL_CNTL_
      CALL CONSTANTS('RY',RY)
!
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'FOURIER')
!
!     == EPWPSI ========================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'EPWPSI',1,TCHK)
      IF(.NOT.TCHK) CALL LINKEDLIST$SET(LL_CNTL,'EPWPSI',0,30.D0)
      CALL LINKEDLIST$CONVERT(LL_CNTL,'EPWPSI',1,'R(8)')
      CALL LINKEDLIST$GET(LL_CNTL,'EPWPSI',1,EPWPSI)
      EPWPSI=EPWPSI*RY
!
!     == EPWRHO ========================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'EPWRHO',1,TCHK)
      IF(TCHK) THEN
        CALL LINKEDLIST$CONVERT(LL_CNTL,'EPWRHO',1,'R(8)')
        CALL LINKEDLIST$GET(LL_CNTL,'EPWRHO',1,EPWRHO)
        EPWRHO=EPWRHO*RY
      ELSE
        CALL LINKEDLIST$EXISTD(LL_CNTL,'CDUAL',1,TCHK)
        IF(.NOT.TCHK) THEN
          CDUAL=4.D0
          CALL LINKEDLIST$SET(LL_CNTL,'CDUAL',0,CDUAL)
        END IF
        CALL LINKEDLIST$CONVERT(LL_CNTL,'CDUAL',1,'R(8)')
        CALL LINKEDLIST$GET(LL_CNTL,'CDUAL',1,CDUAL)
        EPWRHO=EPWPSI*CDUAL
      END IF
!
!     ==  PERFORM ACTIONS ==============================================
      CALL POTENTIAL$SETEPW(EPWRHO)
      CALL WAVES$SETR8('EPWPSI',EPWPSI)
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_PSIDYN(LL_CNTL_)
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK,TCHK1,TCHK2
      REAL(8)               :: FRICTION
      REAL(8)               :: SCALE
      LOGICAL(4)            :: TSTOPE
      LOGICAL(4)            :: TRANE
      REAL(8)               :: AMPRE
      LOGICAL(4)            :: TSTORE    
      REAL(8)               :: EMASS
      REAL(8)               :: EMASSCG2
      REAL(8)               :: DT
!     ******************************************************************
                           CALL TRACE$PUSH('READIN_PSIDYN')  
      LL_CNTL=LL_CNTL_
!
!     ==================================================================
!     ==  READ BLOCK GENERIC                                          ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'GENERIC')
      CALL LINKEDLIST$GET(LL_CNTL,'DT',1,DT)
      CALL WAVES$SETR8('TIMESTEP',DT)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!PSIDYN                                  ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'PSIDYN')
!
!     == CAPTURE OUTDATED VERSIONS  ====================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'DIAG',1,TCHK)
      IF(TCHK) THEN
        CALL ERROR$MSG('SYNTAX HAS CHANGED')
        CALL ERROR$MSG('OPTION DIAG HAS BEEN REMOVED')
        CALL ERROR$STOP('READIN$PSIDYN')
      END IF
!
!     ==  BEGIN WITH ZERO VELOCITIES ===================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'STOP',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'STOP',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'STOP',1,TSTOPE)
      CALL WAVES$SETL4('STOP',TSTOPE)
!
!     ==  BEGIN WITH RANDOM VELOCITIES =================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'RANDOM',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'RANDOM',0,0.D0)
      CALL LINKEDLIST$CONVERT(LL_CNTL,'RANDOM',1,'R(8)')
      CALL LINKEDLIST$GET(LL_CNTL,'RANDOM',1,AMPRE)
      TRANE=(AMPRE.NE.0.D0)
      CALL WAVES$SETL4('RANDOMIZE',TRANE)
      CALL WAVES$SETR8('AMPRE',AMPRE)
!
!     ==  FRICTION  (MAY BE CHANGED BY !AUTO) ==========================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FRIC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FRIC',0,0.D0)
      CALL LINKEDLIST$CONVERT(LL_CNTL,'FRIC',1,'R(8)')
      CALL LINKEDLIST$GET(LL_CNTL,'FRIC',1,FRICTION)
      CALL WAVES$SETR8('FRICTION',FRICTION)
!
!     ==  ENHANCEMENT FACTOR FOR FICTITIOUS ELECTRON MASS ==============
      CALL LINKEDLIST$EXISTD(LL_CNTL,'MPSI',1,TCHK)
      IF(.NOT.TCHK) THEN
        EMASS=10.D0*DT**2
        CALL LINKEDLIST$SET(LL_CNTL,'MPSI',0,EMASS)
      ELSE
        CALL LINKEDLIST$CONVERT(LL_CNTL,'MPSI',1,'R(8)')
        CALL LINKEDLIST$GET(LL_CNTL,'MPSI',1,EMASS)
      END IF
      CALL WAVES$SETR8('EMASS',EMASS)
!
!     ==  ENHANCEMENT FACTOR FOR FICTITIOUS ELECTRON MASS ==============
      CALL LINKEDLIST$EXISTD(LL_CNTL,'MPSICG2',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'MPSICG2',0,0.D0)
      CALL LINKEDLIST$CONVERT(LL_CNTL,'MPSICG2',1,'R(8)')
      CALL LINKEDLIST$GET(LL_CNTL,'MPSICG2',1,EMASSCG2)
      CALL WAVES$SETR8('EMASSCG2',EMASSCG2)
!
!     ==  STORE REAL SPACE WAVE FUNCTIONS TO AVOID ADDITIONAL FFT =======
      CALL LINKEDLIST$EXISTD(LL_CNTL,'STOREPSIR',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'STOREPSIR',0,.TRUE.)
      CALL LINKEDLIST$GET(LL_CNTL,'STOREPSIR',1,TSTORE)
      CALL WAVES$SETL4('STOREPSIR',TSTORE)
!
!     ==  SAFEORTHO STRICTLY CONSERVES ENERGY, ==========================
!     ==  BUT DOES NOT PRODUCE EIGENSTATES ===============================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'SAFEORTHO',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'SAFEORTHO',0,.TRUE.)
      CALL LINKEDLIST$GET(LL_CNTL,'SAFEORTHO',1,TCHK)
      CALL WAVES$SETL4('SAFEORTHO',TCHK)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!PSIDYN!AUTO                             ==
!     ==================================================================
      CALL READIN_AUTO(LL_CNTL,'WAVES',0.3D0,0.97D0,0.3D0,1.D0)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!PSIDYN!THERMOSTAT                       ==
!     ==================================================================
      CALL READIN_THERMOSTAT(LL_CNTL,'WAVES',1.D-2,100.D0)
!
!     ==================================================================
!     ==  CHECK FOR SIMULTANEOUS USE OF AUTO AND THERMOSTAT           ==
!     ==================================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'THERMOSTAT',1,TCHK1)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'AUTO',1,TCHK2)
      IF(TCHK1.AND.TCHK2) THEN
        CALL ERROR$MSG('AUTO AND THERMOSTAT MUST NOT BE SPECIFIED SIMULTANEOUSLY')
        CALL ERROR$STOP('READIN_PSIDYN')
      END IF
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_RDYN(LL_CNTL_)
!     ******************************************************************
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)            :: LL_CNTL
      LOGICAL(4)               :: TCHK,tchk1,tchk2
      LOGICAL(4)               :: TAUTOR
      REAL(8)                  :: FRICTION
      REAL(8)                  :: SCALE
      LOGICAL(4)               :: TFOR
      LOGICAL(4)               :: START
      LOGICAL(4)               :: TSTOPR
      REAL(8)                  :: AMPRP
      LOGICAL(4)               :: TRANP
      REAL(8)                  :: X
      REAL(8)                  :: CELVIN
!     ******************************************************************
                            CALL TRACE$PUSH('READIN_RDYN')
      LL_CNTL=LL_CNTL_
      CALL CONSTANTS('KB',CELVIN)
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$EXISTL(LL_CNTL,'RDYN',1,TFOR)
      CALL LINKEDLIST$SELECT(LL_CNTL,'RDYN')
!
!     == SET ATOMS OBJECT ==============================================
      CALL ATOMS$SETL4('MOVE',TFOR)
!     == SET CONTINUUM OBJECT ==========================================
      CALL CONTINUUM$SETL4('MOVE',TFOR)
!
!     == STOP
      CALL LINKEDLIST$EXISTD(LL_CNTL,'STOP',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'STOP',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'STOP',1,TSTOPR)
      CALL ATOMS$SETL4('STOP',TSTOPR)
!
!     == RANDOMIZE
      CALL LINKEDLIST$EXISTD(LL_CNTL,'RANDOM[K]',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'RANDOM[K]',0,0.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'RANDOM[K]',1,AMPRP) 
      AMPRP=AMPRP*CELVIN
      TRANP=(AMPRP.NE.0.D0)
      CALL ATOMS$SETL4('RANDOMIZE',TRANP)
      CALL ATOMS$SETR8('AMPRE',AMPRP)
!
!     == FRICTION =====================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FRIC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FRIC',0,0.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'FRIC',1,FRICTION)
!     __ FRICTION MAY HAVE AN INFLUENCE ON THE ELECTRON FRICTION_______ 
!     __ EVEN IF ATOMS DO NOT MOVE_____________________________________
      IF(.NOT.TFOR) FRICTION=0.D0
      CALL ATOMS$SETR8('FRICTION',FRICTION)
!
!     == START WITH POSITIONS FROM STRUCTURE INPUT FILE 'STRC' ========
      CALL LINKEDLIST$EXISTD(LL_CNTL,'START',1,TCHK)
      IF(TCHK) THEN
        CALL LINKEDLIST$GET(LL_CNTL,'START',1,TCHK)
      END IF
      CALL ATOMS$SETL4('START',TCHK)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!RDYN!AUTO                               ==
!     ==================================================================
      CALL READIN_AUTO(LL_CNTL,'ATOMS',1.D-2,1.D0,0.1D0,1.D0)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!RDYN!THERMOSTAT                         ==
!     ==================================================================
      CALL READIN_THERMOSTAT(LL_CNTL,'ATOMS',293.D0*CELVIN,10.D0)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!RDYN!WARMUP                             ==
!     ==================================================================
      CALL READIN_RDYN_WARMUP(LL_CNTL)
!
!     ==================================================================
!     ==  CHECK FOR SIMULTANEOUS USE OF AUTO AND THERMOSTAT           ==
!     ==================================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'THERMOSTAT',1,TCHK1)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'AUTO',1,TCHK2)
      IF(TCHK1.AND.TCHK2) THEN
        CALL ERROR$MSG('AUTO AND THERMOSTAT MUST NOT BE SPECIFIED SIMULTANEOUSLY')
        CALL ERROR$STOP('READIN_RDYN')
      END IF
                            CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_AUTO(LL_CNTL_,ID,ANNEL,FACL,ANNEU,FACU)
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      CHARACTER(*) ,INTENT(IN) :: ID       ! IDENTIFIER
      REAL(8)      ,INTENT(IN) :: ANNEL    ! DEFAULT: LOWER FRICTION
      REAL(8)      ,INTENT(IN) :: FACL     ! DEFAULT: SCALE FOR LOWER FRICTION
      REAL(8)      ,INTENT(IN) :: ANNEU    ! DEFAULT: UPPER FRICTION
      REAL(8)      ,INTENT(IN) :: FACU     ! DEFAULT: SCALE FOR UPPER FRICTION
      TYPE(LL_TYPE)            :: LL_CNTL
      LOGICAL(4)               :: TCHK,tchk1,tchk2
      REAL(8)                  :: FRICTION
      REAL(8)                  :: SCALE
!     ******************************************************************
      LL_CNTL=LL_CNTL_
      CALL LINKEDLIST$EXISTL(LL_CNTL,'AUTO',1,TCHK)
      IF(.NOT.TCHK) RETURN
      CALL LINKEDLIST$SELECT(LL_CNTL,'AUTO')
      CALL AUTO$SELECT(ID)
      CALL AUTO$SETL4('ON',.TRUE.)
!     
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FRIC(-)',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FRIC(-)',0,ANNEL)
      CALL LINKEDLIST$CONVERT(LL_CNTL,'FRIC(-)',1,'R(8)')
      CALL LINKEDLIST$GET(LL_CNTL,'FRIC(-)',1,FRICTION)
      CALL AUTO$SETR8('LOWERFRICTION',FRICTION)
!     
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FACT(-)',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FACT(-)',0,FACL)
      CALL LINKEDLIST$CONVERT(LL_CNTL,'FACT(-)',1,'R(8)')
      CALL LINKEDLIST$GET(LL_CNTL,'FACT(-)',1,SCALE)
      CALL AUTO$SETR8('LOWERFACTOR',SCALE)
!     
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FRIC(+)',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FRIC(+)',0,ANNEU)
      CALL LINKEDLIST$CONVERT(LL_CNTL,'FRIC(+)',1,'R(8)')
      CALL LINKEDLIST$GET(LL_CNTL,'FRIC(+)',1,FRICTION)
      CALL AUTO$SETR8('UPPERFRICTION',FRICTION)
!     
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FACT(+)',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FACT(+)',0,FACU)
      CALL LINKEDLIST$CONVERT(LL_CNTL,'FACT(+)',1,'R(8)')
      CALL LINKEDLIST$GET(LL_CNTL,'FACT(+)',1,SCALE)
      CALL AUTO$SETR8('UPPERFACTOR',SCALE)
!     
      CALL AUTO$SELECT('~')
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_THERMOSTAT(LL_CNTL_,ID,TEMP_,FREQ_)
!     ******************************************************************
!     ** REQUIRES SETTING OF                                          **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      CHARACTER(*) ,INTENT(IN) :: ID
      REAL(8)      ,INTENT(IN) :: TEMP_
      REAL(8)      ,INTENT(IN) :: FREQ_
      TYPE(LL_TYPE)            :: LL_CNTL
      LOGICAL(4)               :: TCHK,TCHK1,TCHK2
      REAL(8)                  :: TERA
      REAL(8)                  :: SECOND
      REAL(8)                  :: CELVIN
      LOGICAL(4)               :: TON
      REAL(8)                  :: TEMP
      LOGICAL(4)               :: TSTOP
      REAL(8)                  :: FREQ
      REAL(8)                  :: PERIOD
      REAL(8)                  :: FRICTION
!     ******************************************************************
                            CALL TRACE$PUSH('READIN_THERMOSTAT')
      LL_CNTL=LL_CNTL_
      CALL CONSTANTS('TERA',TERA)
      CALL CONSTANTS('SECOND',SECOND)
      CALL CONSTANTS('KB',CELVIN)
!
!     ==================================================================
!     == SELECT RNOSE LIST OR EXIT IF IT DOES NOT EXIST               ==
!     ==================================================================
      CALL LINKEDLIST$EXISTL(LL_CNTL,'THERMOSTAT',1,TON)
      CALL THERMOSTAT$CREATE(ID)
      CALL THERMOSTAT$SETL4('ON',TON)
      IF(.NOT.TON) THEN
        CALL TRACE$POP
        RETURN
      ELSE
        CALL LINKEDLIST$SELECT(LL_CNTL,'THERMOSTAT')
      END IF
!
!     ==================================================================
!     == STOP INITIAL VELOCITIES                                      ==
!     ==================================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'STOP',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'STOP',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'STOP',1,TSTOP)
      CALL THERMOSTAT$SETL4('STOP',TSTOP)
!
!     ==================================================================
!     == TEMPERATURE                                                  ==
!     ==================================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'<EKIN>',1,TCHK1)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'T[K]',1,TCHK2)
      IF(TCHK1.AND.TCHK2) THEN
        CALL ERROR$MSG('<EKIN> AND T[K] MUST NOT BE SPECIFIED SIMULTANEOUSLY')
        CALL ERROR$STOP('READIN_THERMOSTAT')
      ELSE IF(TCHK1) THEN
        CALL LINKEDLIST$GET(LL_CNTL,'<EKIN>',1,TEMP)
      ELSE IF(TCHK2) THEN
        CALL LINKEDLIST$GET(LL_CNTL,'T[K]',1,TEMP)
        TEMP=TEMP*CELVIN
      ELSE
        TEMP=TEMP_
      END IF
      CALL THERMOSTAT$SETR8('TEMP',TEMP)
!
!     ==================================================================
!     ==  "EIGENFREQUENCY" OF THE THERMOSTAT                          ==
!     ==================================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FREQ[THZ]',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FREQ[THZ]',0,FREQ_)
      CALL LINKEDLIST$GET(LL_CNTL,'FREQ[THZ]',1,FREQ)
      FREQ=FREQ*TERA/SECOND
      PERIOD=1.D0/FREQ       ! CONVERT TO OSCILLATION PERIOD
      CALL THERMOSTAT$SETR8('TNOSE',PERIOD)
!
!     ==================================================================
!     == FRICTION ON THE THERMOSTAT                                   ==
!     ==================================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FRIC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FRIC',0,00.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'FRIC',1,FRICTION)
      CALL THERMOSTAT$SETR8('FRICTION',FRICTION) 
!
!     ==================================================================
!     == INITIALIZE #(DEGREES OF FREEDOM) TO ONE                      ==
!     ==================================================================
      CALL THERMOSTAT$SETR8('GFREE',1.D0)
!
                            CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_RDYN_WARMUP(LL_CNTL_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK
      REAL(8)               :: K_B    ! BOLTZMAN CONSTANT
      INTEGER(4)            :: ISVAR
      REAL(8)               :: SVAR
!     ******************************************************************
      LL_CNTL=LL_CNTL_
      CALL CONSTANTS('KB',K_B)
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'RDYN')
      CALL LINKEDLIST$EXISTL(LL_CNTL,'WARMUP',1,TCHK)
      IF(.NOT.TCHK) RETURN
      CALL LINKEDLIST$SELECT(LL_CNTL,'WARMUP')
      CALL HEATBATH$SETL4('ON',TCHK)
!
      CALL LINKEDLIST$EXISTD(LL_CNTL,'NPULSES',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'NPULSES',0,30)
      END IF  
      CALL LINKEDLIST$GET(LL_CNTL,'NPULSES',1,ISVAR)
      CALL HEATBATH$SETI4('NPULSE',ISVAR)
!
      CALL LINKEDLIST$EXISTD(LL_CNTL,'PULSELEN',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'PULSELEN',0,10)
      END IF  
      CALL LINKEDLIST$GET(LL_CNTL,'PULSELEN',1,ISVAR)
      CALL HEATBATH$SETI4('NSTEP',ISVAR)
!
      CALL LINKEDLIST$EXISTD(LL_CNTL,'T[K]',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'T[K]',0,300.D0)
      END IF  
      CALL LINKEDLIST$GET(LL_CNTL,'T[K]',1,SVAR)
      CALL HEATBATH$SETR8('TFINAL',SVAR*K_B)

      RETURN
      END      
!
!     ..................................................................
      SUBROUTINE READIN_MERMIN(LL_CNTL_,TON)
!     ******************************************************************
!     **  READ BLOCK !CONTROL!MERMIN                                  **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK
      REAL(8)               :: KELVIN
      REAL(8)               :: EV
      LOGICAL(4),INTENT(OUT):: TON
      REAL(8)               :: MASS
      REAL(8)               :: FRICTION
      REAL(8)               :: TEMP
      REAL(8)               :: SVAR
      REAL(8)               :: FINAL,RATE
      INTEGER(4)            :: IDIAL,NDIAL
      CHARACTER(32)         :: DIALID
!     ******************************************************************
                           CALL TRACE$PUSH('READIN_MERMIN')  
      LL_CNTL=LL_CNTL_
      CALL CONSTANTS('KB',KELVIN)
      CALL CONSTANTS('EV',EV)
!
!     ==================================================================
!     == SELECT MERMIN LIST OR EXIT IF IT DOES NOT EXIST              ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$EXISTL(LL_CNTL,'MERMIN',1,TON)
      IF(.NOT.TON) THEN
        CALL TRACE$POP
        RETURN
      END IF
!
      CALL LOCK$DISABLE('!MERMIN IN READIN_MERMIN')
!
      CALL LINKEDLIST$SELECT(LL_CNTL,'MERMIN')
!
!     ==================================================================
!     == COLLECT DATA                                                 ==
!     ==================================================================
      CALL DYNOCC$SETL4('DYN',TON)
!
!     == RESTART WITH OCCUPATIONS FROM STRC FILE =======================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'START',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'START',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'START',0,TCHK)
      CALL DYNOCC$SETL4('START',TCHK)
!
!     ==  CONSTANT CHARGE ENSEMBLE =====================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FIXQ',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FIXQ',0,.TRUE.)
      CALL LINKEDLIST$GET(LL_CNTL,'FIXQ',0,TCHK)
      CALL DYNOCC$SETL4('FIXQ',TCHK)
!
!     ==  CONSTANT SPIN ENSEMBLE =====================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FIXS',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FIXS',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'FIXS',0,TCHK)
      CALL DYNOCC$SETL4('FIXS',TCHK)
!
!     ==  FICTITIOUS MASS FOR THE OCCUPATIONS=========================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'MASS',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'MASS',0,300.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'MASS',0,MASS)
      CALL DYNOCC$SETR8('MASS',MASS)
!
!     ==  FRICTION ON THE OCCUPATION DYNAMICS ========================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FRIC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FRIC',0,0.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'FRIC',0,FRICTION)
      CALL DYNOCC$SETR8('FRICTION',FRICTION)
!
!     ==  TRUE ELECTRON TEMPERATURE =================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'T[K]',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'T[K]',0,1000.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'T[K]',0,TEMP)
      TEMP=TEMP*KELVIN
      CALL DYNOCC$SETR8('TEMP',TEMP)
!
!     ==  INITIAL VELOCITIES OF OCCUPATIONS STOPPED =================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'STOP',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'STOP',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'STOP',0,TCHK)
      CALL DYNOCC$SETL4('STOP',TCHK)
!
!     ==  FERMI LEVEL (ONLY USED IF FIXQ=.FALSE. =======================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'EFERMI[EV]',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'EFERMI[EV]',0,0.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'EFERMI[EV]',0,SVAR)
      SVAR=SVAR*EV
      CALL DYNOCC$SETR8('EFERMI',SVAR)
!
!     ==  FERMI LEVEL (ONLY USED IF FIXQ=.FALSE. =======================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'MAGFIELD[EV]',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'MAGFIELD[EV]',0,0.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'MAGFIELD[EV]',0,SVAR)
      SVAR=SVAR*EV
      CALL DYNOCC$SETR8('MAGNETICFIELD',SVAR)
!
!     ==================================================================
!     ==  RESOLVE DIALS                                               ==
!     ==================================================================
      CALL LINKEDLIST$NLISTS(LL_CNTL,'DIAL',NDIAL)
      DO IDIAL=1,NDIAL
        CALL LINKEDLIST$SELECT(LL_CNTL,'DIAL',IDIAL)
        CALL LINKEDLIST$EXISTD(LL_CNTL,'ID',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!CNTL!MERMIN!DIAL:ID NOT FOUND')
          CALL ERROR$STOP('READIN_MERMIN')
        END IF
        CALL LINKEDLIST$GET(LL_CNTL,'ID',0,DIALID)
        IF(TRIM(DIALID).EQ.'T[K]') THEN
          CALL DIALS$SELECT('TEMP(E)')
          CALL LINKEDLIST$GET(LL_CNTL,'RATE',1,RATE)
          CALL LINKEDLIST$GET(LL_CNTL,'FINAL',1,FINAL)
          RATE=RATE*KELVIN
          FINAL=FINAL*KELVIN
        ELSE IF(TRIM(DIALID).EQ.'SPIN[HBAR]') THEN
          CALL DIALS$SELECT('SPIN')
          CALL LINKEDLIST$GET(LL_CNTL,'RATE',1,RATE)
          CALL LINKEDLIST$GET(LL_CNTL,'FINAL',1,FINAL)
          RATE=2.D0*RATE
          FINAL=2.D0*FINAL
        ELSE IF(TRIM(DIALID).EQ.'CHARGE[E]') THEN
          CALL DIALS$SELECT('CHARGE')
          CALL LINKEDLIST$GET(LL_CNTL,'RATE',1,RATE)
          CALL LINKEDLIST$GET(LL_CNTL,'FINAL',1,FINAL)
          RATE=-RATE
          FINAL=-FINAL
        ELSE
          CALL ERROR$MSG('DIAL NAME NOT RECOGNIZED')
          CALL ERROR$CHVAL('DIALID',DIALID)
          CALL ERROR$STOP('READIN_MERMIN')
        END IF
        CALL DIALS$SETL4('ON',.TRUE.)
        CALL DIALS$SETR8('RATE',RATE)
        CALL DIALS$SETR8('FINAL',FINAL)
        CALL DIALS$SELECT('..')
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_SHADOW(LL_CNTL_)
!     ******************************************************************
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK
      REAL(8)               :: SVAR,SVAR1,SVAR2
      INTEGER(4)            :: ISVAR
      INTEGER(4)            :: NFILO
      LOGICAL(4)            :: TON
!     ******************************************************************
                           CALL TRACE$PUSH('READIN_SHADOW')  
      LL_CNTL=LL_CNTL_
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$EXISTL(LL_CNTL,'SHADOW',1,TON)
      IF(.NOT.TON) THEN
        CALL TRACE$POP
        RETURN
      END IF
      CALL ERROR$MSG('!CONTROL!SHADOW IS DISABLED')
      CALL ERROR$STOP('READIN_SHADOW')
      CALL LINKEDLIST$SELECT(LL_CNTL,'SHADOW')

!     == SWITCH LONG-RANGE INTERACTIONS ON/OFF  ========================
!     CALL LINKEDLIST$EXISTD(LL_CNTL,'LONGRANGE',1,TCHK)
!     IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'LONGRANGE',0,.FALSE.)
!     CALL LINKEDLIST$GET(LL_CNTL,'LONGRANGE',0,TCHK)
!     CALL SHADOW$SET('TLONGRANGE',4,.TRUE.)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!OPTIMIZE                                ==
!     ==================================================================
      CALL LINKEDLIST$EXISTL(LL_CNTL,'OPTIMIZE',1,TCHK)
      IF(TCHK) THEN
        CALL LINKEDLIST$SELECT(LL_CNTL,'OPTIMIZE')
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'TOL',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'TOL',0,1.D-6)
        CALL LINKEDLIST$GET(LL_CNTL,'TOL',0,SVAR)
!       CALL SHADOW$SET('TOL',8,SVAR)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'NSTEP',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'NSTEP',0,10000)
        CALL LINKEDLIST$GET(LL_CNTL,'NSTEP',0,ISVAR)
!       CALL SHADOW$SET('NSTEP',4,ISVAR)
!
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      END IF
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!SHADOW!PRECONDITION                     ==
!     ==================================================================
      CALL LINKEDLIST$EXISTL(LL_CNTL,'PRECONDITION',1,TCHK)
      IF(TCHK) THEN
        CALL LINKEDLIST$SELECT(LL_CNTL,'PRECONDITION')
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'OMEGA1[CM**-1]',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'OMEGA1[CM**-1]',0,300.D0)
        CALL LINKEDLIST$GET(LL_CNTL,'OMEGA1[CM**-1]',1,SVAR1)
        SVAR1=SVAR1*4.556D-6
!       CALL SHADOW$SET('OMEGA1',8,SVAR1)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'OMEGA2[CM**-1]',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'OMEGA2[CM**-1]',0,3000.D0)
        CALL LINKEDLIST$GET(LL_CNTL,'OMEGA2[CM**-1]',1,SVAR2)
        SVAR2=SVAR2*4.556D-6
!       CALL SHADOW$SET('OMEGA2',8,SVAR2)
!
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      END IF
                           CALL TRACE$POP
!
!     ==================================================================
!     ==  REPORT  -> SHOULD BE MOVED INTO SHADOW OBJECT               ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='()')
      WRITE(NFILO,FMT='("SHADOW"/"====")')     
!     CALL SHADOW$GET('OPTIMIZE',4,TCHK)
      IF(TCHK) THEN
        WRITE(NFILO,FMT='(55("."),": ",T1,"OPTIMIZE STRUCTURE")')
!       CALL SHADOW$GET('NSTEP',4,ISVAR)
        WRITE(NFILO,FMT='(55("."),": " &
     &           ,T1,"MAX. NUMBER OF ITERATIONS" &
     &           ,T58,F10.5)')ISVAR
!       CALL SHADOW$GET('TOL',8,SVAR)
        WRITE(NFILO,FMT='(55("."),": " &
     &           ,T1,"TOLERANCE ON THE FORCE" &
     &           ,T58,F10.5)')SVAR
      END IF
!     CALL SHADOW$GET('PRECONDITION',4,TCHK)
      IF(TCHK) THEN
        WRITE(NFILO,FMT='(55("."),": ",T1,"PRECONDITION DYNAMICS")')
!       CALL SHADOW$GET('OMEGA1',8,SVAR)
        WRITE(NFILO,FMT='(55("."),": " &
     &           ,T1,"OMEGA1" &
     &           ,T58,F10.5)')SVAR
!       CALL SHADOW$GET('OMEGA2',8,SVAR)
        WRITE(NFILO,FMT='(55("."),": " &
     &           ,T1,"OMEGA2" &
     &           ,T58,F10.5)')SVAR
      END IF
                              CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_QMMM(LL_CNTL_)
!     ******************************************************************
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK
      LOGICAL(4)            :: TON
      LOGICAL(4)            :: TSTOP
      REAL(8)               :: AMPRE
      REAL(8)               :: FRICTION
      REAL(8)               :: KELVIN
      integer(4)            :: multiple
!     ******************************************************************
                           CALL TRACE$PUSH('READIN_QMMM')  
      LL_CNTL=LL_CNTL_
      CALL CONSTANTS('KB',KELVIN)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!QM-MM                                   ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$EXISTL(LL_CNTL,'QM-MM',1,TON)
      CALL QMMM$SETL4('ON',TON)
      IF(.NOT.TON) THEN 
        CALL TRACE$POP
        RETURN
      END IF
      CALL LINKEDLIST$SELECT(LL_CNTL,'QM-MM')
!
!     == DEFAULT VALUES ================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FREEZE',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FREEZE',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'FREEZE',1,TCHK)
      CALL QMMM$SETL4('MOVE',.NOT.TCHK)
!
!     == OVERSAMPLE WITH NMULTIPLE TIME STEPS ==========================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'MULTIPLE',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'MULTIPLE',0,1)
      CALL LINKEDLIST$GET(LL_CNTL,'MULTIPLE',1,MULTIPLE)
      CALL QMMM$SETI4('MULTIPLE',MULTIPLE)
!
!     == START WITH ZERO INITIAL VELOCITIES ============================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'STOP',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'STOP',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'STOP',1,TSTOP)
      CALL QMMM$SETL4('STOP',TSTOP)
!
!     == RANDOMIZE INITIAL VELOCITIES ==================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'RANDOM[K]',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'RANDOM[K]',0,0.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'RANDOM[K]',1,AMPRE) 
      AMPRE=AMPRE*KELVIN
      IF(ampre.ne.0) CALL QMMM$SETR8('RANDOM',AMPRE)
!
!     == FRICTION OFR THE MM ATOMS ======================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FRIC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FRIC',0,0.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'FRIC',0,FRICTION)
      CALL QMMM$SETR8('FRICTION',FRICTION)
!
!     == FRICTION OFR THE MM ATOMS ======================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'ADIABATIC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'ADIABATIC',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'ADIABATIC',0,TCHK)
      CALL QMMM$SETL4('ADIABATIC',TCHK)
!      
!     ==================================================================
!     ==  !CONTROL!QM-MM!AUTO                                         ==
!     ==================================================================
      CALL READIN_AUTO(LL_CNTL,'QM-MM',0.0D0,1.D0,0.5D0,1.D0)
!      
!     ==================================================================
!     ==  !CONTROL!QM-MM!THERMOSTAT                                   ==
!     ==================================================================
      CALL READIN_THERMOSTAT(LL_CNTL_,'QM-MM',293.D0*KELVIN,10.D0)
                           CALL TRACE$POP 
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_ANALYSE_HYPERFINE(LL_CNTL_)
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK
      INTEGER(4)            :: NHYP
      INTEGER(4)            :: IHYP
      CHARACTER(32)         :: ATOM
!     ******************************************************************
                           CALL TRACE$PUSH('READIN_ANALYSE_HYPERFINE')  
      LL_CNTL=LL_CNTL_
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ANALYSE')
      CALL LINKEDLIST$NLISTS(LL_CNTL,'HYPERFINE',NHYP)
      DO IHYP=1,NHYP
        CALL LINKEDLIST$SELECT(LL_CNTL,'HYPERFINE',IHYP)
        CALL LINKEDLIST$GET(LL_CNTL,'ATOM',0,ATOM)
        CALL HYPERFINE$SELECT('~')
        CALL HYPERFINE$SELECT(ATOM)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'EFG',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'EFG',0,.FALSE.)
        CALL LINKEDLIST$GET(LL_CNTL,'EFG',1,TCHK)
        CALL HYPERFINE$SETL4('TEFG',TCHK)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'ISOMERSHIFT',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'ISOMERSHIFT',0,.FALSE.)
        CALL LINKEDLIST$GET(LL_CNTL,'ISOMERSHIFT',1,TCHK)
        CALL HYPERFINE$SETL4('TIS',TCHK)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'FERMICONTACT',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FERMICONTACT',0,.FALSE.)
        CALL LINKEDLIST$GET(LL_CNTL,'FERMICONTACT',1,TCHK)
        CALL HYPERFINE$SETL4('TFC',TCHK)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'ANISOTROPIC',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'ANISOTROPIC',0,.FALSE.)
        CALL LINKEDLIST$GET(LL_CNTL,'ANISOTROPIC',1,TCHK)
        CALL HYPERFINE$SETL4('TANIS',TCHK)
!
        CALL HYPERFINE$SELECT('~')
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ...................................................................
      SUBROUTINE READIN_CONTINUUM(LL_CNTL_)
      USE LINKEDLIST_MODULE
      USE STRINGS_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)            :: LL_CNTL
      LOGICAL(4)               :: TCHK
      REAL(8)                  :: SVAR
      REAL(8)                  :: FRICTION
      REAL(8)                  :: SCALE
!     ******************************************************************
      LL_CNTL=LL_CNTL_
!     ==================================================================
!     ==  READ BLOCK !CONTINUUM                                       ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$EXISTL(LL_CNTL,'CONTINUUM',1,TCHK)
      CALL CONTINUUM$SETL4('ON',TCHK)
      IF(.NOT.TCHK) RETURN
                               CALL TRACE$PUSH('READIN_CONTINUUM')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTINUUM')
!
!     == STOP =======================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'STOP',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'STOP',1,.FALSE.)
      END IF
      CALL LINKEDLIST$GET(LL_CNTL,'STOP',1,TCHK)
      CALL CONTINUUM$SETL4('STOP',TCHK)
!
!     == FREEZE =======================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FREEZE',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'FREEZE',1,.FALSE.)
      END IF
      CALL LINKEDLIST$GET(LL_CNTL,'FREEZE',1,TCHK)
      CALL CONTINUUM$SETL4('FREEZE',TCHK)
!
!     == EXCLUDE OVERLAP ===========================================
!     == SET CHARGES WITH IN SPHER OVERLAP EXACTLY TO ZERO =========
      CALL LINKEDLIST$EXISTD(LL_CNTL,'EXCLUDEOVERLAP',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'EXCLUDEOVERLAP',1,.FALSE.)
      END IF
      CALL LINKEDLIST$GET(LL_CNTL,'EXCLUDEOVERLAP',1,TCHK)
      CALL CONTINUUM$SETL4('EXCLUDEOVERLAP',TCHK)
!
!     == START =====================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'START',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'START',1,.FALSE.)
      END IF
      CALL LINKEDLIST$GET(LL_CNTL,'START',1,TCHK)
      CALL CONTINUUM$SETL4('START',TCHK)
!
!     == MASS ===================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'M',1,TCHK)
      IF(.NOT.TCHK) THEN
        PRINT*,'WARNING! NO MASS FOR SURFACE CHARGES SUPPLIED!'
        PRINT*,'DEFAULT VALUE OF 1000.D0 IS SUPPLIED BY PAW!'
        CALL LINKEDLIST$SET(LL_CNTL,'M',1,1000.D0)
      END IF
      CALL LINKEDLIST$GET(LL_CNTL,'M',1,SVAR)
      CALL CONTINUUM$SETR8('MASS',SVAR)
!
!     == EPSILON = DIELECTRIC CONSTANT ===========================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'EPSILON',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'EPSILON',1,1.D12)
      END IF
      CALL LINKEDLIST$GET(LL_CNTL,'EPSILON',1,SVAR)
      CALL CONTINUUM$SETR8('EPSILON',SVAR)
!
!     ==  FRIC ===================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FRIC',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL LINKEDLIST$SET(LL_CNTL,'FRIC',1,0.D0)
      END IF
      CALL LINKEDLIST$GET(LL_CNTL,'FRIC',1,SVAR)
      CALL CONTINUUM$SETR8('FRICTION',SVAR)
!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!CONTINUUM!AUTO                          ==
!     ==================================================================
      CALL FILEHANDLER$SETFILE('CONTINUUM_RESTART',.TRUE.,-'.CONTINUUM_RESTART')
      CALL FILEHANDLER$SETSPECIFICATION('CONTINUUM_RESTART','FORM','FORMATTED')
      CALL FILEHANDLER$SETFILE('CONTINUUM_PROTOCOL',.TRUE.,-'_SURFACECHARGE.PROT')
      CALL FILEHANDLER$SETSPECIFICATION('CONTINUUM_PROTOCOL','STATUS','OLD')
      CALL FILEHANDLER$SETSPECIFICATION('CONTINUUM_PROTOCOL','FORM','FORMATTED')

!
!     ==================================================================
!     ==  READ BLOCK !CONTROL!CONTINUUM!AUTO                          ==
!     ==================================================================
      CALL READIN_AUTO(LL_CNTL,'CONTINUUM',0.3D0,0.96D0,1.D0,1.D0)
!
!     ==================================================================
!     ==  READ BLOCK !QNOSE                                           ==
!     ==================================================================
      CALL READIN_CONTINUUM_NOSE(LL_CNTL_)
!
                                 CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_CONTINUUM_NOSE(LL_CNTL_)
!     ******************************************************************
!     ** REQUIRES SETTING OF                                          **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK
      REAL(8)               :: TERA
      REAL(8)               :: SECOND
      REAL(8)               :: CELVIN
      LOGICAL(4)            :: TON
      REAL(8)               :: TEMP
      LOGICAL(4)            :: TSTOP
      REAL(8)               :: FREQ
      REAL(8)               :: PERIOD
      REAL(8)               :: FRICTION
!     ******************************************************************
                            CALL TRACE$PUSH('READIN_CONTINUUM_NOSE')
      LL_CNTL=LL_CNTL_
      CALL CONSTANTS('TERA',TERA)
      CALL CONSTANTS('SECOND',SECOND)
      CALL CONSTANTS('KB',CELVIN)
!
!     ==================================================================
!     == SELECT RNOSE LIST OR EXIT IF IT DOES NOT EXIST               ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTINUUM')
!
      CALL LINKEDLIST$EXISTL(LL_CNTL,'NOSE',1,TON)
      CALL THERMOSTAT$CREATE('CONTINUUM')
      CALL THERMOSTAT$SETL4('ON',TON)
      IF(.NOT.TON) THEN
        CALL TRACE$POP
        RETURN
      END IF
!
      CALL LINKEDLIST$SELECT(LL_CNTL,'NOSE')
!
!     ==================================================================
!     ==  COLLECT DATA                                                ==
!     ==================================================================
!     == STOP INITIAL VELOCITIES =======================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'STOP',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'STOP',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_CNTL,'STOP',1,TSTOP)
      CALL THERMOSTAT$SETL4('STOP',TSTOP)
!
!     == TEMPERATURE  ==================================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'<EKIN>',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL ERROR$MSG('!CONTROL!CONTINUUM!NOSE:<EKIN> NOT SPECIFIED')
        CALL ERROR$STOP('READIN_CONTINUUM_NOSE')
      END IF
      CALL LINKEDLIST$GET(LL_CNTL,'<EKIN>',1,TEMP)
      CALL THERMOSTAT$SETR8('TEMP',TEMP)
!
!     ==  "EIGENFREQUENCY" OF THE THERMOSTAT  ========================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FREQ[THZ]',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FREQ[THZ]',0,10.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'FREQ[THZ]',1,FREQ)
      FREQ=FREQ*TERA/SECOND
      PERIOD=1.D0/FREQ       ! CONVERT TO OSCILLATION PERIOD
      CALL THERMOSTAT$SETR8('TNOSE',PERIOD)
!
!     == FRICTION ON THE THERMOSTAT ===================================
      CALL LINKEDLIST$EXISTD(LL_CNTL,'FRIC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FRIC',0,00.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'FRIC',1,FRICTION)
      CALL THERMOSTAT$SETR8('FRICTION',FRICTION) 
!
                            CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_ANALYSE_WAVE(LL_CNTL_)
!     ******************************************************************
!     ==                                                              ==
!     ==  FILE=FILENAME                                               ==
!     ==  TITLE= IMAGE TITLE                                          ==
!     ==  TYPE='WAVE','DENSITY'                                       ==
!     ==  WEIGHTING='NONE','SPIN','TOTAL'                             ==
!     ==  FORMAT=ALL,RANGE,LIST                                       ==
!     ==  STATE->IB,IKPT,ISPIN                                        ==
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK
      TYPE(LL_TYPE)         :: LL_IMAGELIST
      INTEGER(4)            :: NWAVE
      INTEGER(4)            :: NSTATE
      INTEGER(4)            :: IWAVE,ISTATE
      INTEGER(4)            :: IB,IKPT,ISPIN
      CHARACTER(256)        :: CH256SVAR1
      CHARACTER(8)          :: CH8SVAR1
!     ******************************************************************
                           CALL TRACE$PUSH('READIN_ANALYSE_WAVE')  
      LL_CNTL=LL_CNTL_
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ANALYSE')
      CALL LINKEDLIST$NLISTS(LL_CNTL,'WAVE',NWAVE)
      DO IWAVE=1,NWAVE
        CALL LINKEDLIST$SELECT(LL_CNTL,'WAVE',IWAVE)
             CALL GRAPHICS$GETLIST(LL_IMAGELIST)    
             CALL LINKEDLIST$SELECT(LL_IMAGELIST,'~')
             CALL LINKEDLIST$SELECT(LL_IMAGELIST,'IMAGE',-1)
!
!       == SET TITLE OF THE IMAGE ======================================
        CALL LINKEDLIST$EXISTD(LL_CNTL,'TITLE',1,TCHK)
        IF(.NOT.TCHK) THEN
          CH256SVAR1=' '
          WRITE(CH256SVAR1,*)'WAVE',IWAVE
          CALL LINKEDLIST$SET(LL_CNTL,'TITLE',0,TRIM(CH256SVAR1))
        ELSE
          CALL LINKEDLIST$GET(LL_CNTL,'TITLE',1,CH256SVAR1)
        END IF
        CALL LINKEDLIST$SET(LL_IMAGELIST,'TITLE',0,TRIM(CH256SVAR1))
!
!       == SET FILENAME FOR TEH IMAGE===================================
        CALL LINKEDLIST$GET(LL_CNTL,'FILE',1,CH256SVAR1)
        CALL LINKEDLIST$SET(LL_IMAGELIST,'FILE',0,TRIM(CH256SVAR1))
!
!       __ GET TYPE_(DENSITY,WAVE)____________________________________
        CALL LINKEDLIST$GET(LL_CNTL,'TYPE',1,CH8SVAR1)
        CALL LINKEDLIST$SET(LL_IMAGELIST,'TYPE',0,TRIM(CH8SVAR1))
!
!       __ GET WEIGHTING_(NONE,SPIN,TOTAL)____________________________
        IF(CH8SVAR1(1:4).EQ.'TYPE') THEN
          CALL LINKEDLIST$SET(LL_CNTL,'WEIGHTING',0,'NONE')
        END IF
        CALL LINKEDLIST$EXISTD(LL_CNTL,'WEIGHTING',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'WEIGHTING',0,'TOTAL')
        CALL LINKEDLIST$GET(LL_CNTL,'WEIGHTING',1,CH8SVAR1)
        CALL LINKEDLIST$SET(LL_IMAGELIST,'WEIGHTING',0,TRIM(CH8SVAR1))
!
!         __ GET FORMAT_(ALL,RANGE,LIST)________________________________
        CALL LINKEDLIST$EXISTD(LL_CNTL,'FORMAT',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'FORMAT',0,'ALL')
        CALL LINKEDLIST$GET(LL_CNTL,'FORMAT',1,CH8SVAR1)
        CALL LINKEDLIST$SET(LL_IMAGELIST,'FORMAT',0,TRIM(CH8SVAR1))
!
!       ================================================================
!       ==  READ BLOCK !ANALYSE!WAVE!STATE                            ==
!       ================================================================
        CALL LINKEDLIST$NLISTS(LL_CNTL,'STATE',NSTATE)
        DO ISTATE=1,NSTATE
          CALL LINKEDLIST$SELECT(LL_CNTL,'STATE',ISTATE)
          CALL LINKEDLIST$SELECT(LL_IMAGELIST,'STATE',-1)
!         __ BAND INDEX________________________________________________
          CALL LINKEDLIST$EXISTD(LL_CNTL,'B',1,TCHK)
          IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'B',0,1)
          CALL LINKEDLIST$GET(LL_CNTL,'B',1,IB)
          CALL LINKEDLIST$SET(LL_IMAGELIST,'IB',0,IB)
!         __ K-POINT INDEX_____________________________________________
          CALL LINKEDLIST$EXISTD(LL_CNTL,'K',1,TCHK)
          IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'K',0,1)
          CALL LINKEDLIST$GET(LL_CNTL,'K',1,IKPT)
          CALL LINKEDLIST$SET(LL_IMAGELIST,'IKPT',0,IKPT)
!         __ SPIN INDEX _______________________________________________
          CALL LINKEDLIST$EXISTD(LL_CNTL,'S',1,TCHK)
          IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'S',0,1)
          CALL LINKEDLIST$GET(LL_CNTL,'S',1,ISPIN)
          CALL LINKEDLIST$SET(LL_IMAGELIST,'ISPIN',0,ISPIN)
!
          CALL LINKEDLIST$SELECT(LL_IMAGELIST,'..')
          CALL LINKEDLIST$SELECT(LL_CNTL,'..')
        ENDDO
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE READIN_ANALYSE_POTCHARGEPOT(LL_CNTL_)
!     ******************************************************************
!     ****************************************************************** 
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_CNTL_
      TYPE(LL_TYPE)         :: LL_CNTL
      LOGICAL(4)            :: TCHK
      LOGICAL(4)            :: TON
      TYPE(LL_TYPE)         :: LL_IMAGELIST
      CHARACTER(256)   :: CH256SVAR1
      CHARACTER(8)     :: CH8SVAR1
!     ******************************************************************
                           CALL TRACE$PUSH('READIN_ANALYSE_POINTCHARGEPOT')  
      LL_CNTL=LL_CNTL_
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'CONTROL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ANALYSE')
      CALL LINKEDLIST$EXISTL(LL_CNTL,'POINTCHARGEPOT',1,TON)
      IF(.NOT.TON) THEN
        CALL TRACE$POP
        RETURN
      END IF
      CALL ERROR$MSG('OPTIN POINTCHARGEPOT DISABLED')
      CALL ERROR$MSG('USE A PAW TOOL')
      CALL ERROR$STOP('READIN_ANALYSE_POINTCHARGEPOT')
      CALL LINKEDLIST$SELECT(LL_CNTL,'POINTCHARGEPOT')
!
      CALL GRAPHICS$GETLIST(LL_IMAGELIST)    
      CALL LINKEDLIST$SELECT(LL_IMAGELIST,'~')
      CALL LINKEDLIST$SELECT(LL_IMAGELIST,'IMAGE',-1)
!     __ GET TITLE__________________________________________________
      CH256SVAR1='POTENTIAL OF POINT CHARGE MODEL'
      CALL LINKEDLIST$SET(LL_IMAGELIST,'TITLE',0,CH256SVAR1)
!     __ GET FILE___________________________________________________
      CALL LINKEDLIST$GET(LL_CNTL,'FILE',1,CH256SVAR1)
      CALL LINKEDLIST$SET(LL_IMAGELIST,'FILE',0,CH256SVAR1)
!     __ GET FILE_(DENSITY,WAVE)____________________________________
      CH8SVAR1='PQV'
      CALL LINKEDLIST$SET(LL_IMAGELIST,'TYPE',0,CH8SVAR1)
                           CALL TRACE$POP
      RETURN
      END
!
!     .....................................................STRCIN.......
      SUBROUTINE STRCIN
!     ******************************************************************
!     **                                                              **
!     **  READ STRUCTURAL DATA                                        **
!     **                                                              **
!     ************P.E. BLOECHL, IBM RESEARCH LABORATORY ZURICH (1995)***
      USE IO_MODULE
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      INTEGER(4)            :: NFILO   ! PROTOCOL FILE UNIT
      INTEGER(4)            :: NFIL
      LOGICAL(4)            :: TCHK
      REAL(8)               :: RUNIT
      INTEGER(4)            :: NFREE,NKPT,NAT
!     ******************************************************************
                          CALL TRACE$PUSH('STRCIN')
      CALL FILEHANDLER$UNIT('PROT',NFILO)
!
!     ==================================================================
!     ==  SELECT STRUCTURE FILE AND READ IT INTO THE BUFFER           ==
!     ==================================================================
      CALL LINKEDLIST$NEW(LL_STRC)
      CALL FILEHANDLER$UNIT('STRC',NFIL)
      CALL LINKEDLIST$READ(LL_STRC,NFIL)
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
!
!     ==================================================================
!     ==  ENTER BLOCK !STRUCTURE                                      ==
!     ==================================================================
      
      CALL LINKEDLIST$EXISTL(LL_STRC,'STRUCTURE',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL ERROR$MSG('DATA FOR BLOCK STRUCTURE MISSING')
        CALL ERROR$STOP('STRCIN')
      END IF
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
!    
!     ==================================================================
!     ==  READ BLOCK !STRUCTURE!GENERIC                               ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'GENERIC')
!
!     ==  READ ACTUAL VALUES  ==========================================
      CALL LINKEDLIST$EXISTD(LL_STRC,'LUNIT',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'LUNIT',0,1.D0)
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
!    
!     ==================================================================
!     ==  READ BLOCK !STRUCTURE!LATTICE                               ==
!     ==================================================================
      CALL STRCIN_LATTICE(LL_STRC)
!    
!     ==================================================================
!     ==  READ BLOCK !STRUCTURE!KPOINT                                ==
!     ==================================================================
      CALL STRCIN_KPOINT(LL_STRC,NKPT)
!    
!     ==================================================================
!     ==  READ BLOCK !STRUCTURE!SPECIES                               ==
!     ==================================================================
      CALL STRCIN_SPECIES(LL_STRC)
!
!     ==================================================================
!     ==  ENTER BLOCK !ATOM                                           ==
!     ==================================================================
      CALL STRCIN_ATOM(LL_STRC)
!
!     ==================================================================
!     ==  ENTER BLOCK !GROUP                                          ==
!     ==================================================================
      CALL STRCIN_GROUP(LL_STRC)
!
!     ==================================================================
!     ==  ENTER BLOCK !STRC!OCCUP                                     ==
!     ==================================================================
      CALL STRCIN_OCCUP(LL_STRC,NKPT)
!
!     ==================================================================
!     ==  ENTER BLOCK !ISOLATE                                        ==
!     ==================================================================
      CALL STRCIN_ISOLATE(LL_STRC)
!
!     ==================================================================
!     ==  ENTER BLOCK !ORBPOT                                         ==
!     ==================================================================
      CALL STRCIN_ORBPOT(LL_STRC)
!
!     ==================================================================
!     ==  ENTER BLOCK !STRUCTURE!QM-MM                                ==
!     ==================================================================
      CALL STRCIN_SOLVENT(LL_STRC)
!
!     ==================================================================
!     ==  ENTER BLOCK !STRUCTURE!CONTINUUM                            ==
!     ==================================================================
      CALL STRCIN_CONTINUUM(LL_STRC)
!
!     ==================================================================
!     ==  ENTER BLOCK !STRUCTURE!CONSTRAINTS!RIGID                    ==
!     ================================================================== 
      CALL STRCIN_CONSTRAINTS_RIGID(LL_STRC)
      CALL STRCIN_CONSTRAINTS_FREEZE(LL_STRC)
      CALL STRCIN_CONSTRAINTS_LINEAR(LL_STRC)
      CALL STRCIN_CONSTRAINTS_BOND(LL_STRC)
      CALL STRCIN_CONSTRAINTS_MIDPLANE(LL_STRC)
      CALL STRCIN_CONSTRAINTS_TRANSLATION(LL_STRC)
      CALL STRCIN_CONSTRAINTS_ROTATION(LL_STRC)
      CALL STRCIN_CONSTRAINTS_ORIENTATION(LL_STRC)
      CALL STRCIN_CONSTRAINTS_COGSEP(LL_STRC)
      CALL STRCIN_CONSTRAINTS_ANGLE(LL_STRC)
      CALL STRCIN_CONSTRAINTS_TORSION(LL_STRC)
                          CALL TRACE$PASS('BLOCK !STRUCTURE FINISHED')
!
!     ==================================================================
!     ==  FIX THERMOSTAT                                              ==
!     ==================================================================
      CALL ATOMLIST$NATOM(NAT)
      CALL CONSTRAINTS$NFREE(NAT,NFREE)
      CALL THERMOSTAT$SELECT('ATOMS')
      CALL THERMOSTAT$SETR8('GFREE',DBLE(NFREE))
!
!     ==================================================================
!     ==                                                              ==
!     ==================================================================
      CALL FILEHANDLER$CLOSE('STRC')
      CALL FILEHANDLER$CLOSE('PROT')
                          CALL TRACE$POP
      RETURN
      END
!     ..................................................................
      SUBROUTINE STRCIN_LATTICE(LL_STRC_)
!     ****************************************************************** 
!     **  DEFINES LATTICE IN ATOMLIST OBJECT                          **
!     **                                                              **
!     **  REQUIRES PREDEFINED: NOTHING                                **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      LOGICAL(4)               :: TCHK
      REAL(8)                  :: UNIT
      REAL(8)                  :: RBAS(3,3)
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_LATTICE')  
      LL_STRC=LL_STRC_
!    
!     ==================================================================
!     ==  READ UNIT FROM BLOCK !STRUCTURE!GENERIC                     ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'GENERIC')
!
      CALL LINKEDLIST$GET(LL_STRC,'LUNIT',1,UNIT)
!    
!     ==================================================================
!     ==  READ BLOCK !STRUCTURE!LATTICE                               ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$EXISTL(LL_STRC,'LATTICE',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL ERROR$MSG('BLOCK !STRUCTURE!LATTICE IS MANDATORY')
        CALL ERROR$STOP('STRCIN_LATTICE')
      END IF
      CALL LINKEDLIST$SELECT(LL_STRC,'LATTICE')
!
!     == DEFAULT VALUES  ===============================================
      CALL LINKEDLIST$EXISTD(LL_STRC,'T',1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL ERROR$MSG('KEYWORD T= IS MANDATORY')
        CALL ERROR$STOP('STRCIN; !STRUCTURE!LATTICE')
      END IF
!
!     ==  READ ACTUAL VALUES  ==========================================
      CALL LINKEDLIST$GET(LL_STRC,'T',1,RBAS)
      RBAS(:,:)=RBAS(:,:)*UNIT
      CALL ATOMLIST$SETLATTICE(RBAS)
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_KPOINT(LL_STRC_,NKPT)
!     ******************************************************************
!     **  DEFINES THE K-POINT INFO OF OCCUPATIONS_MODULE              **
!     **                                                              **
!     **  REQUIRES PREDEFINED: NOTHING                                **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      INTEGER(4)   ,INTENT(OUT):: NKPT
      TYPE(LL_TYPE)            :: LL_STRC
      LOGICAL(4)               :: TCHK
      INTEGER(4)               :: IKPT
      INTEGER(4)   ,ALLOCATABLE:: IXK(:,:)
      INTEGER(4)               :: IXK0(3)
      INTEGER(4)               :: NKDIV(3)
      REAL(8)                  :: WKPT
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_KPOINT')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$NLISTS(LL_STRC,'KPOINT',NKPT)
      IF(NKPT.EQ.0) THEN
        CALL LINKEDLIST$SELECT(LL_STRC,'KPOINT')
        IXK0(:)=0
        CALL LINKEDLIST$SET(LL_STRC,'K',0,IXK0) 
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
        NKPT=1
      END IF
!
!     ==  READ ACTUAL VALUES  ==========================================
      ALLOCATE(IXK(3,NKPT))
      DO IKPT=1,NKPT
        CALL LINKEDLIST$SELECT(LL_STRC,'KPOINT',IKPT)
        CALL LINKEDLIST$EXISTD(LL_STRC,'K',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('KEYWORD K IN BLOCK !STRUCTURE!KPOINT IS MANDATORY')
          CALL ERROR$I4VAL('IKPT',IKPT)
          CALL ERROR$STOP('STRCIN_KPOINT')
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'K',1,IXK0)
        IXK(:,IKPT)=IXK0(:)
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
!
!     ==  PERFORM ACTIONS  ==============================================
      WKPT=1.D0/DBLE(NKPT)
      NKDIV(:)=2
      CALL DYNOCC$SETI4('NKPT',NKPT)
      CALL DYNOCC$SETI4A('NKDIV',3,NKDIV)
      CALL DYNOCC$SETI4A('IXK',3*NKPT,IXK)
      DEALLOCATE(IXK)
                           CALL TRACE$POP
      RETURN
      END
!     
!     ...................................................................
      SUBROUTINE STRCIN_SPECIES(LL_STRC_)
!     ******************************************************************
!     **  DEFINES THE ATOMTYPELIST                                    **
!     **                                                              **
!     **  REQUIRES PREDEFINED: NOTHING                                **
!     ****************************************************************** 
      USE LINKEDLIST_MODULE
      USE PERIODICTABLE_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      LOGICAL(4)               :: TCHK
      INTEGER(4)               :: NSP
      INTEGER(4)               :: ISP
      CHARACTER(8)             :: CH8SVAR1
      CHARACTER(32)            :: SPNAME
      CHARACTER(256)           :: SETUPFILE
      INTEGER(4)               :: IZ
      REAL(8)                  :: Z
      REAL(8)                  :: SVAR
      REAL(8)                  :: PROTONMASS
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_SPECIES')
      LL_STRC=LL_STRC_
      CALL CONSTANTS('U',PROTONMASS)
!
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$NLISTS(LL_STRC,'SPECIES',NSP)
      CALL ATOMTYPELIST$INITIALIZE(10)
      DO ISP=1,NSP
        CALL LINKEDLIST$SELECT(LL_STRC,'SPECIES',ISP)
        CALL LINKEDLIST$GET(LL_STRC,'NAME',1,SPNAME)
             CALL ATOMTYPELIST$ADD(SPNAME)
             CH8SVAR1=SPNAME(1:2)
             IF(CH8SVAR1(2:2).EQ.'_') CH8SVAR1(2:2)=' '
!            CALL PERIODICTABLE$ATOMICNUMBER(CH8SVAR1(1:2),IZ)
             CALL PERIODICTABLE$GET(CH8SVAR1(1:2),'Z',IZ)
             Z=DBLE(IZ)
             CALL ATOMTYPELIST$SETZ(SPNAME,Z)
!
!       ================================================================
!       ==  connect setup file                                        ==
!       ================================================================
        CALL LINKEDLIST$GET(LL_STRC,'FILE',1,SETUPFILE)
             CALL ATOMTYPELIST$INDEX(SPNAME,ISP)
             CH8SVAR1=' '
             WRITE(CH8SVAR1,*)ISP
             CH8SVAR1='ATOM'//ADJUSTL(CH8SVAR1)
             CALL ATOMTYPELIST$SETFILE(SPNAME,CH8SVAR1(1:5))
!
             CALL FILEHANDLER$SETFILE(CH8SVAR1(1:5),.FALSE.,SETUPFILE)
             CALL FILEHANDLER$SETSPECIFICATION(CH8SVAR1(1:5),'STATUS','OLD')
             CALL FILEHANDLER$SETSPECIFICATION(CH8SVAR1(1:5),'POSITION','REWIND')
             CALL FILEHANDLER$SETSPECIFICATION(CH8SVAR1(1:5),'ACTION','READ')
             CALL FILEHANDLER$SETSPECIFICATION(CH8SVAR1(1:5),'FORM','FORMATTED')
!
!       ================================================================
!       ==                                                            ==
!       ================================================================
        CALL LINKEDLIST$GET(LL_STRC,'ZV',1,SVAR)
             CALL ATOMTYPELIST$SETVALENCE(SPNAME,SVAR)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'M',1,TCHK)
        IF(.NOT.TCHK) THEN
!         CALL PERIODICTABLE$MASS(IZ,SVAR)
          CALL PERIODICTABLE$GET(IZ,'MASS',SVAR)
          CALL LINKEDLIST$SET(LL_STRC,'M',0,SVAR/PROTONMASS)
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'M',1,SVAR)
        CALL ATOMTYPELIST$SETMASS(SPNAME,SVAR*PROTONMASS)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'PSEKIN',1,TCHK)
        IF(.NOT.TCHK) CALL LINKEDLIST$SET(LL_STRC,'PSEKIN',0,0.D0)
        CALL LINKEDLIST$GET(LL_STRC,'PSEKIN',1,SVAR)
        CALL ATOMTYPELIST$SETPSEKIN(SPNAME,SVAR)
!
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_ATOM(LL_STRC_)
!     ******************************************************************
!     **  DEFINES THE ATOMLIST                                        **
!     **                                                              **
!     **  REQUIRES PREDEFINED: ATOMTYPELIST                           **
!     **  MODIFIES           : ATOMLIST                               **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      LOGICAL(4)               :: TCHK
      INTEGER(4)            :: NAT
      INTEGER(4)            :: IAT
      INTEGER(4)            :: ISP
      INTEGER(4)            :: NSP
      CHARACTER(32)         :: ATOM,SPECIES,STRING
      REAL(8)               :: SVAR
      REAL(8)               :: UNIT
      REAL(8)               :: POS(3)
      REAL(8)               :: PROTONMASS
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_ATOM')
      LL_STRC=LL_STRC_
      CALL CONSTANTS('U',PROTONMASS)
      CALL ATOMTYPELIST$LENGTH(NSP)
!    
!     ==================================================================
!     ==  READ BLOCK !STRUCTURE!GENERIC                               ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'GENERIC')
      CALL LINKEDLIST$GET(LL_STRC,'LUNIT',1,UNIT)
!    
!     ==================================================================
!     ==  READ BLOCK !STRUCTURE!ATOM                                  ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$NLISTS(LL_STRC,'ATOM',NAT)
      CALL ATOMLIST$INITIALIZE(NAT)
      DO IAT=1,NAT
        CALL LINKEDLIST$SELECT(LL_STRC,'ATOM',IAT)
        CALL LINKEDLIST$GET(LL_STRC,'NAME',1,ATOM)
        CALL ATOMLIST$SETCH('NAME',IAT,ATOM)
!  
        CALL LINKEDLIST$EXISTD(LL_STRC,'SP',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL LINKEDLIST$SET(LL_STRC,'SP',0,ATOM(1:2))
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'SP',1,SPECIES)
!
        TCHK=.FALSE.
        DO ISP=1,NSP
          CALL ATOMTYPELIST$NAME(ISP,STRING)
          IF(STRING.EQ.SPECIES) THEN
            TCHK=.TRUE.
            CALL ATOMLIST$SETI4('ISPECIES',IAT,ISP)
            CALL ATOMTYPELIST$Z(SPECIES,SVAR)
            CALL ATOMLIST$SETR8('Z',IAT,SVAR)
            CALL ATOMTYPELIST$VALENCE(SPECIES,SVAR)
            CALL ATOMLIST$SETR8('ZVALENCE',IAT,SVAR)
            CALL ATOMTYPELIST$MASS(SPECIES,SVAR)
            CALL ATOMLIST$SETR8('MASS',IAT,SVAR)
            CALL ATOMTYPELIST$PSEKIN(SPECIES,SVAR)
            CALL ATOMLIST$SETR8('PSEKIN',IAT,SVAR)
          END IF
        ENDDO 
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('NO SPECIES FOR ATOM')
          CALL ERROR$MSG('IN BLOCK !STRUCTURE!ATOM')
          CALL ERROR$CHVAL('ATOM NAME',ATOM)
          CALL ERROR$STOP('STRCIN_ATOM')
        END IF
!
!       __ATOMIC POSITION_______________________________________________
        CALL LINKEDLIST$GET(LL_STRC,'R',1,POS)
        POS(:)=POS(:)*UNIT
        CALL ATOMLIST$SETR8A('R(0)',IAT,3,POS) 
        CALL ATOMLIST$SETR8A('R(-)',IAT,3,POS)
        CALL ATOMLIST$SETR8A('R(+)',IAT,3,POS)
!
!       __ATOMIC MASS___________________________________________________
        CALL LINKEDLIST$EXISTD(LL_STRC,'M',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'M',1,SVAR)
          CALL ATOMLIST$SETR8('MASS',IAT,SVAR*PROTONMASS)
        END IF
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
!
!     ==  CHECKS AND TRANSFORMATIONS =================================
      CALL ATOMLIST$ORDER
!
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_ISOLATE(LL_STRC_)
!     ******************************************************************
!     **  DEFINES THE ISOLATE OBJECT                                  **
!     **                                                              **
!     **  REQUIRES PREDEFINED: NOTHING                                **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      LOGICAL(4)               :: TCHK
      LOGICAL(4)               :: TON
      INTEGER(4)               :: NFCT
      REAL(8)                  :: RC
      REAL(8)                  :: RCFAC
      REAL(8)                  :: GMAX2
      INTEGER(4)               :: NFILO
      LOGICAL(4)               :: DECOUPLE
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_ISOLATE')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$EXISTL(LL_STRC,'ISOLATE',1,TON)
      IF(.NOT.TON) THEN
        NFCT=2
        RC=1.D0
        RCFAC=1.5D0
        GMAX2=3.D0
        DECOUPLE=.FALSE.
        CALL ISOLATE$ONOFF('OFF',NFCT,RC,RCFAC,GMAX2,DECOUPLE)
        CALL TRACE$POP
        RETURN
      END IF
      CALL LINKEDLIST$SELECT(LL_STRC,'ISOLATE',0)
!
!     == SET DEFAULTS ==================================================
      
      CALL LINKEDLIST$EXISTD(LL_STRC,'NF',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'NF',0,2)
      CALL LINKEDLIST$GET(LL_STRC,'NF',1,NFCT)

      CALL LINKEDLIST$EXISTD(LL_STRC,'RC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'RC',0,1.D0)
      CALL LINKEDLIST$GET(LL_STRC,'RC',1,RC)

      CALL LINKEDLIST$EXISTD(LL_STRC,'RCFAC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'RCFAC',0,1.5D0)
      CALL LINKEDLIST$GET(LL_STRC,'RCFAC',1,RCFAC)

      CALL LINKEDLIST$EXISTD(LL_STRC,'GMAX2',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'GMAX2',0,3.D0)
      CALL LINKEDLIST$GET(LL_STRC,'GMAX2',1,GMAX2)
!
      CALL LINKEDLIST$EXISTD(LL_STRC,'DECOUPLE',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'DECOUPLE',0,.TRUE.)
      CALL LINKEDLIST$GET(LL_STRC,'DECOUPLE',1,DECOUPLE)
!
!     == PERFORM ACTIONS ===============================================
      CALL ISOLATE$ONOFF('ON',NFCT,RC,RCFAC,GMAX2,DECOUPLE)
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_OCCUP(LL_STRC_,NKPT)
!     ******************************************************************
!     **  DEFINES THE DYNOCC OBJECT                                   **
!     **                                                              **
!     **  REQUIRES PREDEFINED: FILEHANDLER,ATOMLIST                   **
!     **  MODIFIES           :: DFT,DYNOCC                            **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN):: LL_STRC_
      INTEGER(4)   ,INTENT(IN):: NKPT
      TYPE(LL_TYPE)           :: LL_STRC
      LOGICAL(4)              :: TCHK
      INTEGER(4)            :: NB
      INTEGER(4)            :: NSPIN
      INTEGER(4)            :: NTH
      INTEGER(4)            :: NAT
      INTEGER(4)            :: ITH,IB,IKPT,ISPIN,IAT
      INTEGER(4)            :: IK1,IK2,IS1,IS2
      REAL(8)               :: F0      !OCCUPATION       
      REAL(8)               :: QION    !IONIZATION STATE 
      REAL(8)               :: TOTSPIN ! SPIN STATE
      REAL(8)               :: SUMOFZ  ! SUM OF NUCLEAR CHARGES FROM ALL ATOMS
      REAL(8)               :: SVAR
      INTEGER(4)            :: NFILO
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_OCCUP')
      LL_STRC=LL_STRC_
      CALL FILEHANDLER$UNIT('PROT',NFILO)
!    
!     ==================================================================
!     ==  READ BLOCK !STRUCTURE!OCCUPATIONS                           ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'OCCUPATIONS')
!
!     == DEFAULT VALUES  ===============================================
      CALL LINKEDLIST$EXISTD(LL_STRC,'NSPIN',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'NSPIN',0,1)
      CALL LINKEDLIST$GET(LL_STRC,'NSPIN',1,NSPIN)
      IF(NSPIN.LT.1.OR.NSPIN.GT.2) THEN
        CALL ERROR$MSG('NUMBER OF SPINS OUT OF RANGE')
        CALL ERROR$I4VAL('NSPIN',NSPIN)
        CALL ERROR$STOP('STRCIN_OCCUP')
      END IF 

      CALL LINKEDLIST$EXISTD(LL_STRC,'CHARGE[E]',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'CHARGE[E]',0,0.D0)
      CALL LINKEDLIST$CONVERT(LL_STRC,'CHARGE[E]',1,'R(8)')
      CALL LINKEDLIST$GET(LL_STRC,'CHARGE[E]',1,QION)
      QION =-QION

      CALL LINKEDLIST$EXISTD(LL_STRC,'SPIN[HBAR]',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'SPIN[HBAR]',0,0.D0)
      CALL LINKEDLIST$CONVERT(LL_STRC,'CHARGE[E]',1,'R(8)')
      CALL LINKEDLIST$GET(LL_STRC,'SPIN[HBAR]',1,TOTSPIN) 
      TOTSPIN=2.D0*TOTSPIN
      IF(DABS(TOTSPIN).GT.1.D-6.AND.NSPIN.EQ.1) THEN
        CALL ERROR$MSG('A FINITE MAGNETIC MOMENT REQUIRES NSPIN=2')
        CALL ERROR$I4VAL('NSPIN',NSPIN)
        CALL ERROR$R8VAL('SPIN[HBAR]',TOTSPIN/2.D0)
        CALL ERROR$STOP('STRCIN_OCCUP')
      END IF
!    
!     ==================================================================
!     ==  SET DFT OBJECT TO LSD                                       ==
!     ==================================================================
      CALL DFT$SETL4('SPIN',NSPIN.EQ.2)
!    
!     ==================================================================
!     ==  GET HIGHEST BAND FROM BLOCK !STRUCTURE!OCCUPATIONS!STATE    ==
!     ==================================================================
      CALL LINKEDLIST$EXISTD(LL_STRC,'NBAND',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'NBAND',0,1)
      CALL LINKEDLIST$GET(LL_STRC,'NBAND',1,NB)
!
      CALL LINKEDLIST$NLISTS(LL_STRC,'STATE',NTH)
!     ==  FIND NUMBER OF THE HIGHEST BAND  =============================
      DO ITH=1,NTH
        CALL LINKEDLIST$SELECT(LL_STRC,'STATE',ITH)
        CALL LINKEDLIST$EXISTD(LL_STRC,'B',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'B',1,IB)
          NB=MAX(NB,IB)
        END IF
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
!    
      CALL ATOMLIST$NATOM(NAT)
      SUMOFZ=0.D0
      DO IAT=1,NAT
        CALL ATOMLIST$GETR8('ZVALENCE',IAT,SVAR)
        SUMOFZ=SUMOFZ+SVAR
      ENDDO
      NB=MAX(NB,INT(0.5D0*SUMOFZ+0.99999D0))
!
!     ==================================================================
!     ==  INITIALIZE DYNOCC OBJECT                                    ==
!     ==================================================================
      CALL DYNOCC$CREATE(NB,NKPT,NSPIN)
      CALL DYNOCC$SETR8('SUMOFZ',SUMOFZ)
      CALL DYNOCC$SETR8('TOTCHA',QION)
      CALL DYNOCC$SETR8('SPIN',TOTSPIN)
      CALL DYNOCC$INIOCC      ! GUESS OCCUPATIONS FOR EACH STATE
!    
!     ==================================================================
!     ==  READ BLOCK !STRUCTURE!OCCUPATIONS                           ==
!     ==================================================================
      CALL LINKEDLIST$NLISTS(LL_STRC,'STATE',NTH)
      DO ITH=1,NTH
        CALL LINKEDLIST$SELECT(LL_STRC,'STATE',ITH)
        CALL LINKEDLIST$EXISTD(LL_STRC,'K',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'K',1,IKPT)
          IK1=IKPT
          IK2=IKPT
          IF(IKPT.GT.NKPT) THEN
            CALL ERROR$MSG('K-POINT DOES NOT EXIST')
            CALL ERROR$OVERFLOW('IKPT',IKPT,NKPT)
            CALL ERROR$STOP('STRCIN; !STRUCTURE!OCCUPATIONS!STATE')
          ENDIF
        ELSE
          IK1=1
          IK2=NKPT
        END IF
        CALL LINKEDLIST$EXISTD(LL_STRC,'S',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'S',1,ISPIN)
          IS1=ISPIN
          IS2=ISPIN
          IF(ISPIN.GT.NSPIN) THEN
            CALL ERROR$MSG('SPIN DOES NOT EXIST')
            CALL ERROR$OVERFLOW('ISPIN',ISPIN,NSPIN)
            CALL ERROR$STOP('STRCIN; !STRUCTURE!OCCUPATIONS!STATE')
          ENDIF
        ELSE
          IS1=1
          IS2=NSPIN
        END IF
!
        CALL LINKEDLIST$GET(LL_STRC,'B',1,IB)
        IF(IB.GT.NB)  THEN
          CALL ERROR$MSG('NUMBER OF BANDS LARGER THAN MAXIMUM')
          CALL ERROR$OVERFLOW('NB',IB,NB)
          CALL ERROR$STOP('STRCIN; !STRUCTURE!OCCUPATIONS!STATE')
        END IF
!
        CALL LINKEDLIST$GET(LL_STRC,'F',1,F0)
        SVAR=2.D0/DBLE(NSPIN)
        IF(F0.LT.0.D0.OR.F0.GT.SVAR) THEN
          WRITE(NFILO,FMT='(A,E10.3,A)') &
     &         'WARNING!',F0,' IS STRANGE NUMBER FOR AN OCCUPATION '
        END IF
!       PRINT*,'BEFORE MODOCC ',IS1,IS2,IK1,IK2,F0
        DO ISPIN=IS1,IS2
          DO IKPT=IK1,IK2
            CALL DYNOCC$MODOCC(IB,IKPT,ISPIN,F0)
          ENDDO
        ENDDO
!
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_ORBPOT(LL_STRC_)
!     ******************************************************************
!     **  DEFINE GROUPS IN GROUPLIST                                  **
!     **                                                              **
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      LOGICAL(4)               :: TCHK
      LOGICAL(4)               :: TON
      CHARACTER(32)            :: ATOM
      INTEGER(4)               :: NTH,ITH
      CHARACTER(32)            :: TYPE
      INTEGER(4)               :: ISPIN
      REAL(8)                  :: VALUE
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_ORBPOT')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$EXISTL(LL_STRC,'ORBPOT',1,TON)
      IF(.NOT.TON) THEN
        CALL TRACE$POP
        RETURN
      END IF

      CALL LINKEDLIST$SELECT(LL_STRC,'ORBPOT')
      CALL LINKEDLIST$NLISTS(LL_STRC,'POT',NTH)
      DO ITH=1,NTH
        CALL LINKEDLIST$SELECT(LL_STRC,'POT',ITH)
        CALL LINKEDLIST$GET(LL_STRC,'ATOM',1,ATOM)
        CALL LINKEDLIST$GET(LL_STRC,'TYPE',1,TYPE)
        CALL LINKEDLIST$GET(LL_STRC,'S',1,ISPIN)
        CALL LINKEDLIST$GET(LL_STRC,'VALUE',1,VALUE)
        CALL EXTERNAL1CPOT$SETPOT(ATOM,TYPE,ISPIN,VALUE)
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_GROUP(LL_STRC_)
!     ******************************************************************
!     **  DEFINE GROUPS IN GROUPLIST                                  **
!     **                                                              **
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      LOGICAL(4)               :: TCHK
      INTEGER(4)               :: NGRP
      INTEGER(4)               :: NAT
      INTEGER(4)               :: NATGR1
      INTEGER(4)               :: IAT,IGRP,iat1
      CHARACTER(32)            :: GROUP
      character(32),allocatable:: atoms(:)
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_GROUP')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$NLISTS(LL_STRC,'GROUP',NGRP)
      CALL ATOMLIST$NATOM(NAT)
      CALL GROUPLIST$INITIALIZE(NAT,NGRP+1)
!
!     ==  DEFAULT =========== ==========================================
      DO IAT=1,NAT
        CALL GROUPLIST$ADD('ALL',IAT)
      ENDDO
!
!     ==  READ ACTUAL VALUES  ==========================================
      DO IGRP=1,NGRP
        CALL LINKEDLIST$SELECT(LL_STRC,'GROUP',IGRP)
        CALL LINKEDLIST$EXISTD(LL_STRC,'NAME',0,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRC!GROUP:NAME NOT FOUND')
          CALL ERROR$STOP('STRCIN_GROUP')
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'NAME',1,GROUP)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'ATOMS',0,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRC!GROUP:ATOMS NOT FOUND')
          CALL ERROR$STOP('STRCIN_GROUP')
        END IF
        CALL LINKEDLIST$SIZE(LL_STRC,'ATOMS',1,NATGR1)
        ALLOCATE(ATOMS(NATGR1))
        CALL LINKEDLIST$GET(LL_STRC,'ATOMS',1,ATOMS(:))
        DO IAT=1,NATGR1        
          CALL ATOMLIST$INDEX(ATOMS(IAT),IAT1)
          CALL GROUPLIST$ADD(GROUP,IAT1)
        ENDDO
        DEALLOCATE(ATOMS)
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_LINEAR(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)               :: NUM,NUMJ
      INTEGER(4)               :: ITH,JTH
      INTEGER(4)               :: NAT
      INTEGER(4)               :: IAT
      CHARACTER(32)            :: CH32SVAR1
      REAL(8)     ,ALLOCATABLE :: VEC1(:,:) !(3,NAT)
!     ******************************************************************
                           CALL TRACE$PASS('STRCIN_CONSTRAINTS_LINEAR')
      LL_STRC=LL_STRC_
      CALL ATOMLIST$NATOM(NAT)
      ALLOCATE(VEC1(3,NAT))

      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'LINEAR',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'LINEAR',ITH)
        VEC1(:,:)=0.D0
        CALL LINKEDLIST$NLISTS(LL_STRC,'ATOM',NUMJ)
        IF(NUMJ.EQ.0) THEN
          CALL ERROR$MSG('BLOCK !ATOM IS MANDATORY')
          CALL ERROR$STOP('STRCIN; !STRUCTURE!CONSTRAINTS!LINEAR')
        END IF
!        
        DO JTH=1,NUMJ
          CALL LINKEDLIST$SELECT(LL_STRC,'ATOM',JTH)
          CALL LINKEDLIST$GET(LL_STRC,'NAME',1,CH32SVAR1)
          CALL ATOMLIST$INDEX(CH32SVAR1,IAT)
          CALL LINKEDLIST$GET(LL_STRC,'R',1,VEC1(:,IAT))
          CALL LINKEDLIST$SELECT(LL_STRC,'..')
        ENDDO
!
        CALL CONSTRAINTS$OPEN('GENERALLINEAR','LINEAR CONSTRAINT')
        CALL CONSTRAINTS$DEFINER8A('VEC',3*NAT,VEC1)
        CALL READMOVABLECONSTRAINT(LL_STRC)
        CALL CONSTRAINTS$CLOSE
!
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
      DEALLOCATE(VEC1)
                             CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_BOND(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)               :: NUM
      INTEGER(4)               :: ITH
      CHARACTER(32)            :: CH32SVAR1
      CHARACTER(32)            :: CH32SVAR2
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_BOND')
!
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'BOND',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'BOND',ITH)
        CALL LINKEDLIST$GET(LL_STRC,'ATOM1',1,CH32SVAR1)
        CALL LINKEDLIST$GET(LL_STRC,'ATOM2',1,CH32SVAR2)
        CALL CONSTRAINTS$OPEN('BONDLENGTH' &
     &                  ,'BOND '//CH32SVAR1(1:10)//'-'//CH32SVAR2(1:10))
        CALL CONSTRAINTS$DEFINECH('ATOM1',CH32SVAR1(1:32))
        CALL CONSTRAINTS$DEFINECH('ATOM2',CH32SVAR2(1:32))
        CALL READMOVABLECONSTRAINT(LL_STRC)
        CALL CONSTRAINTS$CLOSE
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_RIGID(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)            :: NUM
      INTEGER(4)            :: ITH
      CHARACTER(32)         :: CH32SVAR1
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_RIGID')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'RIGID',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'RIGID',ITH)
        CALL LINKEDLIST$GET(LL_STRC,'GROUP',1,CH32SVAR1)
!
!       == PERFORM ACTIONS==============================================
        CALL CONSTRAINTS$OPEN('RIGID' &
     &                       ,'GROUP '//CH32SVAR1//' IS KEPT RIGID')
        CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
        CALL CONSTRAINTS$CLOSE
      ENDDO 
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................     
      SUBROUTINE STRCIN_CONSTRAINTS_FREEZE(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)            :: NUM
      INTEGER(4)            :: ITH
      CHARACTER(32)         :: CH32SVAR1
      LOGICAL(4)            :: TCHK,TCHK1
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_FREEZE')
      LL_STRC=LL_STRC_
!
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')
      CALL LINKEDLIST$NLISTS(LL_STRC,'FREEZE',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'FREEZE',ITH)
        CALL LINKEDLIST$EXISTD(LL_STRC,'GROUP',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'GROUP',1,CH32SVAR1)
          CALL CONSTRAINTS$OPEN('FIXGROUP','FIX GROUP:'//CH32SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$CLOSE
        END IF
        CALL LINKEDLIST$EXISTD(LL_STRC,'ATOM',1,TCHK1)
        IF(TCHK1) THEN
          CALL LINKEDLIST$GET(LL_STRC,'ATOM',1,CH32SVAR1)
          CALL CONSTRAINTS$OPEN('FIXATOM','FIX ATOM:'//CH32SVAR1)
          CALL CONSTRAINTS$DEFINECH('ATOM',CH32SVAR1)
          CALL CONSTRAINTS$CLOSE
        END IF
        IF(TCHK.EQV.TCHK1) THEN
          CALL ERROR$MSG('EXACTLY ONE OF THE KEYWORDS ATOM= OR GROUP=')
          CALL ERROR$MSG('NEED TO BE SPECIFIED')
          IF(TCHK1) THEN
            CALL ERROR$CHVAL('SPECIFIED','ATOM')
          END IF
          IF(TCHK) THEN
            CALL ERROR$CHVAL('SPECIFIED','GROUP')
          END IF
          CALL ERROR$STOP('STRCIN!STRUCTURE!CONSTRAINTS!FREEZE')
        END IF
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP

      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_MIDPLANE(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)            :: NUM
      INTEGER(4)            :: ITH
      CHARACTER(32)    :: CH32SVAR1
      CHARACTER(32)    :: CH32SVAR2
      CHARACTER(32)    :: CH32SVAR3
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_MIDPLANE')
      LL_STRC=LL_STRC_
!
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'MIDPLANE',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'MIDPLANE',ITH)
        CALL LINKEDLIST$GET(LL_STRC,'ATOM1',1,CH32SVAR1)
        CALL LINKEDLIST$GET(LL_STRC,'ATOM2',1,CH32SVAR2)
        CALL LINKEDLIST$GET(LL_STRC,'ATOM3',1,CH32SVAR3)
        CALL CONSTRAINTS$OPEN('MIDPLANE' &
     &                    ,'MIDPLANE:'//CH32SVAR1(1:10)// &
     &                     ','//CH32SVAR2(1:10)//','//CH32SVAR3(1:10))
        CALL CONSTRAINTS$DEFINECH('ATOM1',CH32SVAR1)
        CALL CONSTRAINTS$DEFINECH('ATOM2',CH32SVAR2)
        CALL CONSTRAINTS$DEFINECH('ATOM3',CH32SVAR3)
        CALL READMOVABLECONSTRAINT(LL_STRC)
        CALL CONSTRAINTS$CLOSE
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END

!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_TRANSLATION(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)               :: NUM
      INTEGER(4)               :: ITH
      CHARACTER(32)            :: CH32SVAR1
      CHARACTER(32)            :: CH256SVAR1
      REAL(8)                  :: DIR(3) 
      LOGICAL(4)               :: TCHK
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_TRANSLATION')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'TRANSLATION',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'TRANSLATION',ITH)
        
        CALL LINKEDLIST$EXISTD(LL_STRC,'GROUP',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'GROUP',0,'ALL')
        CALL LINKEDLIST$GET(LL_STRC,'GROUP',1,CH32SVAR1)

        CALL LINKEDLIST$EXISTD(LL_STRC,'DIR',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'DIR',1,DIR)
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("CENTER OF GRAVITY OF GROUP ",A10 &
     &          ," ALONG:",3F6.2," IS FIXED")') CH32SVAR1,DIR(:)
          CALL CONSTRAINTS$OPEN('TRANSLATIONALMOMENTUM',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('DIR',3,DIR)
          CALL CONSTRAINTS$CLOSE
        ELSE
          DIR(1)=1.D0   
          DIR(2)=0.D0   
          DIR(3)=0.D0   
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("CENTER OF GRAVITY OF GROUP ",A10 &
     &            ," ALONG:",3F6.2," IS FIXED")') CH32SVAR1,DIR(:)
          CALL CONSTRAINTS$OPEN('TRANSLATIONALMOMENTUM',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('DIR',3,DIR)
          CALL CONSTRAINTS$CLOSE
          DIR(1)=0.D0   
          DIR(2)=1.D0   
          DIR(3)=0.D0   
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("CENTER OF GRAVITY OF GROUP ",A10 &
     &            ," ALONG:",3F6.2," IS FIXED")') CH32SVAR1,DIR(:)
          CALL CONSTRAINTS$OPEN('TRANSLATIONALMOMENTUM',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('DIR',3,DIR)
          CALL CONSTRAINTS$CLOSE
          DIR(1)=0.D0   
          DIR(2)=0.D0   
          DIR(3)=1.D0   
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("CENTER OF GRAVITY OF GROUP ",A10 &
     &         ," ALONG:",3F6.2," IS FIXED")') &
     &          CH32SVAR1,DIR(:)
          CALL CONSTRAINTS$OPEN('TRANSLATIONALMOMENTUM',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('DIR',3,DIR)
          CALL CONSTRAINTS$CLOSE
        END IF
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_ORIENTATION(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)               :: NUM
      INTEGER(4)               :: ITH
      CHARACTER(32)            :: CH32SVAR1
      CHARACTER(256)           :: CH256SVAR1
      REAL(8)                  :: AXIS(3) 
      LOGICAL                  :: TCHK
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_ORIENTATION')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'ORIENTATION',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'ORIENTATION',ITH)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'GROUP',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'GROUP',0,'ALL')
        CALL LINKEDLIST$GET(LL_STRC,'GROUP',1,CH32SVAR1)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'AXIS',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'AXIS',1,AXIS)
          CH256SVAR1=' '
            WRITE(CH256SVAR1,FMT='("ORIENTATION OF GROUP " &
     &           ,A10," ABOUT:" &
     &           ,3F6.2," IS FIXED")')CH32SVAR1,AXIS(:)
          CALL CONSTRAINTS$OPEN('ORIENTATION',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('PHI',3,AXIS)
          CALL CONSTRAINTS$CLOSE
        ELSE
          AXIS(1)=1.D0   
          AXIS(2)=0.D0   
          AXIS(3)=0.D0   
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("ORIENTATION OF GROUP " &
     &         ,A10," ABOUT:" &
     &         ,3F6.2," IS FIXED")')CH32SVAR1,AXIS(:)
          CALL CONSTRAINTS$OPEN('ORIENTATION',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('PHI',3,AXIS)
          CALL CONSTRAINTS$CLOSE
          AXIS(1)=0.D0   
          AXIS(2)=1.D0   
          AXIS(3)=0.D0   
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("ORIENTATION OF GROUP " &
     &         ,A10," ABOUT:" &
     &         ,3F6.2," IS FIXED")')CH32SVAR1,AXIS(:)
          CALL CONSTRAINTS$OPEN('ORIENTATION',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('PHI',3,AXIS)
          CALL CONSTRAINTS$CLOSE
          AXIS(1)=0.D0   
          AXIS(2)=0.D0   
          AXIS(3)=1.D0   
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("ORIENTATION OF GROUP " &
     &         ,A10," ABOUT:" &
     &         ,3F6.2," IS FIXED")')CH32SVAR1,AXIS(:)
          CALL CONSTRAINTS$OPEN('ORIENTATION',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('PHI',3,AXIS)
          CALL CONSTRAINTS$CLOSE
        END IF
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_ROTATION(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)               :: NUM
      INTEGER(4)               :: ITH
      CHARACTER(32)            :: CH32SVAR1
      CHARACTER(256)           :: CH256SVAR1
      REAL(8)                  :: AXIS(3) 
      LOGICAL                  :: TCHK
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_ROTATION')

      LL_STRC=LL_STRC_

      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'ROTATION',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'ROTATION',ITH)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'GROUP',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'GROUP',0,'ALL')
        CALL LINKEDLIST$GET(LL_STRC,'GROUP',1,CH32SVAR1)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'AXIS',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'AXIS',1,AXIS)
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("ROTATION OF GROUP ",A10 &
     &          ," ABOUT:",3F6.2," IS FIXED")') &
     &          CH32SVAR1,AXIS(:)
          CALL CONSTRAINTS$OPEN('ANGULARMOMENTUM',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('PHI',3,AXIS)
          CALL CONSTRAINTS$CLOSE
        ELSE
          AXIS(1)=1.D0   
          AXIS(2)=0.D0   
          AXIS(3)=0.D0   
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("ROTATION OF GROUP ",A10 &
     &          ," ABOUT:",3F6.2," IS FIXED")') &
     &          CH32SVAR1,AXIS(:)
          CALL CONSTRAINTS$OPEN('ANGULARMOMENTUM',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('PHI',3,AXIS)
          CALL CONSTRAINTS$CLOSE
          AXIS(1)=0.D0   
          AXIS(2)=1.D0   
          AXIS(3)=0.D0   
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("ROTATION OF GROUP ",A10 &
     &        ," ABOUT:",3F6.2," IS FIXED")') &
     &        CH32SVAR1,AXIS(:)
          CALL CONSTRAINTS$OPEN('ANGULARMOMENTUM',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('PHI',3,AXIS)
          CALL CONSTRAINTS$CLOSE
          AXIS(1)=0.D0   
          AXIS(2)=0.D0   
          AXIS(3)=1.D0   
          CH256SVAR1=' '
          WRITE(CH256SVAR1,FMT='("ROTATION OF GROUP ",A10 &
     &          ," ABOUT:",3F6.2," IS FIXED")') &
     &          CH32SVAR1,AXIS(:)
          CALL CONSTRAINTS$OPEN('ANGULARMOMENTUM',CH256SVAR1)
          CALL CONSTRAINTS$DEFINECH('GROUP',CH32SVAR1)
          CALL CONSTRAINTS$DEFINER8A('PHI',3,AXIS)
          CALL CONSTRAINTS$CLOSE
        END IF
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_COGSEP(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)               :: NUM
      INTEGER(4)               :: ITH
      CHARACTER(32)            :: NAME1,NAME2
      CHARACTER(256)           :: CH256SVAR1
      LOGICAL                  :: TCHK
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_ORIENTATION')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'COGSEP',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'COGSEP',ITH)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'GROUP1',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONSTRAINTS!COGSEP:GROUP1 NOT FOUND')
          CALL ERROR$STOP('STRCIN_CONSTRAINTS_COGSEP')
        ENDIF
        CALL LINKEDLIST$GET(LL_STRC,'GROUP1',1,NAME1)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'GROUP2',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONSTRAINTS!COGSEP:GROUP2 NOT FOUND')
          CALL ERROR$STOP('STRCIN_CONSTRAINTS_COGSEP')
        ENDIF
        CALL LINKEDLIST$GET(LL_STRC,'GROUP2',1,NAME2)
!
        CALL CONSTRAINTS$OPEN('COGSEP' &
     &                  ,'COGSEP '//NAME1(1:10)//'-'//NAME2(1:10))
        CALL CONSTRAINTS$DEFINECH('GROUP1',NAME1)
        CALL CONSTRAINTS$DEFINECH('GROUP2',NAME2)
        CALL READMOVABLECONSTRAINT(LL_STRC)
        CALL CONSTRAINTS$CLOSE
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_ANGLE(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)               :: NUM
      INTEGER(4)               :: ITH
      CHARACTER(32)            :: NAME1,NAME2,NAME3
      CHARACTER(256)           :: CH256SVAR1
      LOGICAL                  :: TCHK
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_ORIENTATION')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'ANGLE',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'ANGLE',ITH)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'ATOM1',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONSTRAINTS!ANGLE:ATOM1 NOT FOUND')
          CALL ERROR$STOP('STRCIN_CONSTRAINTS_ANGLE')
        ENDIF
        CALL LINKEDLIST$GET(LL_STRC,'ATOM1',1,NAME1)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'ATOM2',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONSTRAINTS!ANGLE:ATOM2 NOT FOUND')
          CALL ERROR$STOP('STRCIN_CONSTRAINTS_ANGLE')
        ENDIF
        CALL LINKEDLIST$GET(LL_STRC,'ATOM2',1,NAME2)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'ATOM3',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONSTRAINTS!ANGLE:ATOM3 NOT FOUND')
          CALL ERROR$STOP('STRCIN_CONSTRAINTS_ANGLE')
        ENDIF
        CALL LINKEDLIST$GET(LL_STRC,'ATOM3',1,NAME3)
!
        CALL CONSTRAINTS$OPEN('BONDANGLE' &
     &                  ,'ANGLE '//NAME1(1:10)//'-'//NAME2(1:10)//'-'//NAME3(1:10))
        CALL CONSTRAINTS$DEFINECH('ATOM1',NAME1)
        CALL CONSTRAINTS$DEFINECH('ATOM2',NAME2)
        CALL CONSTRAINTS$DEFINECH('ATOM3',NAME3)
        CALL READMOVABLECONSTRAINT(LL_STRC)
        CALL CONSTRAINTS$CLOSE
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_CONSTRAINTS_TORSION(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      INTEGER(4)               :: NUM
      INTEGER(4)               :: ITH
      CHARACTER(32)            :: NAME1,NAME2,NAME3,NAME4
      CHARACTER(256)           :: CH256SVAR1
      REAL(8)                  :: AXIS(3) 
      LOGICAL                  :: TCHK
!     ******************************************************************
                           CALL TRACE$PUSH('STRCIN_CONSTRAINTS_ORIENTATION')
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'CONSTRAINTS')

      CALL LINKEDLIST$NLISTS(LL_STRC,'TORSION',NUM)
      DO ITH=1,NUM
        CALL LINKEDLIST$SELECT(LL_STRC,'TORSION',ITH)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'ATOM1',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONSTRAINTS!TORSION:ATOM1 NOT FOUND')
          CALL ERROR$STOP('STRCIN_CONSTRAINTS_TORSION')
        ENDIF
        CALL LINKEDLIST$GET(LL_STRC,'ATOM1',1,NAME1)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'ATOM2',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONSTRAINTS!TORSION:ATOM2 NOT FOUND')
          CALL ERROR$STOP('STRCIN_CONSTRAINTS_TORSION')
        ENDIF
        CALL LINKEDLIST$GET(LL_STRC,'ATOM2',1,NAME2)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'ATOM3',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONSTRAINTS!TORSION:ATOM3 NOT FOUND')
          CALL ERROR$STOP('STRCIN_CONSTRAINTS_TORSION')
        ENDIF
        CALL LINKEDLIST$GET(LL_STRC,'ATOM3',1,NAME3)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'ATOM4',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONSTRAINTS!TORSION:ATOM4 NOT FOUND')
          CALL ERROR$STOP('STRCIN_CONSTRAINTS_TORSION')
        ENDIF
        CALL LINKEDLIST$GET(LL_STRC,'ATOM4',1,NAME4)
!
        CALL CONSTRAINTS$OPEN('TORSION' &
     &            ,'TORSION '//NAME1(1:10)//'-'//NAME2(1:10) &
     &                       //'-'//NAME3(1:10)//'-'//NAME4(1:10))
        CALL CONSTRAINTS$DEFINECH('ATOM1',NAME1)
        CALL CONSTRAINTS$DEFINECH('ATOM2',NAME2)
        CALL CONSTRAINTS$DEFINECH('ATOM3',NAME3)
        CALL CONSTRAINTS$DEFINECH('ATOM4',NAME4)
        CALL CONSTRAINTS$CLOSE
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!     ................................................................
      SUBROUTINE READMOVABLECONSTRAINT(LL_STRC_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      LOGICAL(4)               :: TCHK
      REAL(8)                  :: SVAR
      REAL(8)                  :: SMASS
      REAL(8)                  :: ANNES1
      REAL(8)                  :: pi
      INTEGER(4)               :: ISVAR
!     ******************************************************************
      PI=4.D0*DATAN(1.D0)
      LL_STRC=LL_STRC_
                       CALL TRACE$PUSH('READMOVABLECONSTRAINT')
!     
!     == DECIDE WHETHER PRINTOUT IS REQUESTED ========================
      CALL LINKEDLIST$EXISTD(LL_STRC,'SHOW',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'SHOW',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_STRC,'SHOW',1,TCHK)
      CALL CONSTRAINTS$DEFINEL4('SHOW',TCHK)
!        
!       == REQUEST WHETHER CONSTRAINT SHALL FLOAT ====================
      CALL LINKEDLIST$EXISTD(LL_STRC,'FLOAT',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'FLOAT',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_STRC,'FLOAT',1,TCHK)
      CALL CONSTRAINTS$DEFINEL4('FLOAT',TCHK)
      IF(TCHK) THEN
        CALL LINKEDLIST$EXISTD(LL_STRC,'M',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'M',0,1.D+4)
        CALL LINKEDLIST$GET(LL_STRC,'M',1,SMASS)
        CALL CONSTRAINTS$DEFINER8('SMASS',SMASS)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'FRIC',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'FRIC',0,0.D0)
        CALL LINKEDLIST$GET(LL_STRC,'FRIC',1,ANNES1)
        CALL CONSTRAINTS$DEFINER8('ANNES',ANNES1)
      END IF
!        
!       == REQUEST WHETHER CONSTRAINT BE MOVED  ======================
      CALL LINKEDLIST$EXISTD(LL_STRC,'MOVE',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'MOVE',0,.FALSE.)
      CALL LINKEDLIST$GET(LL_STRC,'MOVE',1,TCHK)
      CALL CONSTRAINTS$DEFINEL4('MOVE',TCHK)
!
      IF(TCHK) THEN 
        CALL LINKEDLIST$EXISTD(LL_STRC,'NSTEP',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_STRC,'NSTEP',0,100)
        CALL LINKEDLIST$GET(LL_STRC,'NSTEP',1,ISVAR)
        CALL CONSTRAINTS$DEFINEI4('NSTEP',ISVAR)
!
        CALL LINKEDLIST$EXISTD(LL_STRC,'VALUE[DEG]',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'VALUE[DEG]',1,SVAR)
          CALL CONSTRAINTS$DEFINER8('SFINAL',SVAR/180.D0*PI)
        ELSE
          CALL LINKEDLIST$EXISTD(LL_STRC,'VALUE',1,TCHK)
          IF(TCHK) THEN
            CALL LINKEDLIST$GET(LL_STRC,'VALUE',1,SVAR)
            CALL CONSTRAINTS$DEFINER8('SFINAL',SVAR)
          END IF
        ENDIF
        CALL LINKEDLIST$EXISTD(LL_STRC,'VELOC',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'VELOC',1,SVAR)
          CALL CONSTRAINTS$DEFINER8('VFINAL',SVAR)
        END IF
      END IF
                       CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE STRCIN_SOLVENT(LL_STRC_)
!     ******************************************************************    
!     **                                                              **    
!     ******************************************************************    
      USE LINKEDLIST_MODULE
      USE PERIODICTABLE_MODULE
      IMPLICIT NONE
      TYPE ATOM_TYPE
        CHARACTER(32)     :: NAME
        REAL(8)           :: R(3)
        REAL(8)           :: Q
        REAL(8)           :: M
        CHARACTER(5)      :: FFTYPE
        INTEGER(4)        :: QMSATOM   ! M-ATOM FOR Q ATOM
                                       ! S ATOM FOR M-ATOM
                                       ! Q ATOM FOR S ATOM
      END TYPE ATOM_TYPE
      TYPE LINK_TYPE
        INTEGER(4)        :: MJOINT
        INTEGER(4)        :: QJOINT
        INTEGER(4)        :: SJOINT
        INTEGER(4)        :: MATOM
        INTEGER(4)        :: QATOM
        INTEGER(4)        :: SATOM
      END TYPE LINK_TYPE
      TYPE BOND_TYPE
        INTEGER(4)        :: ATOM1
        INTEGER(4)        :: ATOM2
        REAL(8)           :: BO
      END TYPE BOND_TYPE
      TYPE(LL_TYPE),INTENT(IN)    :: LL_STRC_
      TYPE(LL_TYPE)               :: LL_STRC
      REAL(8)                     :: UNIT
      REAL(8)                     :: PROTONMASS
      INTEGER(4)                  :: NATQ,NATM,NATS
      INTEGER(4)                  :: NBONDM,NBONDS
      INTEGER(4)                  :: NLINK
      INTEGER(4)                  :: NMAP
      TYPE(ATOM_TYPE),ALLOCATABLE :: QATOM(:)
      TYPE(ATOM_TYPE),ALLOCATABLE :: MATOM(:)
      TYPE(ATOM_TYPE),ALLOCATABLE :: SATOM(:)
      TYPE(LINK_TYPE),ALLOCATABLE :: LINK(:)
      TYPE(BOND_TYPE),ALLOCATABLE :: MBOND(:)
      TYPE(BOND_TYPE),ALLOCATABLE :: SBOND(:)
      INTEGER(4)                  :: IATQ,IATM,IATS,IATM1,IATM2,IATS1,IATS2
      INTEGER(4)                  :: IBONDM,IBONDS,ILINK,I
      INTEGER(4)                  :: IZ
      LOGICAL(4)                  :: TRC    ! ATOM IS PART OF THE RECTION CENTER OR DUMMY ATOM
      LOGICAL(4)                  :: TCHK
      INTEGER(4)     ,ALLOCATABLE :: LINKARRAY(:,:)
      INTEGER(4)     ,ALLOCATABLE :: MAPARRAY(:,:)
      CHARACTER(32)               :: CH32SVAR1
!     ******************************************************************    
                          CALL TRACE$PUSH('STRCIN_SOLVENT')
      LL_STRC=LL_STRC_
      CALL CONSTANTS('U',PROTONMASS)
!    
!     ==================================================================
!     ==  READ UNIT FROM BLOCK !STRUCTURE!GENERIC                     ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'GENERIC')
      CALL LINKEDLIST$GET(LL_STRC,'LUNIT',1,UNIT)
!
!     ==================================================================
!     ==  READ BLOCK SOLVENT                                          ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$EXISTL(LL_STRC,'QM-MM',1,TCHK)
      IF(.NOT.TCHK) RETURN
      CALL LINKEDLIST$SELECT(LL_STRC,'QM-MM')
!     CALL LINKEDLIST$REPORT(LL_STRC,6)
!
!     ==================================================================
!     ==  READ #(ATOMS) AND  #(BONDS)                                 ==
!     ==================================================================
      CALL ATOMLIST$NATOM(NATQ)
      NATS=NATQ
      CALL LINKEDLIST$NLISTS(LL_STRC,'ATOM',NATM)
      CALL LINKEDLIST$NLISTS(LL_STRC,'LINK',NLINK)
      ALLOCATE(MATOM(NATM))
      ALLOCATE(SATOM(NATS))
      ALLOCATE(QATOM(NATQ))
!
!     ==================================================================
!     ==  COLLECT QM ATOMS                                            ==
!     ==================================================================
      DO IATQ=1,NATQ
        CALL ATOMLIST$GETCH('NAME',IATQ,QATOM(IATQ)%NAME)
        CALL ATOMLIST$GETR8A('R(0)',IATQ,3,QATOM(IATQ)%R)
        CALL ATOMLIST$GETR8('MASS',IATQ,QATOM(IATQ)%M)
        QATOM(IATQ)%FFTYPE=' '
        QATOM(IATQ)%Q=0.D0
        QATOM(IATQ)%QMSATOM=0
      ENDDO
!
!     ==================================================================
!     ==================================================================
!     ==  READ ATOMS                                                  ==
!     ==================================================================
!     ==================================================================
      IATS=0
      DO IATM=1,NATM
        CALL LINKEDLIST$SELECT(LL_STRC,'ATOM',IATM)
!
!       ==  ATOM NAME  =================================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'NAME',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('VARIABLE !QM-MM!ATOM:NAME NOT FOUND')
          CALL ERROR$STOP('STRCIN_SOLVENT') 
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'NAME',1,MATOM(IATM)%NAME)
!
!       ==  QMATOM  =====================================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'QMATOM',1,TCHK)
        IATQ=0
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'QMATOM',1,CH32SVAR1)
          DO I=1,NATQ
            IF(CH32SVAR1.EQ.QATOM(I)%NAME) THEN
              IATQ=I
              EXIT
            END IF
          ENDDO
          IF(IATQ.EQ.0) THEN
            CALL ERROR$MSG('QMATOM NOT FOUND')
            CALL ERROR$CHVAL('QMATOM',CH32SVAR1)
            CALL ERROR$CHVAL('MMATOM',MATOM(IATM)%NAME)
            CALL ERROR$STOP('STRCIN_SOLVENT')
          END IF
          IATS=IATS+1     ! INCREASE COUNTER FOR SHADOW ATOMS
          IF(IATS.GT.NATS) THEN
             CALL ERROR$MSG('#(SHADOW ATOMS) LARGER THAN EXPECTED')
             CALL ERROR$STOP('STRCIN_SOLVENT')
          END IF
          SATOM(IATS)%NAME=QATOM(IATQ)%NAME
          QATOM(IATQ)%QMSATOM=IATM
          MATOM(IATM)%QMSATOM=IATS
          SATOM(IATS)%QMSATOM=IATQ
        ELSE
          MATOM(IATM)%QMSATOM=0
        END IF
!
!       ==  FORCE FIELD ATOM TYPE========================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'FFTYPE',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('VARIABLE !QM-MM!ATOM:FFTYPE NOT FOUND')
          CALL ERROR$STOP('STRCIN_SOLVENT') 
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'FFTYPE',1,MATOM(IATM)%FFTYPE)
        IF(IATQ.NE.0) THEN
          SATOM(IATS)%FFTYPE=MATOM(IATM)%FFTYPE
        END IF
!
!       ==  POSITION====================================================
        IF(IATQ.EQ.0) THEN
          CALL LINKEDLIST$EXISTD(LL_STRC,'R',1,TCHK)
          IF(.NOT.TCHK) THEN
            CALL ERROR$MSG('KEYWORD QM-MM!ATOM:R NOT FOUND')
            CALL ERROR$STOP('STRCIN_SOLVENT') 
         END IF
         CALL LINKEDLIST$GET(LL_STRC,'R',1,MATOM(IATM)%R)
         MATOM(IATM)%R(:)=MATOM(IATM)%R(:)*UNIT
       ELSE
         MATOM(IATM)%R(:)=QATOM(IATQ)%R
         SATOM(IATS)%R(:)=QATOM(IATQ)%R
       END IF
!
!      ==  MASS ========================================================
       IF(IATQ.EQ.0) THEN 
          CALL LINKEDLIST$EXISTD(LL_STRC,'M',1,TCHK)
          IF(TCHK) THEN
            CALL LINKEDLIST$GET(LL_STRC,'M',1,MATOM(IATM)%M)
            MATOM(IATM)%M=MATOM(IATM)%M*PROTONMASS
          ELSE
            CH32SVAR1=MATOM(IATM)%FFTYPE(1:2)
            IF(CH32SVAR1(2:2).EQ.'_') CH32SVAR1(2:2)=' '
            CALL PERIODICTABLE$GET(CH32SVAR1,'Z',IZ)
            CALL PERIODICTABLE$GET(IZ,'MASS',MATOM(IATM)%M)
            MATOM(IATM)%M=MATOM(IATM)%M
          END IF
        ELSE
          MATOM(IATM)%M=QATOM(IATQ)%M
          SATOM(IATS)%M=QATOM(IATQ)%M
        END IF
!
!       ==  CHARGE ======================================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'Q',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'Q',1,MATOM(IATM)%Q)
          MATOM(IATM)%Q=-MATOM(IATM)%Q
        ELSE
          MATOM(IATM)%Q=0.D0
        END IF
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
!
!     ==================================================================
!     ==================================================================
!     ==  READ LINKS                                                  ==
!     ==================================================================
!     ==================================================================
      CALL LINKEDLIST$NLISTS(LL_STRC,'LINK',NLINK)
      ALLOCATE(LINK(NLINK))
      DO ILINK=1,NLINK
        CALL LINKEDLIST$SELECT(LL_STRC,'LINK',ILINK)
!
!       == JOINT ATOM ==================================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'MMJOINT',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('VARIABLE !QM-MM!LINK:MMJOINT NOT FOUND')
          CALL ERROR$STOP('STRCIN_SOLVENT') 
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'MMJOINT',1,CH32SVAR1)
        LINK(ILINK)%MJOINT=0
        DO IATM=1,NATM
          IF(CH32SVAR1.EQ.MATOM(IATM)%NAME) THEN
            LINK(ILINK)%MJOINT=IATM
            EXIT
          END IF
        ENDDO
        IF(LINK(ILINK)%MJOINT.EQ.0) THEN
          CALL ERROR$MSG('!QM-MM!LINK:MMJOINT IS NOT A MM ATOM')
          CALL ERROR$CHVAL('MMJOINT',CH32SVAR1)
          CALL ERROR$STOP('STRCIN_SOLVENT') 
        END IF
        LINK(ILINK)%SJOINT=MATOM(LINK(ILINK)%MJOINT)%QMSATOM
        LINK(ILINK)%QJOINT=SATOM(LINK(ILINK)%SJOINT)%QMSATOM
!
!       == MM ATOM =====================================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'MMATOM',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('VARIABLE !QM-MM!LINK:MMATOM NOT FOUND')
          CALL ERROR$STOP('STRCIN_SOLVENT') 
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'MMATOM',1,CH32SVAR1)
        LINK(ILINK)%MATOM=0
        DO IATM=1,NATM
          IF(CH32SVAR1.EQ.MATOM(IATM)%NAME) THEN
            LINK(ILINK)%MATOM=IATM
            EXIT
          END IF
        ENDDO
        IF(LINK(ILINK)%MATOM.EQ.0) THEN
          CALL ERROR$MSG('!QM-MM!LINK:MMATOM IS NOT A MM ATOM')
          CALL ERROR$CHVAL('MMATOM',CH32SVAR1)
          CALL ERROR$STOP('STRCIN_SOLVENT') 
        END IF
!          
!       == QM ATOM =====================================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'QMATOM',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('VARIABLE !QM-MM!LINK:QMATOM NOT FOUND')
          CALL ERROR$STOP('STRCIN_SOLVENT') 
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'QMATOM',1,CH32SVAR1)
        DO IATQ=1,NATQ
          IF(CH32SVAR1.EQ.QATOM(IATQ)%NAME) THEN
            LINK(ILINK)%QATOM=IATQ
            EXIT
          END IF
        ENDDO
        IF(LINK(ILINK)%QATOM.EQ.0) THEN
          CALL ERROR$MSG('!QM-MM!LINK:QMATOM IS NOT A QM ATOM')
          CALL ERROR$CHVAL('QMATOM',CH32SVAR1)
          CALL ERROR$STOP('STRCIN_SOLVENT') 
        END IF
!
!       == SHADOW ATOM =================================================
        IATS=IATS+1
        IF(IATS.GT.NATS) THEN
           CALL ERROR$MSG('#(SHADOW ATOMS) LARGER THAN EXPECTED')
           CALL ERROR$STOP('STRCIN_SOLVENT')
        END IF
        LINK(ILINK)%SATOM=IATS
!
!       == SHADOW ATOM FFTYPE ==========================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'SHFFTYPE',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('VARIABLE !QM-MM!LINK!SHFFTYPE NOT FOUND')
          CALL ERROR$STOP('STRCIN_SOLVENT') 
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'SHFFTYPE',1,SATOM(IATS)%FFTYPE)
!       
!       == SHADOW ATOM NAME,POSITION,MASS,CHARGE,QMSATOM================
        IATQ=LINK(ILINK)%QATOM
        SATOM(IATS)%NAME=QATOM(IATQ)%NAME
        SATOM(IATS)%R=QATOM(IATQ)%R
        SATOM(IATS)%M=QATOM(IATQ)%M
        SATOM(IATS)%Q=QATOM(IATQ)%Q
!
        IATS=LINK(ILINK)%SATOM
        IATQ=LINK(ILINK)%QATOM
        IATM=LINK(ILINK)%MATOM
        SATOM(IATS)%QMSATOM=IATQ
        QATOM(IATQ)%QMSATOM=IATM
        MATOM(IATM)%QMSATOM=IATS
!       
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
!
!     ==================================================================
!     ==================================================================
!     ==  READ BONDS                                                  ==
!     ==================================================================
!     ==================================================================
      CALL LINKEDLIST$NLISTS(LL_STRC,'BOND',NBONDM)
      ALLOCATE(MBOND(NBONDM))
      DO IBONDM=1,NBONDM
        CALL LINKEDLIST$SELECT(LL_STRC,'BOND',IBONDM)
!       == FIRST ATOM ==================================================
        MBOND(IBONDM)%ATOM1=0
        CALL LINKEDLIST$GET(LL_STRC,'ATOM1',1,CH32SVAR1)
        DO IATM=1,NATM
          IF(CH32SVAR1.EQ.MATOM(IATM)%NAME) THEN
            MBOND(IBONDM)%ATOM1=IATM
            EXIT
          END IF
        ENDDO
        IF(MBOND(IBONDM)%ATOM1.EQ.0) THEN
          CALL ERROR$MSG('FIRST ATOM IN BOND NOT IN THE M-ATOM LIST')
          CALL ERROR$CHVAL('ATOM1',CH32SVAR1)
          CALL ERROR$STOP('STRCIN_SOLVENT; !STRUCTURE!QM-MM!BOND')
        END IF         
!
!       == SECOND ATOM =================================================
        MBOND(IBONDM)%ATOM2=0
        CALL LINKEDLIST$GET(LL_STRC,'ATOM2',1,CH32SVAR1)
        DO IATM=1,NATM
          IF(CH32SVAR1.EQ.MATOM(IATM)%NAME) THEN
            MBOND(IBONDM)%ATOM2=IATM
            EXIT
          END IF
        ENDDO
        IF(MBOND(IBONDM)%ATOM2.EQ.0) THEN
          CALL ERROR$MSG('SECOND ATOM IN BOND NOT IN THE M-ATOM LIST')
          CALL ERROR$CHVAL('ATOM2',CH32SVAR1)
          CALL ERROR$STOP('STRCIN_SOLVENT; !STRUCTURE!QM-MM!BOND')
        END IF         
!
!       == BOND ORDER ==================================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'BO',1,TCHK)
        IF(TCHK) THEN
          CALL LINKEDLIST$GET(LL_STRC,'BO',1,MBOND(IBONDM)%BO)
        ELSE
          MBOND(IBONDM)%BO=1
        END IF
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
!
!     ==================================================================
!     ==  RESOLVE SHADOW BONDS                                        ==
!     ==================================================================
!     == COUNT #(SHADOW BONDS) =========================================
      NBONDS=0
      DO IBONDM=1,NBONDM
        IATM1=MBOND(IBONDM)%ATOM1
        IATM2=MBOND(IBONDM)%ATOM2
        IATS1=MATOM(IATM1)%QMSATOM
        IATS2=MATOM(IATM2)%QMSATOM
        IF(IATS1.NE.0.AND.IATS2.NE.0) NBONDS=NBONDS+1
      ENDDO
      ALLOCATE(SBOND(NBONDS))
!
!     == DETERMINE SHADOW BONDS ========================================
      IBONDS=0
      DO IBONDM=1,NBONDM
        IATM1=MBOND(IBONDM)%ATOM1
        IATM2=MBOND(IBONDM)%ATOM2
        IATS1=MATOM(IATM1)%QMSATOM
        IATS2=MATOM(IATM2)%QMSATOM
        IF(IATS1.NE.0.AND.IATS2.NE.0) THEN
          IBONDS=IBONDS+1   ! BOND LIES ENTIRELY IN THE REACTION CENTER
                            ! OR IS A LINK BOND
          SBOND(IBONDS)%ATOM1=IATS1
          SBOND(IBONDS)%ATOM2=IATS2
          SBOND(IBONDS)%BO=MBOND(IBONDM)%BO
        END IF
      ENDDO
!
!     ==================================================================
!     ==================================================================
!     ==  TRANSFER DATA TO MODULES                                    ==
!     ==================================================================
!     ==================================================================
!
!     ==================================================================
!     ==  SET LINKS                                                   ==
!     ==================================================================
      ALLOCATE(LINKARRAY(6,NLINK))
      ALLOCATE(MAPARRAY(3,NATS))
      DO ILINK=1,NLINK
        LINKARRAY(1,ILINK)=LINK(ILINK)%QJOINT
        LINKARRAY(2,ILINK)=LINK(ILINK)%MJOINT
        LINKARRAY(3,ILINK)=LINK(ILINK)%SJOINT
        LINKARRAY(4,ILINK)=LINK(ILINK)%QATOM
        LINKARRAY(5,ILINK)=LINK(ILINK)%MATOM
        LINKARRAY(6,ILINK)=LINK(ILINK)%SATOM
      ENDDO
      NMAP=0
      DO IATS=1,NATS
        NMAP=NMAP+1
        MAPARRAY(1,NMAP)=SATOM(IATS)%QMSATOM
        MAPARRAY(2,NMAP)=QATOM(MAPARRAY(1,NMAP))%QMSATOM
        MAPARRAY(3,NMAP)=IATS
      ENDDO
      CALL QMMM$SETI4A('MAP',3*NMAP,MAPARRAY)
      CALL QMMM$SETI4A('LINK',6*NLINK,LINKARRAY)
      DEALLOCATE(LINKARRAY)
      DEALLOCATE(MAPARRAY)
!
!     ==================================================================
!     ==  DEFINE CLASSICAL OBJECT                                     ==
!     ==================================================================
      CALL CLASSICAL$SELECT('QMMM')
      CALL STRCIN_SOLVENT_SETM(NATM,MATOM,NBONDM,MBOND)
      CALL CLASSICAL$SELECT('SHADOW')
      CALL STRCIN_SOLVENT_SETM(NATS,SATOM,NBONDS,SBOND)
!
!     ==================================================================
!     ==  DEALLOCATE AND RETURN                                       ==
!     ==================================================================
      DEALLOCATE(MATOM)
      DEALLOCATE(QATOM)
      DEALLOCATE(SATOM)
      DEALLOCATE(LINK)
      DEALLOCATE(MBOND)
      DEALLOCATE(SBOND)
                          CALL TRACE$POP
      RETURN
      CONTAINS
!       ................................................................
        SUBROUTINE STRCIN_SOLVENT_SETM(NAT,ATOM,NBOND,BOND)  
!       ****************************************************************    
!       **                                                            **    
!       ****************************************************************    
        IMPLICIT NONE
        INTEGER(4)     ,INTENT(IN) :: NAT
        INTEGER(4)     ,INTENT(IN) :: NBOND
        TYPE(ATOM_TYPE),INTENT(IN) :: ATOM(NAT)
        TYPE(BOND_TYPE),INTENT(IN) :: BOND(NBOND)
        INTEGER(4)                 :: IAT,IBOND
        REAL(8)                    :: R(3,NAT)
        REAL(8)                    :: MASS(NAT)
        REAL(8)                    :: CHARGE(NAT)
        CHARACTER(5)               :: FFTYPE(NAT)
        INTEGER(4)                 :: INDEX2(2,NBOND)
        REAL(8)                    :: BO(NBOND)
!       ****************************************************************    
!
!       ================================================================
!       ==  SEND ATOM AND BOND INFORMATION TO CLASSICAL OBJECT        ==
!       ================================================================
        DO IAT=1,NAT
          R(:,IAT)   =ATOM(IAT)%R(:)
          MASS(IAT)  =ATOM(IAT)%M
          CHARGE(IAT)=ATOM(IAT)%Q
          FFTYPE(IAT)=ATOM(IAT)%FFTYPE
        ENDDO
        CALL CLASSICAL$SETI4('NAT',NAT)
        CALL CLASSICAL$SETR8A('R(0)',3*NAT,R)
        CALL CLASSICAL$SETR8A('R(-)',3*NAT,R)
        CALL CLASSICAL$SETR8A('MASS',NAT,MASS)
        CALL CLASSICAL$SETR8A('QEL',NAT,CHARGE)
        CALL CLASSICAL$SETCHA('TYPE',NAT,FFTYPE)
!
!       ================================================================
!       ==  SEND BOND INFORMATION TO CLASSICAL OBJECT                 ==
!       ================================================================
        DO IBOND=1,NBOND
          INDEX2(1,IBOND)=BOND(IBOND)%ATOM1
          INDEX2(2,IBOND)=BOND(IBOND)%ATOM2
          BO(IBOND)=BOND(IBOND)%BO
        ENDDO
        CALL CLASSICAL$SETI4('NBOND',NBOND)
        CALL CLASSICAL$SETI4A('INDEX2',2*NBOND,INDEX2)
        CALL CLASSICAL$SETR8A('BONDORDER',NBOND,BO)
        CALL CLASSICAL$SETL4('LONGRANGE',.TRUE.)
        RETURN
        END SUBROUTINE STRCIN_SOLVENT_SETM
      END
!
!     ...................................................................
      SUBROUTINE STRCIN_CONTINUUM(LL_STRC_)
      USE LINKEDLIST_MODULE
      USE STRINGS_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(IN) :: LL_STRC_
      TYPE(LL_TYPE)            :: LL_STRC
      LOGICAL(4)               :: TCHK
      INTEGER(4)               :: NAT1
      INTEGER(4)               :: IAT1
      INTEGER(4)               :: IAT,NAT
      CHARACTER(32)            :: NAME
      REAL(8)       ,ALLOCATABLE:: RSOLV(:)
      CHARACTER(128),ALLOCATABLE:: GRIDTYPE(:)
!     ******************************************************************
      LL_STRC=LL_STRC_
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$EXISTL(LL_STRC,'CONTINUUM',1,TCHK)
      IF(.NOT.TCHK) RETURN
                                 CALL TRACE$PUSH('STRCIN_CONTINUUM')
      CALL ATOMLIST$NATOM(NAT)
      ALLOCATE(RSOLV(NAT))
      RSOLV(:)=0.D0
      ALLOCATE(GRIDTYPE(NAT))
      GRIDTYPE(:)=' '
!
      CALL LINKEDLIST$SELECT(LL_STRC,'CONTINUUM')
      CALL LINKEDLIST$NLISTS(LL_STRC,'ATOM',NAT1)
      DO IAT1=1,NAT1
        CALL LINKEDLIST$SELECT(LL_STRC,'ATOM',IAT1)
!
!       ==  NAME  ================================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'NAME',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL ERROR$MSG('!STRUCTURE!CONTINUUM!ATOM:NAME NOT SPECIFIED')
          CALL ERROR$STOP('STRCIN_CONTINUUM')
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'NAME',1,NAME)
        CALL ATOMLIST$INDEX(NAME,IAT)
!
!       ==  RAD  ================================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'RAD',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL LINKEDLIST$SET(LL_STRC,'RAD',1,3.D0)
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'RAD',1,RSOLV(IAT))
!
!       ==  GRID TYPE ===============================================
        CALL LINKEDLIST$EXISTD(LL_STRC,'GRIDTYPE',1,TCHK)
        IF(.NOT.TCHK) THEN
          CALL LINKEDLIST$SET(LL_STRC,'GRIDTYPE',1,-'NEW_TESS.1')
        END IF
        CALL LINKEDLIST$GET(LL_STRC,'GRIDTYPE',1,GRIDTYPE(IAT))
!
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
      CALL CONTINUUM$SETR8A('RAD',NAT,RSOLV)
      CALL CONTINUUM$SETCHA('TESS',NAT,GRIDTYPE)
      DEALLOCATE(GRIDTYPE)
      DEALLOCATE(RSOLV)
                                          CALL TRACE$POP
      RETURN
      END
!
!     .....................................................STRCOUT......
      SUBROUTINE STRCOUT
!     ******************************************************************
!     **                                                              **
!     **  UPDATES THE BUFFER STRC AND WRITES IT ON STRC_OUT           **
!     **                                                              **
!     ************P.E. BLOECHL, IBM RESEARCH LABORATORY ZURICH (1991)***
      USE IO_MODULE, ONLY : LL_STRC
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      INTEGER(4)               :: NFIL
      INTEGER(4)               :: NAT
      INTEGER(4)               :: NATMM
      REAL(8)                  :: R(3)
      REAL(8)                  :: Q
      REAL(8)   ,ALLOCATABLE   :: RMM(:,:)
      REAL(8)                  :: RUNIT
      INTEGER(4)               :: IAT           ! RUNNING VARIABLES
      INTEGER(4)               :: IAT1          ! AUXILARY VARIABLES
      CHARACTER(32)            :: NAME
      LOGICAL(4)               :: TCHK
      INTEGER(4)               :: NLINK,ILINK
!     ******************************************************************
                          CALL TRACE$PUSH('STRCOUT')
!    
!     ==================================================================
!     ==  UPDATE BUFFER STRC                                          ==
!     ==================================================================
!     __PULL OUT LENGTH UNIT OF THE STRUCTURE FILE______________________
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$SELECT(LL_STRC,'GENERIC')
      CALL LINKEDLIST$GET(LL_STRC,'LUNIT',1,RUNIT)
!
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$NLISTS(LL_STRC,'ATOM',NAT)
      DO IAT=1,NAT
        CALL LINKEDLIST$SELECT(LL_STRC,'ATOM',IAT)
        CALL LINKEDLIST$GET(LL_STRC,'NAME',1,NAME)
        CALL ATOMLIST$INDEX(NAME,IAT1)
        CALL ATOMLIST$GETR8A('R(0)',IAT1,3,R)
        CALL LINKEDLIST$SET(LL_STRC,'R',0,R/RUNIT)
        CALL ATOMLIST$GETR8('Q',IAT1,Q)
        CALL LINKEDLIST$SET(LL_STRC,'Q',0,-Q)
        CALL LINKEDLIST$SET(LL_STRC,'INDEX',0,IAT1)
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      ENDDO
!    
!     ==================================================================
!     ==  WRITE BUFFER STRC                                           ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$SELECT(LL_STRC,'STRUCTURE')
      CALL LINKEDLIST$EXISTL(LL_STRC,'QM-MM',1,TCHK)
      IF(TCHK) THEN
        CALL LINKEDLIST$SELECT(LL_STRC,'QM-MM')
!       == REPLACE MM ATOMIC POSITIONS AND CHARGES
        CALL CLASSICAL$SELECT('QMMM')
        CALL CLASSICAL$GETI4('NAT',NATMM)
        ALLOCATE(RMM(3,NATMM))
        CALL CLASSICAL$GETR8A('R(0)',3*NATMM,RMM)
        CALL LINKEDLIST$NLISTS(LL_STRC,'ATOM',NAT)
        IF(NAT.NE.NATMM) THEN
        END IF
        DO IAT=1,NAT
          CALL LINKEDLIST$SELECT(LL_STRC,'ATOM',IAT)
          CALL LINKEDLIST$EXISTD(LL_STRC,'R',1,TCHK)
          IF(TCHK) THEN
            CALL LINKEDLIST$SET(LL_STRC,'R',1,RMM(:,IAT)/RUNIT)
          END IF
          CALL LINKEDLIST$SELECT(LL_STRC,'..')
        ENDDO  
        DEALLOCATE(RMM)
!
!       == REPLACE SHADOW ATOMIC POSITION IN THE LINKS
        CALL CLASSICAL$SELECT('SHADOW')
        CALL CLASSICAL$GETI4('NAT',NATMM)
        ALLOCATE(RMM(3,NATMM))
        CALL CLASSICAL$GETR8A('R(0)',3*NATMM,RMM)
        CALL LINKEDLIST$NLISTS(LL_STRC,'LINK',NLINK)
        DO ILINK=1,NLINK
          CALL LINKEDLIST$SELECT(LL_STRC,'LINK',ILINK)
          CALL LINKEDLIST$SELECT(LL_STRC,'SHADOW')
          CALL LINKEDLIST$SET(LL_STRC,'R',0,RMM(:,NATMM-NLINK+ILINK)/RUNIT)
          CALL LINKEDLIST$SELECT(LL_STRC,'..')
          CALL LINKEDLIST$SELECT(LL_STRC,'..')
        ENDDO
        DEALLOCATE(RMM)
        CALL LINKEDLIST$SELECT(LL_STRC,'..')
      END IF
!    
!     ==================================================================
!     ==  WRITE BUFFER STRC                                           ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('STRC_OUT',NFIL)
      CALL LINKEDLIST$SELECT(LL_STRC,'~')
      CALL LINKEDLIST$WRITE(LL_STRC,NFIL)
      CALL FILEHANDLER$CLOSE('STRC_OUT')
!
      CALL TRACE$POP; RETURN
      END

