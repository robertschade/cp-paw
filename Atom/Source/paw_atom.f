!.......................................................................
MODULE GRID
REAL(8)                :: R1=1.056D-4
REAL(8)                :: DEX=0.05
INTEGER(4)             :: NR=250
REAL(8)   ,ALLOCATABLE :: RGRID(:)
REAL(8)                :: XEXP
REAL(8)                :: OUTERBOXRADIUS=25.D0
REAL(8)                :: INNERBOXRADIUS=5.D0
REAL(8)                :: AUGMENTATIONRADIUS=4.D0
CONTAINS
        SUBROUTINE CREATEGRID
          IMPLICIT NONE
          REAL(8)    :: RI
          REAL(8)    :: XEXP
          INTEGER(4) :: IR
          IF(.NOT.ALLOCATED(RGRID))ALLOCATE(RGRID(NR))
          XEXP=DEXP(DEX)
          RI=R1/XEXP
          DO IR=1,NR
            RI=RI*XEXP
            RGRID(IR)=RI
          ENDDO
        END SUBROUTINE CREATEGRID
END MODULE GRID
!
!     ..................................................................
MODULE AEATOM
USE GRID
REAL(8)               :: AEZ=0.D0
INTEGER(4)            :: NB=0           !NUMBER OF STATES
INTEGER(4)            :: NC=0           !NUMBER OF CORE STATES
REAL(8)   ,ALLOCATABLE:: AEPOT(:)       !(NR) POTENTIAL
REAL(8)   ,ALLOCATABLE:: AECORE(:)      !(NR) CORE DENSITY
REAL(8)   ,ALLOCATABLE:: EB(:)          !(NB) ONE-PARTICLE ENERGIES
REAL(8)   ,ALLOCATABLE:: FB(:)          !(NB) OCCUPATIONS
INTEGER(4),ALLOCATABLE:: LB(:)          !(NB) OCCUPATIONS
INTEGER(4),ALLOCATABLE:: NNB(:)         !(NB) OCCUPATIONS
REAL(8)   ,ALLOCATABLE:: AEPSI(:,:,:)   !(NR,3,NB) STATES
REAL(8)   ,ALLOCATABLE:: AEPSISMALL(:,:,:) !(NR,3,NB) STATES (SMALL COMPONENT)
REAL(8)               :: ECORE          ! CORE TOTAL ENERGY
CONTAINS
!       ................................................................
        SUBROUTINE CREATEAEATOM
        IF(NB.EQ.0) THEN
          CALL ERROR$MSG('CANNOT MAKE AEATOM')
          CALL ERROR$MSG('NB NOT SET')
          CALL ERROR$STOP('MKAEATOM')
        END IF
        IF(NR.EQ.0) THEN
          CALL ERROR$MSG('CANNOT MAKE AEATOM')
          CALL ERROR$MSG('NR NOT SET')
          CALL ERROR$STOP('MKAEATOM')
        END IF
        ALLOCATE(AEPOT(NR))
        ALLOCATE(AECORE(NR))
        ALLOCATE(EB(NB))
        ALLOCATE(FB(NB))
        ALLOCATE(LB(NB))
        ALLOCATE(NNB(NB))
        ALLOCATE(AEPSI(NR,3,NB))
        ALLOCATE(AEPSISMALL(NR,3,NB))
        RETURN
        END SUBROUTINE CREATEAEATOM
END MODULE AEATOM
!
!     ..................................................................
MODULE PROJECTION
USE GRID
INTEGER(4)             :: NWAVE=0        ! #(STATES) 
REAL(8)   ,ALLOCATABLE :: PSPOT(:)       ! (NR) POTENTIAL VTILDE
REAL(8)   ,ALLOCATABLE :: VHAT(:)        ! (NR) POTENTIAL VHAT
REAL(8)   ,ALLOCATABLE :: PSCORE(:)      ! (NR) CORE DENSITY
REAL(8)   ,ALLOCATABLE :: EWAVE(:)       ! (NWAVE) ENERGY
INTEGER(4),ALLOCATABLE :: LPHI(:)        ! ANGULAR MOMENTUM
REAL(8)   ,ALLOCATABLE :: AEPHI(:,:,:)   ! (NR,3,NWAVE)
REAL(8)   ,ALLOCATABLE :: PSPHI(:,:,:)   ! (NR,3,NWAVE)
REAL(8)   ,ALLOCATABLE :: PRO(:,:)       ! (NR,NWAVE)
REAL(8)   ,ALLOCATABLE :: DO(:,:)        ! (NWAVE,NWAVE)
REAL(8)   ,ALLOCATABLE :: DTKIN(:,:)     ! (NWAVE,NWAVE)
REAL(8)   ,ALLOCATABLE :: DATH(:,:)      ! (NWAVE,NWAVE)
REAL(8)                :: RCSMALL=0.3D0
CONTAINS
!       ................................................................
        SUBROUTINE CREATEPROJECTION
        IF(NWAVE.EQ.0) THEN
          CALL ERROR$MSG('CANNOT MAKE AEATOM')
          CALL ERROR$MSG('NWAVE NOT SET')
          CALL ERROR$STOP('MKAEATOM')
        END IF
        IF(NR.EQ.0) THEN
          CALL ERROR$MSG('CANNOT MAKE AEATOM')
          CALL ERROR$MSG('NR NOT SET')
          CALL ERROR$STOP('MKAEATOM')
        END IF
        ALLOCATE(PSPOT(NR))
        ALLOCATE(VHAT(NR))
        ALLOCATE(PSCORE(NR))
        ALLOCATE(LPHI(NWAVE))
        ALLOCATE(EWAVE(NWAVE))
        ALLOCATE(AEPHI(NR,3,NWAVE))
        ALLOCATE(PSPHI(NR,3,NWAVE))
        ALLOCATE(PRO(NR,NWAVE))
        ALLOCATE(DO(NWAVE,NWAVE))
        ALLOCATE(DTKIN(NWAVE,NWAVE))
        ALLOCATE(DATH(NWAVE,NWAVE))
        DO=0.D0
        DATH=0.D0
        DTKIN=0.D0
        RETURN
        END SUBROUTINE CREATEPROJECTION
!       .............................................................
        SUBROUTINE PROJECTION$LMAX(LMAX)
        IMPLICIT NONE
        INTEGER(4),INTENT(OUT):: LMAX
        LMAX=MAXVAL(LPHI)
        END SUBROUTINE PROJECTION$LMAX
!       .............................................................
        SUBROUTINE PROJECTION$NPRO(L,NPRO)
        IMPLICIT NONE
        INTEGER(4),INTENT(IN) :: L
        INTEGER(4),INTENT(OUT):: NPRO
        INTEGER(4)            :: I1
!       ****************************************************************
        NPRO=0
        DO I1=1,NWAVE
          IF(LPHI(I1).EQ.L) NPRO=NPRO+1
        ENDDO
        END SUBROUTINE PROJECTION$NPRO
!       ................................................................
        SUBROUTINE PROJECTION$POT(L,NPRO,PROL,AEPHIL,PSPHIL,DATHL,DTKINL,DOL)
        IMPLICIT NONE
        INTEGER(4),INTENT(IN) :: L
        INTEGER(4),INTENT(IN) :: NPRO
        REAL(8)   ,INTENT(OUT),OPTIONAL :: PROL(NR,NPRO)
        REAL(8)   ,INTENT(OUT),OPTIONAL :: AEPHIL(NR,3,NPRO)
        REAL(8)   ,INTENT(OUT),OPTIONAL :: PSPHIL(NR,3,NPRO)
        REAL(8)   ,INTENT(OUT),OPTIONAL :: DATHL(NPRO,NPRO)
        REAL(8)   ,INTENT(OUT),OPTIONAL :: DTKINL(NPRO,NPRO)
        REAL(8)   ,INTENT(OUT),OPTIONAL :: DOL(NPRO,NPRO)
        INTEGER(4)            :: I1,I2,J1,J2
        INTEGER(4)            :: INDEX(NPRO)
!       ****************************************************************
        I1=0
        DO J1=1,NWAVE
          IF(LPHI(J1).EQ.L) THEN
            I1=I1+1
            IF(I1.GT.NPRO) EXIT ! PICK ONLY A SUBSET OF PROJECTORS
            INDEX(I1)=J1
          END IF 
        ENDDO
        DO I1=1,NPRO
          J1=INDEX(I1)
          IF(PRESENT(PROL))   PROL(:,I1)=PRO(:,J1)
          IF(PRESENT(AEPHIL)) AEPHIL(:,:,I1)=AEPHI(:,:,J1)
          IF(PRESENT(PSPHIL)) PSPHIL(:,:,I1)=PSPHI(:,:,J1)
        ENDDO
        DO I1=1,NPRO
          J1=INDEX(I1)
          DO I2=1,NPRO
            J2=INDEX(I2)
            IF(PRESENT(DATHL))  DATHL(I1,I2)=DATH(J1,J2)
            IF(PRESENT(DTKINL)) DTKINL(I1,I2)=DTKIN(J1,J2)
            IF(PRESENT(DOL))    DOL(I1,I2)   =DO(J1,J2)
          END DO
        ENDDO
        END SUBROUTINE PROJECTION$POT
END MODULE PROJECTION
!
!     .................................................................
      PROGRAM MAIN
!     ******************************************************************
!     **                                                              **
!     **  SELF-CONSISTENT SCALAR-RELATIVISTIC ELECTRONIC STRUCTURE    **
!     **                  FOR ATOMS;                                  **
!     **         ATOMIC INPUT FOR THE CP-PAW METHOD                   **
!     **                                                              **
!     ******************************************************************
      USE STRINGS_MODULE
      USE LINKEDLIST_MODULE
      USE GRID
      IMPLICIT NONE
      CHARACTER(256)   :: ROOTNAME
      CHARACTER(256)   :: CNTLNAME
      TYPE(LL_TYPE)    :: LL_CNTL
      CHARACTER(2)     :: ELEMENT
      INTEGER(4)       :: NFIL
      INTEGER(4)       :: NFILO
      CHARACTER(16)    :: ID
      INTEGER(4)       :: I
!     ******************************************************************
                          CALL TRACE$PUSH('PAWATOMS')
!
!     ==================================================================
!     == DEFINE PROTOCOLL FILE                                        ==
!     ==================================================================
      CALL GETARG(1,CNTLNAME)
      I=INDEX(CNTLNAME,'.',BACK=.TRUE.)
      ROOTNAME=CNTLNAME(1:I-1)
      CALL FILEHANDLER$SETROOT(ROOTNAME)
      CALL FILEHANDLER$SETFILE('PROT',.FALSE.,TRIM(ROOTNAME)//-'.PROT')
      CALL FILEHANDLER$SETSPECIFICATION('PROT','STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION('PROT','POSITION','APPEND')
      CALL FILEHANDLER$SETSPECIFICATION('PROT','ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION('PROT','FORM','FORMATTED')
!
!     ==================================================================
!     == DEFINE INPUT FILE                                            ==
!     ==================================================================
      CALL FILEHANDLER$SETFILE('INPUT',.FALSE.,TRIM(ROOTNAME)//-'.ACNTL')
      CALL FILEHANDLER$SETSPECIFICATION('INPUT','STATUS','OLD')
      CALL FILEHANDLER$SETSPECIFICATION('INPUT','POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION('INPUT','ACTION','READ')
      CALL FILEHANDLER$SETSPECIFICATION('INPUT','FORM','FORMATTED')
!
!     ==================================================================
!     == DEFINE SETUP FILE (OLD STYLE)                                ==
!     ==================================================================
      CALL FILEHANDLER$SETFILE('SETUPO',.FALSE.,TRIM(ROOTNAME)//-'.OUT')
      CALL FILEHANDLER$SETSPECIFICATION('SETUPO','STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION('SETUPO','POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION('SETUPO','ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION('SETUPO','FORM','FORMATTED')
!
!     ==================================================================
!     == DEFINE SETUP FILE                                            ==
!     ==================================================================
      CALL FILEHANDLER$SETFILE('SETUP',.FALSE.,TRIM(ROOTNAME)//-'.STP')
      CALL FILEHANDLER$SETSPECIFICATION('SETUP','STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION('SETUP','POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION('SETUP','ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION('SETUP','FORM','FORMATTED')
!
!     ==================================================================
!     == DEFINE  GRAPHICS FILE FOR PROJECTOR FUNCTIONS                ==
!     ==================================================================
      ID=+'PRO_S'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PROJECTORS_S')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
      ID=+'PRO_P'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PROJECTORS_P')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
      ID=+'PRO_D'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PROJECTORS_D')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
      ID=+'PRO_F'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PROJECTORS_F')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==================================================================
!     == DEFINE  GRAPHICS FILE FOR LOCAL POTENTIALS                   ==
!     ==================================================================
      ID=+'POT'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.POTENTIALS')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==================================================================
!     == DEFINE  GRAPHICS FILE FOR LOCAL PARTIAL WAVES                ==
!     ==================================================================
      ID=+'PHI_S'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PARTIALWAVES_S')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
      ID=+'PHI_P'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PARTIALWAVES_P')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
      ID=+'PHI_D'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PARTIALWAVES_D')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
      ID=+'PHI_F'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PARTIALWAVES_F')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==================================================================
!     == DEFINE  GRAPHICS FILE FOR LOCAL PARTIAL WAVES                ==
!     ==================================================================
      ID=+'EPWCONV'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.EPWCONV')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==================================================================
!     == DEFINE  GRAPHICS FILE FOR SCATTERING PROPERTIES              ==
!     ==================================================================
      ID=+'PHASESHIFT_S'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PHASESHIFT_S')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
      ID=+'PHASESHIFT_P'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PHASESHIFT_P')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
      ID=+'PHASESHIFT_D'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PHASESHIFT_D')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
      ID=+'PHASESHIFT_F'
      CALL FILEHANDLER$SETFILE(ID,.FALSE.,TRIM(ROOTNAME)//-'.PHASESHIFT_F')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'STATUS','UNKNOWN')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'ACTION','WRITE')
      CALL FILEHANDLER$SETSPECIFICATION(ID,'FORM','FORMATTED')
!
!     ==================================================================
!     == READ INPUT FILE                                              ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('INPUT',NFIL)
      CALL LINKEDLIST$NEW(LL_CNTL)
      CALL LINKEDLIST$READ(LL_CNTL,NFIL)
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
!
!     ==================================================================
!     == GET INPUT BUFFER                                             ==
!     ==================================================================
      CALL RESOLVEPAWATOMSINBUFFER(LL_CNTL,ELEMENT)
      CALL TRACE$PASS('AFTER RESOLVEPAWATOMSINBUFFER')
!
!     ==================================================================
!     == WRITE HEADER                                                 ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("=")/72("="),T20 &
     &         ," PROGRAM FOR PAW ATOMIC SETUPS "/72("="))')
      WRITE(NFILO,*)
      CALL REPORT$CHVAL(NFILO,'ELEMENT',ELEMENT)
      WRITE(NFILO,*)
      CALL DFT$REPORT(NFILO)
      WRITE(NFILO,*)
!
!     ==================================================================
!     == CALCULATE ALL-ELECTRON ATOM                                  ==
!     ==================================================================
      CALL ALLELECTRONATOM(LL_CNTL,ELEMENT)
      CALL TRACE$PASS('AFTER ALLELECTRONATOM')
!
!     ==================================================================
!     ==  CALCULATE LOCAL PSEUDO POTENTIAL                            ==
!     ==================================================================
      CALL VTILDE(LL_CNTL)
      CALL TRACE$PASS('AFTER VTILDE')
!
!     ==================================================================
!     ==  CALCULATE PSEUDO CORE                                       ==
!     ==================================================================
      CALL PSEUDIZECORE(LL_CNTL)
      CALL TRACE$PASS('AFTER PSEUDIZECORE')
!
!     ==================================================================
!     ==  CALCULATE AE-PARTIAL WAVES                                  ==
!     ==================================================================
      CALL PARTIALWAVES(LL_CNTL)
      CALL TRACE$PASS('AFTER PARTIALWAVES')
!
!     ==================================================================
!     ==  CALCULATE PROJECTOR FUNCTIONS                               ==
!     ==================================================================
      CALL PROJECTORS
      CALL TRACE$PASS('AFTER PROJECTORS')
!
!     ==================================================================
!     ==  CALCULATE MAKEVHAT                                          ==
!     ==================================================================
      CALL MAKEVHAT
      CALL TRACE$PASS('AFTER MAKEVHAT')
!
!     ==================================================================
!     ==  WRITE OUTPUT FILE                                           ==
!     ==================================================================
      CALL WRITEOUT
      CALL TRACE$PASS('SETUP FILE WRITTEN (OLD STYLE)')
      CALL WRITESTP(LL_CNTL)
      CALL TRACE$PASS('SETUP FILE WRITTEN (NEW STYLE)')
!
!     ==================================================================
!     ==  WRITE GRAPHICS FILES                                        ==
!     ==================================================================
      CALL WRITEPOTENTIALS
      CALL WRITEGRAPHICS
      CALL TRACE$PASS('GRAPHICS FILES WRITTEN')
!
!     ==================================================================
!     ==  CALCULATE PLANE WAVE CONVERGENCE                            ==
!     ==================================================================
      CALL PWCONVERGENCE
      CALL TRACE$PASS('AFTER PWCONVERGENCE')
!
!     ==================================================================
!     ==  CALCULATE LOGARITHMIC DERIVATIVE                            ==
!     ==================================================================
      CALL ENERGYTRANSFERABILITY      
!
!     ==================================================================
!     ==  CALCULATE PAW ATOM                                          ==
!     ==================================================================
!     CALL PAWATOM
!     CALL TRACE$PASS('AFTER PAWATOM')
!
!     ==================================================================
!     ==  CALCULATE PAW ATOM                                          ==
!     ==================================================================!
      CALL CHARGETRANSFERABILITY
      CALL TRACE$PASS('AFTER CHARGETRANSFERABILITY')
      WRITE(NFILO,FMT='(72("=")/72("="),T20 &
     &         ," PROGRAM FINISHED "/72("="))')
      STOP
      END
!
!     ..................................................................
      SUBROUTINE RESOLVEPAWATOMSINBUFFER(LL_CNTL,ELEMENT)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE PERIODICTABLE_MODULE, ONLY : PERIODICTABLE$GET
      USE LINKEDLIST_MODULE
      USE AEATOM    ,ONLY : AEZ,NB,NC,CREATEAEATOM
      USE PROJECTION,ONLY : NWAVE,CREATEPROJECTION,RCSMALL
      USE GRID      ,ONLY : R1,DEX,NR &
     &                     ,OUTERBOXRADIUS &
     &                     ,AUGMENTATIONRADIUS &
     &                     ,CREATEGRID
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(INOUT):: LL_CNTL
      CHARACTER(2) ,INTENT(OUT)  :: ELEMENT ! ELEMENT SYMBOL
      INTEGER(4)                 :: ILDA
      INTEGER(4)                 :: ISVAR
      INTEGER(4)                 :: NV
      LOGICAL(4)                 :: TCHK
!     ******************************************************************
!
!     ==================================================================
!     == ANALYZE BUFFER                                               ==
!     ==================================================================
!
!     ==================================================================
!     == SET FUNCTIONAL                                               ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'DFT')
      CALL LINKEDLIST$GET(LL_CNTL,'TYPE',1,ILDA)
      CALL DFT$SETI4('TYPE',ILDA)
      CALL DFT$SETL4('SPIN',.FALSE.)
!
!     ===================================================================
!     ==  GET BOX RADIUS                                               ==
!     ===================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'GENERIC')
      CALL LINKEDLIST$EXISTD(LL_CNTL,'RBOX',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'RBOX',1,25.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'RBOX',1,OUTERBOXRADIUS)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'RAUG',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'RAUG',1,25.D0)
      CALL LINKEDLIST$GET(LL_CNTL,'RAUG',1,AUGMENTATIONRADIUS)
!
!     ==================================================================
!     ==  DEFINE RADIAL GRID                                          ==
!     ==  POSSIBLE CHOICE :                                           ==
!     ==  DEX=0.0244 .. NR=DLOG(7200.0D0*AEZ)/DEX .. R1=0.00625D0/AEZ ==
!     ==  DEX=0.05   .. NR=250                  .. R1=1.056E-4        ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'RGRID')
      CALL LINKEDLIST$EXISTD(LL_CNTL,'R1',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'R1',0,1.056D-4)
      CALL LINKEDLIST$GET(LL_CNTL,'R1',1,R1)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'DEX',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'DEX',0,0.05D0)
      CALL LINKEDLIST$GET(LL_CNTL,'DEX',1,DEX)
      CALL LINKEDLIST$EXISTD(LL_CNTL,'NR',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'NR',0,250)
      CALL LINKEDLIST$GET(LL_CNTL,'NR',1,NR)
      CALL CREATEGRID
!
!     ===================================================================
!     ==  GET DECAY OF COMPENSATION DENSITY                            ==
!     ===================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'COMPENSATE')
      CALL LINKEDLIST$EXISTD(LL_CNTL,'RC',1,TCHK)
      IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'RC',0,0.3D0)
      CALL LINKEDLIST$GET(LL_CNTL,'RC',1,RCSMALL)
!
!     ==================================================================
!     ==  CREATE AEATOM                                          ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'GENERIC')
      CALL LINKEDLIST$GET(LL_CNTL,'ELEMENT',1,ELEMENT)
      CALL PERIODICTABLE$GET(ELEMENT,'Z',ISVAR)
      AEZ=DBLE(ISVAR)
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'VALENCE')
      CALL LINKEDLIST$NLISTS(LL_CNTL,'STATE',NV)
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'AECORE')
      CALL LINKEDLIST$NLISTS(LL_CNTL,'STATE',NC)
      NB=NC+NV
      CALL CREATEAEATOM
!
!     ==================================================================
!     ==  CREATE PROJECTION                                           ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$NLISTS(LL_CNTL,'WAVE',NWAVE)
      CALL CREATEPROJECTION
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE ALLELECTRONATOM(LL_CNTL,ELEMENT)
!     ******************************************************************
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      USE GRID
      USE AEATOM
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(INOUT):: LL_CNTL
      CHARACTER(2),INTENT(IN)   :: ELEMENT ! ELEMENT SYMBOL
      INTEGER(4)                :: NFILO
      INTEGER(4)                :: NV
      INTEGER(4)  ,ALLOCATABLE  :: SB(:)
      INTEGER(4)                :: ITH
      INTEGER(4)                :: ISVAR,IB
      REAL(8)                   :: PI,Y0,C0LL
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10 &
     &                 ," ALL-ELECTRON SCF CALCULATION "/72("-"))')
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI)
      C0LL=Y0
      NV=NB-NC
!
!     ===================================================================
!     ==  GET STATES                                                   ==
!     ===================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'AECORE')
      DO IB=1,NC
        ITH=IB
        CALL LINKEDLIST$SELECT(LL_CNTL,'STATE',ITH)
        CALL LINKEDLIST$GET(LL_CNTL,'L',1,LB(IB))
        CALL LINKEDLIST$GET(LL_CNTL,'N',1,NNB(IB)); NNB(IB)=NNB(IB)-LB(IB)-1
        CALL LINKEDLIST$CONVERT(LL_CNTL,'F',1,'R(8)')
        CALL LINKEDLIST$GET(LL_CNTL,'F',1,FB(IB))
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      ENDDO
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'VALENCE')
      DO IB=NC+1,NB
        ITH=IB-NC
        CALL LINKEDLIST$SELECT(LL_CNTL,'STATE',ITH)
        CALL LINKEDLIST$GET(LL_CNTL,'L',1,LB(IB))
        CALL LINKEDLIST$GET(LL_CNTL,'N',1,NNB(IB)); NNB(IB)=NNB(IB)-LB(IB)-1
        CALL LINKEDLIST$CONVERT(LL_CNTL,'F',1,'R(8)')
        CALL LINKEDLIST$GET(LL_CNTL,'F',1,FB(IB))
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      ENDDO
!
!     ===================================================================
!     ==  SELF CONSISTENT CALCULATION FOR THE ATOM                     ==
!     ===================================================================
PRINT*,'BEFORE AESCF'
      AECORE(:)=0.D0
      ALLOCATE(SB(NB)); SB(:)=1
      CALL AESCF(AEZ,R1,DEX,NR,OUTERBOXRADIUS &
     &          ,NB,NNB,LB,SB,FB,EB,AECORE,AEPOT,AEPSI)
      DEALLOCATE(SB)
