!
!.......................................................................
MODULE DYNOCC_MODULE
!***********************************************************************
!**                                                                   **
!**  NAME: DYNOCC                                                     **
!**                                                                   **
!**  PURPOSE: ORGANIZES THE OCCUPATIONS OF THE ONE-PARTICLE STATES    **
!**                                                                   **
!**  FUNCTIONS:                                                       **
!**    DYNOCC$CREATE                                                  **
!**    DYNOCC$SET                                                     **
!**    DYNOCC$GET                                                     **
!**    DYNOCC$STOP                                                    **
!**    DYNOCC$INIOCC                                                  **
!**    DYNOCC$MODOCC                                                  **
!**    DYNOCC$PROPAGATE                                               **
!**    DYNOCC$SWITCH                                                  **
!**    DYNOCC$REPORT                                                  **
!**                                                                   **
!**  REMARKS:                                                         **
!**    THE OCCUPATIONS F ARE DIRECTLY RELATED TO THE DYNAMICAL        **
!**    VARIABLES X BY F=3*X**2-2*X**3                                 **
!**                                                                   **
!************PETER E BLOECHL, IBM ZURICH RESEARCH LABORATORY (1996)*****
LOGICAL(4)  :: TINI=.FALSE.    ! INITIAL OCCUPATIONS SET/NOT
LOGICAL(4)  :: START=.TRUE.    ! DOES NOT READ FROM RESTART FILE 
INTEGER(4)  :: NB=0            ! #(BANDS)
INTEGER(4)  :: NKPT=0          ! #(K-POINTS)
INTEGER(4)  :: NSPIN=0         ! #(SPINS)
LOGICAL(4)  :: TDYN=.FALSE.    ! DYNAMICAL/STATIC OCCUPATION
LOGICAL(4)  :: RESET=.TRUE.    ! SETS OUTPUT MODE OF DYNOCC$REPORT
LOGICAL(4)  :: TSTOP=.FALSE.   ! SET VELOCITY TO ZERO
LOGICAL(4)  :: TFIXSPIN=.FALSE.! FIXED SPIN/ MAGNETIC FIELD 
LOGICAL(4)  :: TFIXTOT=.FALSE. ! FIXED CHARGE/CHEMICAL POTENTIAL
REAL(8)     :: FMAX=1.D0       ! MAX OCCUPATION OF A SINGLE STATE
REAL(8)     :: SUMOFZ=0.D0     ! SUM OF NUCLEAR CHARGES
REAL(8)     :: TOTCHA=0.D0     ! NUMBER OF ELECTRONS
REAL(8)     :: SPINCHA=0.D0    ! TOTAL SPIN [ELECTRON SPINS]
REAL(8)     :: MX=800.D0       ! MASS OF OCCUPATION DYNAMICS
REAL(8)     :: TOTPOT=0.D0     ! FERMI LEVEL
REAL(8)     :: SPINPOT=0.D0    ! MAGNETIC FIELD
REAL(8)     :: TEMP=0.D0       ! TEMPERATURE
REAL(8)     :: ANNEX=0.D0      ! FRICTION 
REAL(8)     :: DELTAT=0.D0     ! TIME STEP
REAL(8)   ,ALLOCATABLE :: XM(:,:,:)       ! DYNAMICAL VARIABLES FRO OCCUPATIONS
REAL(8)   ,ALLOCATABLE :: X0(:,:,:)
REAL(8)   ,ALLOCATABLE :: XP(:,:,:)
REAL(8)   ,ALLOCATABLE :: EPSILON(:,:,:)  ! DE/DF=<PSI|H|PSI>
!! REMARK MPSIDOT2 IS NOT PROPERLY TREATED, BECAUSE IT IS CALCULATED IN TWO STEPS
REAL(8)   ,ALLOCATABLE :: MPSIDOT2(:,:,:) ! M_PSI<PSIDOT||PSIDOT> 
!====== K-POINT RELATED
REAL(8)   ,ALLOCATABLE :: XK(:,:) !(3,NKPT)
REAL(8)   ,ALLOCATABLE :: WKPT(:) !(NKPT)
CONTAINS
!      .................................................................
       SUBROUTINE XOFOCC(OCC,X)
       IMPLICIT NONE
       REAL(8),INTENT(IN) :: OCC
       REAL(8),INTENT(OUT):: X
       REAL(8)            :: X1,X3,OCC1
!      *****************************************************************
       IF(OCC.LT.0.D0.OR.OCC.GT.FMAX) THEN
         CALL ERROR$MSG('OCCUPATION MUST BE BETWEEN ZERO AND FMAX')
         CALL ERROR$STOP('XOFOCC IN MODULE DYNOCC')
       END IF
       OCC1=OCC/FMAX
       CALL CUBPOLYNOMROOT(-OCC1,0.D0,3.D0,-2.D0,X1,X,X3)
       RETURN
       END SUBROUTINE XOFOCC
!      .................................................................
       SUBROUTINE OCCOFX(X,OCC)
       IMPLICIT NONE
       REAL(8),INTENT(IN) :: X
       REAL(8),INTENT(OUT):: OCC
!      *****************************************************************
       OCC=X*X*(3.D0-2.D0*X)*FMAX
       RETURN
       END SUBROUTINE OCCOFX
!      .................................................................
       SUBROUTINE CUBPOLYNOMROOT(A0_,A1_,A2_,A3_,X1,X2,X3)
!      **                                                             **
!      **  SEARCHES THE THREE ZEROS OF THE 3RD ORDER POLYNOMIAL       **
!      **          A0_+A1_*X+A2_*X**2+A3_*X**3                        **
!      **  IF ONLY ONE ZERO EXISTS, X1=X2=X3                          **
!      **                                                             **
!      **  SEE "NUMERICAL RECIPES"; CAMBRIDGE UNIVERSITY PRESS        **
!      **     SECTION 5.5 QUADRATIC AND CUBIC EQUATIONS, P 145        **
!      **                                                             **
!      *****************************************************************
       IMPLICIT NONE
       REAL(8)   ,INTENT(IN) :: A0_,A1_,A2_,A3_
       REAL(8)   ,INTENT(OUT):: X1,X2,X3
       REAL(8)               :: A0,A1,A2,A3
       REAL(8)               :: Q,R,Q3,Q3MR2,THETA,SVAR
       REAL(8)               :: PI
!      *****************************************************************
       PI=4.D0*DATAN(1.D0)
       A3=1.D0
       A2=A2_/A3_
       A1=A1_/A3_
       A0=A0_/A3_
       Q=(A2**2-3.D0*A1)/9.D0
       R=(2.D0*A2**3-9.D0*A2*A1+27.D0*A0)/54.D0
       Q3=Q**3
       Q3MR2=Q3-R**2
       IF(Q3MR2.GE.0) THEN
         THETA=ACOS(R/DSQRT(Q3))
         SVAR=-2.D0*DSQRT(Q)
         X1=SVAR*COS(THETA/3.D0)
         X2=SVAR*COS((THETA+2.D0*PI)/3.D0)
         X3=SVAR*COS((THETA+4.D0*PI)/3.D0)
         IF(X1.GT.X2) THEN
           SVAR=X1
           IF(X1.GT.X3) THEN
             X1=X3 ; X3=SVAR
           ELSE
             X1=X2 ; X2=SVAR
           END IF
         END IF
         IF(X2.GT.X3) THEN
           SVAR=X2 ; X2=X3 ; X3=SVAR
         END IF
       ELSE
         SVAR=(DSQRT(-Q3MR2)+DABS(R))**(1.0/3.0)
         X1=-SIGN(1.D0,R)*(SVAR+Q/SVAR)
         X2=X1
         X3=X1
       END IF
       SVAR=A2/3.D0
       X1=X1-SVAR
       X2=X2-SVAR
       X3=X3-SVAR
       RETURN
       END SUBROUTINE CUBPOLYNOMROOT
END MODULE DYNOCC_MODULE
!      .................................................................
       SUBROUTINE DYNOCC$CREATE(NB_,NKPT_,NSPIN_)
!      *****************************************************************
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       INTEGER(4),INTENT(IN) :: NB_
       INTEGER(4),INTENT(IN) :: NKPT_
       INTEGER(4),INTENT(IN) :: NSPIN_
!      *****************************************************************
       IF(.NOT.ALLOCATED(XK)) THEN
         CALL ERROR$MSG('K-POINTS DO NOT EXIST')
         CALL ERROR$STOP('DYNOCC$CREATE')
       END IF
       IF(.NOT.ALLOCATED(WKPT)) THEN
         CALL ERROR$MSG('K-POINT WEIGHTS DO NOT EXIST')
         CALL ERROR$STOP('DYNOCC$CREATE')
       END IF
       NB=NB_
       IF(NKPT.NE.NKPT_.AND.NKPT.NE.0) THEN
         CALL ERROR$MSG('NKPT MUST NOT BE CHANGED')
         CALL ERROR$STOP('DYNOCC$CREATE')
       END IF 
       NKPT=NKPT_
       NSPIN=NSPIN_
       ALLOCATE(XM(NB,NKPT,NSPIN))
       ALLOCATE(X0(NB,NKPT,NSPIN))
       ALLOCATE(XP(NB,NKPT,NSPIN))
       XM(:,:,:)=0.5D0
       X0(:,:,:)=0.5D0
       XP(:,:,:)=0.5D0
       RETURN
       END
!      .................................................................
       SUBROUTINE DYNOCC$SETL4(ID_,VAL_)