PRINT*,'AFTER AESCF'
!
!     ===================================================================
!     ==  CALCULATE AND PRINT ENERGIES                                 ==
!     ===================================================================
      CALL AEENERGIES(.TRUE.,R1,DEX,NR,AEZ,AEPOT,AECORE,NC &
     &               ,NB,NNB,LB,FB,EB,AEPSI)
!
!     ===================================================================
!     ==  CALCULATE CORE DENSITY                                       ==
!     ===================================================================
      AECORE(:)=0.D0
      DO IB=1,NC
        AECORE(:)=AECORE(:)+C0LL*FB(IB)*AEPSI(:,1,IB)**2
      ENDDO
!
      RETURN
      END
!
!     ...................................................SRATOM.........
      SUBROUTINE AESCF(AEZ,R1,DEX,NR,BOXRADIUS &
     &            ,NB,NNOFI,LOFI,SOFI,FOFI,EOFI,AECORE,POT,PHI)
!     ******************************************************************
!     **                                                              **
!     **  SELF-CONSISTENT SCALAR-RELATIVISTIC  ALL-ELECTRON ATOM      **
!     **  CALCULATION USING LOG MESH                                  **
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      USE SCHRGL_INTERFACE_MODULE
      IMPLICIT NONE
      REAL(8),   PARAMETER  :: TOL=1.D-10
      REAL(8),   PARAMETER  :: NITER=500
      REAL(8),   INTENT(IN) :: BOXRADIUS
      REAL(8),   INTENT(IN) :: AEZ
      REAL(8),   INTENT(IN) :: R1
      REAL(8),   INTENT(IN) :: DEX
      INTEGER(4),INTENT(IN) :: NR
      INTEGER(4),INTENT(IN) :: NB         ! NUMBER OF SHELLS
      INTEGER(4),INTENT(IN) :: LOFI(NB)    ! ANGULAR MOMENTUM QUANTUM NUMBER
      INTEGER(4),INTENT(IN) :: NNOFI(NB)   ! #(NODES)
      INTEGER(4),INTENT(IN) :: SOFI(NB)    ! SPIN QUANTUM NUMBER
      REAL(8),   INTENT(IN) :: FOFI(NB)    ! OCCUPATION
      REAL(8),   INTENT(OUT):: EOFI(NB)    ! ONE-PARTICLE ENERGY
      REAL(8),   INTENT(OUT):: POT(NR)
      REAL(8),   INTENT(OUT):: PHI(NR,3,NB)
      REAL(8),   INTENT(IN) :: AECORE(NR)
      INTEGER(4)            :: NFILO
      LOGICAL(4)            :: CONVG
      REAL(8)               :: XMAX,XAV
      REAL(8)               :: R(NR)
      REAL(8)               :: RHO(NR)
      REAL(8)               :: RI
      REAL(8)               :: XEXP
      REAL(8)               :: SVAR
      INTEGER(4)            :: IR,IB,ISPIN
      REAL(8)               :: PI
      REAL(8)               :: Y0
      REAL(8)               :: C0LL
      REAL(8)               :: EOLD
      INTEGER(4)            :: I
      INTEGER(4)            :: ITER   ! SCF ITERATION COUNT
      INTEGER(4)            :: NNODE  ! #(NODES)
      INTEGER(4)            :: NMAIN  ! MAIN QUANTUM NUMBER
      REAL(8)               :: ZCORE  ! -#(CORE ELECTRONS)
      REAL(8)               :: ZEFF   ! EFFECTIVE MAIN QUANTUM NUMBER
      REAL(8)               :: AUX1(NR)
      REAL(8)               :: AUX2(NR)
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI)
      C0LL=Y0
!
!     ==================================================================
!     ==  GENERATE R-GRID                                             ==
!     ==================================================================
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
!
!     ==================================================================
!     ==  GENERATE STARTING THOMAS-FERMI POTENTIAL
!     ==================================================================
      DO IR=1,NR
        CALL TFAPOT(R(IR),AEZ,POT(IR))
        POT(IR)=POT(IR)/Y0
      ENDDO
!
!     ==================================================================
!     ==  STARTING APPROXIMATION FOR ENERGIES                         ==
!     ==  STATES SHOULD BE ORDERED WITH INCREASING ENERGY             ==
!     ==================================================================
      AUX1=-AECORE(:)/Y0*R(:)**2
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,ZCORE)  
!     THE FOLLOWING LINE CREATES AN INTERFACE ERROR
!     CALL RADIAL$INTEGRAL(R1,DEX,NR,-AECORE(:)/Y0*R(:)**2,ZCORE)
      ZEFF=AEZ+ZCORE
      DO IB=1,NB
        ZEFF=ZEFF-FOFI(IB)               ! EFFECTIVE ATOMIC NUMBER
        NMAIN=LOFI(IB)+NNOFI(IB)+1 
        EOFI(IB)=-0.5D0*( (ZEFF+1.D0)/DBLE(NMAIN) )**2
        IF(EOFI(IB).GT.POT(NR)) EOFI(IB)=POT(NR)-0.1D0
      ENDDO
!
!     ==================================================================
!     ==================================================================
!     ==  RETURN POINT FOR SELF-CONSISTENCY LOOP                      ==
!     ==================================================================
!     ==================================================================
      XAV=0.D0
      XMAX=0.D0
      CONVG=.FALSE.
      CALL MIXPOT('ON',R1,DEX,NR,POT,XMAX,XAV)
      DO ITER=1,NITER
        PRINT*,'ITER ',ITER,EOFI
!
!     ==================================================================
!     ==  CALCULATE WAVEFUNCTIONS                                     ==
!     ==================================================================
        ZEFF=AEZ+ZCORE
        DO IB=1,NB
          ISPIN=SOFI(IB)
          CALL FIXNODE(R1,DEX,NR,LOFI(IB),EOFI(IB),AEZ,BOXRADIUS &
     &                  ,POT,PHI(1,1,IB),ZEFF,NNOFI(IB),1.D+1)
          ZEFF=ZEFF-FOFI(IB)
        ENDDO
!
!       ================================================================
!       ==  ACCUMULATE CHARGE DENSITY                                 ==
!       ================================================================
        DO IR=1,NR
          RHO(IR)=AECORE(IR)
        ENDDO
        DO IB=1,NB
          ISPIN=SOFI(IB)
          SVAR=FOFI(IB)*Y0
          RHO(:)=RHO(:) + SVAR*PHI(:,1,IB)**2
        ENDDO
!
!       ================================================================
!       ==  EXIT IF CONVERGED                                         ==
!       ================================================================
        IF(CONVG) THEN
          CALL REPORT$I4VAL(NFILO,"SCF LOOP CONVERGED AFTER ",ITER," ITERATIONS")
          CALL REPORT$R8VAL(NFILO,'AV. DIFF BETWEEN IN- AND OUTPUT POTENTIAL',XAV,'?')
          CALL REPORT$R8VAL(NFILO,'MAXIMUM  OF (VIN-VOUT)*R^2',XMAX,'?')
          CALL MIXPOT('OFF',R1,DEX,NR,POT,XMAX,XAV)
          RETURN
        END IF
!
!       ================================================================
!       ==  GENERATE OUTPUT POTENTIAL                                 ==
!       ================================================================
        CALL VOFRHO(AEZ,R1,DEX,NR,RHO,POT)
!
!       ================================================================
!       ==  GENERATE NEXT ITERATION USING D. G. ANDERSON'S METHOD     ==
!       ================================================================
        CALL MIXPOT('GO',R1,DEX,NR,POT,XMAX,XAV)
        CONVG=(XMAX.LT.TOL)
      ENDDO
      CALL ERROR$MSG('SELFCONSISTENCY LOOP NOT CONVERGED')
      CALL ERROR$STOP('AESCF')
      STOP
      END
!
!     ..................................................................
      SUBROUTINE MIXPOT(SWITCH,R1,DEX,NR,POT,XMAX,XAV)
!     ******************************************************************
!     **                                                              **
!     **  MIX POTENTIAL USING D.G.ANDERSEN'S METHOD                   **
!     **                                                              **
!     **  1) INITIALIZE WITH SWITCH='ON'                              **
!     **     STORES THE FIRST INPUT POTENTIAL <-POT                   **
!     **     ALLOCATES  INTERNAL ARRAYS                               **
!     **                                                              **
!     **  2) ITERATE WITH WITH SWITCH='GO'                            **
!     **     RECEIVES THE OUTPUT POTENTIAL    <-POT           E       **
!     **     CALCULATES NEW INPUT POTENTIAL   ->POT                   **
!     **     STORES THE NEW INPUT POTENTIAL                           **
!     **                                                              **
!     **  3) CLEAR MEMORY WITH SWITCH='OFF'                           **
!     **                                                              **
!     **  WARNING! DO NOT USE SIMULTANEOUSLY FOR TOW DIFFERENT SCHEMES**
!     **                                                              **
!     ******************************************************************
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN)   :: SWITCH !CAN BE 'ON', 'GO' OR 'OFF'
      REAL(8)     ,INTENT(IN)   :: R1
      REAL(8)     ,INTENT(IN)   :: DEX
      INTEGER(4)  ,INTENT(IN)   :: NR
      REAL(8)     ,INTENT(INOUT):: POT(NR) ! 
      REAL(8)     ,INTENT(OUT)  :: XMAX    ! MAX.|R**2*(VOUT-VIN)|
      REAL(8)     ,INTENT(OUT)  :: XAV     ! <R**2(VOUT-VIN)**2>
      REAL(8)     ,PARAMETER    :: ALPHA=0.1D0 !MIXING PARAMETER
      CHARACTER(8)       ,SAVE :: STATUS='OFF'
      LOGICAL(4)         ,SAVE :: TSTART
      INTEGER(4)         ,SAVE :: NRSAVE
      REAL(8),ALLOCATABLE,SAVE :: OLDPOTIN(:)
      REAL(8),ALLOCATABLE,SAVE :: OLDPOTOUT(:)
      REAL(8),ALLOCATABLE,SAVE :: NEWPOTOUT(:)
      REAL(8),ALLOCATABLE,SAVE :: NEWPOTIN(:)
      REAL(8)                  :: BETA
      REAL(8)                  :: SVAR1,SVAR2
      REAL(8)                  :: DIFFNEW,DIFFOLD,DDIFF
      REAL(8)                  :: TEST
      REAL(8)                  :: XEXP
      REAL(8)                  :: RI
      INTEGER(4)               :: IR
!     ******************************************************************
      IF(SWITCH.EQ.'GO') THEN
        IF(NR.NE.NRSAVE) THEN
          CALL ERROR$MSG('INCONSISTENT NUMBER OF GRIDPOINTS')
          CALL ERROR$STOP('MIXPOT')
        END IF
        XEXP=DEXP(DEX)
!       ================================================================
!       == COPY POT INTO NEWPOTIN                                     ==
!       ================================================================
        DO IR=1,NR
          NEWPOTOUT(IR)=POT(IR)
        ENDDO
!       ================================================================
!       == CALCULATE MAX AND VARIANCE OF POTOUT-POTIN                 ==
!       ================================================================
        XMAX=0.D0
        XAV=0.D0
        SVAR1=0.D0
        RI=R1/XEXP
        DO IR=1,NR
          RI=RI*XEXP
          TEST=(NEWPOTOUT(IR)-NEWPOTIN(IR))
          XMAX=MAX(ABS(TEST*RI**2),XMAX)
          XAV=XAV+TEST**2*RI**2
          SVAR1=SVAR1+RI**2
        ENDDO
        XAV=DSQRT(XAV/SVAR1)
!       ================================================================
!       ==  CALCULATE MIXING FACTOR BETA                              ==
!       ================================================================
        IF(TSTART) THEN
          TSTART=.FALSE.
          BETA=0.D0
        ELSE
          SVAR1=0.0D0
          SVAR2=0.0D0
          RI=R1/XEXP
          DO IR=1,NR
            RI=RI*XEXP
            DIFFNEW =NEWPOTOUT(IR)-NEWPOTIN(IR)
            DIFFOLD =OLDPOTOUT(IR)-OLDPOTIN(IR)
            DDIFF=DIFFNEW-DIFFOLD
!            SVAR1=SVAR1 + DIFFNEW*DDIFF *RI**2
!            SVAR2=SVAR2 +   DDIFF*DDIFF *RI**2
            SVAR1=SVAR1 + DIFFNEW*DDIFF *RI
            SVAR2=SVAR2 +   DDIFF*DDIFF *RI
          ENDDO
          BETA=SVAR1/SVAR2
        END IF
!       ================================================================
!       == MIX POTENTIALS                                             ==
!       ================================================================
        DO IR=1,NR
          SVAR1=(1.0D0-BETA)*NEWPOTIN(IR) + BETA*OLDPOTIN(IR)
          SVAR2=(1.0D0-BETA)*NEWPOTOUT(IR)+ BETA*OLDPOTOUT(IR)
          POT(IR)=SVAR1 + ALPHA*(SVAR2-SVAR1)
          OLDPOTIN(IR) =NEWPOTIN(IR)
          OLDPOTOUT(IR)=NEWPOTOUT(IR)
          NEWPOTIN(IR) =POT(IR)
        ENDDO
!
!     ==================================================================
!     == INITIALIZE MIXING                                            ==
!     ==================================================================
      ELSE IF(SWITCH.EQ.'ON') THEN
        IF(TRIM(STATUS).NE.'OFF') THEN
          DEALLOCATE(OLDPOTIN)
          DEALLOCATE(OLDPOTOUT)
          DEALLOCATE(NEWPOTIN)
          DEALLOCATE(NEWPOTOUT)
        END IF
        NRSAVE=NR
        ALLOCATE(OLDPOTIN(NRSAVE))
        ALLOCATE(OLDPOTOUT(NRSAVE))
        ALLOCATE(NEWPOTIN(NRSAVE))
        ALLOCATE(NEWPOTOUT(NRSAVE))
        TSTART=.TRUE.
        STATUS='ON'
        DO IR=1,NR
          OLDPOTOUT(IR)=0.D0
          OLDPOTIN(IR) =0.D0
          NEWPOTOUT(IR)=0.D0
          NEWPOTIN(IR) =POT(IR)
        ENDDO
!
!     ==================================================================
!     == CLEAR ARRAYS                                                 ==
!     ==================================================================
      ELSE IF(SWITCH.EQ.'OFF') THEN
        DEALLOCATE(OLDPOTIN)
        DEALLOCATE(OLDPOTOUT)
        DEALLOCATE(NEWPOTIN)
        DEALLOCATE(NEWPOTOUT)
        TSTART=.FALSE.
        STATUS='OFF'
      END IF
      RETURN
      END
!
!     .....................................................VOUT.........
      SUBROUTINE VOFRHO(AEZ,R1,DEX,NR,RHO,POT)
!     ******************************************************************
!     **                                                              **
!     **  ELECTROSTATIC AND EXCHANGE-CORRELATION POTENTIAL            **
!     **                                                              **
!     ******************************************************************
      IMPLICIT NONE
      REAL(8),   INTENT(IN) :: R1
      REAL(8),   INTENT(IN) :: DEX
      INTEGER(4),INTENT(IN) :: NR
      REAL(8),   INTENT(IN) :: AEZ
      REAL(8),   INTENT(IN) :: RHO(NR)
      REAL(8),   INTENT(OUT):: POT(NR)
      REAL(8)               :: PI
      REAL(8)               :: FOURPI
      REAL(8)               :: Y0
      REAL(8)               :: XEXP
      REAL(8)               :: AUX(NR)
      REAL(8)               :: GRHO(NR)
      REAL(8)               :: R(NR),RI
      REAL(8)               :: VGXC,VXC,EXC,RH,GRHO2
      REAL(8)               :: DUMMY1,DUMMY2,DUMMY3
      INTEGER(4)            :: IR
!     ******************************************************************
      PI=4.D0*DATAN(1.D0)
      FOURPI=4.D0*PI
      Y0=1.D0/DSQRT(FOURPI)
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
!
!     ==================================================================
!     ==  TOTAL POTENTIAL                                             ==
!     ==================================================================
! POT(:)=0.D0
! POT(:)=POT(:)-AEZ/R(:)/Y0
! PRINT*,'WARNING IN VOFRHO!!!'
! RETURN
      POT(:)=0.D0
      CALL RADIAL$POISSON(R1,DEX,NR,0,RHO,POT)
      POT(:)=POT(:)-AEZ/R(:)/Y0
!
      CALL RADIAL$DERIVE(R1,DEX,NR,RHO(:),GRHO)
      DO IR=1,NR
        RH=RHO(IR)*Y0
        GRHO2=(Y0*GRHO(IR))**2
        CALL DFT(RH,0.D0,GRHO2,0.D0,0.D0,EXC,VXC,DUMMY1,VGXC,DUMMY2,DUMMY3)
        POT(IR)=POT(IR)+FOURPI*Y0*VXC
        GRHO(IR)=VGXC*2.D0*GRHO(IR)
      ENDDO
      CALL RADIAL$DERIVE(R1,DEX,NR,GRHO(:),AUX)
      POT(:)=POT(:)-2.D0/R(:)*GRHO(:)-AUX
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE AEENERGIES(TALL,R1,DEX,NR,AEZ,POT,AECORE,NC,NB,NN,L,F,EB,PHI)
!     ******************************************************************
!     **                                                              **
!     **  CALCULATES AND REPORTS TOTAL AND ONE PARTICLE ENERGIES      **
!     **                                                              **
!     ******************************************************************
      IMPLICIT NONE
      LOGICAL(4),INTENT(IN) :: TALL  ! TALL=T ASSUMES THAT THE CORE DENSITY HAS NOT BEEN SPLIT OFF
      REAL(8)   ,INTENT(IN) :: R1
      REAL(8)   ,INTENT(IN) :: DEX
      INTEGER(4),INTENT(IN) :: NR
      REAL(8)   ,INTENT(IN) :: AEZ           ! ATOMIC NUMBER
      REAL(8)   ,INTENT(IN) :: POT(NR)       ! POTENTIAL
      REAL(8)   ,INTENT(IN) :: AECORE(NR)    ! AECORE DENSITY
      INTEGER(4),INTENT(IN) :: NC            ! #(CORE STATES)
      INTEGER(4),INTENT(IN) :: NB            ! #(WAVE FUNCTIONS)
      INTEGER(4),INTENT(IN) :: NN(NB)        ! NUMBER OF NODES
      INTEGER(4),INTENT(IN) :: L(NB)         ! MAIN ANGULAR MOMENTUM    
      REAL(8)   ,INTENT(IN) :: F(NB)         ! OCCUPATIONS
      REAL(8)   ,INTENT(IN) :: EB(NB)        ! ONE PARTICLE ENERGIES
      REAL(8)   ,INTENT(IN) :: PHI(NR,3,NB)  ! VALENCE WAVE FUNCTIONS
      INTEGER(4)            :: NFILO
      REAL(8)               :: RHOV(NR)      ! VALENCE DENSITY
      REAL(8)               :: RHOC(NR)      ! CORE DENSITY
      REAL(8)               :: EBANDCC       ! SUM OF CORE EIGENVALUES
      REAL(8)               :: EKINCC        ! KINETIC ENERGY OF THE CORE STATES
      REAL(8)               :: EELCC         ! ELECTROSTATIC SELF INTERACTION OF THE CORE
      REAL(8)               :: EXCCC         ! CORE XC-ENERGY
      REAL(8)               :: EELVC         ! CORE VALENCE ELECTROSTATIC INTERACTION
      REAL(8)               :: EELVV         ! VALENCE ELECTROSTATIC SELF ENERGY
      REAL(8)               :: EXCVV         ! VALENCE XC-ENERGY
      REAL(8)               :: ESUM          ! SUM OF VALENCE ONE-PARTICLE ENERGIES
      REAL(8)               :: EKINV         ! VALENCE KINETIC ENERGY
      REAL(8)               :: R(NR)
      REAL(8)               :: PI,FOURPI
      REAL(8)               :: Y0,C0LL
      REAL(8)               :: EV             ! ELECTRON VOLT
      REAL(8)               :: XEXP
      INTEGER(4)            :: IB,IR
      REAL(8)               :: AUX1(NR)
      REAL(8)               :: AUX2(NR)
      REAL(8)               :: AUX3(NR)
      REAL(8)               :: GRHO(NR)
      REAL(8)               :: SVAR,GRHO2,RH,VXC,VGXC,DUMMY1,DUMMY2,EXC,DUMMY3
      REAL(8)               :: RMAX,PHI1,PHI2,X1,X2,X3,F1,F2,F3
      REAL(8)               :: RI
!     ******************************************************************
      PI=4.D0*DATAN(1.D0)
      FOURPI=4.D0*PI
      Y0=1.D0/SQRT(FOURPI)
      C0LL=Y0
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
      CALL FILEHANDLER$UNIT('PROT',NFILO)
!
!     ==================================================================
!     ==  ACCUMULATE CHARGE DENSITY
!     ==================================================================
      DO IR=1,NR
        RHOV(IR)=0.D0
        RHOC(IR)=0.D0
      ENDDO
      IF(TALL) THEN
        DO IB=1,NC
          DO IR=1,NR
            RHOC(IR)=RHOC(IR) + F(IB)*C0LL*PHI(IR,1,IB)**2
          ENDDO
        ENDDO
      ELSE
        RHOC(:)=AECORE(:)
      ENDIF
      DO IB=NC+1,NB
        DO IR=1,NR
          RHOV(IR)=RHOV(IR) + F(IB)*C0LL*PHI(IR,1,IB)**2
        ENDDO
      ENDDO
PRINT*,'RHOV ',RHOV(1:4)
PRINT*,'RHOC ',RHOC(1:4)
PRINT*,'RHOT ',RHOV(1:4)+RHOC(1:4)
!HERERHO THIS CAN BE REMOVED
!CALL RADIAL$DERIVE(R1,DEX,NR,RHOC+RHOV,GRHO)
!PRINT*,'R,RHOTOT,GRHO'
!DO IR=1,NR
!WRITE(*,FMT='(4F20.10)')R(IR),RHOC(IR)+RHOV(IR),GRHO(IR)
!ENDDO
!STOP 'FORCED STOP IN AEENERGIES, CAN BE REMOVED...'
!
!     ==================================================================
!     ==================================================================
!     ==  COMPUTE TOTAL ENERGY                                        ==
!     ==================================================================
!     ==================================================================
!
!     ==================================================================
!     == CORE KINETIC ENERGY
!     ==================================================================
      IF(TALL) THEN
        EBANDCC=0.D0
        DO IB=1,NC
          EBANDCC=EBANDCC+F(IB)*EB(IB)
        ENDDO
        DO IR=1,NR
          AUX1(IR)=RHOC(IR)*POT(IR)*R(IR)**2
        ENDDO
        CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,SVAR)
        EKINCC=EBANDCC-SVAR
      END IF
!
!     ==================================================================
!     ==  VALENCE KINETIC ENERGY
!     ==================================================================
      ESUM=0.D0
      DO IB=NC+1,NB
        ESUM=ESUM+F(IB)*EB(IB)
      ENDDO
      DO IR=1,NR
        AUX1(IR)=RHOV(IR)*POT(IR)*R(IR)**2
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,EKINV)
      EKINV=ESUM-EKINV
!
!     ==================================================================
!     ==  CORE CORE ELECTROSTATIC
!     ==================================================================
      CALL RADIAL$POISSON(R1,DEX,NR,0,RHOC,AUX3)
      DO IR=1,NR
        AUX1(IR)=RHOC(IR)*(0.5D0*AUX3(IR)*R(IR)**2-AEZ/Y0*R(IR))
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,EELCC)
!
!     ==================================================================
!     ==  CORE VALENCE ELECTROSTATIC
!     ==================================================================
      CALL RADIAL$POISSON(R1,DEX,NR,0,RHOC,AUX3)
      DO IR=1,NR
        AUX1(IR)=RHOV(IR)*(AUX3(IR)*R(IR)**2-AEZ/Y0*R(IR))
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,EELVC)
!
!     ==================================================================
!     ==  VALENCE VALENCE ELECTROSTATIC
!     ==================================================================
      CALL RADIAL$POISSON(R1,DEX,NR,0,RHOV,AUX3)
      DO IR=1,NR
        AUX1(IR)=RHOV(IR)*0.5D0*AUX3(IR)*R(IR)**2
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,EELVV)
!
!     ==================================================================
!     ==  CORE CORE EXCHANGE
!     ==================================================================
      CALL RADIAL$DERIVE(R1,DEX,NR,RHOC,GRHO)
      DO IR=1,NR
        GRHO2=(Y0*GRHO(IR))**2
        RH=RHOC(IR)*Y0
        CALL DFT(RH,0.D0,GRHO2,0.D0,0.D0,EXC,VXC,DUMMY1,VGXC,DUMMY2,DUMMY3)
        AUX1(IR)=EXC*FOURPI*R(IR)**2
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,EXCCC)
!
!     ==================================================================
!     == VALENCE EXCHANGE CORRELATION
!     ==================================================================
      CALL RADIAL$DERIVE(R1,DEX,NR,RHOC+RHOV,GRHO)
      DO IR=1,NR
        GRHO2=(Y0*GRHO(IR))**2
        RH=(RHOC(IR)+RHOV(IR))*Y0
        CALL DFT(RH,0.D0,GRHO2,0.D0,0.D0,EXC,VXC,DUMMY1,VGXC,DUMMY2,DUMMY3)
!THIS FUDGE CAN BE USED TO CALCULATE THE EXACT H-ATOM ENERGY
!CHANGE ALSO VOFRHO AND SET THE SPIN SWITCH FOR DFT
!       CALL DFT(RH,RH,GRHO2,GRHO2,GRHO2,EXC,VXC,DUMMY1,VGXC,DUMMY2,DUMMY3)
        AUX1(IR)=EXC*FOURPI*R(IR)**2
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,EXCVV)
      EXCVV=EXCVV-EXCCC
!
!     ==================================================================
!     ==  PRINT TOTAL ENERGY AND EIGENVALUES                          ==
!     ==================================================================
      CALL CONSTANTS('EV',EV)
!     ==  PRINTOUT
      CALL REPORT$TITLE(NFILO,'ALL-ELECTRON ATOMIC OUTPUT')
      CALL REPORT$R8VAL(NFILO,'ATOMIC NUMBER',AEZ,' ')
      CALL REPORT$R8VAL(NFILO,'TOTAL ENERGY',EKINV+EELVV+EELVC+EXCVV,'H')
      CALL REPORT$R8VAL(NFILO,'SUM OF ONE-PARTICLE ENERGIES',ESUM,'H')
      CALL REPORT$R8VAL(NFILO,'VALENCE KINETIC ENERGY',EKINV,'H')
      CALL REPORT$R8VAL(NFILO,'VALENCE ELECTROSTATIC ENERGY',EELVV+EELVC,'H')
      CALL REPORT$R8VAL(NFILO,'VALENCE EXCHANGE AND CORRELATION ENERGY',EXCVV,'H')
      CALL REPORT$R8VAL(NFILO,'CORE KINETIC ENERGY',EKINCC,'H')
      CALL REPORT$R8VAL(NFILO,'CORE ELECTROSTATIC ENERGY',EELCC,'H')
      CALL REPORT$R8VAL(NFILO,'CORE EXCHANGE AND CORRELATION ENERGY',EXCCC,'H')
      CALL REPORT$R8VAL(NFILO,'CORE ENERGY',EKINCC+EELCC+EXCCC,'H')
      WRITE(NFILO,6001)
 6001 FORMAT(' EIGENVALUES OF CORE STATES ' &
     &      /'     N    L     POPULATION   ENERGY')
      DO IB=1,NB
        WRITE(NFILO,6002)NN(IB)+L(IB)+1,L(IB),F(IB),EB(IB),EB(IB)/EV
 6002   FORMAT(' ',2I5,F15.5,F20.5,'H = ',F20.5,'EV')
        IF(IB.EQ.NC) WRITE(NFILO,6003)
 6003   FORMAT(' EIGENVALUES OF VALENCE STATES ' &
     &      /'     N    L     POPULATION   ENERGY')
      ENDDO
!
!     ==================================================================
!     == WRITE WAVE FUNCTIONS                                         ==
!     ==================================================================
!     CALL WRI(R1,DEX,NR,NV,PHI(1,NC+1) &
!    &          ,'  ALL-ELECTRON WAVE FUNCTIONS    ')
!     CALL WRI(R1,DEX,NR,1,AEVAT,'ALL-ELECTRON POTENTIAL        ')
!
!     ==  DETERMINE MAXIMUM OF THE VALENCE WAVE FUNCTIONS  =============
      DO IB=NC+1,NB
        RMAX=0.D0
        PHI1=DABS(PHI(NR,1,IB))
        DO IR=NR-2,1,-1
          PHI2=DABS(PHI(IR,1,IB))
          IF(PHI2.LT.PHI1) THEN
            RMAX=R(IR+1)
            X1=R(IR)
            X2=R(IR+1)
            X3=R(IR+2)
            F1=PHI(IR,1,IB)
            F2=PHI(IR+1,1,IB)
            F3=PHI(IR+2,1,IB)
            RMAX=0.5D0*(X1+X3) &
     &         - 0.5D0*(F1-F3)/( (F1-F2)/(X1-X2)-(F3-F2)/(X3-X2) ) 
            GOTO 100                     
          END IF
          PHI1=PHI2
        ENDDO
 100    CONTINUE
        WRITE(NFILO,6100)IB-NC,RMAX
 6100   FORMAT(' OUTMOST MAXIMUM OF R*PHI FOR V-STATE',I2,':',F10.5)
      ENDDO        
!
!     ==================================================================
!     ==  WRITE ATOMIC CHARGE DENSITY                                 ==
!     ==================================================================
!     ISTELL=0
!     IF(ISTELL.EQ.1) THEN
!       PRINT*,'WRITE AE-ATOMIC CHARGE DENSITY ON FILE ',NFIL
!       WRITE(NFILO,8000)AEZ,R1,DEX,NR
!8000   FORMAT(1H ,3E20.13,I10)
!       WRITE(NFILO,8001)(RHOV(IR),IR=1,NR)
!8001   FORMAT(1H ,5E14.8)
!       PRINT*,'WRITING ATOMIC CHARGE DENSITY FINISHED'
!     END IF
!
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE VTILDE(LL_CNTL)
!     ******************************************************************
!     **                                                              **
!     **  CALCULATES THE PSEUDOPOTENTIAL                              **
!     **  BY PSEUDIZING THE AE POTENTIAL                              **
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      USE GRID
      USE AEATOM, ONLY : AEPOT
      USE PROJECTION, ONLY : PSPOT
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(INOUT):: LL_CNTL
      CHARACTER(32)              :: TYPE
      REAL(8)                    :: RC       ! CUTOFF RADIUS
      REAL(8)                    :: V0       ! VTILDE(R=0)
      INTEGER(4)                 :: NIN
      LOGICAL(4)                 :: TCHK
      INTEGER(4)                 :: NFILO
      REAL(8)                    :: POWER
      LOGICAL(4)                 :: T0VAL
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10 &
     &     ," CONSTRUCT PSEUDOPOTENTIAL "/72("-"))')
!
!     ==================================================================
!     ==  FIND METHOD SELECTION ON INPUT LINKEDLIST                   ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'VTILDE')
      CALL LINKEDLIST$GET(LL_CNTL,'TYPE',1,TYPE)
!
!     ==================================================================
!     ==  CONSTRUCT PSEUDOPOTENTIAL POTENTIAL                         ==
!     ==================================================================
PRINT*,'TYPE ',TYPE
      IF(TRIM(TYPE).EQ.'POLYNOMIAL') THEN
        CALL LINKEDLIST$GET(LL_CNTL,'RC',1,RC)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'POWER',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'POWER',0,2)
        CALL LINKEDLIST$GET(LL_CNTL,'POWER',1,NIN)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'POT(0)',1,T0VAL)
        IF(T0VAL) THEN
          CALL LINKEDLIST$GET(LL_CNTL,'POT(0)',1,V0)
        ELSE
          V0=0.D0
        END IF
!
!       == REPORT PARAMETERS ===========================================
        CALL REPORT$CHVAL(NFILO,'TYPE',TYPE)
        CALL REPORT$STRING(NFILO,'FUNCTIONAL FORM: V(R)=A*R^N+B*R^(N+1) ')
        CALL REPORT$R8VAL(NFILO,'R_C',RC,'A0')
        CALL REPORT$I4VAL(NFILO,'LOWEST POWER (N) OF THE POLYNOMIAL',NIN,' ')
        IF(T0VAL) THEN
          CALL REPORT$R8VAL(NFILO,'V0',V0,'H')
        ELSE
          CALL REPORT$STRING(NFILO,'POTENTIAL AT THE ORIGIN NOT FIXED')
        END IF
!
!       ================================================================
!       ==  CONSTRUCT PSEUDOPOTENTIAL POTENTIAL                       ==
!       ================================================================
        CALL VTILDE_POLYNOMIAL(R1,DEX,RC,NIN,T0VAL,V0,NR,AEPOT,PSPOT)
      ELSE IF(TRIM(TYPE).EQ.'HBS') THEN
        CALL TRACE$PASS('MARKE 0')
        CALL LINKEDLIST$GET(LL_CNTL,'RC',1,RC)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'POWER',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'POWER',0,6.D0)
        CALL LINKEDLIST$GET(LL_CNTL,'POWER',1,POWER)
!
        CALL LINKEDLIST$EXISTD(LL_CNTL,'POT(0)',1,T0VAL)
        IF(T0VAL) THEN
          CALL LINKEDLIST$GET(LL_CNTL,'POT(0)',1,V0)
        ELSE
          V0=0.D0
        END IF
!
!       == REPORT PARAMETERS ===========================================
        CALL REPORT$CHVAL(NFILO,'TYPE',TYPE)
        CALL REPORT$STRING(NFILO,'FUNCTIONAL FORM: V(R)=V0*F(R)+(1-F(R))*V(R)')
        CALL REPORT$R8VAL(NFILO,'R_C',RC,'A0')
        CALL REPORT$I4VAL(NFILO,'LOWEST POWER (N) OF THE POLYNOMIAL',NIN,' ')
        IF(T0VAL) THEN
          CALL REPORT$R8VAL(NFILO,'V0',V0,'H')
        ELSE
          CALL REPORT$STRING(NFILO,'POTENTIAL AT THE ORIGIN NOT FIXED')
        END IF
!
!       ================================================================
!       ==  CONSTRUCT PSEUDOPOTENTIAL POTENTIAL                       ==
!       ================================================================
        CALL VTILDE_HBS(R1,DEX,RC,POWER,T0VAL,V0,NR,AEPOT,PSPOT)
!        CALL WRITEF(NFILO,'PSPOT',PSPOT)
      ELSE
        CALL ERROR$MSG('TYPE NOT RECOGNIZED')
        CALL ERROR$STOP('VTILDE')
      END IF
      RETURN 
      END
!
!     ..................................................................
      SUBROUTINE VTILDE_HBS(R1,DEX,RC,POWER,T0VAL,V0,NR,AEPOT,PSPOT)
!     ******************************************************************
!     **                                                              **
!     **  PSEUDIZES THE FUNCTION AEPOT BY A POLYNOMIAL                **
!     **     PSPOT = V0/Y0*K(R)+(1-K(R))*AEPOT                        **
!     **  WHERE                                                       **
!     **    K(R)=EXP((R/RC)**POWER)                                   **
!     **  SEE EQ 87 OF BLOECHL, PRB. 50, 17953 (1994)                 **
!     **  Y0 IS THE SPHERICAL HARMONICS FOR L=0. THE POTENTIAL        **
!     **  IS REPRESENTED IN A SPHERICAL HARMONICS EXPANSION           **
!     **                                                              **
!     **                                                              **
!     ******************************************************************
      IMPLICIT NONE
      LOGICAL(4),PARAMETER      :: TPR=.TRUE.
      REAL(8)   ,INTENT(IN)     :: R1         ! 1ST RADIAL GRID POINT
      REAL(8)   ,INTENT(IN)     :: DEX        ! LOG. GRID SPACING
      INTEGER(4),INTENT(IN)     :: NR         ! #(RADIAL GRID POINTS)
      REAL(8)   ,INTENT(IN)     :: RC         ! CUTOFF RADIUS
      LOGICAL(4),INTENT(IN)     :: T0VAL      ! FIX VTILDE(R=0)
      REAL(8)   ,INTENT(IN)     :: V0         ! VTILDE(R=0)
      REAL(8)   ,INTENT(IN)     :: POWER      !
      REAL(8)   ,INTENT(IN)     :: AEPOT(NR)  ! AE POTENTIAL
      REAL(8)   ,INTENT(OUT)    :: PSPOT(NR)  ! PS POTENTIAL
      INTEGER(4)                :: NFILO
      REAL(8)                   :: PI,Y0
      REAL(8)                   :: DFDR,DFDR1,DFDR2,FOFR
      INTEGER(4)                :: IR
      INTEGER(4)                :: IRC
      REAL(8)                   :: RI,XEXP
      REAL(8)                   :: CUT(NR)
      REAL(8)                   :: FAC
!     ******************************************************************
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI)
      XEXP=DEXP(DEX)
      IRC=NINT(1.D0+LOG(RC/R1)/DEX)
      RI=R1/XEXP
      DO IR=1,NR
        PSPOT(IR)=AEPOT(IR)
        RI=RI*XEXP
        CUT(IR)=EXP(-(RI/RC)**POWER)
      ENDDO
!     ==                     ===========================================
      IF(T0VAL) THEN
        FAC=V0/Y0
      ELSE
        FAC=AEPOT(IRC)
      END IF
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        PSPOT(IR)=FAC*CUT(IR)+(1.D0-CUT(IR))*AEPOT(IR)
      ENDDO
!
      IF(.NOT.TPR) RETURN
!     ==================================================================
!     == DIAGNOSTIC OUTPUT                                            ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='("INFO FROM VTILDE_HBS"/26("-"))')
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        IF(RI.GT.0.1D0.AND.RI.LT.10.D0.AND.5*(IR/5).EQ.IR) THEN
          WRITE(NFILO,FMT='(I5,F10.5,3E15.6)')IR,RI,AEPOT(IR),PSPOT(IR)
        END IF
      ENDDO
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE VTILDE_POLYNOMIAL(R1,DEX,RC,NIN,T0VAL,V0,NR,AEPOT,PSPOT)
!     ******************************************************************
!     **                                                              **
!     **  PSEUDIZES THE FUNCTION AEPOT BY A POLYNOMIAL                **
!     **     PSPOT = A + B*R**(NIN) + C*RI**(NIN+1)                   **
!     **  SUCH THAT VALUE AND DERIVATIVE OF PSPOT AND AEPOT           **
!     **  AGREE AT RC AND SUCH THAT PSPOT(R=0)=V0                     **
!     **                                                              **
!     ******************************************************************
      IMPLICIT NONE
      LOGICAL(4),PARAMETER      :: TPR=.FALSE.
      REAL(8)   ,INTENT(IN)     :: R1
      REAL(8)   ,INTENT(IN)     :: DEX
      INTEGER(4),INTENT(IN)     :: NR
      REAL(8)   ,INTENT(IN)     :: RC         ! CUTOFF RADIUS
      LOGICAL(4),INTENT(IN)     :: T0VAL      ! FIX VTILDE(R=0)
      REAL(8)   ,INTENT(IN)     :: V0         ! VTILDE(R=0)
      INTEGER(4),INTENT(IN)     :: NIN        ! LOWEST POWER OF PSPOT
      REAL(8)   ,INTENT(IN)     :: AEPOT(NR)  ! AE POTENTIAL
      REAL(8)   ,INTENT(OUT)    :: PSPOT(NR)  ! PS POTENTIAL
      REAL(8)                   :: WORK(NR)
      INTEGER(4)                :: IRC
      INTEGER(4)                :: NFILO
      REAL(8)                   :: PI,Y0
      REAL(8)                   :: XRC,X1,X2
      REAL(8)                   :: DFDR,DFDR1,DFDR2,FOFR
      REAL(8)                   :: A,B
      INTEGER(4)                :: IR
      REAL(8)                   :: RI,XEXP,RIN,XEXPN
!     ******************************************************************
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI)
      IRC=INT(1.D0+DLOG(RC/R1)/DEX)
      XEXP=DEXP(DEX)
      DO IR=1,NR
        PSPOT(IR)=AEPOT(IR)
      ENDDO
      CALL RADIAL$DERIVE(R1,DEX,NR,AEPOT,WORK)
      CALL RADIAL$VALUE(R1,DEX,NR,WORK,RC,DFDR)
      CALL RADIAL$VALUE(R1,DEX,NR,AEPOT,RC,FOFR)
      B=DFDR/(RC**(NIN-1)*DBLE(NIN))
      A=FOFR-B*RC**NIN
!     ==  CONVERT POLYNOMIAL ===========================================
      XEXPN=XEXP**NIN
      RIN=(R1/XEXP)**NIN
      DO IR=1,IRC
        RIN=RIN*XEXPN
        PSPOT(IR)=A+B*RIN
      ENDDO
!
!     ==================================================================
!     ==  ADD POTENTIAL SO THAT PSPOT(R=0)=V0                         ==
!     ==================================================================
      IF(T0VAL) THEN
        A=V0/Y0-A
        RI=R1/XEXP
        DO IR=1,IRC
          RI=RI*XEXP
           PSPOT(IR)=PSPOT(IR)+A*(1.D0-(RI/RC)**NIN &
     &                       *(DBLE(NIN+1)-DBLE(NIN)*(RI/RC)))
        ENDDO
      END IF
!
      IF(.NOT.TPR) RETURN
!     ==================================================================
!     == DIAGNOSTIC OUTPUT                                            ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='("INFO FROM PSEUDIZEPOTENTIAL$FIT"/26("-"))')
      WRITE(NFILO,FMT='("IR",T10,"R(IR)",T20,"AEPOT",T35,"PSPOT")')
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        IF(RI.GT.0.1D0.AND.RI.LT.10.D0.AND.5*(IR/5).EQ.IR) THEN
          WRITE(NFILO,FMT='(I5,F10.5,3E15.6)')IR,RI,AEPOT(IR),PSPOT(IR)
        END IF
      ENDDO
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE PSEUDIZECORE(LL_CNTL)
!     ******************************************************************
!     **                                                              **
!     **  CALCULATES THE PSEUDO CORE-DENSITY                          **
!     **  BY PSEUDIZING THE ALL ELECTRON CORE DENSITY                 **
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      USE GRID
      USE AEATOM    ,ONLY : AECORE
      USE PROJECTION,ONLY : PSCORE
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(INOUT):: LL_CNTL
      CHARACTER(32)              :: TYPE
      REAL(8)                    :: RC       ! CUTOFF RADIUS
      REAL(8)                    :: V0       ! VTILDE(R=0)
      INTEGER(4)                 :: NIN
      LOGICAL(4)                 :: TCHK
      LOGICAL(4)                 :: T0VAL=.TRUE.
      INTEGER(4)                 :: NFILO
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10," CONSTRUCT PSEUDOCORE "/72("-"))')
!
!     ==================================================================
!     ==  CONSTRUCT PSEUDOPOTENTIAL POTENTIAL                         ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$SELECT(LL_CNTL,'PSCORE')
      CALL LINKEDLIST$GET(LL_CNTL,'TYPE',1,TYPE)
      IF(TRIM(TYPE).EQ.'POLYNOMIAL') THEN
!       == COLLECT PARAMETERS ==========================================
        CALL LINKEDLIST$GET(LL_CNTL,'RC',1,RC)
        CALL LINKEDLIST$EXISTD(LL_CNTL,'POWER',1,TCHK)
        IF(.NOT.TCHK)CALL LINKEDLIST$SET(LL_CNTL,'POWER',0,2)
        CALL LINKEDLIST$GET(LL_CNTL,'POWER',1,NIN)
        CALL LINKEDLIST$EXISTD(LL_CNTL,'RHO(0)',1,T0VAL)
        IF(T0VAL) THEN
          CALL LINKEDLIST$GET(LL_CNTL,'RHO(0)',1,V0)
        ELSE
          V0=0.D0
        END IF
!
!       == REPORT PARAMETERS ===========================================
        CALL REPORT$CHVAL(NFILO,'TYPE',TYPE)
        CALL REPORT$STRING(NFILO,'FUNCTIONAL FORM: RHO(R)=A*R^N+B*R^(N+1) ')
        CALL REPORT$R8VAL(NFILO,'R_C',RC,'A0')
        CALL REPORT$I4VAL(NFILO,'LOWEST POWER (N) OF THE POLYNOMIAL',NIN,' ')
        IF(T0VAL) THEN
          CALL REPORT$R8VAL(NFILO,'PSEUDO DENSITY AT THE NUCLEUS',V0,'E/A0^3 ')
        ELSE
          CALL REPORT$STRING(NFILO,'VALUE AT THE ORIGIN NOT FIXED')
        END IF
!
!       == CONSTRUCT PSEUDO DENSITY ====================================
        CALL VTILDE_POLYNOMIAL(R1,DEX,RC,NIN,T0VAL,V0,NR,AECORE,PSCORE)
      ELSE
        CALL ERROR$MSG('TYPE NOT RECOGNIZED')
        CALL ERROR$STOP('PSEUDIZECORE')
      END IF
      RETURN 
      END
!
!     ..................................................................
      SUBROUTINE PARTIALWAVES(LL_CNTL)
!     ******************************************************************
!     **                                                              **
!     **                                                              **
!     **                                                              **
!     **                                                              **
!     ******************************************************************
      USE LINKEDLIST_MODULE
      USE SCHRGL_INTERFACE_MODULE,ONLY : FIXNODE,SCHROEDER
      USE GRID
      USE AEATOM    
      USE PROJECTION
      IMPLICIT NONE
      TYPE(LL_TYPE),INTENT(INOUT):: LL_CNTL
      INTEGER(4)                 :: N   
      INTEGER(4)                 :: L
      INTEGER(4)                 :: IRAUG
      CHARACTER(32)              :: PSTYPE
      REAL(8)                    :: ZEFF
      REAL(8)                    :: E
      REAL(8)                    :: AUX(NR),SVAR
      LOGICAL                    :: TCHK1,TCHK2,TCHK
      INTEGER(4)                 :: IWAVE,I,IR,IB
      REAL(8)                    :: RC,RLAMBDA
      REAL(8)                    :: CUT(NR)
      LOGICAL(4)                 :: TNORM
      INTEGER(4)                 :: NODEC
      INTEGER(4)                 :: NFILO
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10,"  CONSTRUCT PARTIAL WAVES  " &
     &     /72("-"))')
!     __ SCAN THROUGH WAVES_____________________________________________
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
      CALL LINKEDLIST$NLISTS(LL_CNTL,'WAVE',NWAVE)
      DO IWAVE=1,NWAVE
        CALL LINKEDLIST$SELECT(LL_CNTL,'WAVE',IWAVE)
        CALL LINKEDLIST$GET(LL_CNTL,'L',1,LPHI(IWAVE))
        CALL LINKEDLIST$EXISTD(LL_CNTL,'N',1,TCHK1)
        IF(TCHK1) CALL LINKEDLIST$GET(LL_CNTL,'N',1,N)
        CALL LINKEDLIST$EXISTD(LL_CNTL,'E',1,TCHK2)
        IF(TCHK2) CALL LINKEDLIST$GET(LL_CNTL,'E',1,E)
        IF((TCHK1.AND.TCHK2).OR..NOT.(TCHK1.OR.TCHK2)) THEN
          CALL ERROR$MSG('EITHER N OR E MUST BE SPECIFIED')
          CALL ERROR$STOP('PARTIALWAVES')
        END IF
PRINT*,'IN PARTIALWAVES: ',TCHK1,TCHK2,LPHI(IWAVE),N,E
        IF(TCHK1) THEN