!      *****************************************************************
!      **  SET LOGICAL PARAMETERS                                     **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       CHARACTER(*),INTENT(IN) :: ID_
       LOGICAL(4)  ,INTENT(IN) :: VAL_
!      *****************************************************************
       IF(ID_.EQ.'DYN') THEN
         TDYN=VAL_
       ELSE IF(ID_.EQ.'FIXS') THEN
         TFIXSPIN=VAL_
       ELSE IF(ID_.EQ.'FIXQ') THEN
         TFIXTOT=VAL_
       ELSE IF(ID_.EQ.'STOP') THEN
         TSTOP=VAL_
       ELSE IF(ID_.EQ.'START') THEN
         START=VAL_
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID_',ID_)
         CALL ERROR$STOP('DYNOCC$SETL4')
       END IF
       RESET=.TRUE.
       RETURN
       END
!      .................................................................
       SUBROUTINE DYNOCC$SETI4A(ID_,LEN_,VAL_)
!      *****************************************************************
!      **  SET LOGICAL PARAMETERS                                     **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       CHARACTER(*),INTENT(IN) :: ID_
       INTEGER(4)  ,INTENT(IN) :: LEN_
       INTEGER(4)  ,INTENT(IN) :: VAL_(LEN_)
!      *****************************************************************
       IF(ID_.EQ.'+-+-+-+-') THEN
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID_',ID_)
         CALL ERROR$STOP('DYNOCC$SETI4A')
       END IF
       RESET=.TRUE.
       RETURN
       END
!      .................................................................
       SUBROUTINE DYNOCC$SETI4(ID_,VAL_)
!      *****************************************************************
!      **  SET LOGICAL PARAMETERS                                     **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       CHARACTER(*),INTENT(IN) :: ID_
       INTEGER(4)  ,INTENT(IN) :: VAL_
!      *****************************************************************
       IF(ID_.EQ.'NKPT') THEN
         IF(NKPT.NE.0) THEN
           CALL ERROR$MSG('NKPT IS ALREADY SET')
           CALL ERROR$STOP('DYNOCC$SETI4')
         END IF
         NKPT=VAL_
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID_',ID_)
         CALL ERROR$STOP('DYNOCC$SETI4')
       END IF
       RESET=.TRUE.
       RETURN
       END
!
!      .................................................................
       SUBROUTINE DYNOCC$SETR8A(ID_,LEN_,DATA_)
!      *****************************************************************
!      **  SET REAL(8) ARRAY                                          **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       CHARACTER(*),INTENT(IN) :: ID_
       INTEGER(4)  ,INTENT(IN) :: LEN_
       REAL(8)     ,INTENT(IN) :: DATA_(LEN_)
       REAL(8)                 :: SVAR
!      *****************************************************************
       IF(ID_.EQ.'XK') THEN
         IF(NKPT.EQ.0) THEN
           NKPT=LEN_/3
         END IF
         IF(LEN_.NE.3*NKPT) THEN
           CALL ERROR$MSG('SIZE INCONSISTENT')
           CALL ERROR$STOP('DYNOCC$SETR8A')
         END IF
         IF(.NOT.ALLOCATED(XK))ALLOCATE(XK(3,NKPT))
         XK(:,:)=RESHAPE(DATA_,(/3,NKPT/))
       ELSE IF(ID_.EQ.'WKPT') THEN
         IF(NKPT.EQ.0) THEN
           NKPT=LEN_
         END IF
         IF(LEN_.NE.NKPT) THEN
           CALL ERROR$MSG('SIZE INCONSISTENT')
           CALL ERROR$STOP('DYNOCC$SETR8A')
         END IF
         IF(.NOT.ALLOCATED(WKPT))ALLOCATE(WKPT(NKPT))
         WKPT(:)=DATA_(:)
       ELSE IF(ID_.EQ.'EPSILON') THEN
         IF(LEN_.NE.NB*NKPT*NSPIN) THEN
           CALL ERROR$MSG('DIMENSIONS INCONSISTENT')
           CALL ERROR$CHVAL('ID_',ID_)
           CALL ERROR$I4VAL('LEN_',LEN_)
           CALL ERROR$I4VAL('NB*NKPT*NSPIN',NB*NKPT*NSPIN)
           CALL ERROR$STOP('DYNOCC$SETR8A')
         END IF
         IF(.NOT.ALLOCATED(EPSILON))ALLOCATE(EPSILON(NB,NKPT,NSPIN))
         EPSILON=RESHAPE(DATA_,(/NB,NKPT,NSPIN/))
!PRINT*,'FROM DYNOCC$SETR8A'
!CALL CONSTANTS$GET('EV',SVAR)
!WRITE(*,FMT='("EPSILON",10F10.5)')EPSILON/SVAR
       ELSE IF(ID_.EQ.'M<PSIDOT|PSIDOT>') THEN
         IF(LEN_.NE.NB*NKPT*NSPIN) THEN
           CALL ERROR$MSG('DIMENSIONS INCONSISTENT')
           CALL ERROR$CHVAL('ID_',ID_)
           CALL ERROR$I4VAL('LEN_',LEN_)
           CALL ERROR$I4VAL('NB*NKPT*NSPIN',NB*NKPT*NSPIN)
           CALL ERROR$STOP('DYNOCC$SETR8A')
         END IF
         IF(.NOT.ALLOCATED(MPSIDOT2)) THEN
           ALLOCATE(MPSIDOT2(NB,NKPT,NSPIN))
           MPSIDOT2(:,:,:)=0.D0
           SVAR=1.0D0
         ELSE
           MPSIDOT2(:,:,:)=0.5D0*MPSIDOT2(:,:,:)
           SVAR=0.5D0
         END IF
         MPSIDOT2=MPSIDOT2+SVAR*RESHAPE(DATA_,(/NB,NKPT,NSPIN/))
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID_',ID_)
         CALL ERROR$STOP('DYNOCC$SETR8A')
       END IF
       RETURN
       END
!
!      .................................................................
       SUBROUTINE DYNOCC$SETR8(ID_,DATA_)
!      *****************************************************************
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE 
       CHARACTER(*),INTENT(IN) :: ID_
       REAL(8)     ,INTENT(IN) :: DATA_
       INTEGER(4)              :: IB,ISPIN,IKPT,IND
       REAL(8)                 :: SVAR
!      *****************************************************************
       IF(ID_.EQ.'SUMOFZ') THEN
         SUMOFZ=DATA_
         RESET=.TRUE.
       ELSE IF(ID_.EQ.'TOTCHA') THEN
         TOTCHA=DATA_+SUMOFZ
         RESET=.TRUE.
       ELSE IF(ID_.EQ.'SPIN') THEN
         SPINCHA=DATA_
         RESET=.TRUE.
         PRINT*,'DYNOCC$SETR8: SPIN HAS BEEN SET TO ',SPINCHA
       ELSE IF(ID_.EQ.'FMAX') THEN
         FMAX=DATA_
         RESET=.TRUE.
       ELSE IF(ID_.EQ.'EFERMI') THEN
         TOTPOT=DATA_
         RESET=.TRUE.
       ELSE IF(ID_.EQ.'MAGNETICFIELD') THEN
         SPINPOT=DATA_
         RESET=.TRUE.
       ELSE IF(ID_.EQ.'MASS') THEN
         MX=DATA_
         RESET=.TRUE.
       ELSE IF(ID_.EQ.'FRICTION') THEN
         ANNEX=DATA_
         RESET=.TRUE.
       ELSE IF(ID_.EQ.'TIMESTEP') THEN
         DELTAT=DATA_
       ELSE IF(ID_.EQ.'TEMP') THEN
         TEMP=DATA_
         RESET=.TRUE.
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID_',ID_)
         CALL ERROR$STOP('DYNOCC$SETR8')
       END IF
       RETURN
       END
!      .................................................................
       SUBROUTINE DYNOCC$GETL4(ID_,VAL_)
!      *****************************************************************
!      **  SET LOGICAL PARAMETERS                                     **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       CHARACTER(*),INTENT(IN) :: ID_
       LOGICAL(4)  ,INTENT(OUT):: VAL_
!      *****************************************************************
       IF(ID_.EQ.'DYN') THEN
         VAL_=TDYN
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID_',ID_)
         CALL ERROR$STOP('DYNOCC$GETL4')
       END IF
       RETURN
       END
!      .................................................................
       SUBROUTINE DYNOCC$GETI4(ID_,VAL_)
!      *****************************************************************
!      **  SET INTEGER PARAMETERS                                     **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       CHARACTER(*),INTENT(IN) :: ID_
       INTEGER(4)  ,INTENT(OUT):: VAL_
!      *****************************************************************
       IF(ID_.EQ.'NKPT') THEN
         VAL_=NKPT
       ELSE IF(ID_.EQ.'NSPIN') THEN
         VAL_=NSPIN
       ELSE IF(ID_.EQ.'NB') THEN
         VAL_=NB
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID_',ID_)
         CALL ERROR$STOP('DYNOCC$GETI4')
       END IF
       RETURN
       END
!      .................................................................
       SUBROUTINE DYNOCC$GETI4A(ID_,LEN_,VAL_)
!      *****************************************************************
!      **  SET INTEGER PARAMETERS                                     **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       CHARACTER(*),INTENT(IN) :: ID_
       INTEGER(4)  ,INTENT(IN)::  LEN_
       INTEGER(4)  ,INTENT(OUT):: VAL_(LEN_)