!         ==============================================================
!         == CALCULATE AE-WAVE FUNCTIONS TO BE PSEUDIZED              ==
!         == FOR A GIVEN MAIN QUANTUM NUMBER N                        ==
!         ==============================================================
!         == ESTIMATE ENERGY ===========================================
          TCHK=.FALSE.
          DO IB=1,NB
            IF(LB(IB).EQ.LPHI(IWAVE).AND.NNB(IB).EQ.N-LPHI(IWAVE)-1) THEN 
              E=EB(IB)
              TCHK=.TRUE.
            END IF
          END DO
          IF(.NOT.TCHK) THEN
            ZEFF=AEZ
            DO IB=1,NC
              ZEFF=ZEFF-FB(IB)
            ENDDO
            IF(N.EQ.0) THEN
              CALL ERROR$MSG('MAIN QUANTUM NUMBER MUST NOT BE ZERO')
              CALL ERROR$STOP('PARTIALWAVES')
            END IF
            E=-0.5D0*((ZEFF-1)/DBLE(N))**2
          END IF
!
!         == CALCULATE WAVE FUNCTION ===================================
          CALL FIXNODE(R1,DEX,NR,LPHI(IWAVE),E,AEZ,OUTERBOXRADIUS &
     &                ,AEPOT,AEPHI(:,:,IWAVE),ZEFF,N-LPHI(IWAVE)-1,1.D-9)
!
!         == REPORT ENERGY TO LINKEDLIST ===============================
          EWAVE(IWAVE)=E
          CALL LINKEDLIST$SET(LL_CNTL,'E',0,E)
        ELSE
!         ==============================================================
!         == CALCULATE AE-WAVE FUNCTIONS TO BE PSEUDIZED              ==
!         == FOR A GIVEN ONE-PARTICLE ENERGY                          ==
!         ==============================================================
!         == FIXED ENERGY CALCULATION ==================================
          IRAUG=1.D0+DLOG(AUGMENTATIONRADIUS/R1)/DEX+1.D0
          CALL SCHROEDER(.TRUE.,.TRUE.,R1,DEX,NR,LPHI(IWAVE),E,AEZ &
     &              ,IRAUG+5,AUGMENTATIONRADIUS,AEPOT,AEPHI(:,:,IWAVE),AUX)
!         == REPORT NUMBER OF NODES TO LINKEDLIST ======================
          N=L+1
          DO IR=1,IRAUG-1
            IF(AEPHI(IR,1,IWAVE)*AEPHI(IR+1,1,IWAVE).LT.0.D0)N=N+1
          ENDDO
          EWAVE(IWAVE)=E
        END IF
!
!       ================================================================
!       ==  ORTHOGONALIZE ALL ELECTRON PARTIAL WAVES TO THE CORE STATES=
!       ================================================================
    
!
!       ================================================================
!       ==  CALCULATE PS PARTIAL WAVES                                ==
!       ================================================================
!
!       == CALCULATE NUMBER OF NODES FOR THE PS-PARTIAL WAVE ===========
        NODEC=-1
        DO IB=1,NC
          IF(LPHI(IWAVE).EQ.LB(IB)) NODEC=MAX(NODEC,NNB(IB))
        ENDDO
!
        CALL LINKEDLIST$GET(LL_CNTL,'PSTYPE',1,PSTYPE)
        IF(TRIM(PSTYPE).EQ.'HBS') THEN
          CALL LINKEDLIST$GET(LL_CNTL,'RC',1,RC)
          CALL LINKEDLIST$CONVERT(LL_CNTL,'LAMBDA',1,'R(8)')
          CALL LINKEDLIST$GET(LL_CNTL,'LAMBDA',1,RLAMBDA)
          CUT(:)=DEXP(-(RGRID(:)/RC)**RLAMBDA)
          TNORM=.FALSE. !   CALL LINKEDLIST$GET(LL_CNTL,'NORMALIZE',1,TNORM)
          CALL REPORT$STRING(NFILO,'HAMANN-BACHELET-SCHLUTER-LIKE CONSTRUCTION')
          CALL REPORT$STRING(NFILO,'V(R)=V_PS(R)+C EXP[-(R/R_C)^LAMBDA] WITH ADJUSTABLE C')
          CALL REPORT$I4VAL(NFILO,'MAIN ANGULAR MOMENTUM',LPHI(IWAVE),' ')
          CALL REPORT$R8VAL(NFILO,'ENERGY',E,'H')
          CALL REPORT$R8VAL(NFILO,'R_C',RC,'A0')
          CALL REPORT$R8VAL(NFILO,'LAMBDA',RLAMBDA,' ')
        ELSE IF(TRIM(PSTYPE).EQ.'BESSEL') THEN
          CALL ERROR$MSG('OPTION BESSEL DOES NOT EXIST')
          CALL ERROR$STOP('PARTIALWAVES')
        ELSE
          CALL ERROR$MSG('OPTION NOT RECOGNIZED')
          CALL ERROR$STOP('PARTIALWAVES')
        END IF
        IRAUG=INT(1.D0+DLOG(AUGMENTATIONRADIUS/R1)/DEX)
        CUT(IRAUG+1:NR)=0.D0
        CALL HBS(R1,DEX,NR,AUGMENTATIONRADIUS,CUT,TNORM &
     &            ,PSPOT,LPHI(IWAVE),E &
     &            ,AEPHI(:,:,IWAVE),NODEC,PSPHI(:,:,IWAVE),PRO(:,IWAVE))
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      ENDDO
      RETURN
      END
!
!     ......................................................PSPHI0......
      SUBROUTINE HBS(R1,DEX,NR,RMT,CUT,TNORM,PSPOT &
     &              ,L,E,AEPHI,NODEC,PSPHI,PRO)
!     ******************************************************************
!     **                                                              **
!     **                                                              **
!     **                                                              **
!     **                                                              **
!     ******************************************************************
      USE SCHRGL_INTERFACE_MODULE,ONLY: AEBOUNDSTATE,SCHROEDER
      IMPLICIT NONE
      INTEGER(4),PARAMETER  :: ITRMAX=100
      LOGICAL(4),PARAMETER  :: TTEST=.TRUE.
      REAL(8)   ,PARAMETER  :: TOL=1.D-10
      REAL(8)   ,INTENT(IN) :: R1
      REAL(8)   ,INTENT(IN) :: DEX
      INTEGER(4),INTENT(IN) :: NR
      REAL(8)   ,INTENT(IN) :: RMT
      INTEGER(4),INTENT(IN) :: L
      INTEGER(4),INTENT(IN) :: NODEC  ! #(NODES) OF THE HIGHEST CORE STATE WITH SAME L
      REAL(8)   ,INTENT(IN) :: E
      REAL(8)   ,INTENT(IN) :: CUT(NR)
      LOGICAL(4),INTENT(IN) :: TNORM  !SWITCH FOR NORM CONCONSERVING PARTIAL WAVES
      REAL(8)   ,INTENT(IN) :: PSPOT(NR)
      REAL(8)   ,INTENT(IN) :: AEPHI(NR,3)
      REAL(8)   ,INTENT(OUT):: PSPHI(NR,3)
      REAL(8)   ,INTENT(OUT):: PRO(NR)
      INTEGER(4)            :: IRMT
      REAL(8)               :: PI,Y0
      REAL(8)               :: PHASAE
      REAL(8)               :: PHASPS
      REAL(8)               :: PHI1,PHI2
      REAL(8)               :: PREFAC,DPRE,DPREX,PREOLD
      REAL(8)               :: AUX(NR),SVAR
      REAL(8)               :: SVAR1,SVAR2
      REAL(8)               :: R(NR),RI,XEXP
      INTEGER(4)            :: ITER,IR
      INTEGER(4)            :: NFILO
      REAL(8) :: ETEST,DLGTEST,PHITEST(NR,3),EOLD,ALPHA
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI)
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
      IRMT=INT(1.D0+DLOG(RMT/R1)/DEX)
      IF(IRMT.GT.NR) THEN
        CALL ERROR$STOP('HBS')
      END IF
!
!     ================================================================
!     == CALCULATE LOGARITHMIC DERIVATIVE AND PHASE SHIFT           ==
!     == NUMBER OF NODES OF THE PS WAVE FUNCTIONS IS THAT OF THE =====
!     == AE WAVE FUNCTIONS MINUS THE NUMBER OF NODES OF THE   
!     == HIGHEST CORE WAVE FUNCTION  
!     == ARCCOT= PI/2-DATAN(X)
!     ================================================================
      CALL PHASESHIFT(R1,DEX,NR,RMT,AEPHI,PHASAE)
!     
!     ================================================================
!     ================================================================
!     ==  OBTAIN PSEUDO PARTIAL WAVE (BIG LOOP)                     ==
!     ================================================================
!     ================================================================
      PSPHI(:,:)=0.D0
      PREFAC=0.D0
      DPREX=1.D0
      PREOLD=0.D0
      DO ITER=1,ITRMAX
!     
!       == SOLVE SCHROEDINGER EQUATION ===============================
        CALL SCHROEDER(.TRUE.,.TRUE.,R1,DEX,NR,L,E,0.D0,IRMT+3,RMT &
     &              ,PSPOT(:)+CUT(:)*PREFAC,PSPHI,AUX)
!     
!       == CALCULATE LOGARITHMIC DERIVATIVE  =========================
        CALL PHASESHIFT(R1,DEX,NR,RMT,PSPHI,PHASPS)
!     
!       == FIND NEW PREFACTOR  =======================================
        CALL RADIAL$INTEGRATE(R1,DEX,NR,R(:)**2*PSPHI(:,1)**2*CUT(:)*Y0,AUX)
        CALL RADIAL$VALUE(R1,DEX,NR,AUX,RMT,SVAR)
        CALL RADIAL$VALUE(R1,DEX,NR,PSPHI(:,1),RMT,PHI1)
        CALL RADIAL$VALUE(R1,DEX,NR,PSPHI(:,2),RMT,PHI2)
        IF(DABS(PHASPS-NINT(PHASPS)).GT.0.1D0) THEN
          DPRE=-0.5D0*PI*(RMT*PHI1/DSIN(PHASPS*PI))**2/SVAR &
     &            *(PHASAE-PHASPS-DBLE(NODEC+1))
        ELSE
!         __APPROXIMATIVE FORMULA NEAR THE ANTIBONDING STATE _________
!         __ TO AVOID OVER AND UNDERFLOWS_____________________________
          DPRE=-0.5D0*PI*(RMT*PHI2)**2/SVAR &
     &         *(PHASAE-PHASPS-DBLE(NODEC+1))
        END IF
        IF(DABS(DPRE).LT.TOL) GOTO 1000
!        WRITE(NFILO,FMT='(" PREFAC ",F7.3," DE ",E10.3 &
!     &               ," PHASAE ",F5.3," PHASEPS ",F5.3)') &
!     &               PREFAC*Y0,DPRE*SVAR,PHASAE,PHASPS
      
!       == RESTRICT STEPS OF PREFAC TO BE SMALLER THAN DPREX      ====
        IF(DABS(DPRE).GT.DPREX) THEN
          IF(DPRE*(PREFAC-PREOLD).LT.0.D0) THEN
            DPREX=0.5D0*DPREX
          END IF
          DPRE=DPREX*DPRE/DABS(DPRE)
        END IF
        PREOLD=PREFAC
        PREFAC=PREFAC+DPRE
      ENDDO
      CALL ERROR$MSG('LOOP TO FIND PSEUDO PARTIAL WAVES NOT CONVERGED')
      CALL ERROR$STOP('HBS')
 1000 CONTINUE
      CALL REPORT$I4VAL(NFILO,'LOOP FOR PS-POTENTIAL CONVERGED AFTER',ITER,'ITERATIONS')
      CALL REPORT$R8VAL(NFILO,'FACTOR FOR VARIABLE POTENTIAL PART',PREFAC*Y0,'H')
      CALL REPORT$R8VAL(NFILO,'ACCCURACY OF FACTOR FOR VARIABLE POTENTIAL PART',DPRE*SVAR,'H')
      CALL REPORT$R8VAL(NFILO,'AE PHASE SHIFT',PHASAE,' ')
      CALL REPORT$R8VAL(NFILO,'PS PHASE SHIFT',PHASPS,' ')
!
!     ==================================================================
!     == MATCH VALUES OF PSPHI AND AEPHI, AND SET TAILS EQUAL         ==
!     ==================================================================
      PSPHI(:,:)=PSPHI(:,:)/PSPHI(IRMT,1)*AEPHI(IRMT,1)
      PSPHI(IRMT:NR,:)=AEPHI(IRMT:NR,:)
!
!     ==================================================================
!     == TEST
!     ==================================================================
      IF(TTEST) THEN
        CALL TEST(R1,DEX,NR,L,E,PSPHI,RMT,PSPOT(:)+PREFAC*CUT(:))
      END IF
!
!     ==================================================================
!     ==  IMPOSE NORM CONSERVATION CONDITION IF REQUIRED              ==
!     ==================================================================
      IF(TNORM) THEN
        CALL ERROR$MSG('TNORM=.TRUE. NOT ALLOWED')
        CALL ERROR$STOP('HBS')
      END IF
      RETURN
      CONTAINS
!       ................................................................
        SUBROUTINE TEST(R1,DEX,NR,L,E,PHI,RMT,POT)
        REAL(8)   ,INTENT(IN) :: R1
        REAL(8)   ,INTENT(IN) :: DEX
        INTEGER(4),INTENT(IN) :: NR
        REAL(8)   ,INTENT(IN) :: RMT
        INTEGER(4),INTENT(IN) :: L
        REAL(8)   ,INTENT(IN) :: E
        REAL(8)   ,INTENT(IN) :: POT(NR)
        REAL(8)   ,INTENT(IN) :: PHI(NR,3)
        REAL(8)   ,PARAMETER  :: ALPHA=1.D0
        REAL(8)               :: R(NR)
        REAL(8)               :: XEXP
        REAL(8)               :: PHITEST(NR,3)
        REAL(8)               :: AUX(NR)
        REAL(8)               :: PHI1,PHI2
        REAL(8)               :: DLGTEST,PHASPS,ETEST,EOLD
        INTEGER(4)            :: ITER,IR
!       ****************************************************************
        XEXP=DEXP(DEX)
        R(1)=R1
        DO IR=2,NR
          R(IR)=R(IR-1)*XEXP
        ENDDO
        IRMT=INT(1.D0+DLOG(RMT/R1)/DEX)
!
!       ================================================================
!       ==  WRITE TARGET INFORMATION                                  ==
!       ================================================================
        WRITE(NFILO,FMT='(72("-")/72("-"),T10 &
     &    ," TEST PARTIAL WAVE FOR L=",I2," AND E=",F10.5/72("-"))')L,E
        CALL RADIAL$VALUE(R1,DEX,NR,PHI(:,1),RMT,PHI1)
        CALL RADIAL$VALUE(R1,DEX,NR,PHI(:,2),RMT,PHI2)
        DLGTEST=RMT*PHI2/PHI1
        CALL PHASESHIFT(R1,DEX,NR,RMT,PHI,PHASPS)
        WRITE(NFILO,FMT='("BOUNDARY CONDITION AT R=",T30,F20.12)')R(IRMT)
        WRITE(NFILO,FMT='("LOGARITHMIC DERIVATIVE=",T30,F20.12)')DLGTEST
        WRITE(NFILO,FMT='("PHASESHIFT=",T30,F20.12)')PHASPS
        WRITE(NFILO,FMT='("ENERGY=",T30,F20.12)')E
!
!       ================================================================
!       ==  1.TEST : BOUNDARY CONDITION WITH GIVEN ENERGY             ==
!       ================================================================
        WRITE(NFILO,FMT='(72(":"),T10 &
     &       ,"TEST LOGARITHMIC DERIVATIVE AT GIVEN ENERGY")')
        CALL SCHROEDER(.TRUE.,.TRUE.,R1,DEX,NR,L,E,0.D0,IRMT+5,RMT &
     &                ,POT(:),PHITEST,AUX)
        CALL RADIAL$VALUE(R1,DEX,NR,PHITEST(:,1),RMT,PHI1)
        CALL RADIAL$VALUE(R1,DEX,NR,PHITEST(:,2),RMT,PHI2)
        DLGTEST=RMT*PHI2/PHI1
        CALL PHASESHIFT(R1,DEX,NR,RMT,PHITEST,PHASPS)
        WRITE(NFILO,FMT='("NEW LOGARITHMIC DERIVATIVE=",T30,F20.12)')DLGTEST
        WRITE(NFILO,FMT='("PHASESHIFT=",T30,F20.12)')PHASPS
!
!       ================================================================
!       ==  2.TEST : ENERGY FOR GIVE BIOUNDARY CONDITION              ==
!       ================================================================
        WRITE(NFILO,FMT='(72(":"),T10 &
     &         ,"TEST ENERGY AT GIVEN LOGARITHMIC DERIVATIVE")')
        CALL RADIAL$VALUE(R1,DEX,NR,PHI(:,1),RMT,PHI1)
        CALL RADIAL$VALUE(R1,DEX,NR,PHI(:,2),RMT,PHI2)
        DLGTEST=RMT*PHI2/PHI1
        ETEST=E
        DO ITER=1,500
          EOLD=ETEST
          CALL AEBOUNDSTATE(R1,DEX,NR,L,ETEST,0.D0,RMT &
     &         ,POT,PHITEST,DLG=DLGTEST)
!         PRINT*,'ETEST',ETEST,EOLD,EOLD-ETEST
          IF(DABS(EOLD-ETEST).LT.1.D-12) GOTO 1100
          ETEST=EOLD+ALPHA*(ETEST-EOLD)
        ENDDO
        CALL ERROR$MSG('LOOP NOT CONVERGED')
        CALL ERROR$STOP('HBS/TEST')
 1100   CONTINUE
        CALL RADIAL$VALUE(R1,DEX,IRMT,PHITEST(:,1),RMT,PHI1)
        CALL RADIAL$VALUE(R1,DEX,IRMT,PHITEST(:,2),RMT,PHI2)
        WRITE(NFILO,FMT='("NEW ENERGY=",T30,F20.12)')ETEST
        WRITE(NFILO,FMT='("NEW LOGARITHMIC DERIVATIVE ",T30,F20.12)')RMT*PHI2/PHI1
        WRITE(NFILO,FMT='("PHASESHIFT(NONODES)=",T30,F20.12)') &
     &        0.5D0-DATAN(PHI2/PHI1)/PI
        WRITE(NFILO,FMT='(72("-")/72("-"),T10," TEST PARTIAL WAVES FINISHED "/72("-"))')
        RETURN
      END SUBROUTINE TEST
!     . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
      FUNCTION VALUE(R1,DEX,NR,F,R) RESULT(FOFR)
        IMPLICIT NONE
        REAL(8)   ,INTENT(IN) :: R1      
        REAL(8)   ,INTENT(IN) :: DEX      
        INTEGER(4),INTENT(IN) :: NR
        REAL(8)   ,INTENT(IN) :: R      
        REAL(8)   ,INTENT(IN) :: F(NR)
        REAL(8)               :: FOFR
        REAL(8)               :: X,W1,W2,DL
        INTEGER(4)            :: IX,IR
        X=1.D0+DLOG(R/R1)/DEX
        IX=INT(X)
        X=DBLE(IX)
        W2=X-DBLE(IX)
        W1=1.D0-W2
        FOFR=W1*F(IX)+W2*F(IX+1)
       END FUNCTION VALUE   
!      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
       SUBROUTINE PHASESHIFT(R1,DEX,NR,R,PHI,PHASE)
        IMPLICIT NONE
        REAL(8)   ,INTENT(IN) :: R1      
        REAL(8)   ,INTENT(IN) :: DEX      
        INTEGER(4),INTENT(IN) :: NR
        REAL(8)   ,INTENT(IN) :: R      
        REAL(8)   ,INTENT(IN) :: PHI(NR,3)
        REAL(8)   ,INTENT(OUT):: PHASE
        INTEGER(4)            :: IX,IR
        REAL(8)               :: PI
        REAL(8)               :: PHI1,PHI2
        PI=4.D0*DATAN(1.D0)
        CALL RADIAL$VALUE(R1,DEX,NR,PHI(:,1),R,PHI1)
        CALL RADIAL$VALUE(R1,DEX,NR,PHI(:,2),R,PHI2)
        PHASE=0.5D0-DATAN(PHI2/PHI1)/PI
!
        IX=INT(1.D0+DLOG(R/R1)/DEX)
        DO IR=1,IX-1
          IF(PHI(IR,1)*PHI(IR+1,1).LT.0.D0) PHASE=PHASE+1.D0
        ENDDO
        IF(PHI(IX,1)*PHI1.LT.0.D0)PHASE=PHASE+1.D0
        END SUBROUTINE PHASESHIFT
      END
!
!     ......................................................PSPHI0......
      SUBROUTINE PROJECTORS