!      *****************************************************************
       IF(ID_.EQ.'') THEN
         val_(:)=0
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID_',ID_)
         CALL ERROR$STOP('DYNOCC$GETI4A')
       END IF
       RETURN
       END
!
!      .................................................................
       SUBROUTINE DYNOCC$GETR8(ID_,DATA_)
!      *****************************************************************
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       CHARACTER(*),INTENT(IN) :: ID_
       REAL(8)     ,INTENT(OUT):: DATA_
       REAL(8)                 :: SPEED,SVAR,SUM
       INTEGER(4)              :: IB,IKPT,ISPIN,IND
!      *****************************************************************
       IF(ID_.EQ.'SPIN') THEN
         DATA_=SPINCHA    
       ELSE IF(ID_.EQ.'TOTCHA') THEN
         DATA_=TOTCHA-SUMOFZ
       ELSE IF(ID_.EQ.'FMAX') THEN
         DATA_=FMAX
       ELSE IF(ID_.EQ.'EKIN') THEN
         SVAR=0.D0
         DO ISPIN=1,NSPIN
           DO IKPT=1,NKPT
             DO IB=1,NB
               SPEED=(XP(IB,IKPT,ISPIN)-XM(IB,IKPT,ISPIN))/(2.D0*DELTAT)
               SVAR=SVAR+SPEED**2*WKPT(IKPT)
             ENDDO
           ENDDO
         ENDDO
         DATA_=0.5D0*MX*SVAR*FMAX
         IF(.NOT.TDYN) DATA_=0.D0
       ELSE IF(ID_.EQ.'HEAT') THEN
         SUM=0.D0
         DO ISPIN=1,NSPIN
           DO IKPT=1,NKPT
             DO IB=1,NB
               SVAR=X0(IB,IKPT,ISPIN)
               SVAR=SVAR**2*(3.D0-2.D0*SVAR)
               SVAR=MAX(SVAR,1.D-6)
               SVAR=MIN(SVAR,1.D0-1.D-6)
               SVAR=SVAR*DLOG(SVAR)+(1.D0-SVAR)*DLOG(1.D0-SVAR)
               SUM=SUM+TEMP*SVAR*WKPT(IKPT)
             ENDDO
           ENDDO
         ENDDO
         DATA_=SUM*FMAX
       ELSE IF(ID_.EQ.'TEMP') THEN
         DATA_=TEMP
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID_',ID_)
         CALL ERROR$STOP('DYNOCC$GETR8')
       END IF
       RETURN
       END
!
!      .................................................................
       SUBROUTINE DYNOCC$GETR8A(ID,LEN,VAL)
!      *****************************************************************
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       CHARACTER(*),INTENT(IN) :: ID
       INTEGER(4)  ,INTENT(IN) :: LEN
       REAL(8)     ,INTENT(OUT):: VAL(LEN)
       REAL(8)                 :: SPEED,SVAR,SUM
       INTEGER(4)              :: IB,IKPT,ISPIN,IND,I
!      *****************************************************************
!
!      =================================================================
!      ==  K-POINT RELATIVE COORDINATES                               ==
!      =================================================================
       IF(ID.EQ.'XK') THEN
         IF(LEN.NE.3*NKPT) THEN
           CALL ERROR$MSG('SIZE INCONSISTENT')
           CALL ERROR$CHVAL('ID',ID)
           CALL ERROR$I4VAL('LEN',LEN)
           CALL ERROR$I4VAL('NKPT',NKPT)
           CALL ERROR$STOP('DYNOCC$GETR8A')
         END IF
         VAL=RESHAPE(XK,(/3*NKPT/))
!
!      =================================================================
!      ==  K-POINT GEOMETRIC INTEGRATION WEIGHTS                      ==
!      =================================================================
       ELSE IF(ID.EQ.'WKPT') THEN
         IF(LEN.NE.NKPT) THEN
           CALL ERROR$MSG('SIZE INCONSISTENT')
           CALL ERROR$CHVAL('ID',ID)
           CALL ERROR$I4VAL('LEN',LEN)
           CALL ERROR$I4VAL('NKPT',NKPT)
           CALL ERROR$STOP('DYNOCC$GETR8A')
         END IF
         VAL=WKPT
!
!      =================================================================
!      ==  OCCUPATIONS                                                ==
!      =================================================================
       ELSE IF(ID.EQ.'OCC') THEN
         IF(LEN.NE.NB*NKPT*NSPIN) THEN
           CALL ERROR$MSG('DIMENSIONS INCONSISTENT')
           CALL ERROR$CHVAL('ID',ID)
           CALL ERROR$I4VAL('LEN',LEN)
           CALL ERROR$I4VAL('NB*NKPT*NSPIN',NB*NKPT*NSPIN)
           CALL ERROR$STOP('DYNOCC$GETR8A')
         END IF
         IND=0
         DO ISPIN=1,NSPIN
           DO IKPT=1,NKPT
             DO IB=1,NB
               IND=IND+1
               SVAR=X0(IB,IKPT,ISPIN)
               SVAR=SVAR**2*(3.D0-2.D0*SVAR)
               VAL(IND)=SVAR*FMAX*WKPT(IKPT)
             ENDDO
           ENDDO
         ENDDO
       ELSE
         CALL ERROR$MSG('ID NOT RECOGNIZED')
         CALL ERROR$CHVAL('ID',ID)
         CALL ERROR$STOP('DYNOCC$GETR8A')
       END IF
       RETURN
       END
!
!     ..................................................................
      SUBROUTINE DYNOCC$WRITE(NFIL,NFILO,TCHK)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE DYNOCC_MODULE
      USE RESTART_INTERFACE
      IMPLICIT NONE
      INTEGER(4)       ,INTENT(IN) :: NFIL       ! RESTART-FILE UNIT
      INTEGER(4)       ,INTENT(IN) :: NFILO
      LOGICAL(4)      ,INTENT(OUT):: TCHK
      TYPE(SEPARATOR_TYPE),PARAMETER :: MYSEPARATOR &
          =SEPARATOR_TYPE(3,'OCCUPATIONS','NONE','AUG1996',' ')
      INTEGER(4)                   :: NTASKS,ITASK
!     ******************************************************************
                          CALL TRACE$PUSH('OCCUPATIONS$WRITE')
      CALL MPE$QUERY(NTASKS,ITASK)
      CALL WRITESEPARATOR(MYSEPARATOR,NFIL,NFILO,TCHK)
      IF(ITASK.EQ.1) THEN
        WRITE(NFIL)NB,NKPT,NSPIN
        WRITE(NFIL)X0(:,:,:)
        WRITE(NFIL)XM(:,:,:)
      END IF
                           CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE DYNOCC$READ(NFIL,NFILO,TCHK)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE DYNOCC_MODULE
      USE RESTART_INTERFACE
      USE MPE_MODULE
      IMPLICIT NONE
      INTEGER(4)         ,INTENT(IN) :: NFIL       ! RESTART-FILE UNIT
      INTEGER(4)         ,INTENT(IN) :: NFILO
      LOGICAL(4)         ,INTENT(OUT):: TCHK
      TYPE(SEPARATOR_TYPE),PARAMETER :: MYSEPARATOR &
          =SEPARATOR_TYPE(3,'OCCUPATIONS','NONE','AUG1996',' ')
      TYPE(SEPARATOR_TYPE)           :: SEPARATOR 
      REAL(8)            ,ALLOCATABLE:: TMP0(:,:,:)
      REAL(8)            ,ALLOCATABLE:: TMPM(:,:,:)
      INTEGER(4)                     :: NB1,NKPT1,NSPIN1
      INTEGER(4)                     :: NTASKS,ITASK
      INTEGER(4)                     :: ISPIN,IKPT,IB
      REAL(8)                        :: SVAR
!     ******************************************************************
                          CALL TRACE$PUSH('DYNOCC$READ')
      TCHK=.NOT.START
      SEPARATOR=MYSEPARATOR
      CALL READSEPARATOR(SEPARATOR,NFIL,NFILO,TCHK)
      IF(.NOT.TCHK) THEN
        CALL TRACE$POP ;RETURN
      END IF
!
!     ==================================================================
!     == READ DATA                                                    ==
!     ==================================================================
      X0(:,:,:)=0.D0
      XM(:,:,:)=0.D0
      CALL MPE$QUERY(NTASKS,ITASK)
      IF(ITASK.EQ.1) THEN
        IF(SEPARATOR%VERSION.NE.MYSEPARATOR%VERSION) THEN
          CALL ERROR$MSG('VERSION NOT RECOGNIZED')
          CALL ERROR$CHVAL('VERSION',SEPARATOR%VERSION)
          CALL ERROR$STOP('DYNOCC$READ')
        END IF
        READ(NFIL)NB1,NKPT1,NSPIN1
        ALLOCATE(TMP0(NB1,NKPT1,NSPIN1))
        ALLOCATE(TMPM(NB1,NKPT1,NSPIN1))
        READ(NFIL)TMP0(:,:,:)
        READ(NFIL)TMPM(:,:,:)
!
!       ==================================================================
!       == DISCARD SUPERFLOUS DATA AND MAP INTO ARRAY                   ==
!       ==================================================================
        NB1=MIN(NB1,NB)
        NKPT1=MIN(NKPT1,NKPT)
        NSPIN1=MIN(NSPIN1,NSPIN)
        X0(1:NB1,1:NKPT1,1:NSPIN1)=TMP0(1:NB1,1:NKPT1,1:NSPIN1)
        XM(1:NB1,1:NKPT1,1:NSPIN1)=TMPM(1:NB1,1:NKPT1,1:NSPIN1)
        DEALLOCATE(TMP0)
        DEALLOCATE(TMPM)