!     ******************************************************************
!     ******************************************************************
      USE GRID 
      USE PROJECTION
      USE AEATOM    ,ONLY: AEPOT
      IMPLICIT NONE
      INTEGER(4)             :: LMAX           ! MAX ANG. MOMENTUM
      INTEGER(4)             :: L              !ANGULAR MOMENTUM
      INTEGER(4)             :: NWAVE1         ! #(STATES FOR THIS L)
      REAL(8)   ,ALLOCATABLE :: EWAVE1(:)       !(NWAVE1) STATES
      INTEGER(4),ALLOCATABLE :: INDEX(:)       !(NWAVE1) STATES
      REAL(8)   ,ALLOCATABLE :: AEPHI1(:,:,:)  !(NR,3,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: PSPHI1(:,:,:)  !(NR,3,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: PRO1(:,:)      !(NR,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DO1(:,:)       !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DTKIN1(:,:)    !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DATH1(:,:)     !(NWAVE,NWAVE1)
      INTEGER(4)             :: IWAVE,IWAVE1,IWAVEA,IWAVE1A
      INTEGER(4)             :: IRMT=230
      REAL(8), PARAMETER     :: RMT=3.5D0
!     ******************************************************************
      IRMT=2.D0+DLOG(RMT/R1)/DEX
      LMAX=MAXVAL(LPHI)
      DO L=0,LMAX
!       == HOW MANY PROJECTORS FOR THIS ANGULAR MOMENTUM? ==============
        NWAVE1=0
        DO IWAVE=1,NWAVE
          IF(LPHI(IWAVE).EQ.L) NWAVE1=NWAVE1+1
        ENDDO
!       == MAP ONTO NEW ARRAY ==========================================
        ALLOCATE(AEPHI1(NR,3,NWAVE1))
        ALLOCATE(PSPHI1(NR,3,NWAVE1))
        ALLOCATE(PRO1(NR,NWAVE1))
        ALLOCATE(DTKIN1(NWAVE1,NWAVE1))
        ALLOCATE(DO1(NWAVE1,NWAVE1))
        ALLOCATE(DATH1(NWAVE1,NWAVE1))
        ALLOCATE(INDEX(NWAVE1))
        ALLOCATE(EWAVE1(NWAVE1))
        IWAVE1=0
        DO IWAVE=1,NWAVE
          IF(LPHI(IWAVE).EQ.L) THEN
            IWAVE1 = IWAVE1+1
            INDEX(IWAVE1)     =IWAVE
            EWAVE1(IWAVE1)    =EWAVE(IWAVE)
            AEPHI1(:,:,IWAVE1)=AEPHI(:,:,IWAVE)
            PSPHI1(:,:,IWAVE1)=PSPHI(:,:,IWAVE)
          ENDIF
        ENDDO
!
!       == TRANSFORM TO PROPER PROJECTOR FUNCTIONS  ====================
        CALL MKPRO(R1,DEX,NR,AUGMENTATIONRADIUS &
     &    ,L,IRMT,AEPOT,PSPOT,NWAVE1,EWAVE1,AEPHI1,PSPHI1,DTKIN1,DATH1,DO1,PRO1)
!
!       == MAP BACK ====================================================
        DO IWAVE1=1,NWAVE1
          IWAVE=INDEX(IWAVE1)
          AEPHI(:,:,IWAVE)=AEPHI1(:,:,IWAVE1)
          PSPHI(:,:,IWAVE)=PSPHI1(:,:,IWAVE1)
          PRO(:,IWAVE)=PRO1(:,IWAVE1)
          DO IWAVE1A=1,NWAVE1
            IWAVEA=INDEX(IWAVE1A)
            DTKIN(IWAVE,IWAVEA)=DTKIN1(IWAVE1,IWAVE1A)
            DATH(IWAVE,IWAVEA)=DATH1(IWAVE1,IWAVE1A)
            DO(IWAVE,IWAVEA)=DO1(IWAVE1,IWAVE1A)
          ENDDO
        ENDDO
        DEALLOCATE(INDEX)
        DEALLOCATE(EWAVE1)
        DEALLOCATE(AEPHI1)
        DEALLOCATE(PSPHI1)
        DEALLOCATE(PRO1)
        DEALLOCATE(DATH1)
        DEALLOCATE(DO1)
        DEALLOCATE(DTKIN1)
      ENDDO
      RETURN
      END
!
!     ......................................................PSPHI0......
      SUBROUTINE MKPRO(R1,DEX,NR,RAUG &
     &  ,L,IRMT,AEPOT,PSPOT,NPRO,ELN,AEPHI,PSPHI,DTKIN,DATH,DO,PRO)
!     ******************************************************************
!     **                                                              **
!     **  GIVEN A PAIR OF AE AND PS PARTIALWAVES,                     **
!     **  A NEW SET OF PROJECTOR FUNCTIONS, AE- AND PS-PARTIALWAVES   **
!     **  IS CONSTRUCTED SUCH THAT <PSPHI|PRO>=DELTA                  **
!     **                                                              **
!     **  IT ASSUMES THAT THE SET FOR 1<IPRO<NPRO-1 OBEYES THE RELATION*
!     **                                                              **
!     ******************************************************************
      USE SCHRGL_INTERFACE_MODULE, ONLY : PAWBOUNDSTATE,AEBOUNDSTATE
      IMPLICIT NONE
      LOGICAL(4),PARAMETER    :: TTEST=.TRUE.
      REAL(8),   INTENT(IN)   :: R1
      REAL(8),   INTENT(IN)   :: DEX
      INTEGER(4),INTENT(IN)   :: NR                !
      INTEGER(4),INTENT(IN)   :: L                 !
      INTEGER(4),INTENT(IN)   :: IRMT              ! MAX GRID POINT INSIDE AUGMENTATION REGION
      REAL(8),   INTENT(IN)   :: RAUG
      REAL(8),   INTENT(IN)   :: AEPOT(NR)         !
      REAL(8),   INTENT(IN)   :: PSPOT(NR)         !
      REAL(8),   INTENT(IN)   :: ELN(NPRO)         ! ONE PARTICLE ENERGIES OF AEPHI
      INTEGER(4),INTENT(IN)   :: NPRO              !
      REAL(8),   INTENT(INOUT):: AEPHI(NR,3,NPRO)  !
      REAL(8),   INTENT(INOUT):: PSPHI(NR,3,NPRO)  !
      REAL(8),   INTENT(OUT)  :: PRO(NR,NPRO)      !
      REAL(8),   INTENT(OUT)  :: DTKIN(NPRO,NPRO)
      REAL(8),   INTENT(OUT)  :: DATH(NPRO,NPRO)
      REAL(8),   INTENT(OUT)  :: DO(NPRO,NPRO)
      INTEGER(4)              :: IRAUG
      REAL(8)                 :: R(NR)
      REAL(8)                 :: AUX1(NR)
      REAL(8)                 :: XEXP,RI
      INTEGER(4)              :: IR,N1,N2,N3,I,ITER
      REAL(8)                 :: PI,Y0
      REAL(8)                 :: SVAR,SVAR1,SVAR2
      REAL(8)                 :: DENL
      REAL(8)                 :: SMAT(NPRO,NPRO)
      REAL(8)                 :: PHITEST(NR,3),DLTEST(NPRO),ETEST,DPOT(NR,NPRO)
      INTEGER(4)              :: NFILO
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10,"MAKE PROJECTORS FOR L=",I5," "/72("-"))')L
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI)
!
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
      IRAUG=INT(2.D0+DLOG(RAUG/R1)/DEX)
      IF(TTEST) THEN
        DO N1=1,NPRO
          DLTEST(N1)=R(IRAUG)*PSPHI(IRAUG,2,N1)/PSPHI(IRAUG,1,N1)
          DPOT(:,N1)=-0.5D0*PSPHI(:,3,N1)/PSPHI(:,1,N1)+PSPOT(:)*Y0-ELN(N1)
          DPOT(:,N1)=-DPOT(:,N1)/Y0
          DPOT(IRAUG+1:,N1)=0.D0
        ENDDO
      END IF
!
!     ==================================================================
!     ==  DEFINE NORMALIZATION OF PARTIAL WAVES                       ==
!     ==  SO THAT <AEPHI|THETA|AEPHI>=1                               ==
!     ==================================================================
      DO N1=1,NPRO
        DO IR=1,NR
          AUX1(IR)=(R(IR)*AEPHI(IR,1,N1))**2
        ENDDO
        CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
        SVAR=1.D0/DSQRT(SVAR)
        DO I=1,3
          AEPHI(:,I,N1)=AEPHI(:,I,N1)*SVAR
          PSPHI(:,I,N1)=PSPHI(:,I,N1)*SVAR
        ENDDO
      ENDDO
!
!     ==================================================================
!     ==  CALCULATE DTKIN, DATH AND DO                                ==
!     ==================================================================
      DO N1=1,NPRO
        DO N2=1,NPRO
!
!         ==   DTKIN  ==================================================
          DO IR=1,NR
            AUX1(IR)=R(IR)**2*(AEPHI(IR,1,N1)*AEPHI(IR,3,N2) &
     &                        -PSPHI(IR,1,N1)*PSPHI(IR,3,N2))
          ENDDO
          CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
          DTKIN(N1,N2)=-0.5D0*SVAR
!
!         ==   DATH  ===================================================
          DO IR=1,NR
            AUX1(IR)=R(IR)**2*(AEPHI(IR,1,N1)*AEPOT(IR)*Y0*AEPHI(IR,1,N2) &
     &                        -PSPHI(IR,1,N1)*PSPOT(IR)*Y0*PSPHI(IR,1,N2))
          ENDDO
          CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
          DATH(N1,N2)=DTKIN(N1,N2)+SVAR
!
!         ==   DO    ===================================================
          DO IR=1,NR
            AUX1(IR)=R(IR)**2*(AEPHI(IR,1,N1)*AEPHI(IR,1,N2) &
     &                        -PSPHI(IR,1,N1)*PSPHI(IR,1,N2))
          ENDDO
          CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
          DO(N1,N2)=SVAR
        ENDDO
      ENDDO 
!
!     == SYMMTERIZE  ===================================================
      DO N1=1,NPRO
        DO N2=1,N1-1
          SVAR=0.5D0*(DTKIN(N1,N2)+DTKIN(N2,N1))
          DTKIN(N1,N2)=SVAR
          DTKIN(N2,N1)=SVAR
          SVAR=0.5D0*(DATH(N1,N2)+DATH(N2,N1))
          DATH(N1,N2)=SVAR
          DATH(N2,N1)=SVAR
          SVAR=0.5D0*(DO(N1,N2)+DO(N2,N1))
          DO(N1,N2)=SVAR
          DO(N2,N1)=SVAR
        ENDDO
      ENDDO
!
!     ==================================================================
!     ==  CALCULATE RAW PROJECTORS (UNORTHONORMALIZED)                ==
!     ==================================================================
      DO N1=1,NPRO
        DO IR=1,NR
          PRO(IR,N1)=-0.5D0*PSPHI(IR,3,N1) &
     &               +(PSPOT(IR)*Y0-ELN(N1))*PSPHI(IR,1,N1) 
        ENDDO
        DO IR=IRAUG+1,NR
          PRO(IR,N1)=0.D0
        ENDDO
!
!       == CORRECT IF PROJECTOR ZERO ===================================
        DO IR=1,NR
          AUX1(IR)=R(IR)**2*PRO(IR,N1)*PSPHI(IR,1,N1)
        ENDDO
        CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
        DENL=SVAR
        DO IR=1,NR
          AUX1(IR)=(R(IR)*PSPHI(IR,1,N1))**2
        ENDDO
        CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
        DENL=DENL/SVAR
!
        IF(DABS(DENL).LT.1.D-5) THEN
          DO IR=1,NR
            AUX1(IR)=(R(IR)*PRO(IR,N1))**2
          ENDDO
          CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR2)
          IF(SVAR2.EQ.0.D0) SVAR1=1.D-12
          PRINT*,'WARNING!! PROJECTOR IS ZERO; WILL BE REPLACED' 
          PRINT*,'WARNING!! L=',L,' N=',N1
          PRINT*,'<PRO|PHI>/<PHI|PHI>=',DENL
          PRINT*,'<PRO|PHI>=',SVAR
          PRINT*,'<PHI|PHI>=',SVAR1,' <PRO|PRO>= ',SVAR2
          SVAR=R(IRAUG)/2.D0
          DO IR=1,NR
            PRO(IR,N1)=PSPHI(IR,1,N1)*DEXP(-(R(IR)/SVAR)**6)
          ENDDO
          PRINT*,' PROJECTOR IS REPLACED'
        END IF
      ENDDO
!
!     ==================================================================
!     ==  ORTHONORMALIZE PROJECTORS                                   ==
!     ==================================================================
      DO N1=1,NPRO
        DO N2=1,N1-1        
!
!         == MAKE PARTIAL WAVES ORTHOGONAL TO LOWER PROJECTORS =========
          DO IR=1,NR
            AUX1(IR)=R(IR)**2*PSPHI(IR,1,N1)*PRO(IR,N2)
          ENDDO 
          CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
          DO I=1,3
            DO IR=1,NR
              PSPHI(IR,I,N1)=PSPHI(IR,I,N1)-PSPHI(IR,I,N2)*SVAR
              AEPHI(IR,I,N1)=AEPHI(IR,I,N1)-AEPHI(IR,I,N2)*SVAR
            ENDDO
          ENDDO
!
          SMAT(:,:)  =DATH(:,:)
          SMAT(:,N1) =SMAT(:,N1)-DATH(:,N2)*SVAR
          SMAT(N1,:) =SMAT(N1,:)-SVAR*DATH(N2,:)
          SMAT(N1,N1)=SMAT(N1,N1)+DATH(N2,N2)*SVAR**2
          DATH(:,:)  =SMAT(:,:)
!
          SMAT(:,:)  =DTKIN(:,:)
          SMAT(:,N1) =SMAT(:,N1)-DTKIN(:,N2)*SVAR
          SMAT(N1,:) =SMAT(N1,:)-SVAR*DTKIN(N2,:)
          SMAT(N1,N1)=SMAT(N1,N1)+DTKIN(N2,N2)*SVAR**2
          DTKIN(:,:) =SMAT(:,:)
!
          SMAT(:,:)  =DO(:,:)
          SMAT(:,N1) =SMAT(:,N1)-DO(:,N2)*SVAR
          SMAT(N1,:) =SMAT(N1,:)-SVAR*DO(N2,:)
          SMAT(N1,N1)=SMAT(N1,N1)+DO(N2,N2)*SVAR**2
          DO(:,:)    =SMAT(:,:)
        ENDDO
!
!       == MAKE PROJECTORS ORTHOGONAL TO LOWER PARTIAL WAVES ===========
        DO N2=1,N1-1
          DO IR=1,NR
            AUX1(IR)=R(IR)**2*PSPHI(IR,1,N2)*PRO(IR,N1)
          ENDDO 
          CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
          DO IR=1,NR
            PRO(IR,N1)=PRO(IR,N1)-PRO(IR,N2)*SVAR
          ENDDO
        ENDDO
!
!       == NORMALIZE PROJECTORS ========================================
        DO IR=1,NR
          AUX1(IR)=R(IR)**2*PSPHI(IR,1,N1)*PRO(IR,N1)
        ENDDO
        CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
        SVAR=1.D0/SVAR
        DO IR=1,NR
          PRO(IR,N1)=PRO(IR,N1)*SVAR
        ENDDO
!
!       == RESCALE SO THAT <AEPHI|THETA_MT|AEPHI>=1 ====================
        DO IR=1,NR
          AUX1(IR)=(R(IR)*AEPHI(IR,1,N1))**2
        ENDDO
        CALL RADIAL$INTEGRAL(R1,DEX,IRAUG,AUX1,SVAR)
        SVAR=1.D0/DSQRT(SVAR)
        DO I=1,3
          DO IR=1,NR
            PSPHI(IR,I,N1)=PSPHI(IR,I,N1)*SVAR
            AEPHI(IR,I,N1)=AEPHI(IR,I,N1)*SVAR
          ENDDO
        ENDDO
        DO IR=1,NR
          PRO(IR,N1)=PRO(IR,N1)/SVAR
        ENDDO
        DATH(:,N1) =DATH(:,N1)*SVAR
        DATH(N1,:) =SVAR*DATH(N1,:)
        DTKIN(:,N1)=DTKIN(:,N1)*SVAR
        DTKIN(N1,:)=SVAR*DTKIN(N1,:)
        DO(:,N1)   =DO(:,N1)*SVAR
        DO(N1,:)   =SVAR*DO(N1,:)
      ENDDO
!
!     ==================================================================
!     ==  TEST                                                        ==
!     ==================================================================
      IF(TTEST) THEN
        CALL FILEHANDLER$UNIT('PROT',NFILO)
!       == TEST BIORTHOGONALITY OF PROJECTOR AND PS-PARTIALWAVES =======
        WRITE(NFILO,FMT='("TEST BIORTHOGONALITY FOR L=",I1)')L
        DO N1=1,NPRO
          DO N2=1,NPRO
            CALL RADIAL$INTEGRAL(R1,DEX,NR,R(:)**2*PSPHI(:,1,N1)*PRO(:,N2),SVAR)
            IF(N1.EQ.N2) THEN
              WRITE(NFILO,FMT='("<PSPHI|PRO>(",I2,",",I2,")-1=",E10.2)')N1,N2,SVAR-1.D0
            ELSE
              WRITE(NFILO,FMT='("<PSPHI|PRO>(",I2,",",I2,")  =",E10.2)')N1,N2,SVAR
            END IF
          ENDDO
        ENDDO
!
        WRITE(NFILO,FMT='("TEST TRANSFORMATION OF 1-CENTER MATRICES")')
        WRITE(NFILO,FMT='(T3,"N1 N2  DO",T19,"DO(INTEGR)",T30,"DIFF")')
        DO N1=1,NPRO
          DO N2=1,NPRO
            DO IR=1,NR
              AUX1(IR)=R(IR)**2*(AEPHI(IR,1,N1)*AEPHI(IR,1,N2) &
     &                        -PSPHI(IR,1,N1)*PSPHI(IR,1,N2))
            ENDDO
            CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,SVAR)
            WRITE(NFILO,FMT='("DO ",2I2,2F10.5,E12.3)')N1,N2,DO(N1,N2),SVAR,DO(N1,N2)-SVAR
          ENDDO
        ENDDO
!
        WRITE(NFILO,FMT='("TEST ENERGY FOR L=",I1)')L
        DO N1=1,NPRO
!
          ETEST=ELN(N1)
          WRITE(NFILO,FMT='("BEFORE ELN :",2F10.5)')ETEST,DLTEST(N1)
          DO ITER=1,20
            CALL AEBOUNDSTATE(R1,DEX,NR,L,ETEST,0.D0,R(IRAUG) &
     &                     ,PSPOT(:)+DPOT(:,N1),PHITEST,DLG=DLTEST(N1))
          ENDDO
          WRITE(NFILO,FMT='("PS ELN     :",2F10.5)')ETEST,DLTEST(N1)
          ETEST=ELN(N1)
          DO ITER=1,20
            CALL PAWBOUNDSTATE(R1,DEX,NR,L,ETEST,R(IRAUG) &
     &                   ,PSPOT,NPRO,PRO,DATH,DO,PHITEST,DLG=DLTEST(N1))
          ENDDO
          WRITE(NFILO,FMT='("PAW ELN    :",2F10.5)')ETEST,DLTEST(N1)
!
          DO N2=1,NPRO
            CALL RADIAL$INTEGRAL(R1,DEX,NR,R(:)**2*PHITEST(:,1)*PRO(:,N2),SVAR)
            PRINT*,'<PHI|PRO>',N2,SVAR
          ENDDO
        ENDDO
      END IF
      RETURN 
      END
!
!     ..................................................................
      SUBROUTINE MAKEVHAT
!     ******************************************************************
!     **                                                              **
!     **  CALCULATE THE POTENTIAL OF THE CHARGE DENSITY               **
!     **  AND FROM THAT THE DIFFERENCE VHAT BETWEEN THE PSEUDOPOTENTIAL **
!     **  AND THE EFFECTIVE POTENTIAL FROM THE DENSITY                **
!     **                                                              **
!     ******************************************************************
      USE GRID
      USE AEATOM
      USE PROJECTION
      USE SCHRGL_INTERFACE_MODULE, ONLY : PAWBOUNDSTATE
      IMPLICIT NONE
      INTEGER(4)             :: LMAX           ! MAX ANG. MOMENTUM
      INTEGER(4)             :: L              !ANGULAR MOMENTUM
      INTEGER(4)             :: NWAVE1         ! #(STATES FOR THIS L)
      INTEGER(4),ALLOCATABLE :: INDEX(:)       !(NWAVE1) STATES
      REAL(8)   ,ALLOCATABLE :: PRO1(:,:)      !(NR,NWAVE1)
      REAL(8)                :: PSPSI(NR,3)    !
      REAL(8)   ,ALLOCATABLE :: DO1(:,:)       !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DTKIN1(:,:)    !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DATH1(:,:)     !(NWAVE,NWAVE1)
      REAL(8)                :: RHO(NR)
      REAL(8)                :: QAUG
      REAL(8)                :: SUM
      REAL(8)                :: RI
      INTEGER(4)             :: IWAVE,IWAVE1,IWAVEA,IWAVE1A
      INTEGER(4),PARAMETER   :: IRMT=210
      INTEGER(4)             :: IR,I1,I2,IB,ITER
      INTEGER(4)             :: NPRO
      INTEGER(4)             :: IRAUG
      REAL(8)                :: AUX(NR),SVAR
      REAL(8)                :: R(NR)
      REAL(8)                :: E,EOLD
      REAL(8)                :: PI,Y0,C0LL
      REAL(8)   ,PARAMETER   :: TOL=1.D-8
      LOGICAL(4)             :: CONVG
      REAL(8)                :: POTOFRHO(NR)
      REAL(8)   ,ALLOCATABLE :: PROJ(:)        !(NWAVE1) <PRO|PSI>
      REAL(8)   ,ALLOCATABLE :: DENMAT(:,:)    !(NWAVE1,NWAVE1) 
      INTEGER(4)             :: NFILO
REAL(8)                :: AE1RHO(NR),PS1RHO(NR)
REAL(8)   ,ALLOCATABLE :: AEPHI1(:,:,:),PSPHI1(:,:,:)
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10," MAKE VHAT "/72("-"))')
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI) 
      C0LL=Y0
      IRAUG=1.D0+DLOG(AUGMENTATIONRADIUS/R1)/DEX+1.D0
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
      RHO(:)=0.D0
      CALL RADIAL$INTEGRAL(R1,DEX,NR,(AECORE(:)-PSCORE(:))*R(:)**2,SVAR)
      QAUG=-AEZ+SVAR*4.D0*PI*Y0
      CALL PROJECTION$LMAX(LMAX)
AE1RHO(:)=0.D0
PS1RHO(:)=0.D0
      DO L=0,LMAX
        CALL PROJECTION$NPRO(L,NWAVE1)
        ALLOCATE(PRO1(NR,NWAVE1))
        ALLOCATE(DTKIN1(NWAVE1,NWAVE1))
        ALLOCATE(DO1(NWAVE1,NWAVE1))
        ALLOCATE(DATH1(NWAVE1,NWAVE1))
        ALLOCATE(PROJ(NWAVE1))
        CALL PROJECTION$POT(L,NWAVE1,PROL=PRO1,DOL=DO1,DATHL=DATH1)
!
ALLOCATE(AEPHI1(NR,3,NWAVE1))
ALLOCATE(PSPHI1(NR,3,NWAVE1))
CALL PROJECTION$POT(L,NWAVE1,AEPHIL=AEPHI1,PSPHIL=PSPHI1)

        DO IB=NC+1,NB
          IF(LB(IB).EQ.L) THEN
!
!         ==============================================================
!         ==  FIND PS WAVE FUNCTIONS                                  ==
!         ==============================================================
            E=EB(IB)
            EOLD=E
            ITER=0
            CONVG=.FALSE.
            DO WHILE(.NOT.CONVG)
              ITER=ITER+1
              CALL PAWBOUNDSTATE(R1,DEX,NR,L,E,OUTERBOXRADIUS &
     &                      ,PSPOT,NWAVE1,PRO1,DATH1,DO1,PSPSI)
              CONVG=DABS(EOLD-E).LT.TOL
              EOLD=E
              IF(ITER.GT.50) THEN
                 CALL ERROR$MSG('LOOP NOT CONVERGED')
                 CALL ERROR$STOP('MAKEVHAT')
              END IF
            ENDDO
            WRITE(NFILO,FMT='("ANGULAR MOMENTUM:",I8)')L
            WRITE(NFILO,FMT='("AE -BAND ENERGY :",F20.12)')EB(IB)
            WRITE(NFILO,FMT='("PAW-BAND ENERGY :",F20.12)')E
!
!           ============================================================
!           ==  TEST RENORMALIZATION                                  ==
!           ==  NOT NECCESARY BACAUSE PSPSI IS ALREADY NORMALIZED     ==
!           ============================================================
            AUX(:)=R(:)**2*PSPSI(:,1)**2
            CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX(:),SUM)
            DO I1=1,NWAVE1
              AUX(:)=R(:)**2*PRO1(:,I1)*PSPSI(:,1)
              CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX(:),PROJ(I1))
            ENDDO
            DO I1=1,NWAVE1
              DO I2=1,NWAVE1
                SUM=SUM+PROJ(I1)*DO1(I1,I2)*PROJ(I2)
              ENDDO
            ENDDO
            CALL REPORT$R8VAL(NFILO,"NORM (REMOVE THIS)",SUM,' ')
            SVAR=1.D0/DSQRT(SUM)
            PSPSI(:,:)=PSPSI(:,:)*SVAR
            PROJ(:)=PROJ(:)*SUM
!
!           ============================================================
!           ==  ADD TO DENSITY                                        ==
!           ============================================================
            DO IR=1,NR
              RHO(IR)=RHO(IR)+C0LL*PSPSI(IR,1)**2*FB(IB)
            ENDDO
!
!           ============================================================
!           ==  CALCULATE  <PRO|PSI>                                  ==
!           ============================================================
            DO I1=1,NWAVE1
              AUX(:)=R(:)**2*PRO1(:,I1)*PSPSI(:,1)
              CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX(:),PROJ(I1))
            ENDDO
            WRITE(NFILO,FMT='("PROJECTIONS",2I2,5F10.5)')L,IB,PROJ(:)
            DO I1=1,NWAVE1
              DO I2=1,NWAVE1
                QAUG=QAUG+PROJ(I1)*DO1(I1,I2)*PROJ(I2)*FB(IB)
AE1RHO(:)=AE1RHO(:)+C0LL*AEPHI1(:,1,I1)*AEPHI(:,1,I2)*PROJ(I1)*PROJ(I2)
PS1RHO(:)=PS1RHO(:)+C0LL*PSPHI1(:,1,I1)*PSPHI(:,1,I2)*PROJ(I1)*PROJ(I2)
              ENDDO
            ENDDO
          END IF
        ENDDO
DEALLOCATE(AEPHI1)
DEALLOCATE(PSPHI1)
        DEALLOCATE(PROJ)
        DEALLOCATE(PRO1)
        DEALLOCATE(DATH1)
        DEALLOCATE(DO1)
        DEALLOCATE(DTKIN1)
      ENDDO
!
!     ==================================================================
!     ==  CALCULATE  EFFECTIVE POTENTIAL OF THE PSEUDO DENSITY        ==
!     ==================================================================
      RHO(:)=RHO(:)+PSCORE(:)
PRINT*,'PSRHO IN VHAT ',RHO(1:4)
      CALL VOFRHO(0.D0,R1,DEX,NR,RHO,POTOFRHO)
      DO IR=1,NR
!        POTOFRHO(IR)=POTOFRHO(IR)+QAUG*ERF(R(IR)/RCSMALL)/R(IR)/Y0        
        CALL LIB$ERFR8(R(IR)/RCSMALL,SVAR)
        POTOFRHO(IR)=POTOFRHO(IR)+QAUG*SVAR/R(IR)/Y0        
      ENDDO