!
!       ==================================================================
!       == AUGMENT MISSING DATA                                         ==
!       ==================================================================
        DO IKPT=NKPT1+1,NKPT
          X0(:,IKPT,:)=X0(:,1,:)
          XM(:,IKPT,:)=XM(:,1,:)
        ENDDO
        IF(NSPIN1.EQ.1.AND.NSPIN.EQ.2) THEN
          X0(:,:,2)=X0(:,:,1)
          XM(:,:,2)=XM(:,:,1)
        END IF
      END IF
!
!     ====================================================================
!     ==  BROADCAST                                                     ==
!     ====================================================================
      CALL MPE$BROADCAST(1,X0)
      CALL MPE$BROADCAST(1,XM)
!
!     ====================================================================
!     ==  RESET THERMODYNAMIC VARIABLES                                 ==
!     ====================================================================
      IF(NSPIN.EQ.1) THEN
        SPINCHA=0.D0
      ELSE
        SPINCHA=0.D0
        DO IKPT=1,NKPT
          DO IB=1,NB
            CALL OCCOFX(X0(IB,IKPT,1),SVAR)
            SPINCHA=SPINCHA+SVAR
            CALL OCCOFX(X0(IB,IKPT,2),SVAR)
            SPINCHA=SPINCHA-SVAR*WKPT(IKPT)
          ENDDO
        ENDDO        
      END IF
      TOTCHA=0.D0
      DO ISPIN=1,NSPIN
        DO IKPT=1,NKPT
          DO IB=1,NB
            CALL OCCOFX(X0(IB,IKPT,ISPIN),SVAR)
            TOTCHA=TOTCHA+SVAR*WKPT(IKPT)
          ENDDO
        ENDDO        
      ENDDO
                           CALL TRACE$POP
      RETURN
      END
!
!      .................................................................
       SUBROUTINE DYNOCC$REPORT(NFIL)
!      *****************************************************************
!      **                                                             **
!      **  THE DATA OF THE DYNOCC OBJECT ARE DIVIDED IN STATIC        **
!      **  DYNAMIC DATA.                                              **
!      **  THE PARAMETER RESET IS CHANGED TO TRUE WHENEVER STATIC     **
!      **  DATA ARE CHANGED AND TO FALSE AFTER EACH REPORT.           **
!      **  STATIC DATA ARE THEREFORE REPORTED, WHENEVER ONE OF THEM   **
!      **  HAS BEEN MODIFIED.                                         **
!      **                                                             **
!      **  DYNAMIC DATA ARE ALWAYS REPORTED                           **
!      **                                                             **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       INTEGER(4),INTENT(IN) :: NFIL
       REAL(8)               :: SVAR
       REAL(8)               :: OCC(NB,NKPT,NSPIN)
       INTEGER(4)            :: ISPIN,IKPT
       REAL(8)               :: EV
       REAL(8)               :: KELVIN
!      *****************************************************************
       CALL CONSTANTS('EV',EV)
       CALL CONSTANTS('KB',KELVIN)
!      == 1EL<->0.5HBAR => HBAR=2 EL
       IF(.NOT.RESET.AND.TDYN) THEN
         CALL REPORT$TITLE(NFIL,'OCCUPATIONS')
         CALL REPORT$R8VAL(NFIL,'TEMPERATURE',TEMP/KELVIN,'K')
         CALL REPORT$R8VAL(NFIL,'CHEMICAL POTENTIAL',TOTPOT/EV,'EV')
         CALL REPORT$R8VAL(NFIL,'CHARGE',-(TOTCHA-SUMOFZ),'E')
!
         IF(NSPIN.EQ.2) THEN
           CALL REPORT$R8VAL(NFIL,'MAGNETIC FIELD',SPINPOT/(EV),'EV/(HBAR/2)')
           CALL REPORT$R8VAL(NFIL,'SPIN',SPINCHA/2.D0,'HBAR')
         END IF
         CALL DYNOCC$GETR8('HEAT',SVAR)
         CALL REPORT$R8VAL(NFIL,'HEAT',SVAR,'H')
         IF(ALLOCATED(EPSILON)) THEN
           CALL DYNOCC$GETR8A('OCC',NB*NKPT*NSPIN,OCC)
           DO ISPIN=1,NSPIN
             DO IKPT=1,NKPT
               WRITE(NFIL,*)'OCCUPATIONS AND ENERGIES[EV] FOR K-POINT:',IKPT &
      &                                           ,' AND SPIN:',ISPIN
               WRITE(NFIL,FMT='("EIG ",10F8.3)')EPSILON(:,IKPT,ISPIN)/EV
               WRITE(NFIL,FMT='("OCC ",10F8.3)')OCC(:,IKPT,ISPIN)
             ENDDO
           ENDDO
         END IF
       END IF
!
!      =================================================================
!      ==                                                             ==
!      =================================================================
       IF(RESET.AND.(.NOT.TDYN)) THEN
         CALL REPORT$TITLE(NFIL,'OCCUPATIONS')
         CALL REPORT$CHVAL(NFIL,'OCCUPATIONS ARE','FIXED')
         CALL REPORT$R8VAL(NFIL,'#(ELECTRONS)',TOTCHA,' ')
         CALL REPORT$R8VAL(NFIL,'CHARGE',-(TOTCHA-SUMOFZ),'E')
         IF(NSPIN.EQ.2) THEN
           CALL REPORT$R8VAL(NFIL,'SPIN',SPINCHA/2.D0,'HBAR')
         END IF
         CALL DYNOCC$GETR8A('OCC',NB*NKPT*NSPIN,OCC)
         DO ISPIN=1,NSPIN
           DO IKPT=1,NKPT
             WRITE(NFIL,*)'OCCUPATIONS FOR K-POINT:',IKPT &
      &                                           ,' AND SPIN:',ISPIN
             WRITE(NFIL,FMT='("OCC ",10F8.3)')OCC(:,IKPT,ISPIN)
           ENDDO
         ENDDO
       END IF
!
!      =================================================================
!      ==                                                             ==
!      =================================================================
       IF(RESET.AND.TDYN) THEN
         CALL REPORT$TITLE(NFIL,'OCCUPATIONS')
         CALL REPORT$STRING(NFIL,'DYNAMICAL OCCUPATIONS USING MERMIN FUNCTIONAL')
         CALL REPORT$R8VAL(NFIL,'TEMPERATURE',TEMP/KELVIN,'K')
         CALL REPORT$R8VAL(NFIL,'MASS OF X',MX,'A.U.')
         IF(ANNEX.NE.0.D0) THEN
           CALL REPORT$R8VAL(NFIL,'FRICTION',ANNEX,' ')
         END IF
         IF(TSTOP) THEN
           CALL REPORT$CHVAL(NFIL,'INITIAL VELOCITIES ARE SET TO ','ZERO')
         END IF
         IF(TFIXTOT) THEN
           CALL REPORT$R8VAL(NFIL,'FIXED CHARGE',-(TOTCHA-SUMOFZ),'E')
           CALL REPORT$R8VAL(NFIL,'#(ELECTRONS)',TOTCHA,' ')
           IF(ALLOCATED(EPSILON)) THEN
             CALL REPORT$R8VAL(NFIL,'CHEMICAL POTENTIAL',TOTPOT/EV,'EV')
           END IF
         ELSE
           CALL REPORT$R8VAL(NFIL,'SUM OF NUCLEAR CHARGES',SUMOFZ,'E')
           CALL REPORT$R8VAL(NFIL,'FIXED CHEMICAL POTENTIAL',TOTPOT/EV,'EV')
           IF(ALLOCATED(EPSILON)) THEN
             CALL REPORT$R8VAL(NFIL,'CHARGE',-(TOTCHA-SUMOFZ),'E')
           END IF
         END IF
!
         IF(NSPIN.EQ.2) THEN
           IF(TFIXSPIN) THEN
             CALL REPORT$R8VAL(NFIL,'FIXED SPIN',SPINCHA*0.5D0,'HBAR')
             IF(ALLOCATED(EPSILON)) THEN
               CALL REPORT$R8VAL(NFIL,'MAGNETIC FIELD',SPINPOT/EV,'EV/(HBAR/2)')
             END IF
           ELSE
             CALL REPORT$R8VAL(NFIL,'FIXED MAGNETIC FIELD',SPINPOT/EV,'EV/(HBAR/2)')
             IF(ALLOCATED(EPSILON)) THEN
               CALL REPORT$R8VAL(NFIL,'SPIN',SPINCHA/2.D0,'HBAR')
             END IF
           END IF
         END IF
         CALL DYNOCC$GETR8('HEAT',SVAR)
         CALL REPORT$R8VAL(NFIL,'HEAT',SVAR,'H')
         IF(ALLOCATED(EPSILON)) THEN
           CALL DYNOCC$GETR8A('OCC',NB*NKPT*NSPIN,OCC)
           DO ISPIN=1,NSPIN
             DO IKPT=1,NKPT
               WRITE(NFIL,*)'OCCUPATIONS AND ENERGIES[EV] FOR K-POINT:',IKPT &
      &                                           ,' AND SPIN:',ISPIN
               WRITE(NFIL,FMT='("OCC ",10F8.3)')OCC(:,IKPT,ISPIN)
               WRITE(NFIL,FMT='("EIG ",10F8.3)')EPSILON(:,IKPT,ISPIN)/EV
             ENDDO
           ENDDO
         END IF
       END IF
       IF((.NOT.RESET).AND.(.NOT.TDYN)) THEN
         IF(ALLOCATED(EPSILON)) THEN
!          CALL DYNOCC$GETR8A('EPSILON',NB*NKPT*NSPIN,EPSILON)
           DO ISPIN=1,NSPIN
             DO IKPT=1,NKPT
               WRITE(NFIL,*)'ENERGIES[EV] FOR K-POINT:',IKPT &
      &                                           ,' AND SPIN:',ISPIN
               WRITE(NFIL,FMT='("EIG ",10F8.3)')EPSILON(:,IKPT,ISPIN)/EV
             ENDDO
           ENDDO
         END IF
       END IF
       RESET=.FALSE.
       RETURN
       END
!
!      .................................................................
       SUBROUTINE DYNOCC$INIOCC
!      *****************************************************************
!      ** CHOOSE INITIAL CONDITIONS FOR THE OCCUPATIONS               **
!      ** EXECUTED ONLY IF TINI=FALSE                                 **
!      ** TINI IS SET TO TRUE BY INIOCC AND READ                      **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       REAL(8)                :: SVAR,X1,X2,X3
       INTEGER(4)             :: IB,IKPT,ISPIN
       REAL(8)                :: EMERMN
       REAL(8)                :: FILL,SIGMA
!      *****************************************************************
       IF(TINI.AND.(.NOT.START)) RETURN
                                  CALL TRACE$PUSH('DYNOCC$INIOCC')
       TINI=.TRUE.
       X0(:,:,:)=0.D0
!
!      =================================================================
!      ==  DETERMINE INITIAL OCCUPATIONS FROM ONE-ELECTRON ENERGIES   == 
!      =================================================================
       IF(ALLOCATED(EPSILON)) THEN
PRINT*,'INITIALIZE OCCUPATIONS USING EIGENVALUES'
         IF(TFIXTOT) THEN
           IF(TFIXSPIN.AND.NSPIN.EQ.2) THEN
             DO ISPIN=1,NSPIN
               SIGMA=DBLE(3-2*ISPIN)
               CALL MERMIN(NB,NKPT,1,NB,NKPT,1,TOTCHA+0.5D0*SIGMA*SPINCHA &
     &            ,TEMP,WKPT,EPSILON(:,:,ISPIN),X0(:,:,ISPIN),TOTPOT,EMERMN)
             ENDDO
             X0(:,:,:)=X0(:,:,:)*0.5D0
           ELSE IF(.NOT.TFIXSPIN.AND.NSPIN.EQ.2) THEN
             DO ISPIN=1,NSPIN
               SIGMA=DBLE(3-2*ISPIN)
               EPSILON(:,:,ISPIN)=EPSILON(:,:,ISPIN)+SPINPOT*SIGMA
               CALL MERMIN(NB,NKPT,1,NB,NKPT,1,TOTCHA+SIGMA*SPINCHA &
     &           ,TEMP,WKPT,EPSILON(:,:,ISPIN),X0(:,:,ISPIN),TOTPOT,EMERMN)
               EPSILON(:,:,ISPIN)=EPSILON(:,:,ISPIN)-SPINPOT*SIGMA
             ENDDO
             X0(:,:,:)=X0(:,:,:)*0.5D0
           ELSE
             CALL MERMIN(NB,NKPT,NSPIN,NB,NKPT,NSPIN &
     &              ,TOTCHA,TEMP,WKPT,EPSILON,X0,TOTPOT,EMERMN)
             X0(:,:,:)=X0(:,:,:)/FMAX
           END IF
         ELSE IF(.NOT.TFIXTOT) THEN
           IF(.NOT.TFIXSPIN) THEN
             DO ISPIN=1,NSPIN
               SIGMA=DBLE(3-2*ISPIN)
               SVAR=(EPSILON(IB,IKPT,ISPIN)-(TOTPOT+SIGMA*SPINPOT))/TEMP
               IF(DABS(SVAR).LT.55.D0) THEN
                 X0(IB,IKPT,ISPIN)=1.D0/(1.D0+DEXP(SVAR))
               ELSE
                 X0(IB,IKPT,ISPIN)=0.5D0*(1.D0+DSIGN(1.D0,SVAR))
               END IF
             ENDDO
             X0(:,:,:)=X0(:,:,:)*2.D0/DBLE(NSPIN)
           ELSE 
             CALL MERMIN(NB,NKPT,NSPIN,NB,NKPT,NSPIN &
     &            ,TOTCHA,TEMP,WKPT,EPSILON,X0,TOTPOT,EMERMN)
           END IF
         END IF
         DO ISPIN=1,NSPIN
           DO IKPT=1,NKPT
             DO IB=1,NB
               SVAR=X0(IB,IKPT,ISPIN)
               CALL XOFOCC(SVAR,X0(IB,IKPT,ISPIN))
             ENDDO
           ENDDO
         ENDDO
         XM(:,:,:)=X0(:,:,:)
!
!      =================================================================
!      ==  DETERMINE INITIAL OCCUPATIONS WITHOUT ONE-ELECTRON ENERGIES== 
!      =================================================================
       ELSE
PRINT*,'INITIALIZE OCCUPATIONS WITHOUT EIGENVALUES'
         DO ISPIN=1,NSPIN
           IF(NSPIN.EQ.1) THEN
             SIGMA=0.D0
             SPINCHA=0.D0
           ELSE
             SIGMA=DBLE(3-2*ISPIN)
           END IF
           PRINT*,'SPINCHA ',SPINCHA,' NSPIN ',NSPIN
!          == ESTIMATE #(BANDS) ========================================
           SVAR=(TOTCHA+SPINCHA*SIGMA)/(FMAX*DBLE(NSPIN))
           DO IB=1,NB
             IF(SVAR.GE.1) THEN
               X0(IB,:,ISPIN)=1.D0
               SVAR=SVAR-1.D0
             ELSE IF(SVAR.LE.0.D0) THEN
               X0(IB,:,ISPIN)=0.D0
             ELSE
               CALL CUBPOLYNOMROOT(-SVAR,0.D0,3.D0,-2.D0,X1,X2,X3)
               IF(ABS(X1-0.5D0).LT.MIN(ABS(X2-0.5D0),ABS(X3-0.5D0))) THEN
                 X0(IB,:,ISPIN)=X1
               ELSE IF(ABS(X2-0.5D0).LT.MIN(ABS(X3-0.5D0),ABS(X1-0.5D0))) THEN
                 X0(IB,:,ISPIN)=X2
               ELSE IF(ABS(X3-0.5D0).LT.MIN(ABS(X1-0.5D0),ABS(X2-0.5D0))) THEN
                 X0(IB,:,ISPIN)=X3
               END IF
               SVAR=0.D0
             END IF
           ENDDO
         ENDDO
         XM(:,:,:)=X0(:,:,:)
       END IF
!PRINT*,'FROM DYNOCC$INIOCC'
!CALL CONSTANTS$GET('EV',SVAR)
!WRITE(*,FMT='("EPSILON",10F10.5)')EPSILON/SVAR
                                   CALL TRACE$POP
       RETURN
       END
!      .................................................................
       SUBROUTINE DYNOCC$MODOCC(IB_,IKPT_,ISPIN_,OCC_)
!      *****************************************************************
!      **                                                             **
!      **  MODIFY INDIVIDUAL OCCUPATIONS                              **
!      **                                                             **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       INTEGER(4),INTENT(IN) :: IB_,IKPT_,ISPIN_
       REAL(8)   ,INTENT(IN) :: OCC_
       REAL(8)               :: SVAR
!      *****************************************************************
       IF(IB_.GT.NB.OR.IKPT_.GT.NKPT.OR.ISPIN_.GT.NSPIN) THEN
         CALL ERROR$MSG('DIMENSIONS EXCEEDED')
         CALL ERROR$I4VAL('IB_',IB_)
         CALL ERROR$I4VAL('IKPT_',IKPT_)
         CALL ERROR$I4VAL('ISPIN_',ISPIN_)
         CALL ERROR$I4VAL('NB',NB)
         CALL ERROR$I4VAL('NKPT',NKPT)
         CALL ERROR$I4VAL('NSPIN',NSPIN)
         CALL ERROR$STOP('DYNOCC$MODOCC')
       END IF
!
!      =================================================================
!      ==  ADJUST TOTCHA AND SPINCHA                                  ==
!      =================================================================
       CALL OCCOFX(X0(IB_,IKPT_,ISPIN_),SVAR)
       TOTCHA=TOTCHA+OCC_-SVAR
       IF(NSPIN.EQ.2) THEN
         SPINCHA=SPINCHA+(OCC_-SVAR)*DBLE(3-2*ISPIN_)
       END IF
!
!      =================================================================
!      ==  RESET OCCUPATIONS                                          ==
!      =================================================================
       CALL XOFOCC(OCC_,SVAR)
       X0(IB_,IKPT_,ISPIN_)=SVAR
       XM(IB_,IKPT_,ISPIN_)=SVAR
       RETURN 
       END
!      .................................................................
       SUBROUTINE DYNOCC$ORDER(IKPT,ISPIN)
!      *****************************************************************
!      **                                                             **
!      **  REORDERS BANDS IN THE DYNOCC OBJECT ACCORDING TO           **
!      **  A PREDEFINED SETTING OF THE SORT OBJECT                    **
!      **                                                             **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       INTEGER(4),INTENT(IN) :: IKPT
       INTEGER(4),INTENT(IN) :: ISPIN