!
!     ==================================================================
!     ==  CALCULATE  VHAT                                             ==
!     ==================================================================
      VHAT(:)=PSPOT(:)-POTOFRHO(:)
!
!     ==================================================================
!     == CHECK CHARGE CONSERVATION                                    ==
!     ==================================================================
      AUX(:)=4.D0*PI*Y0*RHO(:)*R(:)**2
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX,SVAR)
      CALL REPORT$R8VAL(NFILO,"TOTAL INTEGRATED DENSITY (SHOULD BE ZERO)",SVAR+QAUG,' ')
      CALL REPORT$R8VAL(NFILO,"ATOMIC NUMBER",AEZ,' ')
      CALL REPORT$R8VAL(NFILO,"CHARGE IN ONE-CENTER DENSITY",QAUG,' ')
      CALL REPORT$R8VAL(NFILO,"CHARGE IN PLANE WAVE PART",SVAR,' ')
!
!     ==================================================================
!     ==  TRUNCATE VHAT OUTSIDE AUGMENTATION RADIUS                   ==
!     ==================================================================
      IRAUG=INT(1.D0+DLOG(AUGMENTATIONRADIUS/R1)/DEX)
      DO IR=150,250,5
!       PRINT*,R(IR),VHAT(IR)*Y0
      ENDDO
      AUX(:)=RHO(:)*VHAT(:)*R(:)**2
      AUX(1:IRAUG)=0.D0
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX,SVAR)      
      CALL REPORT$R8VAL(NFILO,"VHAT SET TO ZERO BEYOND RADIUS",R(IRAUG+1),'A0')
      CALL REPORT$R8VAL(NFILO,"ERROR BY VHAT TRUNCATION",SVAR,'H')
      VHAT(IRAUG+1:NR)=0.D0
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE PWCONVERGENCE
!     ******************************************************************
!     **                                                              **
!     **  ANALYZES THE PLANE WAVE CONVERGENCE OF THE TOTAL ENERGY     **
!     **  AND PREPARE THE G-MOMENTS REQUIRED FOR MASS RENORMALIZATION **
!     **                                                              **
!     ******************************************************************
      USE GRID
      USE AEATOM
      USE PROJECTION
      USE SCHRGL_INTERFACE_MODULE, ONLY : PAWBOUNDSTATE
      IMPLICIT NONE
      INTEGER(4)             :: LMAX           ! MAX ANG. MOMENTUM
      INTEGER(4)             :: L              !ANGULAR MOMENTUM
      INTEGER(4)             :: NWAVE1         ! #(STATES FOR THIS L)
      INTEGER(4),ALLOCATABLE :: INDEX(:)       !(NWAVE1) STATES
      REAL(8)   ,ALLOCATABLE :: PRO1(:,:)      !(NR,NWAVE1)
      REAL(8)                :: PSPSI(NR,3)    !
      REAL(8)   ,ALLOCATABLE :: DO1(:,:)       !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DTKIN1(:,:)    !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DATH1(:,:)     !(NWAVE,NWAVE1)
      REAL(8)                :: RHO(NR)
      REAL(8)                :: QAUG
      REAL(8)                :: RI
      INTEGER(4)             :: IWAVE,IWAVE1,IWAVEA,IWAVE1A
      INTEGER(4),PARAMETER   :: IRMT=210
      INTEGER(4),PARAMETER   :: NG=256
      INTEGER(4)             :: IR,I1,I2,IB,ITER,IG,J1,J2
      INTEGER(4)             :: NPRO
      INTEGER(4)             :: IRAUG
      REAL(8)                :: AUX(NR),SVAR
      REAL(8)                :: R(NR)
      REAL(8)                :: E,EOLD
      REAL(8)                :: PI,Y0,C0LL
      REAL(8)   ,PARAMETER   :: TOL=1.D-8
      LOGICAL(4)             :: CONVG
      REAL(8)                :: POTOFRHO(NR)
      REAL(8)   ,ALLOCATABLE :: PROJ(:)        !(NWAVE1) <PRO|PSI>
      REAL(8)                :: PSIG(NG),PSIR(NG)
      REAL(8)                :: GI,G1,DISC
      REAL(8)                :: GMOMENT(NG,3)
      REAL(8)                :: GMOMENTSUM(NG,3),WORK(NG)
      REAL(8)                :: EKING,EKINR,NORMR,NORMG
      REAL(8)                :: PSRHOG(NR,NG)
      REAL(8)                :: DENMAT(NWAVE,NWAVE,NG)
      REAL(8)                :: PSEKING(NG) 
      REAL(8)                :: RY
      INTEGER(4)             :: NFILO
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10," TEST PLANE WAVE CONVERGENCE"/72("-"))')
      CALL CONSTANTS$GET('RY',RY)
!
!     ==================================================================
!     ==  PREPARE SOME COMMON CONSTANTS                               ==
!     ==================================================================
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI) 
      C0LL=Y0
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
      CALL BESSELTRANSFORM$CLEAR
!
!     ==================================================================
!     ==  RESET DATA BEFORE LOOP                                      ==
!     ==================================================================
      RHO(:)=0.D0
      GMOMENTSUM(:,:)=0.D0
      PSEKING(:)=0.D0
      PSRHOG(:,:)=0.D0
      DENMAT(:,:,:)=0.D0
!
!     ==================================================================
!     ==  NOW SUM OVER ALL VALENCE STATES                             ==
!     ==================================================================
      CALL PROJECTION$LMAX(LMAX)
      DO L=0,LMAX
        CALL PROJECTION$NPRO(L,NWAVE1)
        ALLOCATE(PRO1(NR,NWAVE1))
        ALLOCATE(DTKIN1(NWAVE1,NWAVE1))
        ALLOCATE(DO1(NWAVE1,NWAVE1))
        ALLOCATE(DATH1(NWAVE1,NWAVE1))
        ALLOCATE(PROJ(NWAVE1))
        CALL PROJECTION$POT(L,NWAVE1,PROL=PRO1,DOL=DO1,DATHL=DATH1)
        DO IB=NC+1,NB
          IF(LB(IB).NE.L) CYCLE
!
!         ==============================================================
!         ==  FIND PS WAVE FUNCTIONS                                  ==
!         ==============================================================
          E=EB(IB)
          EOLD=E
          ITER=0
          CONVG=.FALSE.
          DO WHILE(.NOT.CONVG)
            ITER=ITER+1
            CALL PAWBOUNDSTATE(R1,DEX,NR,L,E,OUTERBOXRADIUS &
     &                    ,PSPOT,NWAVE1,PRO1,DATH1,DO1,PSPSI)
            CONVG=DABS(EOLD-E).LT.TOL
            EOLD=E
            IF(ITER.GT.50) THEN
               CALL ERROR$MSG('LOOP NOT CONVERGED')
               CALL ERROR$STOP('MAKEVHAT')
            END IF
          ENDDO
          WRITE(NFILO,FMT='("ANGULAR MOMENTUM:",I8)')L
          WRITE(NFILO,FMT='("AE -BAND ENERGY :",F20.12)')EB(IB)
          WRITE(NFILO,FMT='("PAW-BAND ENERGY :",F20.12)')E
!         
!         ============================================================
!         ==  BESSELTRANSFORM                                       ==
!         ============================================================
          PSIR(:)=0.D0
          PSIR(1:NR)=PSPSI(:,1)
          G1=SQRT(200.D0)/DEXP(NG*DEX)
          CALL BESSELTRANSFORM(L,NG,R1,G1,DEX,PSIR,PSIG,DISC)
          PSIG(:)=PSIG(:)*SQRT(2.D0/PI)
!         
!         ==  G-MOMENTS FOR KINETIC ENERGY AND MASS RENORMALIZATION  ==
          GI=G1/XEXP
          DO IG=1,NG
            GI=GI*XEXP
            GMOMENT(IG,1)=PSIG(IG)**2*GI**2
            GMOMENT(IG,2)=PSIG(IG)**2*GI**4
            GMOMENT(IG,3)=PSIG(IG)**2*GI**6
          ENDDO
          WORK(:)=GMOMENT(:,1)
          CALL RADIAL$INTEGRATE(G1,DEX,NG,WORK,GMOMENT(:,1))
          WORK(:)=GMOMENT(:,2)
          CALL RADIAL$INTEGRATE(G1,DEX,NG,WORK,GMOMENT(:,2))
          WORK(:)=GMOMENT(:,3)
          CALL RADIAL$INTEGRATE(G1,DEX,NG,WORK,GMOMENT(:,3))
          GMOMENTSUM(:,:)=GMOMENTSUM(:,:)+GMOMENT(:,:)*FB(IB)
!         
!         ============================================================
!         ==  ENFORCE DIFFERENT PLANE WAVE CUTOFFS                  ==
!         ============================================================
          DO IG=NG,1,-1
!         
!           ==========================================================
!           ==  BACKTRANSFORM                                       ==
!           ==========================================================
            CALL BESSELTRANSFORM(L,NG,G1,R1,DEX,PSIG,PSIR,DISC)
            PSIR(:)=PSIR(:)*SQRT(2.D0/PI)
!
!           ==========================================================
!           ==  CALCULATE PROJECTIONS                               ==
!           ==========================================================
            DO I1=1,NWAVE1
              CALL RADIAL$INTEGRAL(R1,DEX,NR,R(:)**2*PRO1(:,I1)*PSIR(1:NR),PROJ(I1))
            ENDDO
!
!           ==========================================================
!           ==  RENORMALIZE WAVE FUNCTION                           ==
!           ==========================================================
            CALL RADIAL$INTEGRAL(R1,DEX,NR,(R(:)*PSIR(1:NR))**2,SVAR)
            DO I1=1,NWAVE1
              DO I2=1,NWAVE1
                SVAR=SVAR+PROJ(I1)*DO1(I1,I2)*PROJ(I2)
              ENDDO
            ENDDO
            SVAR=1.D0/DSQRT(SVAR)
            PSIR(:)=PSIR(:)*SVAR
            PROJ(:)=PROJ(:)*SVAR
!
!           ==========================================================
!           ==  ADD UP PSEUDO DENSITY                               ==
!           ==========================================================
!           == CALCULATE PSEUDODENSITY ===============================
            PSRHOG(:,IG)=PSRHOG(:,IG)+C0LL*PSIR(1:NR)**2*FB(IB)
!
!           == CALCULATE PSEUDO KINETIC ENERGY =======================
            PSEKING(IG)=PSEKING(IG)+0.5D0*GMOMENT(IG,2)*SVAR**2*FB(IB)
!
!           == CALCULATE DENSITY MATRIX ==============================
            I2=0
            DO I1=1,NWAVE
              IF(LPHI(I1).NE.L) CYCLE
              I2=I2+1
              J2=0
              DO J1=1,NWAVE
                IF(LPHI(J1).NE.L) CYCLE
                J2=J2+1
                DENMAT(I1,J1,IG)=DENMAT(I1,J1,IG)+PROJ(I2)*PROJ(J2)*FB(IB)
              ENDDO
            ENDDO
!
!           ==========================================================
!           ==  NOW REDUCE PLANE WAVE CUTOFF                        ==
!           ==========================================================
            PSIG(IG)=0.D0
          ENDDO
        ENDDO
        DEALLOCATE(PROJ)
        DEALLOCATE(PRO1)
        DEALLOCATE(DATH1)
        DEALLOCATE(DO1)
        DEALLOCATE(DTKIN1)
      ENDDO
!
!     ==================================================================
!     ==  CALCULATE  EFFECTIVE POTENTIAL OF THE PSEUDO DENSITY        ==
!     ==================================================================
      WRITE(NFILO,FMT='("FACTORS FOR EFFECTIVE MASS RENORMALIZATION:")')
      WRITE(NFILO,FMT='("SUM:F*<PS-PSI|PS-PSI>      ",F10.5)')GMOMENTSUM(NG,1)
      WRITE(NFILO,FMT='("SUM:F*<PS-PSI|G**2|PS-PSI> ",F10.5)')GMOMENTSUM(NG,2)
      WRITE(NFILO,FMT='("SUM:F*<PS-PSI|G**4|PS-PSI> ",F10.5)')GMOMENTSUM(NG,3)
      WRITE(NFILO,FMT='("WRITE ENERGIES:")')
       WRITE(NFILO,FMT='(A10,A20,A10,A10,A10,A10,A10)')"EPW[RY]","ETOT"," EKIN "," EC " &
      &     ," EXC "," 1-CENTER "," PW "
      GI=G1/XEXP
      DO IG=1,NG
         GI=GI*XEXP
         IF(GI**2.LT.10.D0.OR.GI**2.GT.250.D0) CYCLE
         CALL PAWETOT(0.5D0*GI**2/RY,PSRHOG(1,IG),DENMAT(1,1,IG),PSEKING(IG))
      ENDDO
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE MAKEVHATX
!     **                                                              **
      USE GRID
      USE AEATOM
      USE PROJECTION
      USE SCHRGL_INTERFACE_MODULE, ONLY : PAWBOUNDSTATE
      IMPLICIT NONE
      INTEGER(4)             :: LMAX           ! MAX ANG. MOMENTUM
      INTEGER(4)             :: L              !ANGULAR MOMENTUM
      INTEGER(4)             :: NWAVE1         ! #(STATES FOR THIS L)
      INTEGER(4),ALLOCATABLE :: INDEX(:)       !(NWAVE1) STATES
      REAL(8)   ,ALLOCATABLE :: PRO1(:,:)      !(NR,NWAVE1)
      REAL(8)                :: PSPSI(NR,3)    !
      REAL(8)   ,ALLOCATABLE :: DO1(:,:)       !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DTKIN1(:,:)    !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DATH1(:,:)     !(NWAVE,NWAVE1)
      REAL(8)                :: RHO(NR)
      REAL(8)                :: QAUG
      REAL(8)                :: RI
      INTEGER(4)             :: IWAVE,IWAVE1,IWAVEA,IWAVE1A
      INTEGER(4),PARAMETER   :: IRMT=210
      INTEGER(4)             :: IR,I1,I2,IB,ITER
      INTEGER(4)             :: NPRO
      INTEGER(4)             :: IRAUG
      REAL(8)                :: AUX(NR),SVAR
      REAL(8)                :: R(NR)
      REAL(8)                :: E,EOLD
      REAL(8)                :: PI,Y0,C0LL
      REAL(8)   ,PARAMETER   :: TOL=1.D-8
      LOGICAL(4)             :: CONVG
      REAL(8)                :: POTOFRHO(NR)
      REAL(8)   ,ALLOCATABLE :: PROJ(:)        !(NWAVE1) <PRO|PSI>
      REAL(8)   ,ALLOCATABLE :: DENMAT(:,:)    !(NWAVE1,NWAVE1) 
      INTEGER(4)             :: NFILO
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10," MAKEVHAT "/72("-"))')
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI) 
      C0LL=Y0
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
      RHO(:)=0.D0
      CALL RADIAL$INTEGRAL(R1,DEX,NR,(AECORE(:)-PSCORE(:))*R(:)**2,SVAR)
      QAUG=-AEZ+SVAR*4.D0*PI*Y0
PRINT*,'QAUG ',QAUG,AEZ,SVAR*4.D0*PI*Y0
      CALL PROJECTION$LMAX(LMAX)
      DO L=0,LMAX
        CALL PROJECTION$NPRO(L,NWAVE1)
        ALLOCATE(PRO1(NR,NWAVE1))
        ALLOCATE(DTKIN1(NWAVE1,NWAVE1))
        ALLOCATE(DO1(NWAVE1,NWAVE1))
        ALLOCATE(DATH1(NWAVE1,NWAVE1))
        ALLOCATE(PROJ(NWAVE1))
        CALL PROJECTION$POT(L,NWAVE1,PROL=PRO1,DOL=DO1,DATHL=DATH1)
        DO IB=NC+1,NB
          IF(LB(IB).EQ.L) THEN
!
!         ==============================================================
!         ==  FIND PS WAVE FUNCTIONS                                  ==
!         ==============================================================
            E=EB(IB)
            EOLD=E
            ITER=0
            CONVG=.FALSE.
            DO WHILE(.NOT.CONVG)
              ITER=ITER+1
              CALL PAWBOUNDSTATE(R1,DEX,NR,L,E,OUTERBOXRADIUS &
     &                      ,PSPOT,NWAVE1,PRO1,DATH1,DO1,PSPSI)
              CONVG=DABS(EOLD-E).LT.TOL
              EOLD=E
              IF(ITER.GT.50) THEN
                 CALL ERROR$MSG('LOOP NOT CONVERGED')
                 CALL ERROR$STOP('MAKEVHAT')
              END IF
            ENDDO
            WRITE(NFILO,FMT='("ANGULAR MOMENTUM:",I8)')L
            WRITE(NFILO,FMT='("AE -BAND ENERGY :",F20.12)')EB(IB)
            WRITE(NFILO,FMT='("PAW-BAND ENERGY :",F20.12)')E
!
!           ============================================================
!           ==  ADD TO DENSITY                                        ==
!           ============================================================
            DO IR=1,NR
              RHO(IR)=RHO(IR)+C0LL*PSPSI(IR,1)**2*FB(IB)
            ENDDO
!
!           ============================================================
!           ==  CALCULATE  <PRO|PSI>                                  ==
!           ============================================================
            DO I1=1,NWAVE1
              CALL RADIAL$INTEGRAL(R1,DEX,NR,R(:)**2*PRO1(:,I1)*PSPSI(:,1),PROJ(I1))
            ENDDO
            DO I1=1,NWAVE1
              DO I2=1,NWAVE1
                QAUG=QAUG+PROJ(I1)*DO1(I1,I2)*PROJ(I2)*FB(IB)
              ENDDO
            ENDDO
          END IF
        ENDDO
        DEALLOCATE(PROJ)
        DEALLOCATE(PRO1)
        DEALLOCATE(DATH1)
        DEALLOCATE(DO1)
        DEALLOCATE(DTKIN1)
      ENDDO
!
!     ==================================================================
!     ==  CALCULATE  EFFECTIVE POTENTIAL OF THE PSEUDO DENSITY        ==
!     ==================================================================
      RHO(:)=RHO(:)+PSCORE(:)
      CALL VOFRHO(0.D0,R1,DEX,NR,RHO,POTOFRHO)
      DO IR=1,NR
!        POTOFRHO(IR)=POTOFRHO(IR)+QAUG*ERF(R(IR)/RCSMALL)/R(IR)/Y0        
        CALL LIB$ERFR8(R(IR)/RCSMALL,SVAR)
        POTOFRHO(IR)=POTOFRHO(IR)+QAUG*SVAR/R(IR)/Y0        
      ENDDO
!
!     == CHECK CHARGE CONSERVATION ======================================
      CALL RADIAL$INTEGRAL(R1,DEX,NR,4.D0*PI*Y0*RHO(:)*R(:)**2,SVAR)
      WRITE(NFILO,*)'SUM OF ELECTRONS',SVAR+QAUG,SVAR,QAUG
!
!     ==================================================================
!     ==  CALCULATE  VHAT                                             ==
!     ==================================================================
      VHAT(:)=PSPOT(:)-POTOFRHO(:)
!
!     ==================================================================
!     ==  TRUNCATE VHAT OUTSIDE AUGMENTATION RADIUS                   ==
!     ==================================================================
      IRAUG=INT(2.D0+DLOG(AUGMENTATIONRADIUS/R1)/DEX)
      DO IR=150,250,5
!       PRINT*,R(IR),VHAT(IR)*Y0
      ENDDO
      AUX(:)=RHO(:)*VHAT(:)*R(:)**2
      AUX(1:IRAUG)=0.D0
!      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX,SVAR)
PRINT*,'WARNING! CODE FUDGED'
      WRITE(NFILO,FMT='("ERROR BY VHAT TRUNCATION:",E20.10,"H")')SVAR
      VHAT(IRAUG:NR)=0.D0
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE WRITEPOTENTIALS
!     ******************************************************************
!     **                                                              **
!     **                                                              **
!     ******************************************************************
      USE GRID
      USE AEATOM
      USE PROJECTION
      IMPLICIT NONE
      INTEGER(4)             :: NFILO
      REAL(8)                :: RI
      INTEGER(4)             :: IR
      REAL(8)                :: PI,Y0
      REAL(8)                :: AEPOT1,PSPOT1,AECORE1,PSCORE1,VHAT1
!     ******************************************************************
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI)
!
!     ==================================================================
!     ==  WRITE POTENTIALS                                            ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(A7,5A10)')'R','AEPOT','PSPOT','VHAT','AECORE','PSCORE'
      DO IR=1,30
        RI=REAL(IR,KIND=8)*0.1D0
        CALL RADIAL$VALUE(R1,DEX,NR,AEPOT,RI,AEPOT1)
        CALL RADIAL$VALUE(R1,DEX,NR,PSPOT,RI,PSPOT1)
        CALL RADIAL$VALUE(R1,DEX,NR,VHAT,RI,VHAT1)
        CALL RADIAL$VALUE(R1,DEX,NR,AECORE,RI,AECORE1)
        CALL RADIAL$VALUE(R1,DEX,NR,PSCORE,RI,PSCORE1)
        AEPOT1=AEPOT1*Y0
        PSPOT1=PSPOT1*Y0
        AECORE1=AECORE1*Y0
        PSCORE1=PSCORE1*Y0
        VHAT1=VHAT1*Y0
        WRITE(NFILO,FMT='(F7.4,5F10.5)')RI,AEPOT1,PSPOT1,VHAT1,AECORE1,PSCORE1
      ENDDO
      RETURN            
      END SUBROUTINE WRITEPOTENTIALS
!
!     ..................................................................
      SUBROUTINE WRITEGRAPHICS
!     ******************************************************************
!     **                                                              **
!     **  REPORTS THE TOTAL ENERGY USEING THE PAW EXPRESSION          **
!     **  FOR A GIVEN PSEUDO DENSITY, DENSITY MATRIX, AND PSEUDO      **
!     **  KINETIC ENERGY                                              **
!     **                                                              **
!     ******************************************************************
      USE GRID
      USE AEATOM
      USE PROJECTION
      IMPLICIT NONE
      REAL(8)                :: R(NR)
      REAL(8)                :: RI
      INTEGER(4)             :: NFIL
      INTEGER(4)             :: IWAVE,IR
      REAL(8)                :: PI,Y0
      REAL(8)   ,ALLOCATABLE :: AEPHI1(:,:,:)
      REAL(8)   ,ALLOCATABLE :: PSPHI1(:,:,:)
      REAL(8)   ,ALLOCATABLE :: PRO1(:,:)
      INTEGER(4)             :: NPRO,IPRO
      INTEGER(4)             :: L
!     ******************************************************************
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI)
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
!
!     ==================================================================
!     ==  WRITE PROJECTOR FUNCTIONS                                   ==
!     ==================================================================
      DO L=0,3
        CALL PROJECTION$NPRO(L,NPRO)
        IF(NPRO.EQ.0) CYCLE
        ALLOCATE(PRO1(NR,NPRO))
        CALL PROJECTION$POT(L,NPRO,PROL=PRO1)
        IF(L.EQ.0) THEN
          CALL FILEHANDLER$UNIT('PRO_S',NFIL)
        ELSE IF(L.EQ.1) THEN
          CALL FILEHANDLER$UNIT('PRO_P',NFIL)
        ELSE IF(L.EQ.2) THEN
          CALL FILEHANDLER$UNIT('PRO_D',NFIL)
        ELSE IF(L.EQ.3) THEN
          CALL FILEHANDLER$UNIT('PRO_F',NFIL)
        ELSE
          CALL ERROR$MSG('L>3 NOT IMPLEMENTED')
          CALL ERROR$STOP('WRITEGRAPHICS')
        END IF 
        REWIND NFIL
        DO IR=1,NR
          WRITE(NFIL,*)R(IR),PRO1(IR,:)
        ENDDO
        DEALLOCATE(PRO1)
      ENDDO
!
!     ==================================================================
!     ==  WRITE POTENTIALS                                            ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('POT',NFIL)
      REWIND NFIL
      DO IR=1,NR
        WRITE(NFIL,*)R(IR),AEPOT(IR),PSPOT(IR),VHAT(IR)
      ENDDO
      CALL FILEHANDLER$CLOSE('POT')