!      *****************************************************************
       IF(IKPT.LT.1.OR.IKPT.GT.NKPT) THEN
         CALL ERROR$MSG('IKPT OUT OF RANGE')
         CALL ERROR$I4VAL('IKPT',IKPT)
         CALL ERROR$STOP('DYNOCC$ORDER')
       END IF
       IF(ISPIN.LT.1.OR.ISPIN.GT.NSPIN) THEN
         CALL ERROR$MSG('SPIN OUT OF RANGE')
         CALL ERROR$I4VAL('ISPIN',ISPIN)
         CALL ERROR$STOP('DYNOCC$ORDER')
       END IF
!      == REORDER INPUT ================================================
       IF(ALLOCATED(EPSILON)) THEN
         CALL SORT$ORDERR8(1,NB,EPSILON(:,IKPT,ISPIN))
       END IF
       IF(ALLOCATED(MPSIDOT2)) THEN
         CALL SORT$ORDERR8(1,NB,MPSIDOT2(:,IKPT,ISPIN))
       END IF
!      == OCCUPATIONS ARE ONLY REORDERED IF OCCUPATIONS ARE DYNAMICAL
       IF(TDYN) THEN
         CALL SORT$ORDERR8(1,NB,XM(:,IKPT,ISPIN))
         CALL SORT$ORDERR8(1,NB,X0(:,IKPT,ISPIN))
         CALL SORT$ORDERR8(1,NB,XP(:,IKPT,ISPIN))
       END IF
       RETURN
       END
!
!      .................................................................
       SUBROUTINE DYNOCC$PROPAGATE
!      *****************************************************************
!      **                                                             **
!      *****************************************************************
       USE DYNOCC_MODULE
       IMPLICIT NONE
       REAL(8)   ,PARAMETER :: TOL=1.D-10
       REAL(8)   ,PARAMETER :: DSMALL=1.D-6
       REAL(8)              :: FX(NB,NKPT,NSPIN)
       INTEGER(4)           :: ISPIN,IKPT,IB
       REAL(8)              :: SVAR,OCC,DOCCDX,FORCE
       REAL(8)              :: SVAR1,SVAR2,SVAR3
       REAL(8)              :: X1,X2,X3
       REAL(8)              :: XMAX
       REAL(8)              :: XMIN
       REAL(8)              :: SIGMA    ! SPIN DIRECTION, I.E.: (+/-)1.D0
       REAL(8)              :: DTOTPOT,DSPINPOT
       REAL(8)              :: S0,S1,S2,S3
       REAL(8)              :: Q0,Q1,Q2,Q3
       LOGICAL(4)           :: TMPSIDOT2
       INTEGER(4)           :: ISVAR
REAL(8)::EV
!      *****************************************************************
       IF(.NOT.TDYN) RETURN
                              CALL TRACE$PUSH('DYNOCC$PROPAGATE')
       IF(NSPIN.EQ.1) THEN
         TFIXSPIN=.FALSE.
         SPINPOT=0.D0
       END IF
       IF(.NOT.ALLOCATED(EPSILON)) THEN
         CALL ERROR$MSG('ONE-PARTICLE ENERGIES HAVE NOT BEEN SET')
         CALL ERROR$STOP('DYNOCC$PROPAGATE')
       END IF
       TMPSIDOT2=ALLOCATED(MPSIDOT2)
       

!      IF(TMPSIDOT2) PRINT*,'MPSIDOT2',MPSIDOT2
!      IF(TMPSIDOT2) PRINT*,'E+MPSIDOT2',EPSILON+MPSIDOT2
!
!      =================================================================
!      ==  AVOID ESCAPING OCCUPATIONS BY IMPOSING PERIODIC            ==
!      ==  BOUNDARY CONDISTIONS AT XMIN AND XMAX                      ==
!      ==  EVERY PASS THROUGH THE BOUNDARY X IS STOPPED               ==
!      =================================================================
       XMIN=0.5D0-DSQRT(0.75D0)
       XMAX=0.5D0+DSQRT(0.75D0)
       DO ISPIN=1,NSPIN
         DO IKPT=1,NKPT
           DO IB=1,NB
             SVAR=(X0(IB,IKPT,ISPIN)-XMIN)/(XMAX-XMIN)
             ISVAR=INT(SVAR+100.D0)-100
             SVAR=(XMAX-XMIN)*DBLE(ISVAR)
             XM(IB,IKPT,ISPIN)=X0(IB,IKPT,ISPIN)-SVAR
             X0(IB,IKPT,ISPIN)=X0(IB,IKPT,ISPIN)-SVAR
           ENDDO
         ENDDO
       ENDDO
!
!      =================================================================
!      ==  OFFSET OCCUPATIONS SLIGTLY AWAY FROM ZERO                  ==
!      =================================================================
       DO ISPIN=1,NSPIN
         DO IKPT=1,NKPT
           DO IB=1,NB
             IF(X0(IB,IKPT,ISPIN).EQ.0.D0)X0(IB,IKPT,ISPIN)=DSMALL
             IF(X0(IB,IKPT,ISPIN).EQ.1.D0)X0(IB,IKPT,ISPIN)=1.D0-DSMALL
           ENDDO
         ENDDO
       ENDDO
!
!      =================================================================
!      ==  SET VELOCITY OF OCCUPATIONS TO ZERO                        ==
!      =================================================================
       IF(TSTOP) THEN
         XM(:,:,:)=X0(:,:,:)
         TSTOP=.FALSE.
       END IF
!
!      =================================================================
!      ==  CALCULATE FORCE ON X                                       ==
!      =================================================================
       DO ISPIN=1,NSPIN 
         SIGMA=DBLE(3-2*ISPIN)   ! SPIN DIRECTION       
         DO IKPT=1,NKPT
           DO IB=1,NB
             SVAR=X0(IB,IKPT,ISPIN)
             OCC=SVAR**2*(3.D0-2.D0*SVAR)
             DOCCDX=6.D0*SVAR*(1.D0-SVAR)
!
!            == FORCE FROM BANDS AND CHEMICAL POTENTIAL ===============
             FORCE=-EPSILON(IB,IKPT,ISPIN)+TOTPOT+SIGMA*SPINPOT
             IF(TMPSIDOT2) FORCE=FORCE-MPSIDOT2(IB,IKPT,ISPIN)
             FX(IB,IKPT,ISPIN)=FORCE*DOCCDX 
!            == FORCE FROM BANDS AND CHEMICAL POTENTIAL ===============
             IF(OCC.GT.0.D0.AND.OCC.LT.1.D0) THEN
               FORCE=-TEMP*(LOG(OCC)-LOG(1.D0-OCC))*DOCCDX
               FX(IB,IKPT,ISPIN)=FX(IB,IKPT,ISPIN)+FORCE
             END IF
           ENDDO
         ENDDO
       ENDDO
!
!      =================================================================
!      ==  PROPAGATE X WITOUT CONSTRAINTS                             ==
!      =================================================================
       SVAR1=2.D0/(1.D0+ANNEX)
       SVAR2=1.D0-SVAR1
       SVAR3=(SVAR1/2.D0)*DELTAT**2/MX
       XP(:,:,:)=SVAR1*X0(:,:,:)+SVAR2*XM(:,:,:)+SVAR3*FX(:,:,:)
!CALL CONSTANTS$GET('EV',EV)
!WRITE(*,FMT='("XM ",10F10.5)')XM
!WRITE(*,FMT='("X0 ",10F10.5)')X0
!WRITE(*,FMT='("XP ",10F10.5)')XP
!WRITE(*,FMT='("EPSILON",10F10.5)')EPSILON/EV
!WRITE(*,FMT='("MPSIDOT2",10F10.5)')MPSIDOT2/EV
!
!      =================================================================
!      ==  CONSTRAINT FORCE                                           ==
!      ==  XP=XP+FX*(DTOTPOT+SIGMA*DSPINTOT)                          ==
!      =================================================================
       DO ISPIN=1,NSPIN
         DO IKPT=1,NKPT
           DO IB=1,NB
             SVAR=X0(IB,IKPT,ISPIN)
             FX(IB,IKPT,ISPIN)=6.D0*SVAR*(1.D0-SVAR)*SVAR3
           ENDDO
         ENDDO
       ENDDO
!
!      =================================================================
!      ==  APPLY CONSTRAINTS                                          ==
!      =================================================================
       Q0=0.D0 ; S0=0.D0
       Q1=0.D0 ; S1=0.D0
       Q2=0.D0 ; S2=0.D0
       Q3=0.D0 ; S3=0.D0
       DO ISPIN=1,NSPIN
         SIGMA=DBLE(3-2*ISPIN)
         DO IKPT=1,NKPT
           DO IB=1,NB
             FORCE=FX(IB,IKPT,ISPIN)
             SVAR=XP(IB,IKPT,ISPIN)
             SVAR1=SVAR**2*(3.D0-2.D0*SVAR)      *FMAX*WKPT(IKPT)
             Q0=Q0+SVAR1 ;  S0=S0+SVAR1*SIGMA
             SVAR1=6.D0*SVAR*(1.D0-SVAR)*FORCE   *FMAX*WKPT(IKPT)
             Q1=Q1+SVAR1 ;  S1=S1+SVAR1*SIGMA
             SVAR1=3.D0*(1.D0-2.D0*SVAR)*FORCE**2*FMAX*WKPT(IKPT)
             Q2=Q2+SVAR1 ;  S2=S2+SVAR1*SIGMA
             SVAR1=-2.D0*FORCE**3                *FMAX*WKPT(IKPT)
             Q3=Q3+SVAR1 ;  S3=S3+SVAR1*SIGMA
           ENDDO
         ENDDO
       ENDDO
       SVAR=1.D0
       Q0=Q0*SVAR-TOTCHA ; S0=S0*SVAR-SPINCHA
       Q1=Q1*SVAR        ; S1=S1*SVAR
       Q2=Q2*SVAR        ; S2=S2*SVAR
       Q3=Q3*SVAR        ; S3=S3*SVAR