!
!     ==================================================================
!     ==  WRITE PARTIAL WAVES                                         ==
!     ==================================================================
      DO L=0,3
        CALL PROJECTION$NPRO(L,NPRO)
        IF(NPRO.EQ.0) CYCLE
        ALLOCATE(AEPHI1(NR,3,NPRO))
        ALLOCATE(PSPHI1(NR,3,NPRO))
        CALL PROJECTION$POT(L,NPRO,AEPHIL=AEPHI1,PSPHIL=PSPHI1)
        IF(L.EQ.0) THEN
          CALL FILEHANDLER$UNIT('PHI_S',NFIL)
        ELSE IF(L.EQ.1) THEN
          CALL FILEHANDLER$UNIT('PHI_P',NFIL)
        ELSE IF(L.EQ.2) THEN
          CALL FILEHANDLER$UNIT('PHI_D',NFIL)
        ELSE IF(L.EQ.3) THEN
          CALL FILEHANDLER$UNIT('PHI_F',NFIL)
        ELSE
          CALL ERROR$MSG('L>3 NOT IMPLEMENTED')
          CALL ERROR$STOP('WRITEGRAPHICS')
        END IF 
        REWIND NFIL
        DO IR=1,NR
          WRITE(NFIL,*)R(IR),(AEPHI1(IR,1,IPRO),PSPHI1(IR,1,IPRO),IPRO=1,NPRO)
        ENDDO
        DEALLOCATE(AEPHI1)
        DEALLOCATE(PSPHI1)
      END DO
      RETURN            
      END SUBROUTINE WRITEGRAPHICS
!
!     ..................................................................
      SUBROUTINE PAWETOT(X,PSRHO,DENMAT,PSEKIN) 
!     ******************************************************************
!     **                                                              **
!     **  REPORTS THE TOTAL ENERGY USEING THE PAW EXPRESSION          **
!     **  FOR A GIVEN PSEUDO DENSITY, DENSITY MATRIX, AND PSEUDO      **
!     **  KINETIC ENERGY                                              **
!     **                                                              **
!     ******************************************************************
      USE GRID
      USE AEATOM
      USE PROJECTION
      IMPLICIT NONE
      REAL(8),INTENT(IN)  :: PSEKIN
      REAL(8),INTENT(IN)  :: PSRHO(NR)
      REAL(8),INTENT(IN)  :: DENMAT(NWAVE,NWAVE)
      REAL(8),INTENT(IN)  :: X ! PARAMETER USED OONLY FOR PRINTOUT
      REAL(8)             :: R(NR)
      REAL(8)             :: RHO(NR)
      REAL(8)             :: GRHO(NR)
      REAL(8)             :: QLM
      REAL(8)             :: Y0,PI,C0LL,FOURPI
      REAL(8)             :: AUX1(NR)
      REAL(8)             :: POT(NR)
      REAL(8)             :: GRHO2,EXC
      REAL(8)             :: PSEXC,PS1EXC,AE1EXC,AEEXC
      REAL(8)             :: PSEEL,PS1EEL,AE1EEL,AEEEL
      REAL(8)             :: DEKIN,AEEKIN
      REAL(8)             :: DUMMY1,DUMMY2,DUMMY3,DUMMY4,DUMMY5
      INTEGER(4)          :: IW1,IW2,IR
      REAL(8)             :: RI
      INTEGER(4)          :: NFILO,NFIL
      REAL(8)             :: SVAR
!     ******************************************************************
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/SQRT(4.D0*PI)
      C0LL=Y0
      FOURPI=4.D0*PI
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      CALL FILEHANDLER$UNIT('EPWCONV',NFIL)
!
!     ==================================================================
!     == CALCULATE ELECTROSTATIC MULTIPOLE MOMENT                     ==
!     ==================================================================
      RHO(:)=0.D0
      DO IW1=1,NWAVE
        DO IW2=1,NWAVE
          IF(LPHI(IW1).NE.LPHI(IW2)) CYCLE
          RHO(:)=RHO(:)+C0LL*(AEPHI(:,1,IW1)*AEPHI(:,1,IW2) &
     &                       -PSPHI(:,1,IW1)*PSPHI(:,1,IW2))*DENMAT(IW1,IW2)
        ENDDO
      ENDDO
      RHO(:)=RHO(:)+AECORE(:)-PSCORE(:)
      CALL RADIAL$MOMENT(R1,DEX,NR,0,RHO(:),QLM)
      QLM=QLM-AEZ*Y0
!
!     ==================================================================
!     == CALCULATE PSEUDO ENERGIES
!     ==================================================================
      RHO(:)=PSRHO(:)+PSCORE(:)
!      
!     == XC ENERGY
      CALL RADIAL$DERIVE(R1,DEX,NR,RHO,GRHO)
      DO IR=1,NR
        GRHO2=(Y0*GRHO(IR))**2
        CALL DFT(RHO(IR)*Y0,0.D0,GRHO2,0.D0,0.D0,EXC,DUMMY1,DUMMY2,DUMMY3,DUMMY4,DUMMY5)
        AUX1(IR)=EXC*FOURPI*R(IR)**2
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,PSEXC)
!
!     == ELECTROSTATIC ENERGY
      CALL GAUSSN(0,1.D0/RCSMALL**2,SVAR)
      DO IR=1,NR
        RHO(IR)=RHO(IR)+QLM*SVAR*DEXP(-(R(IR)/RCSMALL)**2)
      ENDDO
      CALL RADIAL$POISSON(R1,DEX,NR,0,RHO,POT)
      AUX1(:)=0.5D0*RHO(:)*POT(:)*R(:)**2
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,PSEEL)
!
!     == ENERGY VHAT ===
      CALL RADIAL$INTEGRAL(R1,DEX,NR,VHAT(:)*RHO(:)*R(:)**2,SVAR)
      PSEEL=PSEEL+SVAR
!
!     ==================================================================
!     == CALCULATE ONE-CENTER PSEUDO ENERGIES
!     ==================================================================
      RHO(:)=0.D0
      DO IW1=1,NWAVE
        DO IW2=1,NWAVE
          IF(LPHI(IW1).NE.LPHI(IW2)) CYCLE
          RHO(:)=RHO(:)+C0LL*PSPHI(:,1,IW1)*PSPHI(:,1,IW2)*DENMAT(IW1,IW2)
        ENDDO
      ENDDO
      RHO(:)=RHO(:)+PSCORE(:)
!     == XC ENERGY
      CALL RADIAL$DERIVE(R1,DEX,NR,RHO,GRHO)
      DO IR=1,NR
        GRHO2=(Y0*GRHO(IR))**2
        CALL DFT(RHO(IR)*Y0,0.D0,GRHO2,0.D0,0.D0,EXC,DUMMY1,DUMMY2,DUMMY3,DUMMY4,DUMMY5)
        AUX1(IR)=EXC*FOURPI*R(IR)**2
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,PS1EXC)
!     == ELECTROSTATIC ENERGY
      CALL GAUSSN(0,1.D0/RCSMALL**2,SVAR)
      DO IR=1,NR
        RHO(IR)=RHO(IR)+QLM*SVAR*DEXP(-(R(IR)/RCSMALL)**2)
      ENDDO
      CALL RADIAL$POISSON(R1,DEX,NR,0,RHO,POT)
      AUX1(:)=0.5D0*RHO(:)*POT(:)*R(:)**2
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,PS1EEL)
!     == ENERGY VHAT ===
      CALL RADIAL$INTEGRAL(R1,DEX,NR,VHAT(:)*RHO(:)*R(:)**2,SVAR)
      PS1EEL=PS1EEL+SVAR
!
!     ==================================================================
!     == CALCULATE ONE-CENTER ALL-ELECTRON ENERGIES
!     ==================================================================
      RHO(:)=0.D0
      DO IW1=1,NWAVE
        DO IW2=1,NWAVE
          IF(LPHI(IW1).NE.LPHI(IW2)) CYCLE
          RHO(:)=RHO(:)+C0LL*AEPHI(:,1,IW1)*AEPHI(:,1,IW2)*DENMAT(IW1,IW2)
        ENDDO
      ENDDO
      RHO(:)=RHO(:)+AECORE(:)
!     == XC ENERGY
      CALL RADIAL$DERIVE(R1,DEX,NR,RHO,GRHO)
      DO IR=1,NR
        GRHO2=(Y0*GRHO(IR))**2
        CALL DFT(RHO(IR)*Y0,0.D0,GRHO2,0.D0,0.D0,EXC,DUMMY1,DUMMY2,DUMMY3,DUMMY4,DUMMY5)
        AUX1(IR)=EXC*FOURPI*R(IR)**2
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,AE1EXC)
!     == ELECTROSTATIC ENERGY
      CALL RADIAL$POISSON(R1,DEX,NR,0,RHO,POT)
      AUX1(:)=RHO(:)*(0.5D0*POT(:)*R(:)**2-AEZ/Y0*R(:))
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,AE1EEL)
!     == SUBSTRACT CORE ENERGIES 
      CALL RADIAL$DERIVE(R1,DEX,NR,AECORE,GRHO)
      DO IR=1,NR
        GRHO2=(Y0*GRHO(IR))**2
        CALL DFT(AECORE(IR)*Y0,0.D0,GRHO2,0.D0,0.D0,EXC,DUMMY1,DUMMY2,DUMMY3,DUMMY4,DUMMY5)
        AUX1(IR)=EXC*FOURPI*R(IR)**2
      ENDDO
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,SVAR)
      AE1EXC=AE1EXC-SVAR
!
      CALL RADIAL$POISSON(R1,DEX,NR,0,AECORE,POT)
      AUX1(:)=AECORE(:)*(0.5D0*POT(:)*R(:)**2-AEZ/Y0*R(:))
      CALL RADIAL$INTEGRAL(R1,DEX,NR,AUX1,SVAR)
      AE1EEL=AE1EEL-SVAR
!
!     ==================================================================
!     == KINETIC ENERGY                            
!     ==================================================================
      DEKIN=0.D0
      DO IW1=1,NWAVE
        DO IW2=1,NWAVE
          IF(LPHI(IW1).NE.LPHI(IW2)) CYCLE
          DEKIN=DEKIN+DTKIN(IW1,IW2)*DENMAT(IW1,IW2)
        ENDDO
      ENDDO
!
!     ==================================================================
!     == WRITE ENERGIES                            
!     ==================================================================
      AEEXC=PSEXC-PS1EXC+AE1EXC
      AEEEL=PSEEL-PS1EEL+AE1EEL
      AEEKIN=PSEKIN+DEKIN
!      WRITE(NFILO,FMT='("EPW[RY]","ETOT",F20.5," EKIN ",F10.5," EC ",F10.5 &
!     &     ," EXC ",F10.5," 1-CENTER ",F10.5," PW ",F10.5)') &
      WRITE(NFILO,FMT='(F10.5,F20.5,F10.5,F10.5,F10.5,F10.5,F10.5)') &
     &                X,AEEKIN+AEEXC+AEEEL,AEEKIN,AEEEL,AEEXC &
     &               ,DEKIN+AE1EEL-PS1EEL+AE1EXC-PS1EXC,PSEXC+PSEEL+PSEKIN
      WRITE(NFIL,FMT='(F10.5,F20.5,F10.5,F10.5,F10.5,F10.5,F10.5)') &
     &                X,AEEKIN+AEEXC+AEEEL,AEEKIN,AEEEL,AEEXC &
     &               ,DEKIN+AE1EEL-PS1EEL+AE1EXC-PS1EXC,PSEXC+PSEEL+PSEKIN
      RETURN            
      END SUBROUTINE PAWETOT
!
!     ..................................................................
      SUBROUTINE PAWATOM
!     **                                                              **
      USE GRID
      USE AEATOM
      USE PROJECTION
      USE SCHRGL_INTERFACE_MODULE, ONLY : PAWBOUNDSTATE
      IMPLICIT NONE
      INTEGER(4)             :: LMAX           ! MAX ANG. MOMENTUM
      INTEGER(4)             :: L              !ANGULAR MOMENTUM
      INTEGER(4)             :: NWAVE1         ! #(STATES FOR THIS L)
      INTEGER(4),ALLOCATABLE :: INDEX(:)       !(NWAVE1) STATES
      REAL(8)   ,ALLOCATABLE :: PRO1(:,:)      !(NR,NWAVE1)
      REAL(8)                :: PSPSI(NR,3)    !
      REAL(8)   ,ALLOCATABLE :: DO1(:,:)       !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DTKIN1(:,:)    !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DATH1(:,:)     !(NWAVE,NWAVE1)
      REAL(8)                :: PSPOT1(NR)
      INTEGER(4)             :: NFILO
      REAL(8)                :: RHO(NR)
      REAL(8)                :: QAUG
      REAL(8)                :: RI
      INTEGER(4)             :: IWAVE,IWAVE1,IWAVEA,IWAVE1A
      INTEGER(4),PARAMETER   :: IRMT=210
      INTEGER(4)             :: IR,I1,I2,IB,ITER
      INTEGER(4)             :: NPRO
      INTEGER(4)             :: IRAUG
      REAL(8)                :: AUX(NR),SVAR
      REAL(8)                :: R(NR)
      REAL(8)                :: E,EOLD
      REAL(8)                :: PI,Y0,C0LL
      REAL(8)   ,PARAMETER   :: TOL=1.D-8
      LOGICAL(4)             :: CONVG
      REAL(8)                :: POTOFRHO(NR)
      REAL(8)   ,ALLOCATABLE :: PROJ(:)        !(NWAVE1) <PRO|PSI>
      REAL(8)   ,ALLOCATABLE :: DENMAT(:,:)    !(NWAVE1,NWAVE1) 
      INTEGER(4)             :: ITERSCF
      INTEGER(4),PARAMETER   :: NITERSCF=1000
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10," PAWATOM (UNDER CONSTRUCTION) "/72("-"))')
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*PI) 
      C0LL=Y0
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
      PSPOT1(:)=PSPOT(:)
!
!     ==================================================================
!     ==  SELFCONSISTENCY LOOP                                        ==
!     ==================================================================
      DO ITERSCF=1,NITERSCF
        RHO(:)=0.D0
        QAUG=0.D0
        CALL PROJECTION$LMAX(LMAX)
        DO L=0,LMAX
          CALL PROJECTION$NPRO(L,NWAVE1)
          ALLOCATE(PRO1(NR,NWAVE1))
          ALLOCATE(DTKIN1(NWAVE1,NWAVE1))
          ALLOCATE(DO1(NWAVE1,NWAVE1))
          ALLOCATE(DATH1(NWAVE1,NWAVE1))
          ALLOCATE(PROJ(NWAVE1))
          CALL PROJECTION$POT(L,NWAVE1,PROL=PRO1,DOL=DO1,DATHL=DATH1)
          DO IB=NC+1,NB
            IF(LB(IB).NE.L) CYCLE
!
!           ============================================================
!           ==  FIND PS WAVE FUNCTIONS                                ==
!           ============================================================
            E=EB(IB)
            EOLD=E
            ITER=0
            CONVG=.FALSE.
            DO WHILE(.NOT.CONVG)
              ITER=ITER+1
              CALL PAWBOUNDSTATE(R1,DEX,NR,L,E,OUTERBOXRADIUS &
     &                      ,PSPOT,NWAVE1,PRO1,DATH1,DO1,PSPSI)
              CONVG=DABS(EOLD-E).LT.TOL
              EOLD=E
              IF(ITER.GT.50) THEN
                CALL ERROR$MSG('LOOP NOT CONVERGED')
                CALL ERROR$MSG('PAWATOM')
              END IF
            ENDDO
            WRITE(NFILO,FMT='("ANGULAR MOMENTUM:",I8)')L
            WRITE(NFILO,FMT='("AE -BAND ENERGY :",F20.12)')EB(IB)
            WRITE(NFILO,FMT='("PAW-BAND ENERGY :",F20.12)')E
!
!           ============================================================
!           ==  ADD TO DENSITY                                        ==
!           ============================================================
            DO IR=1,NR
              RHO(IR)=RHO(IR)+C0LL*PSPSI(IR,1)**2*FB(IB)
            ENDDO
!
!           ============================================================
!           ==  CALCULATE  <PRO|PSI>                                  ==
!           ============================================================
            DO I1=1,NWAVE1
              CALL RADIAL$INTEGRAL(R1,DEX,NR,R(:)**2*PRO1(:,I1)*PSPSI(:,1),PROJ(I1))
            ENDDO
            DO I1=1,NWAVE1
              DO I2=1,NWAVE1
                QAUG=QAUG+PROJ(I1)*DO1(I1,I2)*PROJ(I2)*FB(IB)
              ENDDO
            ENDDO
          ENDDO
          DEALLOCATE(PROJ)
          DEALLOCATE(PRO1)
          DEALLOCATE(DATH1)
          DEALLOCATE(DO1)
          DEALLOCATE(DTKIN1)
        ENDDO
!
!       ================================================================
!       ==  CALCULATE  EFFECTIVE POTENTIAL OF THE PSEUDO DENSITY      ==
!       ================================================================
        RHO(:)=RHO(:)+PSCORE(:)
        CALL VOFRHO(0.D0,R1,DEX,NR,RHO,POTOFRHO)
        CALL RADIAL$INTEGRAL(R1,DEX,NR,(AECORE(:)-PSCORE(:))*R(:)**2,SVAR)
        QAUG=QAUG-AEZ+SVAR*4*PI*Y0
        DO IR=1,NR
!         POTOFRHO(IR)=POTOFRHO(IR)+QAUG*ERF(R(IR)/RCSMALL)/R(IR)/Y0        
          CALL LIB$ERFR8(R(IR)/RCSMALL,SVAR)
          POTOFRHO(IR)=POTOFRHO(IR)+QAUG*SVAR/R(IR)/Y0        
        ENDDO
        PSPOT1(:)=POTOFRHO(:)+VHAT(:)
!
!       ================================================================
!       ==  CALCULATE ONE-CENTER HAMILTONIAN                          ==
!       ================================================================
      ENDDO
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE CHARGETRANSFERABILITY
!     **                                                              **
!     **  PERFORM SELFCONSISTENT PAW CALCULATION TO ESTIMATE          **
!     **  ERRORS IN THE COULOMB-U MATRIX                              **
!     **                                                              **
!     **                                                              **
      USE GRID
      USE AEATOM
      USE PROJECTION
      USE SCHRGL_INTERFACE_MODULE, ONLY : PAWBOUNDSTATE
      IMPLICIT NONE
!     ******************************************************************
!      CALL PAWSCF(R1,DEX,NR,OUTERBOXRADIUS &
!     &          ,VHAT,AEZ,RCSMALL,PSCORE,AECORE,NPRO,LPRO,PRO,PSPHI,AEPHI &
!     &          ,DTKIN,DO,NB,LB,FB &
!     &          ,PSPOT,DATH,EB)
!      CALL AESCF(AEZ,R1,DEX,NR,OUTERBOXRADIUS &
!     &          ,NB,NNB,LB,SB,FB,EB,AECORE,AEPOT,AEPSI)
      RETURN
      END
!
!     ................................................................
      SUBROUTINE PAWSCF(R1,DEX,NR,BOXRADIUS &
     &          ,VHAT,AEZ,RCSM,PSCORE,AECORE,NPRO,LPRO,PRO,PSPHI,AEPHI &
     &          ,DTKIN,DO,NB,LB,FB &
     &          ,PSPOT,DATH,EB)
!     ******************************************************************
!     **                                                              **
!     **  PERFORMS A SELF-CONSISTENT PAW CALCULATION TO ESTIMATE      **
!     **  CHARGE TRANSFERABILITY                                      **
!     **                                                              **
!     ******************************************************************
      USE SCHRGL_INTERFACE_MODULE
      IMPLICIT NONE
      REAL(8)   ,INTENT(IN)   :: R1
      REAL(8)   ,INTENT(IN)   :: DEX
      INTEGER(4),INTENT(IN)   :: NR
      REAL(8)   ,INTENT(IN)   :: BOXRADIUS
      REAL(8)   ,INTENT(IN)   :: VHAT(NR)
      REAL(8)   ,INTENT(IN)   :: AEZ
      REAL(8)   ,INTENT(IN)   :: RCSM
      REAL(8)   ,INTENT(IN)   :: PSCORE(NR)
      REAL(8)   ,INTENT(IN)   :: AECORE(NR)
      INTEGER(4),INTENT(IN)   :: NPRO
      INTEGER(4),INTENT(IN)   :: LPRO(NPRO)
      REAL(8)   ,INTENT(IN)   :: PRO(NR,NPRO)
      REAL(8)   ,INTENT(IN)   :: PSPHI(NR,NPRO)
      REAL(8)   ,INTENT(IN)   :: AEPHI(NR,NPRO)
      REAL(8)   ,INTENT(IN)   :: DTKIN(NPRO,NPRO)
      REAL(8)   ,INTENT(IN)   :: DO(NPRO,NPRO)
      INTEGER(4),INTENT(IN)   :: NB
      INTEGER(4),INTENT(IN)   :: LB(NB)
      INTEGER(4),INTENT(IN)   :: FB(NB)
      REAL(8)   ,INTENT(INOUT):: PSPOT(NR)
      REAL(8)   ,INTENT(INOUT):: DATH(NPRO,NPRO)
      INTEGER(4),INTENT(IN)   :: EB(NB)
      INTEGER(4),PARAMETER    :: ITERX=100
      INTEGER(4)              :: ITER,IR,IB,IPRO
      REAL(8)                 :: XEXP,R(NR)
      INTEGER(4)              :: LMAX
      REAL(8)                 :: PSPSI(NR,3,NB)
      INTEGER(4)              :: NPROB(NB),INDEX(NPRO,NB)
      INTEGER(4)              :: L
      REAL(8)                 :: E
      REAL(8)                 :: AUX(NR)
      REAL(8)   ,ALLOCATABLE  :: PROB(:,:)
      REAL(8)   ,ALLOCATABLE  :: DATHB(:,:)
      REAL(8)   ,ALLOCATABLE  :: DOB(:,:)
      REAL(8)                 :: PROJ(NPRO,NB)
      REAL(8)                 :: DENMAT(NPRO,NPRO)
      REAL(8)                 :: PSRHO(NR)
      REAL(8)                 :: RCSMALL
      REAL(8)                 :: PI,Y0,C0LL
      REAL(8)                 :: QAUG
      REAL(8)                 :: SVAR
      INTEGER(4)              :: I1,I2,IPRO1,IPRO2
      INTEGER(4)              :: NFILO
!     ****************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10," PAWSCF (UNDER CONSTRUCTION) "/72("-"))')
!     ================================================================
!     ==  PREPARE CONSTANTS                                         ==
!     ================================================================
      XEXP=DEXP(DEX)
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/DSQRT(4.D0*Y0)
      C0LL=Y0
      R(1)=R1/XEXP
      DO IR=2,NR
        R(IR)=R(IR-1)*XEXP
      ENDDO
!     ==================================================================
!     ==  INDEX ARRAY FOR PROJECTORS RELEVANT FOR EACH STATE          ==
!     ==================================================================
      DO IB=1,NB
        LMAX=MAX(L,LB(IB))
        NPROB(IB)=0
        DO IPRO=1,NPRO
          IF(LPRO(IPRO).EQ.LB(IB)) THEN
            NPROB(IB)=NPROB(IB)+1
            INDEX(NPROB(IB),IB)=IPRO
          END IF
        ENDDO
      ENDDO
!
!     ==================================================================
!     == BEGIN SELFCONSISTENCY LOOP                                   ==
!     ==================================================================
      DO ITER=1,ITERX
!       ================================================================
!       == CALCULATE WAVE FUNCTIONS                                   ==
!       ================================================================
        DO IB=1,NB
          L=LB(IB)
          E=EB(IB)
          ALLOCATE(PROB(NR,NPROB(IB)))
          ALLOCATE(DATHB(NPROB(IB),NPROB(IB)))
          ALLOCATE(DOB(NPROB(IB),NPROB(IB)))
          DO IPRO=1,NPROB(IB)
            I1=INDEX(IPRO,IB)
            PROB(:,IPRO)=PRO(:,I1)
            DO IPRO1=1,NPROB(IB)
              I2=INDEX(IPRO1,IB)
              DATHB(IPRO,IPRO1)=DATH(I1,I2)
              DOB(IPRO,IPRO1)=DO(I1,I2)
            ENDDO
          ENDDO
          CALL PAWBOUNDSTATE(R1,DEX,NR,L,E,BOXRADIUS &
     &                      ,PSPOT,NPROB(IB),PROB,DATHB,DOB,PSPSI(:,:,IB))
          DEALLOCATE(PROB)
          DEALLOCATE(DATHB)
          DEALLOCATE(DOB)
        ENDDO