!      PRINT*,'DYNOCC Q:',Q0,Q1,Q2,Q3
!      PRINT*,'DYNOCC S:',S0,S1,S2,S3
!
!      == FIND ZERO OF (SUM0+SUM1*X+SUM2*X**2+SUM3*X**3)-TOTCHA  =======
       IF(TFIXTOT.AND.TFIXSPIN) THEN
         CALL CUBPOLYNOMROOT(Q0+S0,Q1+S1,Q2+S2,Q3+S3,X1,X2,X3)
         IF(DABS(X1).LE.MIN(DABS(X2),DABS(X3))) THEN
           DTOTPOT=X1
         ELSE IF(DABS(X2).LE.MIN(DABS(X1),DABS(X3))) THEN
           DTOTPOT=X2
         ELSE IF(DABS(X3).LE.MIN(DABS(X1),DABS(X2))) THEN
           DTOTPOT=X3
         END IF
         IF(DABS(Q0+S0).LT.TOL)DTOTPOT=0.D0
         CALL CUBPOLYNOMROOT(Q0-S0,Q1-S1,Q2-S2,Q3-S3,X1,X2,X3)
         IF(DABS(X1).LE.MIN(DABS(X2),DABS(X3))) THEN
           DSPINPOT=X1
         ELSE IF(DABS(X2).LE.MIN(DABS(X1),DABS(X3))) THEN
           DSPINPOT=X2
         ELSE IF(DABS(X3).LE.MIN(DABS(X1),DABS(X2))) THEN
           DSPINPOT=X3
         END IF
         IF(DABS(Q0-S0).LT.TOL)DSPINPOT=0.D0
         SVAR=0.5D0*(DTOTPOT+DSPINPOT)
         DSPINPOT=0.5D0*(DTOTPOT-DSPINPOT)
         DTOTPOT=SVAR
       ELSE IF(TFIXTOT.AND.(.NOT.TFIXSPIN)) THEN
         CALL CUBPOLYNOMROOT(Q0,Q1,Q2,Q3,X1,X2,X3)
         IF(DABS(X1).LE.MIN(DABS(X2),DABS(X3))) THEN
           DTOTPOT=X1
         ELSE IF(DABS(X2).LE.MIN(DABS(X1),DABS(X3))) THEN
           DTOTPOT=X2
         ELSE IF(DABS(X3).LE.MIN(DABS(X1),DABS(X2))) THEN
           DTOTPOT=X3
         END IF
         IF(DABS(Q0).LT.TOL)DTOTPOT=0.D0
         DSPINPOT=0.D0
       ELSE IF((.NOT.TFIXTOT).AND.TFIXSPIN) THEN
         CALL CUBPOLYNOMROOT(S0,Q1,S2,Q3,X1,X2,X3)
         IF(DABS(X1).LE.MIN(DABS(X2),DABS(X3))) THEN
           DSPINPOT=X1
         ELSE IF(DABS(X2).LE.MIN(DABS(X1),DABS(X3))) THEN
           DSPINPOT=X2
         ELSE IF(DABS(X3).LE.MIN(DABS(X1),DABS(X2))) THEN
           DSPINPOT=X3
         END IF
         IF(DABS(S0).LT.TOL)DSPINPOT=0.D0
         DTOTPOT=0.D0
       ELSE IF((.NOT.TFIXTOT).AND.(.NOT. TFIXSPIN)) THEN
         DTOTPOT =0.D0
         DSPINPOT=0.D0
       END IF
!      PRINT*,'DYNOCC X1,X2,X3 ',X1,X2,X3
!       
       Q0=0.D0 ; S0=0.D0
       DO ISPIN=1,NSPIN
         SIGMA=DBLE(3-2*ISPIN)
         X1=DTOTPOT+SIGMA*DSPINPOT
         DO IKPT=1,NKPT
           DO IB=1,NB
             XP(IB,IKPT,ISPIN)=XP(IB,IKPT,ISPIN)+FX(IB,IKPT,ISPIN)*X1
             SVAR=XP(IB,IKPT,ISPIN)
             SVAR1=SVAR**2*(3.D0-2.D0*SVAR)
             Q0=Q0+SVAR1       *FMAX*WKPT(IKPT)
             S0=S0+SVAR1*SIGMA *FMAX*WKPT(IKPT)
           ENDDO
         ENDDO
       ENDDO
!
!      =================================================================
!      == ADJUST CHEMICAL POTENTIALS AND CHARGES                      ==
!      == AND TEST CHARGE AND SPIN CONSERVATION                       ==
!      =================================================================
       IF(TFIXTOT) THEN
         IF(DABS(Q0-TOTCHA).GT.1.D-6) THEN
           PRINT*,'WARNING! TOTAL CHARGE NOT CONSERVED',Q0
         END IF
         TOTPOT=TOTPOT+DTOTPOT
       ELSE
         TOTCHA=Q0
       END IF
       IF(TFIXSPIN) THEN
         IF(DABS(S0-SPINCHA).GT.1.D-6) THEN
           PRINT*,'WARNING! TOTAL SPIN NOT CONSERVED',S0
         END IF
         SPINPOT=SPINPOT+DSPINPOT
       ELSE
         SPINCHA=S0
       END IF
!PRINT*,'X0UP   ',X0(:,1,1)
!PRINT*,'X0DOWN ',X0(:,1,2)
PRINT*,'SPIN   ',SPINCHA,' SPINPOT ',SPINPOT
PRINT*,'CHARGE ',TOTCHA ,' EFERMI  ',TOTPOT
                              CALL TRACE$POP
       RETURN
       END
!     ..................................................................
      SUBROUTINE DYNOCC$SWITCH
!     ******************************************************************
!     ******************************************************************
      USE DYNOCC_MODULE
      IMPLICIT NONE
!     ******************************************************************
      IF(ALLOCATED(EPSILON)) DEALLOCATE(EPSILON)
      IF(ALLOCATED(MPSIDOT2)) DEALLOCATE(MPSIDOT2)
      IF(TDYN) THEN
        XM(:,:,:)=X0(:,:,:)
        X0(:,:,:)=XP(:,:,:)
        XP(:,:,:)=0.D0
      END IF
      RETURN
      END
!
!     .....................................................MERMIN.......
      SUBROUTINE MERMIN(NX,NKPTX,NSPINX,NBANDS,NKPT,NSPIN &
     &                 ,TOTCHA,TEMP,WKPT,EIG,F,CHMPOT,EMERMN)
!     ******************************************************************
!     **                                                              **
!     **  CALCULATES THE OCCUPATIONS OF THE ELECTRONIC LEVELS         **
!     **  ACCORDING TO THE FERMI DISTRIBUTION;                        **
!     **  AND CALCULATES THE ENERGY -T*S RELATED TO THE ENTROPY OF    **
!     **  THE ELECTRONS.                                              **
!     **                                                              **
!     **          P.E. BLOECHL, IBM RESEARCH LABORATORY ZURICH (1991) **
!     **                                                              **
!     ******************************************************************
      IMPLICIT NONE
      LOGICAL(4) ,PARAMETER  :: TPR=.TRUE.
      INTEGER(4) ,PARAMETER  :: ITERX=1000   ! MAX #(ITERATIONS)
      REAL(8)    ,PARAMETER  :: TOL=1.D-6    ! TOLERANCE IN #(ELECTRONS)
      INTEGER(4) ,INTENT(IN) :: NBANDS,NX    ! #(BANDS),MAX
      INTEGER(4) ,INTENT(IN) :: NKPT,NKPTX   ! #(K-POINTS),MAX
      INTEGER(4) ,INTENT(IN) :: NSPIN,NSPINX ! #(SPINS),MAX
      REAL(8)    ,INTENT(IN) :: TOTCHA       ! TOTAL CHARGE
      REAL(8)    ,INTENT(IN) :: TEMP         ! K_B*TEMPERATURE IN HARTREE
      REAL(8)    ,INTENT(IN) :: WKPT(NKPTX)         ! K-POINT WEIGHTS
      REAL(8)    ,INTENT(IN) :: EIG(NX,NKPTX,NSPINX) ! EIGENVALUES
      REAL(8)    ,INTENT(OUT):: F(NX,NKPTX,NSPINX)   ! OCCUPATIONS
      REAL(8)    ,INTENT(OUT):: CHMPOT               ! CHEMICAL POTENTIAL
      REAL(8)    ,INTENT(OUT):: EMERMN               ! HEAT OF THE ELECTRONS
      INTEGER(4)             :: IB,I,ISPIN,IKPT
      REAL(8)                :: X0,DX,Y0,XM,YM
      REAL(8)                :: SVAR
      REAL(8)                :: SUM
      INTEGER(4)             :: ITER       ! ITERATION COUNT
      REAL(8)                :: DQ         ! DEVIATION IN TOTAL CHARGE
      REAL(8)                :: EV         ! ELECTRON VOLT
      REAL(8)                :: DE
      REAL(8)                :: F1
      INTEGER(4)             :: IBI
      REAL(8)                :: FMAX
!     ******************************************************************
                           CALL TRACE$PUSH('MERMIN')
      FMAX=1.D0
!
!     ==================================================================
!     ==  ESTIMATE CHEMICAL POTENTIAL BY AVERAGING THE ONE-PARTICLE   ==
!     ==  ENERGIES OF THE HIGHEST OCCUPIED BAND                       ==
!     ==================================================================
      IB=INT(TOTCHA*0.5D0)
      IB=MAX(IB,1)
      I=0
      CHMPOT=0.D0
      DO ISPIN=1,NSPIN
        DO IKPT=1,NKPT
          I=I+1
          CHMPOT=CHMPOT+EIG(IB,IKPT,ISPIN)
        ENDDO
      ENDDO
      CHMPOT=CHMPOT/DBLE(I)
                           CALL TRACE$PASS('A')
!
!     ==================================================================
!     ==  FIND CHEMICAL POTENTIAL BY BISECTION                        ==
!     ==================================================================
      X0=CHMPOT
      DX=1.D-2
      CALL BISEC(1,IBI,X0,Y0,DX,XM,YM)
      CHMPOT=X0
      DO ITER=1,ITERX
        SUM=0.D0
        DO ISPIN=1,NSPIN
          DO IKPT=1,NKPT
            DO IB=1,NBANDS
              SVAR=(EIG(IB,IKPT,ISPIN)-CHMPOT)/TEMP
              IF(SVAR.GT.+50.D0)SVAR=+50.D0
              IF(SVAR.LT.-50.D0)SVAR=-50.D0
              F(IB,IKPT,ISPIN)=1.D0/(1.D0+DEXP(SVAR))
              SUM=SUM+F(IB,IKPT,ISPIN)*WKPT(IKPT)
            ENDDO
          ENDDO
        ENDDO
        DQ=SUM-TOTCHA
        IF(DABS(DQ).LT.TOL) GOTO 110
        X0=CHMPOT
        Y0=DQ
        CALL BISEC(0,IBI,X0,Y0,DX,XM,YM)
        CHMPOT=X0
      ENDDO
      CALL ERROR$MSG('OCCUPATIONS NOT CONVERGED')
      CALL ERROR$STOP('MERMIN')
 110  CONTINUE
                           CALL TRACE$PASS('B')
!
!     ==================================================================
!     ==  CALCULATE HEAT OF THE ELECTRONS                             ==
!     ==================================================================
      EMERMN=0.D0
      DO ISPIN=1,NSPIN
        DO IKPT=1,NKPT
          DO IB=1,NBANDS
            F1=F(IB,IKPT,ISPIN)/FMAX
            IF(F1.NE.0.D0.AND.1.D0-F1.NE.0.D0) THEN
              DE=+TEMP*(F1*DLOG(F1)+(1.D0-F1)*DLOG(1.D0-F1))
              EMERMN=EMERMN+DE*WKPT(IKPT)*FMAX
            END IF
          ENDDO
        ENDDO
      ENDDO
                           CALL TRACE$PASS('C')
!
!     ==================================================================
!     ==  PRINT FOR CHECK                                             ==
!     ==================================================================
      IF(TPR) THEN
        CALL CONSTANTS('EV',EV)
        WRITE(*,FMT='("#ELECTRONS( IN)=",F10.5 &
     &               ," CHEMICAL POTENTIAL=",F10.3 &
     &               /"# ELECTRONS(OUT)=",F10.5)')TOTCHA,CHMPOT/EV,TOTCHA+DQ
        DO ISPIN=1,NSPIN
          DO IKPT=1,NKPT
            WRITE(*,FMT='(5("(",F8.3,";",F4.2,")"))') &
     &         (EIG(IB,IKPT,ISPIN)/EV,F(IB,IKPT,ISPIN),IB=1,NBANDS)
          ENDDO
        ENDDO
      END IF
                         CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
MODULE OCCUPATION_MODULE
USE LINKEDLIST_MODULE 
LOGICAL(4)    :: TINI=.FALSE.
TYPE(LL_TYPE) :: LL_OCC
CONTAINS
   SUBROUTINE OCCUPATION_NEWLIST
   IF(TINI) RETURN
   CALL LINKEDLIST$NEW(LL_OCC)
   TINI=.TRUE.
   RETURN
   END SUBROUTINE OCCUPATION_NEWLIST
END MODULE OCCUPATION_MODULE
!
!     ..................................................................
      SUBROUTINE OCCUPATION$SET(STRING_,NBYTE_,VAL_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE OCCUPATION_MODULE
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: STRING_
      INTEGER(4)  ,INTENT(IN) :: NBYTE_
      REAL(8)     ,INTENT(IN) :: VAL_(NBYTE_)
!     ******************************************************************
      CALL TRACE$PUSH('OCCUPATION$SET')
      CALL OCCUPATION_NEWLIST
      CALL LINKEDLIST$SET(LL_OCC,STRING_,0,VAL_)
      CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE OCCUPATION$GET(STRING_,NBYTE_,VAL_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE OCCUPATION_MODULE
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: STRING_
      INTEGER(4)  ,INTENT(IN) :: NBYTE_
      REAL(8)     ,INTENT(OUT):: VAL_(NBYTE_)
      LOGICAL(4)              :: TCHK
!     ******************************************************************
      CALL TRACE$PUSH('OCCUPATION$GET')
      CALL OCCUPATION_NEWLIST
      CALL LINKEDLIST$EXISTD(LL_OCC,STRING_,1,TCHK)
      IF(.NOT.TCHK) THEN
        CALL ERROR$MSG('ITEM HAS NOT BEEN STORED')
        CALL ERROR$CHVAL('STRING',STRING_)
        CALL ERROR$STOP('OCCUPATION$GET')
      END IF
      CALL LINKEDLIST$GET(LL_OCC,STRING_,1,VAL_)
      CALL TRACE$POP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE OCCUPATION$REPORT(NFIL,STRING_)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE DYNOCC_MODULE, ONLY : NSPIN,NKPT,NB,XK
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: STRING_
      INTEGER(4)  ,INTENT(IN) :: NFIL
      INTEGER(4)              :: ISPIN,IKPT,IB,I,J
      REAL(8)                 :: EV
      REAL(8)                 :: DWORK(3)
      REAL(8)                 :: CELLVOL
      REAL(8)                 :: RBAS(3,3)
      REAL(8)                 :: GBAS(3,3)
      REAL(8)    ,ALLOCATABLE :: EIG(:,:,:)  !(NB,NKPT,NSPIN)
      REAL(8)    ,ALLOCATABLE :: OCC(:,:,:)  !(NB,NKPT,NSPIN)
!     ******************************************************************
      IF(STRING_.EQ.'OCC') THEN
        IF(.NOT.ALLOCATED(OCC)) ALLOCATE(OCC(NB,NKPT,NSPIN))
        CALL DYNOCC$GETR8A('OCC',NB*NKPT*NSPIN,OCC)
        WRITE(NFIL,FMT='(/"OCCUPATIONS" &
     &                 /"===========")')
        DO ISPIN=1,NSPIN
          DO IKPT=1,NKPT
            WRITE(NFIL,FMT='("OCCUPATIONS FOR K-POINT ",I2 &
     &                   ," AND SPIN ",I1)')IKPT,ISPIN
            WRITE(NFIL,FMT='(10F8.3)')(OCC(IB,IKPT,ISPIN),IB=1,NB)
          ENDDO
        ENDDO
        DEALLOCATE(OCC)
      ELSE IF(STRING_.EQ.'EIG') THEN
        WRITE(NFIL,FMT='(/"ONE-PARTICLE ENERGIES" &
     &                   /"=====================")')
        CALL CONSTANTS('EV',EV)
        ALLOCATE(EIG(NB,NKPT,NSPIN))
        CALL OCCUPATION$GET('EIG',NB*NKPT*NSPIN,EIG)
        DO ISPIN=1,NSPIN
          DO IKPT=1,NKPT
            WRITE(NFIL,FMT='("EIGENVALUES[EV] FOR K-POINT ",I2 &
     &                   ," AND SPIN ",I1)')IKPT,ISPIN
            WRITE(NFIL,FMT='(10F8.3)')(EIG(IB,IKPT,ISPIN)/EV,IB=1,NB)
          ENDDO
        ENDDO
        DEALLOCATE(EIG)
      ELSE IF(STRING_.EQ.'KPOINTS') THEN
        WRITE(NFIL,FMT='(/"K-POINTS" &
     &                   /"========")')
        CALL CELL$GETR8A('T(0)',9,RBAS)
        CALL GBASS(RBAS,GBAS,CELLVOL)
        DO IKPT=1,NKPT
          DO I=1,3
            DWORK(I)=0.D0
            DO J=1,3
              DWORK(I)=DWORK(I)+GBAS(I,J)*XK(J,IKPT)
            ENDDO
          ENDDO
          WRITE(NFIL,FMT='(" K",I1 &
     &             ," = (",F5.2,"*G1,",F5.2,"*G2,",F5.2,"*G3)" &
     &             ," = (",F7.5,",",F7.5,",",F7.5,");")') &
     &             IKPT,(XK(I,IKPT),I=1,3) &
     &             ,(DWORK(I),I=1,3)
        ENDDO
      ELSE 
        CALL ERROR$MSG('STRING_ NOT RECOGNIZED')
        CALL ERROR$CHVAL('STRING_',STRING_)
        CALL ERROR$STOP('OCCUPATION$REPORT')
      END IF
      RETURN
      END
      