!
!       ================================================================
!       == CALCULATE PROJECTIONS                                      ==
!       ================================================================
        DO IB=1,NB
          DO IPRO=1,NPRO
            IF(LB(IB).EQ.LPRO(IPRO)) THEN
              CALL RADIAL$INTEGRAL(R1,DEX,NR,R(:)**2*PSPSI(:,1,IB),PROJ(IPRO,IB))
            ELSE
              PROJ(IPRO,IB)=0.D0
            END IF
          ENDDO
        ENDDO
!
!       ================================================================
!       == CALCULATE DENSITY MATRIX                                   ==
!       ================================================================
        DO IPRO1=1,NPRO
          DO IPRO2=1,NPRO
            DENMAT(IPRO1,IPRO2)=DENMAT(IPRO1,IPRO2) &
      &                        +PROJ(IPRO1,IB)*PROJ(IPRO2,IB)*FB(IB)
          ENDDO
        ENDDO
!
!       ================================================================
!       == CALCULATE AUGMENTATION CHARGE                              ==
!       ================================================================
        QAUG=AEZ
        CALL RADIAL$INTEGRAL(R1,DEX,NR,R(:)**2*(AECORE(:)-PSCORE(:))*Y0,SVAR)
        QAUG=QAUG+4.D0*PI*SVAR
        DO IPRO1=1,NPRO
          DO IPRO2=1,NPRO
!           IF(LPRO(IPRO1).EQ.LPRO(IPRO2)) THEN
!           ENDIF
          ENDDO
        ENDDO
!
!       ============================================================
!       ==  ADD TO DENSITY                                        ==
!       ============================================================
        PSRHO(:)=0.D0
        DO IB=1,NB
          DO IR=1,NR
             PSRHO(IR)=PSRHO(IR)+C0LL*PSPSI(IR,1,IB)**2*FB(IB)
          ENDDO
        ENDDO
!
!       ==================================================================
!       ==  CALCULATE  EFFECTIVE POTENTIAL OF THE PSEUDO DENSITY        ==
!       ==================================================================
        PSRHO(:)=PSRHO(:)+PSCORE(:)
        CALL VOFRHO(0.D0,R1,DEX,NR,PSRHO,PSPOT)
        DO IR=1,NR
!         PSPOT(IR)=PSPOT(IR)+QAUG*ERF(R(IR)/RCSMALL)/R(IR)/Y0+VHAT(IR)
          CALL LIB$ERFR8(R(IR)/RCSMALL,SVAR)
          PSPOT(IR)=PSPOT(IR)+QAUG*SVAR/R(IR)/Y0+VHAT(IR)        
        ENDDO

!       ================================================================
!       == END SELFCONSISTENCY LOOP                                   ==
!       ================================================================
      ENDDO
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE WRITEOUT
!     **                                                              **
      USE GRID
      USE AEATOM
      USE PROJECTION
      USE SCHRGL_INTERFACE_MODULE, ONLY : PAWBOUNDSTATE
      IMPLICIT NONE
      INTEGER(4)      :: NFIL
      REAL(8)         :: PSZ=0.D0   !DUMMY: NOT USED
      INTEGER(4)      :: IWAVE
!     ******************************************************************
      CALL FILEHANDLER$UNIT('SETUPO',NFIL)
      WRITE(NFIL,FMT='(F15.10,F10.5,2I4,2F5.2,F15.12)') &
     &                 R1,DEX,NR,NWAVE,PSZ,AEZ,RCSMALL
      WRITE(NFIL,FMT='(14I5)')LPHI(:)
      WRITE(NFIL,FMT='(SP,5E14.8)')VHAT(:)
!     ====  AECORE = CORE CHARGE DENSITY  ==============================
      WRITE(NFIL,FMT='(SP,5E14.8)')AECORE(:)
!     ====  PSCORE = PSEUDIZED CHARGE DENSITY===========================
      WRITE(NFIL,FMT='(SP,5E14.8)')PSCORE(:)
!     ====  DTKIN = <AEPHI|-DELTA/2|AEPHI> - <PSPHI|-DELTA/2|PSPHI> ====
      WRITE(NFIL,FMT='(SP,5E14.8)')DTKIN(:,:)
!     ====  DOVER = <AEPHI|AEPHI> - <PSPHI|PSPHI> ======================
      WRITE(NFIL,FMT='(SP,5E14.8)')DO(:,:)
      DO IWAVE=1,NWAVE
        WRITE(NFIL,FMT='(SP,5E14.8)')PRO(:,IWAVE)
        WRITE(NFIL,FMT='(SP,5E14.8)')AEPHI(:,1,IWAVE)
        WRITE(NFIL,FMT='(SP,5E14.8)')PSPHI(:,1,IWAVE)
      ENDDO
      CALL FILEHANDLER$CLOSE('SETUPO')
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE WRITESTP(LL_CNTL)
!     **                                                              **
      USE GRID
      USE AEATOM
      USE PROJECTION
      USE SCHRGL_INTERFACE_MODULE, ONLY : PAWBOUNDSTATE
      USE LINKEDLIST_MODULE
      IMPLICIT NONE
      TYPE(LL_TYPE)   :: LL_CNTL
      TYPE(LL_TYPE)   :: LL_STP
      INTEGER(4)      :: NFIL
      INTEGER(4)      :: NFILO
      REAL(8)         :: PSZ=0.D0   !DUMMY: NOT USED
      INTEGER(4)      :: IWAVE
      CHARACTER(256)  :: FILE
!     ******************************************************************
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$SELECT(LL_CNTL,'ACNTL')
!
!     ==================================================================
!     == WRITE CORE DENSITIES AND AUGMENTATION POTENTIAL              ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'AECORE')
      CALL LINKEDLIST$SET(LL_CNTL,'CORE',0,AECORE)
      CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      CALL LINKEDLIST$SELECT(LL_CNTL,'PSCORE')
      CALL LINKEDLIST$SET(LL_CNTL,'CORE',0,PSCORE)
      CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      CALL LINKEDLIST$SELECT(LL_CNTL,'VTILDE')
      CALL LINKEDLIST$SET(LL_CNTL,'VHAT',0,VHAT)
      CALL LINKEDLIST$SELECT(LL_CNTL,'..')
!
!     ==================================================================
!     == WRITE PROJECTORS AND PARTIAL WAVES                           ==
!     ==================================================================
      DO IWAVE=1,NWAVE
        CALL LINKEDLIST$SELECT(LL_CNTL,'WAVE',IWAVE)
        CALL LINKEDLIST$SET(LL_CNTL,'PRO',0,PRO(:,IWAVE))
        CALL LINKEDLIST$SET(LL_CNTL,'AEPHI',0,AEPHI(:,1,IWAVE))
        CALL LINKEDLIST$SET(LL_CNTL,'PSPHI',0,PSPHI(:,1,IWAVE))
        CALL LINKEDLIST$SELECT(LL_CNTL,'..')
      ENDDO
!
!     ==================================================================
!     == WRITE MATRIX ELEMENTS BETWEEN PARTIAL WAVES                  ==
!     ==================================================================
      CALL LINKEDLIST$SELECT(LL_CNTL,'MATRIXELEMENTS')
      CALL LINKEDLIST$SET(LL_CNTL,'NWAVE',0,NWAVE)
      CALL LINKEDLIST$SET(LL_CNTL,'DTKIN',0,DTKIN(:,:))
      CALL LINKEDLIST$SET(LL_CNTL,'DO',0,DO(:,:))
      CALL LINKEDLIST$SELECT(LL_CNTL,'..')
!
!     ==================================================================
!     == WRITE LINKEDLIST TO FILE                                     ==
!     ==================================================================
      CALL FILEHANDLER$UNIT('SETUP',NFIL)
      CALL LINKEDLIST$SELECT(LL_CNTL,'~')
      CALL LINKEDLIST$WRITE(LL_CNTL,NFIL)
      CALL FILEHANDLER$CLOSE('SETUP')
!
      RETURN
      CALL FILEHANDLER$FILENAME('SETUP',FILE)
      CALL FILEHANDLER$SETFILE('SETUPR',.FALSE.,FILE)
      CALL FILEHANDLER$SETSPECIFICATION('SETUPR','STATUS','OLD')
      CALL FILEHANDLER$SETSPECIFICATION('SETUPR','POSITION','REWIND')
      CALL FILEHANDLER$SETSPECIFICATION('SETUPR','ACTION','READ')
      CALL FILEHANDLER$SETSPECIFICATION('SETUPR','FORM','FORMATTED')
      CALL FILEHANDLER$UNIT('SETUPR',NFIL)
      CALL LINKEDLIST$NEW(LL_STP)
      CALL LINKEDLIST$READ(LL_STP,NFIL)
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      CALL LINKEDLIST$REPORT(LL_STP,NFILO)
      STOP
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE ENERGYTRANSFERABILITY
!     ******************************************************************
!     **                                                              **
!     **  ANALYZES THE ENERGY TRANSFERABILITY AS FUNCTION OF ENERGY   **
!     **  AND NUMBER OF PROJECTOR FUNCTIONS                           **
!     **                                                              **
!     **  ENERGY SCALE ON OUTPUT : EV                                 **
!     **                                                              **
!     ******************************************************************
      USE PERIODICTABLE_MODULE, ONLY : PERIODICTABLE$GET
      USE GRID
      USE AEATOM
      USE PROJECTION
      USE SCHRGL_INTERFACE_MODULE, ONLY : SCHROEDER
      IMPLICIT NONE
      REAL(8)                :: EV
      INTEGER(4)             :: NFILO
      INTEGER(4)             :: NFIL
      INTEGER(4)             :: IRAUG
!     ==  RADIAL GRID ==================================================
      REAL(8)                :: R(NR)
      REAL(8)                :: RI
      INTEGER(4)             :: IR
!     == ENERGY GRID ===================================================
      REAL(8)                :: EMIN,EMAX
      REAL(8)   ,ALLOCATABLE :: EOFI(:)
      INTEGER(4)             :: NE,IE,IE1
!     == ANGULAR MOMENTA ===============================================
      INTEGER(4)             :: LMAX           ! MAX ANG. MOMENTUM
      INTEGER(4)             :: L              !ANGULAR MOMENTUM
!     == AUGMENTATION ==================================================
      INTEGER(4)             :: NPROSUM  
      INTEGER(4)             :: IPROSUM  
      INTEGER(4)             :: IPRO
      INTEGER(4)             :: NPROX          ! #(STATES FOR THIS L)
      INTEGER(4)             :: NPRO           ! #(STATES FOR THIS L)
      REAL(8)   ,ALLOCATABLE :: PRO1(:,:)      !(NR,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DO1(:,:)       !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DTKIN1(:,:)    !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: DATH1(:,:)     !(NWAVE,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: AEPHI1(:,:,:)  !(NR,3,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: PSPHI1(:,:,:)  !(NR,3,NWAVE1)
      REAL(8)   ,ALLOCATABLE :: PROJ1(:)       !(NWAVE1)
!
      REAL(8)   ,ALLOCATABLE :: PHASEPAW(:,:)
      REAL(8)   ,ALLOCATABLE :: PHASEAE(:,:)
      REAL(8)   ,ALLOCATABLE :: DE(:,:)
      REAL(8)                :: PAWPSI(NR,3)
      REAL(8)                :: REFPSI(NR,3)
      REAL(8)                :: AUX(NR),SVAR1,SVAR2
      INTEGER(4)             :: NODE
      REAL(8)                :: RCOV,RPHASE
!     ******************************************************************
      CALL FILEHANDLER$UNIT('PROT',NFILO)
      WRITE(NFILO,FMT='(72("-")/72("-"),T10 &
     &                 ," TEST ENERGY TRANSFERABILITY "/72("-"))')
      CALL CONSTANTS$GET('EV',EV)
      CALL PERIODICTABLE$GET(NINT(AEZ),'R(COV)',RCOV)
      RPHASE=1.5D0*RCOV
      CALL REPORT$R8VAL(NFILO,'PHASESHIFTS TAKEN AT RADIUS',RPHASE,'A_0')
      CALL REPORT$STRING(NFILO,'(RADIUS=1.5 COVALENT RADIUS)')
!
!     ==================================================================
!     ==  PREPARE SOME COMMON CONSTANTS                               ==
!     ==================================================================
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      DO IR=1,NR
        RI=RI*XEXP
        R(IR)=RI
      ENDDO
!     IRAUG=INT(1.D0+DLOG(AUGMENTATIONRADIUS/R1)/DEX)
      IRAUG=INT(1.D0+DLOG(RPHASE/R1)/DEX)
!
!     ==================================================================
!     ==  COLLECT DATA FORM LINKEDLIST                                ==
!     ==================================================================
      EMIN=-30.D0*EV
      EMAX=30.D0*EV
      NE=121
      LMAX=3
!
!     ==================================================================
!     ==  DEFINE ENERGY GRID                                          ==
!     ==================================================================
      ALLOCATE(EOFI(NE))
      IF(NE.GT.1) THEN
        DO IE=1,NE
          EOFI(IE)=EMIN+(EMAX-EMIN)/DBLE(NE-1)*DBLE(IE-1)
        ENDDO
      ELSE
        EOFI(1)=EMIN
      END IF 
!
!     ==================================================================
!     ==  DEFINE #(PAW PHASE SHIFTS                                   ==
!     ==================================================================
      NPROSUM=0
      DO L=0,LMAX
        CALL PROJECTION$NPRO(L,NPROX)
        NPROSUM=NPROSUM+(1+NPROX)
      ENDDO
!
!     ==================================================================
!     ==  NOW SUM OVER ALL VALENCE STATES                             ==
!     ==================================================================
      ALLOCATE(PHASEPAW(NE,NPROSUM))
      ALLOCATE(PHASEAE(NE,LMAX+1))
      IPROSUM=0
      DO L=0,LMAX
!
!       ================================================================
!       ==  FIND AE PHASE SHIFT                                       ==
!       ================================================================
        DO IE=1,NE
!         -- AUGMENTATION RADIUS NOT USED FOR OUTWARD INTEGRATION ------
          CALL SCHROEDER(.TRUE.,.TRUE.,R1,DEX,NR,L,EOFI(IE),AEZ &
     &              ,IRAUG+4,AUGMENTATIONRADIUS,AEPOT,REFPSI,AUX)
          CALL XPHASESHIFT(R1,DEX,NR,RPHASE &
     &                    ,REFPSI,PHASEAE(IE,L+1))
        ENDDO
!
!       ================================================================
!       ==  FIND PAW PHASE SHIFT                                      ==
!       ================================================================
        CALL PROJECTION$NPRO(L,NPROX)
        DO NPRO=0,NPROX
          IPROSUM=IPROSUM+1
          ALLOCATE(PRO1(NR,NPRO))
          ALLOCATE(DTKIN1(NPRO,NPRO))
          ALLOCATE(DO1(NPRO,NPRO))
          ALLOCATE(DATH1(NPRO,NPRO))
          ALLOCATE(AEPHI1(NR,3,NPRO))
          ALLOCATE(PSPHI1(NR,3,NPRO))
          ALLOCATE(PROJ1(NPRO))
          CALL PROJECTION$POT(L,NPRO,PROL=PRO1,AEPHIL=AEPHI1,PSPHIL=PSPHI1 &
     &                              ,DOL=DO1,DATHL=DATH1)
          DO IE=1,NE
            CALL PAWDER(.TRUE.,R1,DEX,NR,L,EOFI(IE),IRAUG+4 &
     &                     ,PSPOT,NPRO,PRO1,DATH1,DO1,PAWPSI,AUX)
            DO IPRO=1,NPRO
              CALL RADIAL$INTEGRAL(R1,DEX,NR &
     &               ,R(:)**2*PAWPSI(:,1)*PRO(:,IPRO),PROJ1(IPRO))
            ENDDO
            DO IPRO=1,NPRO
              PAWPSI(:,:)=PAWPSI(:,:) &
     &                   +(AEPHI1(:,:,IPRO)-PSPHI1(:,:,IPRO))*PROJ1(IPRO)
            ENDDO
            CALL XPHASESHIFT(R1,DEX,NR,RPHASE,PAWPSI &
     &                     ,PHASEPAW(IE,IPROSUM))
          ENDDO
          DEALLOCATE(PRO1)
          DEALLOCATE(DTKIN1)
          DEALLOCATE(DO1)
          DEALLOCATE(DATH1)
          DEALLOCATE(AEPHI1)
          DEALLOCATE(PSPHI1)
          DEALLOCATE(PROJ1)
        ENDDO
      ENDDO
!
!     ==================================================================
!     ==  ESTIMATE ENERGY SHIFTS                                      ==
!     ==================================================================
      ALLOCATE(DE(NE,NPROSUM))
      IPROSUM=0
      DO L=0,LMAX
        CALL PROJECTION$NPRO(L,NPROX)
        DO IPRO=0,NPROX
          IPROSUM=IPROSUM+1
          DO IE=1,NE-1
            IF(PHASEPAW(IE,IPROSUM)-PHASEAE(IE,L+1).GT.0.D0) THEN
              DE(IE,IPROSUM)=-11.111111D0*EV
              INNER1: DO IE1=IE-1,1,-1
                IF(PHASEPAW(IE1,IPROSUM)-PHASEAE(IE,L+1).LE.0.D0) THEN
                  SVAR1=PHASEPAW(IE1,IPROSUM)  -PHASEAE(IE,L+1)
                  SVAR2=PHASEPAW(IE1+1,IPROSUM)-PHASEAE(IE,L+1)
                  DE(IE,IPROSUM)=EOFI(IE1)-EOFI(IE) &
      &                         -SVAR1*(EOFI(IE1+1)-EOFI(IE1))/(SVAR2-SVAR1)
!                 DE(IE,IPROSUM)=EOFI(IE1)-EOFI(IE)
                  EXIT INNER1
                END IF
              ENDDO INNER1
            ELSE IF(PHASEPAW(IE,IPROSUM)-PHASEAE(IE,L+1).LE.0.D0) THEN
              DE(IE,IPROSUM)=+11.111111D0*EV
              INNER2: DO IE1=IE+1,NE
                IF(PHASEPAW(IE1,IPROSUM)-PHASEAE(IE,L+1).GT.0.D0) THEN
                  SVAR1=PHASEPAW(IE1,IPROSUM)  -PHASEAE(IE,L+1)
                  SVAR2=PHASEPAW(IE1-1,IPROSUM)-PHASEAE(IE,L+1)
                  DE(IE,IPROSUM)=EOFI(IE1)-EOFI(IE) &
      &                         -SVAR1*(EOFI(IE1-1)-EOFI(IE1))/(SVAR2-SVAR1)
!                  DE(IE,IPROSUM)=EOFI(IE1)-EOFI(IE)
                  EXIT INNER2
                END IF
              ENDDO INNER2
            END IF
          ENDDO            
        ENDDO
      ENDDO
!
!     ==================================================================
!     ==  REPORT RESULTS                                              ==
!     ==================================================================
      IPROSUM=0
      DO L=0,LMAX
        CALL PROJECTION$NPRO(L,NPROX)
        WRITE(NFILO,FMT='(72("-"),T10," PHASE SHIFTS FOR L=",I5," ")')L
        DO IE=1,NE,4
          WRITE(NFILO,FMT='("E[EV]=",F7.3," AE:",F8.5," PAW ",10F8.5)') &
    &     EOFI(IE)/EV,PHASEAE(IE,L+1),PHASEPAW(IE,IPROSUM+1:IPROSUM+NPROX+1)
        ENDDO
        WRITE(NFILO,FMT='(72("-"),T10," ENERGY SHIFTS FOR L=",I5," ")')L
        DO IE=1,NE,4
          WRITE(NFILO,FMT='("E[EV]=",F7.3," AE:",F8.5," DE(PAW-AE)[EV] ",10F11.5)') &
    &     EOFI(IE)/EV,PHASEAE(IE,L+1),DE(IE,IPROSUM+1:IPROSUM+NPROX+1)/EV
        ENDDO
        IPROSUM=IPROSUM+1+NPROX
      ENDDO
!
      IPROSUM=0
      DO L=0,LMAX
        IF(L.EQ.0) THEN
          CALL FILEHANDLER$UNIT('PHASESHIFT_S',NFIL)
        ELSE IF(L.EQ.1) THEN
          CALL FILEHANDLER$UNIT('PHASESHIFT_P',NFIL)
        ELSE IF(L.EQ.2) THEN
          CALL FILEHANDLER$UNIT('PHASESHIFT_D',NFIL)
        ELSE IF(L.EQ.3) THEN
          CALL FILEHANDLER$UNIT('PHASESHIFT_F',NFIL)
        ELSE
          CALL ERROR$MSG('LMAX>3 NOT SUPPORTED')
          CALL ERROR$STOP('ENERGYTRANSFERABILITY')
        END IF
        REWIND NFIL
        DO IE=1,NE
          CALL PROJECTION$NPRO(L,NPROX)
          WRITE(NFIL,FMT='(20F10.5)')EOFI(IE)/EV,PHASEAE(IE,L+1) &
     &         ,PHASEPAW(IE,IPROSUM+1:IPROSUM+NPROX+1)
        ENDDO
        IPROSUM=IPROSUM+NPROX+1
      ENDDO
!
!     ==================================================================
!     ==  FIND CLEAN UP                                               ==
!     ==================================================================
      DEALLOCATE(EOFI)
      DEALLOCATE(PHASEPAW)
      DEALLOCATE(PHASEAE)
      DEALLOCATE(DE)
      RETURN
      CONTAINS
!      . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
       SUBROUTINE XPHASESHIFT(R1,DEX,NR,R,PHI,PHASE)
        IMPLICIT NONE
        REAL(8)   ,INTENT(IN) :: R1      
        REAL(8)   ,INTENT(IN) :: DEX      
        INTEGER(4),INTENT(IN) :: NR
        REAL(8)   ,INTENT(IN) :: R      
        REAL(8)   ,INTENT(IN) :: PHI(NR,3)
        REAL(8)   ,INTENT(OUT):: PHASE
        INTEGER(4)            :: IX,IR
        REAL(8)               :: PI
        REAL(8)               :: PHI1,PHI2
!       ****************************************************************
        PI=4.D0*DATAN(1.D0)
        CALL RADIAL$VALUE(R1,DEX,NR,PHI(:,1),R,PHI1)
        CALL RADIAL$VALUE(R1,DEX,NR,PHI(:,2),R,PHI2)
        PHASE=0.5D0-DATAN(PHI2/PHI1)/PI
!
        IX=INT(1.D0+DLOG(R/R1)/DEX)
        DO IR=1,IX-1
          IF(PHI(IR,1)*PHI(IR+1,1).LT.0.D0) PHASE=PHASE+1.D0
!          IF(PHI(IR,1)*PHI(IR+1,1).LT.0.D0) PRINT*,'NODEAT ',IR
        ENDDO
        IF(PHI(IX,1)*PHI1.LT.0.D0)PHASE=PHASE+1.D0
        RETURN
        END SUBROUTINE XPHASESHIFT
      END
!
!     ....................................................................
      SUBROUTINE WRITEF(NFILO,TEXT,F)
      USE GRID
      IMPLICIT NONE    
      INTEGER(4)   ,INTENT(IN) :: NFILO
      CHARACTER(*) ,INTENT(IN) :: TEXT
      REAL(8)      ,INTENT(IN) :: F(NR)
      REAL(8)                  :: RI
      INTEGER(4)               :: IR
      REAL(8)                  :: PI,Y0
!     *******************************************************************
      PI=4.D0*DATAN(1.D0)
      Y0=1.D0/SQRT(4.D0*PI)
      WRITE(NFILO,FMT='(A)')TRIM(TEXT)
      XEXP=DEXP(DEX)
      RI=R1/XEXP
      WRITE(NFILO,FMT='(A5,2A20)')'IR','RI',F(IR)*Y0
      DO IR=1,NR
        RI=RI*XEXP
!        IF(IR.LT.165) CYCLE
!        IF(IR.GT.230) EXIT
!       IF(MOD(IR,5).NE.0) CYCLE
        WRITE(NFILO,FMT='(I5,2E20.5)')IR,RI,F(IR)*Y0
      ENDDO
      RETURN
      END




